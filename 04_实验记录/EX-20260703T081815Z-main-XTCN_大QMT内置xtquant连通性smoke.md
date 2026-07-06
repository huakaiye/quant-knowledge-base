---
type: 实验记录
ex_id: EX-20260703T081815Z-main-XTCN
rd_id: RD-20260703T081815Z-main-LMIG
status: revise
stage: conclusive_attribution_confound_order_pending
owner: main
created_at: 2026-07-03T08:18:15Z
updated_at: 2026-07-03T08:45:00Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 实盘平台工程模块
decision_ids: []
lit_ids: []
idea_ids: []
platform_project: ${LIVE_TRADING_ROOT}
config_paths: []
result_paths:
  - 'E:/xtquant/策略/smoke_xtquant_bigqmt_connect.py'
  - 'E:/xtquant/策略/smoke_bigqmt_builtin_python.py'
  - 'E:/xtquant/策略/smoke_bigqmt_order_roundtrip.py'
summary_paths: []
quality_gate: L0_engineering_smoke
subagent_call_ids: ['SUB-20260703T081815Z-main-MINIQMT-ASSESS']
subagent_exemption:
tags: [实盘平台, miniQMT清退, 大QMT, xtquant, 连通性smoke, 平台迁移]
---

# 大QMT 内置 xtquant 连通性 smoke

## 关联链接

- 研究方向：[[02_研究方向/RD-20260703T081815Z-main-LMIG_miniQMT清退后实盘平台迁移|miniQMT 清退后实盘平台迁移]]
- 父模块：[[02_研究方向/RD-20260605T115651Z-main-EXE0_双池轮动执行与换仓模块|双池轮动执行与换仓模块]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 现状盘点子代理：调用ID SUB-20260703T081815Z-main-MINIQMT-ASSESS（已登记）
- 平台协作规范：[[08_方法论/平台协作规范|平台协作规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]

## 子代理调用记录

| 项 | 内容 |
| --- | --- |
| 调用 ID | SUB-20260703T081815Z-main-MINIQMT-ASSESS |
| 任务代号 | SUBTASK-MINIQMT-ASSESS |
| 平台昵称 | Hooke（自动） |
| 模型 | sonnet（Explore agent） |
| 交付物 | 研究库 miniQMT/实盘/大QMT 现状全库盘点（7 节结论） |
| 用途 | 检索研究库现状，定位 miniQMT 在体系中的角色 + 是否已有迁移讨论 |
| 结论采纳 | 是。盘点确认：miniQMT 是唯一实盘平台假设；零命中"清退/大QMT/迁移"；实盘主文件路径 `E:\xtquant\策略\ETF双池动量轮动_MiniQMT.py`；本机 `${LIVE_TRADING_ROOT}` 未配置（实盘不在本机） |
| 豁免原因 | 无（已调用） |

主控承担的部分（不下放子代理）：实盘边界判断、xtquant 清退范围确认、连通性 smoke 设计与执行、下单 smoke 设计。

## 1. 新手摘要

⚠️ **本实验原结论已于 2026-07-03 16:39 被用户纠正并作废**，下方"原摘要"仅作错误归因记录保留。请优先看第 12 章「归因纠正」。

**原摘要（错误，2026-07-03 12:23 写下）**：以为大QMT 客户端（XtItClient.exe）自带的独立 xtquant 可以直连，外部 Python 3.11 只需加一行 `sys.path.insert` 就能零改动迁移。

**纠正后（2026-07-03 16:39）**：12:23 那次 connect=0 的成功，最可能原因是用户当时临时启动了 miniQMT，是 **miniQMT（miniquote/minibroker 后台）提供了 xtquant 服务后端**，与我用哪个 xtquant 库无关。后续事实核查证实：XtItClient.exe 一直运行中，但当 miniQMT 进程不存在、58610 端口无监听时，connect 一律 -1 失败——**"大QMT 内置 xtquant 能直连"的假设被证伪**。

迁移路线回到原点：miniQMT 清退后，需要找真正能替代 miniQMT 服务后端的方案（EasyXT 桥接 / 大QMT 客户端内部策略框架 / ptrade / 其他）。

## 2. 实验前预测

| 假设 | 预测结果 | 现状 |
| --- | --- | --- |
| H1：外部 pip xtquant + 大QMT userdata_mini | connect 失败（pip xtquant 依赖 XtMiniQmt.exe，已清退） | ⚠️ 归因待重测 |
| H2：大QMT 内置 Python 3.6 + 大QMT 内置 xtquant + userdata_mini | connect 成功 + query_asset 成功 | ❌ **被证伪**（见第 12 章） |
| H3：外部 Python 3.11 + 大QMT 内置 xtquant + userdata_mini | connect 成功 + query_asset 成功 | ❌ **被证伪**（见第 12 章） |
| H4：大QMT 内置 xtquant 连 userdata（非 mini） | connect 失败 | ⚠️ 归因待重测 |
| H5：收盘后大QMT 内部行情服务降级 | connect 失败 | ❌ **归因错误**，真正原因是 miniQMT 未运行，与收盘时段无关 |

## 3. 证伪条件

- FC1：若 H3 失败（外部 Py3.11 + 大QMT 内置 xtquant connect≠0），则"零改动迁移"假设破产，必须走桥接或换运行时。
- FC2：若 query_stock_asset 返回空（账号未登录态不传递），则策略 `init_trader()` 第 3045 行交易熔断逻辑失效。
- FC3：若真实下单 order_stock 返回 ≤0 或委托/撤单回报拿不到，则下单链路不通，迁移无法落地。
- FC4：若 connect 成功但仅限大QMT 内置 Python 3.6（H3 失败但 H2 成功），则必须把策略塞进大QMT 客户端内置 python 跑（运行模式变化，工程量上升）。

## 4. 实际观察

### 4.1 smoke #1（外部 pip xtquant，预测 H1 失败）

- 配置：`C:\Python311\python.exe` + pip 装的 `xtquant==250516.1.1` + `userdata_mini` 与 `userdata` 双路径。
- 时间：2026-07-03 12:08:47（午盘收盘前后，大QMT 客户端 PID 232168 运行中）。
- 结果：
  - `userdata_mini`：`connect() = -1 FAIL`
  - `userdata`：`connect() = -1 FAIL`
  - xtdata 报错："无法连接xtquant服务，请检查QMT-投研版或QMT-极简版是否开启"
- 解读：pip xtquant 依赖 XtMiniQmt.exe 后台，本机 XtMiniQmt.exe 未运行 → 连接失败。**与预测 H1 一致**。
- 注意：这一条同时证伪了"换 userdata 路径就能解决"的早期乐观假设。

### 4.2 smoke #2（大QMT 内置 Python 3.6，预测 H2 成功 / H4 失败）

- 配置：`E:\xtquant\国金证券QMT交易端\bin.x64\python.exe`（3.6.8）+ 内置 `xtquant`（路径 `bin.x64\lib\site-packages\xtquant\__init__.py`）。
- 时间：2026-07-03 12:23:24（大QMT 客户端 PID 232168 运行中）。
- 结果：
  - `userdata_mini`：**`connect() = 0 OK`**；`query_stock_asset OK 总资产=124883.99 现金=124883.99`；`query_stock_positions OK 条数=0`
  - `userdata`：`connect() = -1 FAIL`
- 解读：大QMT 内置 xtquant 通过 `userdata_mini` 直连成功，且能查到真实账号资产。**与预测 H2 一致、H4 一致**。
- 物理证据：大QMT 客户端 `bin.x64` 下含 `XtQuantServer_qmt.dll`（带 `_qmt` 后缀，大QMT 专属量化服务，独立于被清退的 miniQMT）。

### 4.3 smoke #3（外部 Py3.11 + 大QMT 内置 xtquant，预测 H3 成功）

- 配置：`C:\Python311\python.exe`（3.11.9）+ `sys.path.insert(0, r'E:\xtquant\国金证券QMT交易端\bin.x64\Lib\site-packages')` + `userdata_mini`。
- 时间：2026-07-03 12:23 后（紧接 smoke #2）。
- 结果：
  - `xtquant.__file__` = `E:\xtquant\国金证券QMT交易端\bin.x64\Lib\site-packages\xtquant\__init__.py`（确认加载的是大QMT 内置版本，非 pip 版）
  - `xttrader` 加载 OK
  - **`connect() = 0 OK`**
  - `query_stock_asset`：`总资产=124883.99 现金=124883.99`（与 smoke #2 完全一致）
- 解读：**外部 Python 3.11 直接复用大QMT 内置 xtquant 完全可行**，这是最理想的迁移路径。**与预测 H3 一致**。
- 关键意义：策略代码无需切到 Python 3.6、无需进客户端内置框架，只加一行 sys.path 即可。

### 4.4 smoke #4（收盘后复测，预测 H5 失败）

- 配置：同 smoke #3（外部 Py3.11 + 大QMT 内置 xtquant）。
- 时间：2026-07-03 16:15:14（收盘后；大QMT 客户端 PID 232168 仍在运行，`userdata_mini` 16:14 仍在写入）。
- 结果：3 次 `connect() = -1 FAIL`；xtdata "无法连接行情服务"。
- 物理证据：`xtdata.ini` 行情节点 `address=127.0.0.1:58610`，这是大QMT 客户端内部行情服务端口，收盘后降级。
- 解读：**xtquant 服务受交易时段约束**，不是方案缺陷。**与预测 H5 一致**。
- 工程含义：所有 connect/query/order smoke 必须在交易时段（09:15-15:00）内执行；策略实盘运行也必须依赖客户端在交易时段提供的服务。

## 5. 支持证据汇总

| 证据 | smoke | 证据等级 |
| --- | --- | --- |
| 外部 pip xtquant 依赖被清退的 XtMiniQmt.exe | #1 | L1（实测 connect=-1） |
| 大QMT 内置独立 xtquant 存在 | #2 | L0（文件系统直查：`bin.x64\Lib\site-packages\xtquant` + `XtQuantServer_qmt.dll`） |
| 大QMT 内置 xtquant 提供 cp36~cp311 全版本 .pyd | #2/#3 | L0（`IPythonApiClient.cp36/.../cp311-win_amd64.pyd` 全在） |
| 大QMT 内置 xtquant 直连 userdata_mini 成功 | #2 | L1（connect=0 + 真实资产 124883.99） |
| 外部 Py3.11 复用大QMT 内置 xtquant 成功 | #3 | L1（connect=0 + 同一资产值，证明账号态一致） |
| 真实账号资产可查（124883.99 现金 / 空仓） | #2/#3 | L1（query_stock_asset 双口径一致） |
| 持仓查询可查（条数=0，与空仓一致） | #2 | L1（query_stock_positions） |
| 交易时段约束（收盘后服务降级） | #4 | L1（connect=-1 + xtdata.ini 节点证据） |

## 6. 反对证据 / 未覆盖项

- **下单链路未验证（FC3 未闭环）**：order_stock / cancel_order_stock / query_stock_orders / query_stock_trades 未实测，必须在交易时段跑下单 smoke。
- **行情订阅未深度验证**：smoke #1 报错"无法连接行情服务"，但那是 pip xtquant；大QMT 内置 xtquant 的 xtdata.subscribe_quote / get_market_data_ex 在交易时段能否用，未实测（smoke #2/#3 只测了交易接口）。
- **xtquant 版本一致性未核**：大QMT 内置 xtquant 与 pip 版（250516.1.1）的 API 行为是否完全一致、是否有方法签名差异，未做静态对比。
- **大QMT 客户端升级影响未评估**：客户端自动升级后内置 xtquant 可能变化，回归测试机制未建立。
- **运行模式假设未证伪**：当前假设"大QMT 客户端 GUI 登录 + 外部 Python 连 userdata_mini"可长期稳定；若券商要求策略必须进客户端内置框架跑，运行模式需重新评估。

## 7. 和预测一致性

⚠️ **原"5/5 假设全中"结论作废**（2026-07-03 16:39 纠正）。

原表格曾判定 H1-H5 全部一致，但其中 H2/H3 的"成功"存在未排除的混淆变量（miniQMT 临时运行）。真实一致性如下：

| 假设 | 原判定 | 纠正后 | 说明 |
| --- | --- | --- | --- |
| H1 外部 pip xtquant | 一致 | 待重测 | 当时若 miniQMT 在跑，pip xtquant 也可能成功 |
| H2 大QMT 内置 Py3.6 + userdata_mini | 一致 | ❌ 归因错误 | 成功来自 miniQMT，非大QMT 内置能力 |
| H3 外部 Py3.11 + 大QMT 内置 xtquant | 一致 | ❌ 归因错误 | 同 H2 |
| H4 userdata（非 mini） | 一致 | 待重测 | 需在受控条件下重测 |
| H5 收盘后服务降级 | 一致 | ❌ 归因错误 | 16:15 失败的真实原因是 miniQMT 已关闭，与收盘时段无关 |

真正能确立的事实只有一个：**当 xtquant 服务后端（miniquote/minibroker）运行时 connect 能成功；当它不运行时 connect 失败**。这与"哪个 Python"或"哪个 xtquant 库"无关。

## 8. 边界声明（硬约束）

- 本 smoke 只读 + 真实下单 smoke 尚未执行，**不得直接升级为实盘交易依据**。
- 实盘主文件 `ETF双池动量轮动_MiniQMT.py` **未做任何修改**（仅新增 3 个 smoke 脚本，不动原代码）。
- 不改 hard5 / A2-slope004 / B3-gate-tiered-v2 实盘默认开关。
- smoke 脚本仅用于连通性验证，不进入策略正式调用链。
- 真实下单 smoke 必须用 SAFE 模式（限价涨停）避免误成交，REAL 模式需用户显式授权。
- 子代理不独立判断"迁移可行"或"可改实盘"——这是主控与用户决策。

## 9. 下一步

1. **真实下单 smoke（待交易时段）**：用 `smoke_bigqmt_order_roundtrip.py --mode safe`（100 股 510310.SH 限价涨停买入 → 立刻撤单 → 验证委托/撤单/成交回报）。
2. 下单 smoke 通过后，新开 DEC 决策卡：预注册"实盘主文件 xtquant 库来源切换（pip → 大QMT 内置）"的最小改动 + 双轨 + 回滚预案。
3. 行情链路单独验证：交易时段内用大QMT 内置 xtquant 测 `xtdata.subscribe_quote` + `get_market_data_ex` + `get_full_tick`。
4. 建立 xtquant 版本回归测试：每次大QMT 客户端升级后，跑 connect/query/order 三件套 smoke。
5. 待迁移全部验证通过后，更新 `08_方法论/平台协作规范.md` 实盘平台默认假设（miniQMT → 大QMT 内置 xtquant）。

## 10. 是否需要研究决策卡

当前 `revise`，不下 `promote/park/kill`。下单 smoke 完成后，视结果决定是否新开 DEC：
- 下单 smoke 通过 → 新开 DEC 预注册迁移落地。
- 下单 smoke 失败 → 新开 DEC 评估桥接/换运行时备选。

## 11. 实验资产清单

| 文件 | 用途 | 状态 |
| --- | --- | --- |
| `E:/xtquant/策略/smoke_xtquant_bigqmt_connect.py` | smoke #1（外部 pip xtquant，已证伪） | 保留作对照 |
| `E:/xtquant/策略/smoke_bigqmt_builtin_python.py` | smoke #2/#3/#4（大QMT 内置 xtquant，主验证脚本） | 主资产 |
| `E:/xtquant/策略/smoke_bigqmt_order_roundtrip.py` | 真实下单 smoke（待交易时段执行） | 待跑 |

## 12. 归因纠正（2026-07-03 16:39，用户纠错触发）

### 12.1 用户纠正

用户指出："你那一次打通应该是因为我当时临时启动了一下 miniQMT"。这一纠正暴露了 smoke #2/#3 成功时未排除的关键混淆变量：当时是否同时有 miniQMT 进程在跑。

### 12.2 复盘错误

主控在 smoke #2/#3 成功后，未执行最基本的进程核查（`tasklist /FI "IMAGENAME eq XtMiniQmt.exe"` 和 `miniquote.exe` / `minibroker.exe`），就把 connect=0 归因于"大QMT 内置 xtquant 能直连"。这是典型的**单一成功案例 + 未排除混淆变量 → 过度归因**错误，违反 AGENTS.md "未完成未来函数审计不得 promote"和"看结果后新增参数网格必须重新预注册"背后同一精神：单个现象不能直接升级为结论。

### 12.3 事实核查（2026-07-03 16:39）

| 检查项 | 结果 |
| --- | --- |
| XtMiniQmt.exe 进程 | 未运行 |
| miniquote.exe（miniQMT 行情后台） | 未运行 |
| minibroker.exe（miniQMT 交易后台） | 未运行 |
| XtItClient.exe（大QMT 主客户端） | 运行中（PID 232168，668MB） |
| userdata_mini 目录写入 | 16:34 仍在写（说明 XtItClient 在用此目录，但不提供 xtquant 服务） |
| 58610 端口（xtdata.ini 指定的 xtquant 服务端口） | **无任何进程监听** |
| connect() 复测（外部 Py3.11 + 大QMT 内置 xtquant） | -1 FAIL |

**关键推断**：58610 端口无监听 + XtItClient 在跑 + connect=-1，三者共同证明 **XtItClient.exe 本身不提供 xtquant 服务后端**。xtquant 客户端要连的 58610 端口服务，是由 miniquote/minibroker（miniQMT 后台）启动的。

### 12.4 真实机制（修正版）

- xtquant（无论 pip 装的还是大QMT 内置的）只是**客户端 SDK**，它通过本地端口（如 58610）连一个**服务后端**。
- 这个服务后端由 **miniQMT 后台进程**（miniquote.exe 提供行情、minibroker.exe 提供交易）启动。
- XtItClient.exe（大QMT GUI）**不启动这个服务后端**——它只是图形客户端，内部跑自己的策略用客户端内置 python，但不开 xtquant 服务端口给外部连。
- 因此 miniQMT 清退后，**整个"外部 Python + xtquant 连本地服务"模式失效**，无论用哪个 xtquant 库。

### 12.5 对迁移路线的影响

- ❌ "外部 Python + 大QMT 内置 xtquant"路线：证伪。
- ❌ "加一行 sys.path.insert 零改动迁移"：证伪。
- 待重评的路线：
  1. **EasyXT 文件信号桥接**（策略跑在外部，下单走文件 → 大QMT 内部 python 读文件下单；查询需自研双向通信）
  2. **策略整体迁入大QMT 客户端内置框架**（用客户端的 PY策略 框架，python 3.6，受客户端调度）
  3. **ptrade 或其他独立交易系统**（换券商通道或换系统）
  4. **确认清退细则后判断**（若 XtMiniQmt 清退但 miniquote/minibroker 服务保留，可能仍有出路；需券商明确）

### 12.6 必须重做的受控实验

在任何一个替代方案落地前，必须做一次**进程状态受控**的连通性测试，彻底区分"哪个组件提供服务"：

| 实验 | XtMiniQmt | miniquote | minibroker | XtItClient | 预期 connect |
| --- | --- | --- | --- | --- | --- |
| A | 关 | 关 | 关 | 关 | -1（基线） |
| B | 关 | 关 | 关 | 开 | ?（验证 XtItClient 是否单独提供服务） |
| C | 开 | 开 | 开 | 关 | 0？（验证 miniQMT 是否单独提供服务） |
| D | 开 | 开 | 开 | 开 | 0？（12:23 状态） |
| E | 关 | 开 | 开 | 关 | ?（拆解哪个 mini 进程是关键） |

只有 B 和 E 的结果才能区分 XtItClient vs miniquote/minibroker 谁是真正后端。本实验因未做这组对照，结论作废。

### 12.7 教训记录

1. **任何 connect 成功必须同步核查进程清单**，不能事后追溯。
2. **单一成功 + 未排除混淆变量 ≠ 结论**，与研究方法论的"看结果后扩参数"同源错误。
3. 主控不得在缺受控对照时下"5/5 全中"判定。
4. 用户纠正是重要证据来源，应记录入实验档案而非口头接受。
