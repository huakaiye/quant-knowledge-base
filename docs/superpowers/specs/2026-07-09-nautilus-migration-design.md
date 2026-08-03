# 量化平台 NautilusTrader 迁移设计规格

> 历史实施记录：本文中的 V1.4 路径、旧 runner 和当时命令按原证据保留，禁止作为当前执行入口。当前平台为 `${QUANT_PLATFORM_ROOT}`（V2.0），运行必须遵守研究库与平台各自的 `AGENTS.md`。

> 创建时间：2026-07-09
> 状态：设计已确认，待 PoC 验证后进入实现计划
> 作者：主控 Agent + 用户协作 brainstorming
> 关联：聚宽数据库 V3 重构（`feat/jq-database-overhaul`）、ETF 双池动量轮动策略族

---

## 1. 背景与动机

### 1.1 触发问题

用户正在下载分钟线数据（部分完成），考虑重构量化平台 `E:\量化平台_V1.4.0`（~302 文件、9.8 万行，纯 Python）以提高回测速度。原始设想：
- 核心是否可用 C/C++/Rust 等高效语言重写，策略本身继续用 Python？
- 当前平台是否有些功能过于冗余、拖慢运行速度？

### 1.2 关键发现（纠正原始假设）

通过子代理架构盘点和性能分析，得到三个与直觉相反的事实：

**① "Python 核心效率低"归因不成立。** 平台已用 polars（向量化）+ ClickHouse（OLAP）+ numpy 矩阵化动量评分（`momentum.py:144`），不是裸 Python 循环。

**② 真正瓶颈是算法复杂度，不是语言。** 子代理定位的热点全在分钟模式：每分钟 bar 重建 market_bars dict（`sim_broker.py:268`）、`sync_portfolio()` 每分钟 bar 全量重算（`sim_broker.py:357`）、动态池每 bar 补载甚至发 ClickHouse 查询（`daily_engine.py:1782`）。这些是 O(bars × positions) 的重复重算，换语言不改算法照样慢。

**③ 最大的结构性缺口是完全无并行。** 整个 `quant_v2/` 无 multiprocessing。研究库实测"6 段并行 10.5 分钟 vs 串行 51 分钟（-79%）"靠的是外部脚本，引擎本身不支持。

**④ "希望一直用到 tick 数据为止"是最强的技术论据。** tick 数据量是分钟线的 ~240 倍，当前引擎连分钟线都吃力，纯 Python 逐 bar 循环到 tick 级是死路。这强力支持"核心需要更高效实现"的判断。

### 1.3 最终方案选择

经多轮 brainstorming，确认方案：**迁移到 NautilusTrader（Rust 核心 + Python 策略 API），作为长期通用高性能底座。**

排除项：
- 增量下沉 Rust 到现有 V2 平台（备选，Nautilus PoC 失败时的回退方案）
- 整体迁移到 vectorbt（纯向量化，不支持复杂撮合，不符 A 股需求）
- 从零自主重写 Rust 核心（工作量最大，vibe coding 下风险最高）

---

## 2. 成熟框架研究的架构启示

委托 4 个子代理研究了 NautilusTrader、vectorbt、QuantConnect Lean、rqalpha/QuantAxis，提炼出以下可复用架构模式：

### 2.1 NautilusTrader（Rust 核心 + Python API）——选定的基座

- **Rust/Python 混合**：Rust 负责 22 个 crate（数据、撮合、账户、缓存、事件循环），Python 是薄控制面。策略可纯 Python（`on_bar`）或纯 Rust（`StrategyNative`）。
- **PyO3 + mimalloc**：PyO3 绑定，mimalloc 替换默认分配器，核心数据结构与 Python 共享内存零拷贝。
- **整数固定点数**：Price/Quantity 存 `i64` raw（9 位小数精度），消除浮点漂移，是确定性回测的基石。
- **单线程无锁回测**：`Rc<RefCell<...>>` 而非 Arc/Mutex，thread-local 命令队列 deferred 执行（避免 RefCell 重入）。
- **撮合引擎**：SmallVec(INLINE=4) + BTreeMap(价格排序) + AHashMap(点查索引)，价格-时间优先级 FIFO。
- **MessageBus**：Pub/Sub + P2P + Req/Resp 三模式，消息不可变，双时间戳（ts_event + ts_init）纳秒模型。
- **回测/实盘统一**："Same execution semantics and deterministic time model operate in both"——策略代码零改动上实盘。
- **重要局限**：无原生 A 股支持（T+1/涨跌停/集合竞价均需适配）；无 QMT/MiniQMT 适配器；无权威公开 ticks/sec 基准。

### 2.2 QuantConnect Lean（C#，10 年稳定演进）——架构范本

- **接口 + 组合根 + 配置注入**：所有子系统以接口存在（`IDataFeed`/`IBrokerage`/`IFillModel`/`ISlippageModel`），配置字符串驱动装配。这是长期演进的命脉。
- **Time Frontier 推进**：取所有 symbol 最早可用数据点时间戳作为引擎时钟，从根本上杜绝 lookahead bias。
- **enumerator 链式数据流水线**：fill-forward/复权/公司行动做成可组合流式 decorator，避免一次性载入内存爆炸。
- **Reality Model 可插拔**：撮合/滑点/手续费/结算各是小接口，按市场替换。VolumeShare 二次方冲击滑点（Almgren-Chriss）。
- **回测/实盘共用 `IBrokerage` 接口**。

### 2.3 rqalpha（国产 A 股）——A 股特色建模参考

- **PRE/主/POST 三段 Hook**：风控/手续费/限价校验做成可插拔 Mod 横切。
- **T+1 建模在底层**：`AbstractPosition.today_closable()`。
- **涨跌停建模在底层**：`AbstractPriceBoard.get_limit_up()/get_limit_down()`。

### 2.4 关键约束：实盘 QMT 必须保持 Python

**xtquant 只有 Python SDK，无 Rust 绑定。** 即使用 Nautilus，QMT 实盘 adapter 内部仍须调 Python xtquant。因此正确的分工是：

```
回测引擎核心 → Rust（Nautilus，性能敏感：撮合/账户/数据扫描/指标）
策略 API     → Python（聚宽兼容桥，复用现有 jq_bridge，回测/实盘共用）
实盘执行     → 保持现有 Python + xtquant（不动）
```

---

## 3. 总体路线：三阶段，每阶段有继续/回退关卡

```
阶段 0：可行性 PoC（2-3 周）
  ├─ 验证 5 个致命假设
  ├─ 用最简 ETF 策略验证机制（不追求收益复现）
  └─ 关卡：PoC 通过 → 进阶段 1；失败 → 回退到"增量下沉 Rust"方案

阶段 1：核心迁移（2-3 个月）
  ├─ ClickHouse 数据适配层（对齐 jq_v3 口径）
  ├─ A 股市场模型（T+1/涨跌停/集合竞价）
  ├─ 聚宽兼容桥（让现有策略少改或不改）
  └─ 关卡：3 个代表策略回测结果与旧 V2 引擎一致 → 进阶段 2

阶段 2：全面迁移与优化（2-3 个月）
  ├─ 46 个策略变体 + 288 配置迁移
  ├─ 性能 benchmark（vs 旧 V2 引擎）
  ├─ 向量化快路径（参数扫描）
  └─ 实盘保留 Python+xtquant，验证策略代码回测/实盘共用
```

---

## 4. 5 个致命假设与验证计划

| # | 假设 | 风险 | PoC 验证方法 |
|---|------|------|-------------|
| A1 | Nautilus 能在 WSL2 正常编译运行 | **已降为低**（回测已在 WSL 跑，WSL2 即 Linux 环境） | WSL2 装一次，跑通 Nautilus demo 回测 |
| A2 | A 股特色（T+1/涨跌停/集合竞价）能用 Nautilus 表达 | **高（核心风险）** | 实现一个 T+1 约束的 ETF 换仓策略，验证 T+1 是否需要改 Rust 核心 |
| A3 | ClickHouse 数据能高效注入 Nautilus | **低（已确认数据层方案）** | 写最小 ClickHouse→Bar 适配器，跑一段日线 |
| A4 | 聚宽 API 风格策略能经兼容桥在 Nautilus 跑 | 中（API 差异大） | 移植 1 个 ETF 策略，评估 jq_bridge 改动量 |
| A5 | 回测与 Python+xtquant 实盘的策略代码能共用 | 中 | 设计共用 API，确认不分裂为两套 |

**如果 A2 失败（T+1 需要深入改 Rust 持仓内核），整个 Nautilus 路线不推荐，回退到"增量下沉 Rust 到现有 V2 平台"方案。**

---

## 5. 数据适配层设计

### 5.1 复权机制：Nautilus 的关键局限

**Nautilus 完全不懂复权。它没有任何 corporate action / adjustment factor 概念。** GitHub Code Search `corporate_action` 零结果，`Equity` instrument 模型无复权因子字段。它只是"你喂什么价它就按什么价撮合"的执行引擎。

### 5.2 现有平台复权口径现状

现有数据库存双口径（子代理盘点证据）：
- **前复权表**（主表）：`jq_bar_daily`/`jq_bar_minute_v2`——用于策略信号、指标计算
- **未复权真实价表**：`jq_bar_daily_real`/`jq_bar_minute_real`——用于成交撮合、持仓估值
- **运行时切换**：`use_real_price` 开关（`clickhouse_portal.py:160`），`_restore_real_price_frame` 做 `value/factor` 还原（`clickhouse_portal.py:2015`）
- **聚宽 API 口径**：`jq_bridge` 的 `history/get_price` 默认前复权（`jq_bridge.py:1069`），对齐聚宽原生

**已知陷阱：jq_v3 新表只有前复权单一口径，无 real 表。** 迁移前必须在 jq_v3 补齐未复权表（可用前复权 + factor 计算，现有 `_restore_real_price_frame` 已实现该换算）。

### 5.3 选定方案：未复权注入 + 因子补偿（方式 B-2）

```
ClickHouse (未复权表 + factor 列)
   │
   ▼ BarDataWranglerV2
未复权 Bar (OHLCV + 收盘时刻 ts_init)
   │
   ├─ engine.add_data(list[Bar])   ← 撮合/账户/持仓全部真实
   │
   └─ jq_bridge on_bar：用 factor 表把未复权价 ×factor 算前复权信号
      （因子补偿在桥内部做，策略代码无感，保持聚宽 history() 返回前复权）
```

**为什么选未复权注入**：Nautilus 的核心价值在撮合/账户/执行模拟的真实性。若喂前复权价，除权日会用历史上不存在的价格成交，净值系统性偏乐观——等于废掉 Nautilus 的核心价值。A 股 T+1、涨跌停、100 股一手、除权日真实委托股数变化，都需要未复权 + 真实股数才能正确模拟。

**因子补偿在 jq_bridge 内部**：策略调 `history()`/`attribute_history()` 时，桥内部用 factor 表把未复权价转为前复权返回。策略代码完全无感，复用现有聚宽兼容语义。

### 5.4 持仓公司行动处理

现有 `sim_broker.apply_position_ratio_adjustment`（`sim_broker.py:201-251`）按 `current_factor/previous_factor` 缩放持仓数量并反向除成本（市值守恒）。迁移时需在 Nautilus 的 Position/Account 模块对应实现，仅 `use_real_price=True` 时触发（前复权口径下持仓天然连续）。

### 5.5 关键技术细节

- **数据摄入接口**：用低层 `BacktestEngine.add_data(list[Bar])` 直接接收内存对象，绕过 Parquet Catalog。工作流：ClickHouse 查询 → pandas DataFrame → BarDataWranglerV2 → list[Bar] → add_data。
- **Bar 字段**：`open/high/low/close/volume/ts_event/ts_init`，价格浮点传入，wrangler 自动转 i64 定点。
- **时间戳**：Nautilus 严格要求 `ts_init` 是 Bar 收盘时刻（避免 look-ahead）。日线用当日 15:00 收盘时刻，非 00:00。
- **Instrument 定义**：`Equity(price_precision=2, price_increment=Price.from_str("0.01"), lot_size=Quantity.from_int_c(100), currency=CNY)`。
- **因子口径**：必须沿用 `jq_bar_daily.factor`（聚宽原生），不能用 Tushare `adj_factor` 或 xtdata factor（三者不同）。
- **开盘分钟标注**：`jq_bar_minute_v2` 部分历史无 09:30 行（量记在 09:31），`jq_bar_minute_real` 有 09:30，分钟对齐需注意。

---

## 6. A 股市场模型

### 6.1 可配置解决（低风险）

| A 股特色 | Nautilus 实现 | 难度 |
|---------|--------------|------|
| 最小价格变动 0.01 元 | `price_increment=Price.from_str("0.01")` | 配置 |
| 最小委托单位 100 股 | `lot_size=Quantity.from_int_c(100)` | 配置 |
| 价格精度 2 位小数 | `price_precision=2` | 配置 |
| 货币 CNY | `Currency.from_str_c("CNY")` | 配置 |

### 6.2 需写代码扩展（中高风险）

**① T+1（当日买入不可卖）——核心风险点**

Nautilus 的 `Position` 模型无"今日可平量"概念。参考 rqalpha 的 `today_closable()` 设计，两种实现路径：
- (a) 策略层维护 T+1 标记（简单但脏）
- (b) 自定义 Position 子类或填充模型拦截卖出（干净但要懂 Position 内部）

PoC 必须验证：T+1 能否用配置/填充模型解决，还是非得深入改 Nautilus 的 Rust Position 内核。现有 `sim_broker._is_t0_symbol`（`sim_broker.py:814`）逻辑需移植。

**② 涨跌停板（±10%/±20%/±5%）**

Nautilus `Instrument` 无 limit_up/limit_down 字段。解决方案：在填充模型 `FillModel` 里拒绝涨停价成交（纯校验）。现有 `sim_broker._blocked_by_market`（`sim_broker.py:639`）逻辑需移植。比 T+1 容易。

**③ 集合竞价（9:25 开盘价）**

只要分钟数据里有 09:25 这根 Bar，Nautilus 正常处理。主要是数据对齐问题，不是引擎问题。

### 6.3 持仓/撮合模型移植清单

现有 V2 平台需移植到 Nautilus 的 A 股特色逻辑：
- T+1 约束（`sim_broker.py:814` `_is_t0_symbol`）
- 涨跌停拦截（`sim_broker.py:639` `_blocked_by_market`）
- 滑点模型（`sim_broker.py:682` `_apply_slippage`，支持 fixed/price_related/bps）
- 成交量约束（`sim_broker.py:714` `_apply_volume_limit`）
- 手续费 + 最低佣金（`sim_broker.py:728` `_fee`）
- 公司行动持仓调整（`sim_broker.py:201` `apply_position_ratio_adjustment`）
- 复权因子吸附（`price_rounding.py:60` `normalize_adjust_factor`，半拆分吸附到 0.5）

---

## 7. 聚宽兼容桥设计

### 7.0 兼容范围：全功能复刻（2026-07-09 确认）

**用户决策：全功能复刻 jq_bridge 已实现的聚宽 API 表面。** 目标是迁移后任何用聚宽 API 写的策略都能在 Nautilus 上跑，无需改策略代码。

现有 `jq_bridge.py`（1429 行）已完整复刻聚宽 API，分五大类：

| 类别 | API | 引擎相关? | 迁移动作 |
|------|-----|----------|---------|
| 数据查询 | `history`/`attribute_history`/`get_price` | ✅ 相关 | 重写底层：从 Nautilus cache 取 Bar + 因子补偿 |
| 基本面查询 | `get_fundamentals`/`run_query`(valuation/income/balance/cash_flow/indicator) | ❌ 无关(直查 ClickHouse) | **保留不动** |
| 实时/当前数据 | `get_current_data`/`get_current_tick`/`get_ticks`/`get_bars` | ✅ 半相关 | 改读取源：Nautilus 当前 bar |
| 标的/日历 | `get_all_securities`/`get_security_info`/`get_trade_days`/`get_extras`/`get_index_stocks` | ❌ 无关(查 ClickHouse) | **保留不动** |
| 下单 | `order`/`order_value`/`order_target`/`order_target_value`/`cancel_order` | ✅ 相关 | 重写底层：转 Nautilus submit_order |
| 账户/持仓 | `context.portfolio`/`subportfolios`/`positions`(total_amount/closeable_amount/avg_cost) | ✅ 半相关 | 改读取源：Nautilus portfolio/cache |
| 配置控制 | `set_universe`/`set_option`/`set_slippage`/`set_order_cost`/`set_subportfolios` | ✅ 相关 | 改：对接 Nautilus subscribe/FillModel |
| 调度回调 | `run_daily`/`before_trading_start`/`handle_data`/`after_trading_end` | ✅ 相关 | 改：对接 Nautilus 事件循环 |
| 记录 | `record`/`record_strategy_state` | ❌ 无关 | **保留不动** |

**乐观结论**：约 60% 代码（聚宽语义逻辑 + ClickHouse 直查类）引擎无关可保留；约 40%（两个对接点 + 账户代理 + 调度）需重写底层。这是"换底盘"，不是"重造车"。

**对 PoC 的影响**：PoC Task 5 从"Nautilus 原生策略"升级为"迷你兼容桥验证"——实现 `history` + `order_target_value` + `handle_data` 经薄桥在 Nautilus 上跑通，证明桥的底层对接可行。全功能复刻是阶段 1 目标。

### 7.1 目标

288 配置 + 46 策略变体全用聚宽 API 风格。保留现有 `jq_bridge`（`jq_bridge.py`，1429 行）的上层聚宽 API，只改底层引擎接口。

```
聚宽风格策略代码（不动）
   │  history / attribute_history / order_target_value / before_trading_start
   ▼
jq_bridge 聚宽兼容层（改底层，保上层）
   │  适配层：聚宽 API → Nautilus API（on_bar / submit_order / Position）
   ▼
Nautilus 引擎
```

### 7.2 迁移要点

- **上层聚宽 API 不变**：`set_universe`/`history`/`attribute_history`/`get_price`/`order_target_value`/`before_trading_start`/`handle_data` 等签名保持。
- **因子补偿封装在桥内**：`history()` 返回前复权价（桥内部用 factor 表转换未复权 Bar）。
- **取数层重写**：`attribute_history` 等取数函数当前依赖 `dataset_portal`，迁移时改为从 Nautilus cache 或 ClickHouse 直取。
- **下单接口适配**：聚宽 `order_target_value` → Nautilus `submit_order`（需处理 TARGET_VALUE 到具体订单的转换）。

### 7.3 不确定性

jq_bridge 内部可能和 V2 引擎的 `dataset_portal` 深度耦合。迁移时取数层重写工作量需 PoC 评估（A4 假设）。

---

## 8. 实盘边界

**实盘保持现有 Python + xtquant，不迁移到 Nautilus 实盘引擎。**

理由：
1. xtquant 只有 Python SDK，Nautilus 无 QMT adapter。
2. V21 实盘策略（4476 行）已在 Python+xtquant 上验证成熟。
3. Nautilus 的价值在回测高频迭代，不在实盘执行。

**回测/实盘策略代码共用**：策略业务逻辑写在聚宽 API 层（jq_bridge 之上），回测和实盘共用同一套策略代码。差异仅在 jq_bridge 的底层：回测对接 Nautilus，实盘对接 xtquant。这是 A5 假设要验证的。

---

## 9. PoC（阶段 0）详细设计

### 9.1 目标

用最简策略验证 5 个致命假设，不追求收益复现。目的：在最短时间内确认 Nautilus 路线可行或不可行。

### 9.2 验证顺序（按风险从高到低）

```
步骤 1（验证 A1 低风险 + A3 数据注入）：
  WSL2 安装 Nautilus → 跑通官方 demo → 写最小 ClickHouse→Bar 适配器 → 注入一段日线
  
步骤 2（验证 A2 核心风险）：
  定义 A 股 Instrument（涨跌停/100股/0.01元）→ 
  实现 T+1 约束的 ETF 最简换仓策略 → 
  验证 T+1 能否用 FillModel/配置解决，还是需要改 Rust 核心
  
步骤 3（验证 A2 复权 + A4 兼容桥）：
  注入未复权数据 + factor 表 → 
  在策略层实现因子补偿信号 → 
  评估 jq_bridge 从 V2 到 Nautilus 的适配量
  
步骤 4（验证 A5 回测/实盘共用）：
  设计聚宽 API 层接口 → 确认回测/实盘不分裂为两套
```

### 9.3 PoC 判定标准

| 假设 | 通过标准 | 失败后果 |
|------|---------|---------|
| A1 | WSL2 跑通 Nautilus demo + 我们的 Bar 注入 | 低风险，预期通过 |
| A2-T+1 | T+1 用 FillModel/配置实现，不需改 Rust 核心 | **回退到增量下沉方案** |
| A2-涨跌停 | FillModel 拦截涨停价成交成功 | 改 Rust 核心（可接受） |
| A3 | ClickHouse→Bar 注入跑通，日线回测出结果 | 低风险，预期通过 |
| A4 | jq_bridge 适配量 < 500 行改动 | 评估后决定 |
| A5 | 聚宽 API 层回测/实盘接口统一 | 设计调整 |

### 9.4 PoC 时间盒

- 总时长：2-3 周
- 步骤 1：3 天
- 步骤 2：1 周（核心风险，投入最多）
- 步骤 3：3 天
- 步骤 4：2 天
- 缓冲：3 天

### 9.5 PoC 与聚宽数据库 V3 重构的关系

当前平台正在做 `feat/jq-database-overhaul`（8 个 Task 代码已完成，未切换路由）。PoC 应：
- **不依赖 jq_v3 切换完成**：PoC 可用旧表（`jq_bar_daily` + `jq_bar_daily_real`）验证机制。
- **但 jq_v3 必须补齐未复权表**：阶段 1 正式迁移前，jq_v3 需补 `jq_v3_bar_daily_real` 等真实价表。
- **两条线可并行**：PoC 验证 Nautilus 机制 + jq_v3 切换是独立的，不互相阻塞。

---

## 10. 风险与护栏

### 10.1 最大风险

1. **T+1 需要改 Rust 内核**（A2）：vibe coding 下改 Rust 持仓内核调试成本极高。PoC 步骤 2 必须排除。
2. **"一步到位"陷阱**：架构可一步到位（Nautilus 接口边界），实现不能。每阶段必须可回退。
3. **双线作战**：Nautilus 迁移 + jq_v3 重构同时进行。保持两条线独立，PoC 用旧表验证。
4. **策略代码迁移量**：46 策略 + 288 配置迁移可能比预期大。依赖 jq_bridge 适配质量（A4）。

### 10.2 护栏

- **PoC 关卡是硬门**：阶段 0 不通过，不进阶段 1。
- **每步 profiling**：不盲目重写，用数据驱动。
- **旧 V2 引擎保留**：迁移期间 V2 不删除，作为参照基准和回退。
- **回测一致性验证**：阶段 1 关卡要求 3 个代表策略回测结果与旧 V2 引擎一致（hash 级或数值级）。

---

## 11. 待解决问题（PoC 后明确）

1. T+1 的最优实现方式（FillModel vs Position 子类 vs 策略层标记）——PoC 步骤 2 决定。
2. jq_bridge 适配的具体工作量——PoC 步骤 3 评估。
3. 参数扫描的向量化快路径是否用 Nautilus 原生还是外挂 vectorbt 思路——阶段 2 决定。
4. Nautilus 版本锁定策略（避免 breaking change）——阶段 1 初期决定。
5. 是否需要自行编译 Nautilus Rust 核心（Windows/WSL 特殊需求）——PoC 步骤 1 决定。

---

## 子代理调用记录

| 调用 ID | 任务代号 | 模型 | 交付物 |
|---------|---------|------|--------|
| SUB-PLATRECON-A | 平台架构盘点 | sonnet | 技术栈/目录/数据层/引擎/规模盘点 |
| SUB-PLATRECON-B | 性能热点分析 | sonnet | 回测循环/数据读取/撮合/指标/反模式/并行/配置分析 |
| SUB-PLATRECON-C | 近期现状与冗余 | sonnet | git 历史/重构进度/冗余/实盘/测试盘点 |
| SUB-FRAME-A | Nautilus+vectorbt 研究 | sonnet | 两个框架架构机制 + 可借鉴点 |
| SUB-FRAME-B | Lean+rqalpha 研究 | sonnet | 四个框架架构机制 + 可借鉴点 |
| SUB-NAUTILUS-DATA | Nautilus 数据/复权机制 | sonnet | 数据摄入接口 + 复权处理（结论：Nautilus 不懂复权） |
| SUB-JQV3-ADJUSTMENT | 现有 ClickHouse 复权口径 | sonnet | 双口径现状 + jq_v3 缺 real 表发现 |

子代理豁免说明：研究判断、方案选择、技术路线生杀由主控承担；子代理只做检索/归纳/源码分析。

---

## 设计自审

- [x] 占位符扫描：无 TBD/TODO，第 11 节"待解决问题"是 PoC 后才能明确的，已标注。
- [x] 内部一致性：三阶段路线与 5 假设验证一致；数据层方案与 A 股模型互补；实盘边界与兼容桥设计一致。
- [x] 范围检查：聚焦单一实现目标（Nautilus 迁移），PoC 是独立可执行单元。
- [x] 歧义检查：方式 B-2（因子补偿在桥内）、未复权注入、实盘保持 Python 等关键选择均已明确写定。
