<!--
状态: 设计待审阅
创建日期: 2026-07-04
作者: main
父方向: RD-20260703T081815Z-main-LMIG (miniQMT 清退后实盘平台迁移)
祖父模块: RD-20260605T115651Z-main-EXE0 (双池轮动执行与换仓模块)
策略档案: STRAT-20260605T115651Z-main-DP00 (双池动量轮动)
前序实验(已作废): EX-20260703T081815Z-main-XTCN (连通性 smoke, 结论作废)
-->

# QMT Socket Bridge 设计规格

## 0. 摘要

miniQMT（XtMiniQmt.exe + miniquote.exe + minibroker.exe + 58610 端口）即将清退，外部 pip 安装的 xtquant 随之失效。本设计提出一套 **socket bridge + drop-in shim** 方案，让 ETF 双池动量轮动实盘策略（3434 行主文件）**零代码改动**地从 miniQMT 迁移到"大 QMT 客户端进程内 passorder + ContextInfo 行情"通道。

**核心架构**：在大 QMT 客户端（XtItClient.exe）进程内起 socket server，外部 Python 3.11 通过 socket client 透传下单/查询命令，server 调进程内 passorder / get_trade_detail_data / ContextInfo.get_full_tick 等客户端内 API，绕开已清退的 58610 通道。

**已验证**（4 轮 C 系列脚本实测）：
- 查询通道可用（资产/持仓/委托，C2 v6-v7）
- passorder 全局函数可调用（C2 v10）
- passorder 跨线程并发不崩溃（C4 v1，156 次零崩溃）
- schedule_run marshal 路线不可行（C3 v1，15 秒延迟）

**待验证**（开盘后 C2 v11 生死线）：
- passorder 能真生成委托（DELTA>0）
- ContextInfo.get_full_tick 能返回实时行情

---

## 1. 背景与约束

### 1.1 清退范围

miniQMT 清退影响：
- `XtMiniQmt.exe` / `miniquote.exe` / `minibroker.exe` 进程
- 58610 端口的服务后端（由 miniquote/minibroker 提供）
- 外部 pip 安装的 xtquant（依赖 58610）

**保留**：大 QMT 客户端 `XtItClient.exe`（用户仍需用它看盘/登录账号），但它不启动 58610 服务后端。

### 1.2 核心约束（用户硬性要求）

| 约束 | 说明 |
|------|------|
| 策略代码零改动 | 3434 行主文件，4 行 import 一字不改 |
| 不依赖被清退的 miniQMT | 全部链路绕开 58610 |
| 保留外部 Python 3.11 全生态 | numpy/pandas/ClickHouse/策略主文件 |
| 业务核心算法零改动 | 双池动量轮动的进攻/防御逻辑不动 |
| 支持并发下单 | 外部多线程可同时下单，不退化 |

### 1.3 策略最小依赖子集（子代理盘点结果）

策略实际用到的 xtquant API（12 个，远小于完整 xtquant 的 100+）：

**交易（6）**：`XtQuantTrader` 的 `start/connect/order_stock/query_stock_positions/query_stock_asset/query_stock_orders`，纯主动轮询，**无任何回调推送**。

**行情（4）**：`xtdata` 的 `get_full_tick/get_market_data_ex/get_instrument_detail/get_trading_dates`。

**类型（1）**：`StockAccount`（作为不透明 token）。

**常量（6）**：`STOCK_BUY/STOCK_SELL/LATEST_PRICE/ORDER_PART_CANCEL/ORDER_CANCELED/ORDER_SUCCEEDED/ORDER_JUNK`。

**策略完全不依赖**：subscribe 推送、download 下载、XtQuantTraderCallback 回调、cancel 撤单、信用交易。

### 1.4 三大致命约束（必须 1:1 还原）

1. **常量同源**：shim 的 `xtconstant.py` 直接复制原版，不重写。策略的 `{ORDER_PART_CANCEL, ORDER_CANCELED, ORDER_SUCCEEDED, ORDER_JUNK}` set 必须与 server 返回的 `order_status` 共享同一套整数。
2. **委托号稳定**：`order_stock` 返回的 seq 必须能在后续 `query_stock_orders` 中按 `order_id` 回查到。
3. **DataFrame 形态**：`get_market_data_ex` 返回的对象必须支持 `.empty` 和 `["close"].dropna().values`。

---

## 2. 架构总览

```
外部 Python 3.11（策略主文件，零改动）
┌──────────────────────────────────────────────────────┐
│ from xtquant import xtdata, xttrader                 │ ← 4 行不改
│ from xtquant.xttype import StockAccount              │
│ from xtquant import xtconstant                       │
│                                                      │
│ .venv/Lib/site-packages/xtquant/ 已替换为 shim 包     │
└──────────────────┬───────────────────────────────────┘
                   │ TCP 127.0.0.1:58711（长连接）
                   │ 行分隔 JSON
        ┌──────────▼────────────────────────────────┐
        │ bridge client（外部，标准库 socket）        │
        │ 单连接 + 发送锁 + 接收线程 + Future 分发     │
        └──────────┬────────────────────────────────┘
                   │
═══════════════════╪═══════════════════════════════════ 进程边界
                   │
        ┌──────────▼────────────────────────────────┐
        │ bridge server（XtItClient.exe 进程内）      │
        │ socketserver.ThreadingTCPServer            │
        │ + ThreadPoolExecutor(max_workers=8)         │
        │ worker 线程直接调 passorder（路线 1a）      │
        └────────────────────────────────────────────┘
```

### 2.1 三个组件，职责单一

1. **server**（客户端进程内，daemon 线程）：接收 JSON 命令 → 调客户端 API → 返回 JSON 结果。不关心策略逻辑。
2. **client**（外部，标准库）：发 JSON 请求 → 读 JSON 响应 → Future 分发。不关心命令怎么执行。
3. **shim**（外部 .venv）：假装自己是 xtquant，把策略的 API 调用翻译成 bridge 命令。不碰 socket 细节。

---

## 3. 通信协议

### 3.1 传输层

**行分隔 JSON over TCP**：
```
请求:  {"id":"req_a1b2","cmd":"order_stock","args":{...}}\n
响应:  {"id":"req_a1b2","ok":true,"data":{...}}\n
       {"id":"req_a1b2","ok":false,"error":"...","error_type":"NameError"}\n
```

**选型理由**：人类可读（可 telnet 调试）；客户端 3.6 标准库自带 json，零依赖；策略是分钟级轮询，JSON 序列化开销（~0.1ms）相对 TCP 往返（~1ms）可忽略。

### 3.2 连接模式

**长连接复用**：shim 的 `XtQuantTrader` 实例持有一个 TCP 连接，生命周期跟随 trader。

**并发模型**：单连接 + Future。多个业务线程同时调 `client.call_async(req)`，发送端用 `_send_lock` 保护（防 JSON 行交错），独立接收线程按请求 ID 分发响应到对应 Future。

### 3.3 配置

bridge 地址通过环境变量注入：
- `QMT_BRIDGE_HOST`（默认 `127.0.0.1`）
- `QMT_BRIDGE_PORT`（默认 `58711`）
- `QMT_USE_BRIDGE`（默认 `1`；设为 `0` 时 shim 旁路 bridge，加载原版 xtquant，用于回滚）

---

## 4. 并发模型（路线 1a，实测通过）

### 4.1 路线选型过程

评估了三条路线：

| 路线 | 描述 | 结论 |
|------|------|------|
| **路线 1a** | worker 线程直接调 passorder，真并发 | **采用**（C4 v1 实测 156 次零崩溃） |
| 路线 1b | 专用线程串行调 passorder，伪并发 | 备选（1a 失效时回退） |
| 路线 2 | schedule_run marshal 回主线程 | **否决**（C3 v1 实测延迟 15 秒） |

### 4.2 为什么 miniQMT 能并发而 bridge 需要验证

**miniQMT 的并发安全根因是进程边界**：外部 Python 多线程 → TCP socket → XtMiniQmt.exe（独立进程）→ 柜台。外部 Python 全程不碰 C++ 交易对象，只共享一个 socket 和一个 `self.cbs` dict（CPython GIL 保护）。

**bridge 架构没有这层进程隔离**：bridge worker 线程和 C++ 交易对象在同一个 XtItClient.exe 进程内。passorder 是进程内调用，直接读写 C++ 对象的成员。

### 4.3 C4 v1 实测结论

| 场景 | 配置 | 调用数 | OK | 异常 | 客户端 |
|------|------|--------|-----|------|--------|
| 基线 | 单线程 1 次 | 1 | 1 | 0 | 存活 |
| 场景 1 | 5 worker × 5 次（纯并发） | 25 | 25 | 0 | 存活 |
| 场景 2 | 主线程 + 5 worker 混合 | 30 | 30 | 0 | 存活 |
| 场景 3 | 10 worker × 10 次（高压） | 100 | 100 | 0 | 存活 |

**总计 156 次 passorder 跨线程并发调用，零崩溃，零异常，客户端全程存活**。平均每次调用 1ms（passorder 内部异步投递，不阻塞）。

### 4.4 关键发现：in_pythonworker 不存在

C3/C4 实测发现，实际运行时传入策略的 ContextInfo 对象**没有 `in_pythonworker` 属性**（报错 `'ContextInfo' object has no attribute 'in_pythonworker'`），而 `_PyContextInfo.py:842` 明确定义了它。

**推论**：实际 ContextInfo 是 C++ 直接注入的对象（类名 `'ContextInfo'`），不是 `_PyContextInfo.py` 里的 `__PyContext` 类的实例。`in_pythonworker` 不存在暗示 C++ 侧**可能没有**硬性线程检查。这解释了为什么 C4 v1 的并发调用零崩溃。

### 4.5 server 端实现

```python
class _BridgeServer(socketserver.ThreadingTCPServer):
    daemon_threads = True          # 3.6 默认 False，必须覆盖
    allow_reuse_address = True     # 策略重载时防 EADDRINUSE
    request_queue_size = 64
```

handler 内：读完一行立即 `_executor.submit(_handle, req, wfile)`，不阻塞下一行读取。`_executor = ThreadPoolExecutor(max_workers=8)`。

`_handle` 加 `_write_lock` 保护写响应（防多 worker 并发 `wfile.write` 粘包）。

### 4.6 残余风险声明

C4 v1 用 `price=0.001`（必废单价）测试，验证的是"调用不崩"，**不是"订单簿在高并发下不静默损坏"**。可能存在调用不崩但订单串号/回报错配的静默问题。这由开盘后 C2 v11 + 阶段 3 的 T4/T5 真实下单验证补齐。若发现静默损坏，立即回退路线 1b。

---

## 5. shim 包结构（drop-in 替换）

### 5.1 目录结构

策略的 `.venv/Lib/site-packages/xtquant/` 整个目录替换为 shim：

```
.venv/Lib/site-packages/xtquant/
├── __init__.py              ← 空文件（原版就是空的）
├── xtconstant.py            ← 原样复制（保证常量同源）
├── xttype.py                ← StockAccount 值对象
├── xtdata.py                ← 4 个行情函数 + enable_hello 属性
├── xttrader.py              ← XtQuantTrader 类
└── _bridge_client.py        ← 共用的 socket client（内部模块）
```

### 5.2 劫持机制

Python import 查找顺序中，`.venv/Lib/site-packages/xtquant/` 优先于系统路径。策略的 `from xtquant import xtdata` 加载 shim 的 `xtdata.py`。**策略代码零改动**。

### 5.3 关键设计

**xtconstant.py 直接复制原版**：不重写、不重编号。保证常量值与 QMT 同源。

**StockAccount 是值对象**：存 `account_id` + `account_type`，作为不透明 token。传到 bridge 时，shim 从 token 取出 `account_id` 字符串发给 server。

**返回对象用 SimpleNamespace**：让策略的属性访问 `p.stock_code` 正常工作，无需定义完整的 XtPosition/XtOrder 数据类（YAGNI）。

---

## 6. 命令集映射表

### 6.1 交易类命令

| cmd | 策略 API | server 调用 | 返回形态 |
|-----|---------|------------|---------|
| `ping` | — | 无 | dict（server info） |
| `order_stock` | `XtQuantTrader.order_stock` | `passorder(0/1, 1, acc, code, price_type, price, vol, ctx)` | `{order_id}` |
| `query_stock_positions` | `XtQuantTrader.query_stock_positions` | `get_trade_detail_data(acc, "STOCK", "POSITION")` | `list[dict]` |
| `query_stock_asset` | `XtQuantTrader.query_stock_asset` | `get_trade_detail_data(acc, "STOCK", "ACCOUNT")` | `dict / null` |
| `query_stock_orders` | `XtQuantTrader.query_stock_orders` | `get_trade_detail_data(acc, "STOCK", "ORDER")` | `list[dict]` |
| `cancel_order_stock` | `XtQuantTrader.cancel_order_stock` | `cancel(order_id, ctx)` | `{result}` |

**order_type 映射**（只在 server 端）：
```python
_ORDER_TYPE_MAP = {23: 0, 24: 1}   # STOCK_BUY→买入, STOCK_SELL→卖出
```
shim 原样透传 xtconstant 值，server 端翻译。未来扩展信用交易只改 server。

### 6.2 行情类命令

| cmd | 策略 API | server 调用 | 返回形态 |
|-----|---------|------------|---------|
| `get_full_tick` | `xtdata.get_full_tick` | `ContextInfo.get_full_tick(code_list)` | `dict-of-dict` |
| `get_market_data_ex` | `xtdata.get_market_data_ex` | `ContextInfo.get_market_data_ex(...)` | `{stock: DataFrame}` |
| `get_instrument_detail` | `xtdata.get_instrument_detail` | `ContextInfo.get_instrument_detail(code)` | `dict` |
| `get_trading_dates` | `xtdata.get_trading_dates` | `ContextInfo.get_trading_dates(...)` | `list[int]` |

### 6.3 DataFrame 序列化

server 端用 `df.to_dict('split')`（紧凑、保留顺序），shim 端用 `pd.DataFrame(**split)` 还原。比 records 格式省 50% 体积，比 values 格式保留列名。

---

## 7. 错误处理与重连

### 7.1 错误分级

| 错误类 | 来源 | 处理策略 |
|--------|------|---------|
| A. 业务错误 | 柜台拒单 / 参数非法 | server 返回 ok:true，结果反映失败（order_id=-1）；shim 透传，策略判断 |
| B. API 调用异常 | 客户端 API 抛 Python 异常 | server 返回 ok:false + error + error_type；shim 抛 RuntimeError |
| C. 通信错误 | TCP 断开 / 超时 | client 重连 + pending Future 标记失败；shim 抛 QMTBridgeError |
| D. 致命错误 | server 进程消失 | 重试 5 次后抛致命错误，策略应终止 |

**关键原则**：业务失败不抛异常（返回 -1，与原版 xtquant 一致）；调用异常显式抛出（不静默）。

### 7.2 分层超时

| 层 | 超时 | 行为 |
|----|------|------|
| client Future.result | **10 秒** | 抛 TimeoutError |
| server _handle | **15 秒** | 强杀 worker |
| TCP socket | **30 秒** | 连接超时 |

外层比内层短，确保 client 先超时返回。

### 7.3 重连退避

接收线程检测断开后：标记所有 pending Future 失败 → 标记连接状态 → 下次调用触发 lazy reconnect。退避：1s, 2s, 4s, 8s, 16s，上限 30s。重连 5 次失败后抛致命错误。

### 7.4 日志

两端都写日志到 `E:/xtquant/tmp/`：
- `bridge_server.log`（客户端进程写）
- `bridge_client.log`（外部进程写）

格式：一行一条 JSON，便于 grep。默认 INFO 级（只记 cmd/id/耗时），调试时改 DEBUG（记录完整 args/data）。

---

## 8. 测试计划

### 8.1 四阶段门禁

| 阶段 | 内容 | 门禁 | 状态 |
|------|------|------|------|
| **1. 单元验证**（非交易时段） | 查询通道 / 崩溃测试 / schedule_run 否决 | C2/C3/C4 通过 | ✅ 完成 |
| **2. 开盘验证** | passorder DELTA + get_full_tick 实时行情 | DELTA>0 + tick 合理 | ⏳ 待开盘 |
| **3. bridge 联调** | ping/查询/行情/下单/并发 穿透 | T1-T5 全过 | ⏳ 阶段 2 后 |
| **4. 策略切换** | shadow / 小资金实盘 / 全量切换 | P1-P3 无 error | ⏳ 阶段 3 后 |

### 8.2 阶段 2：开盘验证（生死线）

**C2 v11**（在 v10 基础上扩展）：
- passorder 真生成委托：`[A] ORDER after_passorder DELTA > 0`
- ContextInfo.get_full_tick 返回实时行情：`tick["512010.SH"]["lastPrice"]` 是合理价格

两条都通过，bridge 才进入实现阶段。

### 8.3 阶段 3：bridge 联调

| 测试 | 目的 | 门禁 |
|------|------|------|
| T1: ping 自检 | shim 能连上 server | 返回 server info |
| T2: 查询穿透 | shim → server → 查询 → 返回 | 资产与 C2 一致 |
| T3: 行情穿透 | get_full_tick 经 bridge | tick 与 C2 v11 一致 |
| T4: 下单 smoke（小金额真实委托） | order_stock 经 bridge 真下单 | 委托号 > 0 且可回查 |
| T5: 并发下单 | 多线程同时 order_stock | 无崩溃，所有委托号 > 0 |

**T4 关键**：用最小金额（100 股 511880，约 100 元）真实下单一次，肉眼在客户端委托列表确认。

### 8.4 阶段 4：策略切换

| 测试 | 目的 | 门禁 |
|------|------|------|
| P1: shadow 模式 | 策略跑 bridge 但不下单（dry_run） | 决策信号与原版一致 |
| P2: 小资金实盘 | 策略用 bridge 跑实盘 1 周 | 收益/委托/成交与预期一致 |
| P3: 全量切换 | 停掉 miniQMT，纯 bridge 运行 | 策略无感知（log 无 error） |

---

## 9. 回滚方案

### 9.1 保留原版备份

替换前把 `.venv/Lib/site-packages/xtquant/` 复制为 `xtquant_original_backup/`。

### 9.2 环境变量开关

shim 检查 `QMT_USE_BRIDGE`：
- `=1`（默认）：用 bridge
- `=0`：shim 内部 import 原版 xtquant（从备份目录），完全旁路 bridge

### 9.3 miniQMT 保留期

阶段 4 完成前，miniQMT 不要真停。两套并行，bridge 出问题立即切回。

---

## 10. 监控指标（生产环境）

| 指标 | 含义 | 告警阈值 |
|------|------|---------|
| `rtt_ms`（按 cmd 分） | 每种命令的往返延迟 | p99 > 100ms |
| `reconnect_count` | 重连次数 | 每小时 > 0 |
| `error_rate`（按 cmd 分） | 各命令失败率 | > 1% |
| `pending_futures` | 当前未完成请求数 | 持续 > 10 |

---

## 11. 关键风险清单

| 风险 | 严重度 | 缓解措施 |
|------|--------|---------|
| ContextInfo.get_full_tick 也走 58610（清退后失效） | **致命** | C2 v11 开盘验证；若失效，行情需另寻数据源（本设计范围外） |
| passorder 不生成委托（DELTA=0） | **致命** | C2 v11 开盘验证；若失效，换券商通道 |
| 并发下单订单簿静默损坏 | 中 | 阶段 3 T4/T5 真实下单验证；回退路线 1b |
| 客户端升级后 ContextInfo 行为变化 | 中 | 版本锁定；升级前回归测试 |
| bridge server 阻塞主线程导致 handlebar 不调 | 中 | server 必须 daemon 线程；阶段 3 验证 handlebar 正常 |
| socket server 在客户端 3.6 环境的稳定性 | 低 | C4 v1 已验证 100 次并发稳定 |

---

## 12. 研究库落地清单（spec 审阅通过后）

本 spec 是工作流产物，不进研究库台账。审阅通过、转入实施时需做：

1. **纠正 RD-LMIG 方向卡正文**：当前"迁移核心假设"仍写"大QMT 内置 xtquant 可直连"，与 EX-XTCN 证伪结论矛盾，需改为"已证伪，转入 socket bridge 方案"。
2. **更新研究方向台账**第 46 行：`current_best_ex_id` 和 `novice_summary` 反映 bridge 方案。
3. **新建 EX-SOCKBRIDGE**：记录 bridge 设计与验证（用 `tools/New-ResearchItem.ps1 -Type Experiment`）。
4. **新建 DEC**：bridge 方案路线决策（accept socket bridge 路线）。
5. **登记子代理调用台账**：本设计过程中的 SUB-...SOCKSCAN / SUB-...XTAPI / SUB-...INCLIENT / SUB-...STRATDEP / SUB-...PASSTHR / SUB-...PYSRV / SUB-...MQMTARCH / SUB-...SCHEDRUN / SUB-...CTXIDENT / SUB-...RDYRECON 共 10 个子代理调用。
6. **重建** `00_入口/研究进展板.canvas` 和 `研究图谱.json/md`。

---

## 13. 术语

- **miniQMT**：迅投极速交易客户端（XtMiniQmt.exe + miniquote.exe + minibroker.exe），提供 58610 端口的 xtquant 服务后端。即将清退。
- **大 QMT 客户端**：XtItClient.exe，用户看盘/登录账号的主客户端。保留，但不提供 58610 服务。
- **Formula 模式**：策略在客户端"新建策略文件"里运行的执行模式，passorder 是 C++ 注入的全局函数，进程内直调。
- **shim**：drop-in 替换包，假装自己是 xtquant，内部把调用劫持到 bridge。
- **路线 1a**：worker 线程直接调 passorder，真并发（C4 v1 实测通过）。
- **路线 1b**：专用线程串行调 passorder，伪并发（1a 失效时回退）。
- **路线 2**：schedule_run marshal 回主线程（C3 v1 否决，延迟 15 秒）。

---

## 14. 变更记录

| 日期 | 变更 |
|------|------|
| 2026-07-04 | 初版，基于 C2/C3/C4 实测 + 10 个子代理调研 |
