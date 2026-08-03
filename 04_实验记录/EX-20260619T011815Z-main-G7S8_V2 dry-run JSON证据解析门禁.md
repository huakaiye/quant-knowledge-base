---
type: 实验记录
ex_id: EX-20260619T011815Z-main-G7S8
rd_id: RD-20260618T105950Z-main-7FY3
status: completed
stage: engineering_json_gate_passed_not_strategy_validation
owner: main
created_at: 2026-06-19T01:18:15Z
updated_at: 2026-06-19T01:25:07Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 执行与换仓模块
decision_ids: []
lit_ids: []
idea_ids: []
platform_project: ${LEGACY_QUANT_PLATFORM_ROOT}
config_paths:
  - scripts/research/analyze_g7s8_live_dry_run_json_gate.py
  - src/tests/scripts/test_analyze_g7s8_live_dry_run_json_gate.py
result_paths:
  - results/v2/research/RD-20260618T105950Z-main-7FY3/EX-20260619T011815Z-main-G7S8/summary.json
  - results/v2/research/RD-20260618T105950Z-main-7FY3/EX-20260619T011815Z-main-G7S8/dry_run_json_gate.csv
  - results/v2/research/RD-20260618T105950Z-main-7FY3/EX-20260619T011815Z-main-G7S8/orders.csv
  - results/v2/research/RD-20260618T105950Z-main-7FY3/EX-20260619T011815Z-main-G7S8/records.csv
  - results/v2/research/RD-20260618T105950Z-main-7FY3/EX-20260619T011815Z-main-G7S8/run_g7s8_json_gate.log
summary_paths:
  - results/v2/research/RD-20260618T105950Z-main-7FY3/EX-20260619T011815Z-main-G7S8/summary.json
quality_gate: engineering_schema_gate_only_not_strategy_validation
subagent_call_ids:
  - SUB-EXEMPT-20260619T011300Z-main-DRYJSON
subagent_exemption: 当前多代理工具只有在用户显式要求子代理/委派/并行 agent 时才允许 spawn，本轮没有该授权。
tags: [双池轮动, 低滞后, dry-run, JSON解析, 实盘证据, 执行与换仓]
---

# V2 dry-run JSON证据解析门禁

## 关联链接

- 研究方向：[[02_研究方向/RD-20260618T105950Z-main-7FY3_双池轮动真实交易微观数据低滞后研究|7FY3 双池轮动真实交易微观数据低滞后研究]]
- 父方向：[[02_研究方向/RD-20260605T115651Z-main-EXE0_双池轮动执行与换仓模块|EXE0 双池轮动执行与换仓模块]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 来源文献或灵感：
- 产生的决策：
- 前置实验：[[04_实验记录/EX-20260619T010219Z-main-B5JS_V2 dry-run结果落盘证据契约|B5JS V2 dry-run结果落盘证据契约]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：  
拿到 B5JS 生成的 dry-run JSON 后，平台是否有只读门禁能判断它是“可审计观察证据”还是“可归因订单意图证据”。
我们原本预计：  
可以建立一个不连接 QMT、不访问数据库的解析器，输出 schema 门禁、观察门禁和订单意图门禁，避免把空订单 JSON 误判成策略有效。
实际看到：  
脚本、单测和样例门禁均已完成。完整订单意图样例通过三层门禁，`summary.json` 显示 `schema_pass_count=1`、`observation_pass_count=1`、`order_intent_pass_count=1`、`total_order_count=1`；`orders.csv` 保留了 `symbol=510300.XSHG` 和 `pindex=0`。
这说明：  
后续拿到真实 dry-run JSON 后，可以先用 G7S8 判断它是结构可审计、仅观察，还是有完整订单意图，避免直接把 dry-run 文件误写成策略有效性。
但还不能说明：  
即使门禁通过，也只说明 JSON 格式可进入后续观察整理，不能说明任何低滞后信号有效。
下一步要做：  
等待真实 QMT dry-run JSON；若出现真实订单意图，再新开外部观察实验，把 `orders.csv` 与 KFSQ/A22 触发日关联。

## 2. 研究背景

本实验属于 [[02_研究方向/RD-20260618T105950Z-main-7FY3_双池轮动真实交易微观数据低滞后研究|7FY3]]。B5JS 已经让 `run_v2_live.py --dry-run-once` 能显式落盘 JSON，但当前本机 `LIVE_TRADING_ROOT` 仍未配置，无法拿真实 dry-run 或成交日志。

如果后续拿到 JSON 后才临时写解析代码，会再次形成证据链断点。因此 G7S8 先补一个只读解析门禁：区分“结构可审计”“有观察事件”“有完整订单意图”三种不同证据等级。

## 3. 实验前假设

如果 dry-run JSON 解析门禁可用，则它应能稳定读取 B5JS 格式 JSON，输出 `summary.json`、`dry_run_json_gate.csv`、`orders.csv` 和 `records.csv`，并把空订单观察与真实订单意图区分开。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：脚本单测通过；样例 JSON 的 `schema_gate_pass=true`、`observation_gate_pass=true`、`order_intent_gate_pass=true`；缺字段样例在单测中失败。
- 交易行为：不连接 QMT、不提交真实委托、不调用回测；只读本地 JSON。
- 风险表现：空订单 JSON 不应通过 `order_intent_gate_pass`；缺字段 JSON 不应通过 `schema_gate_pass`。
- 分段表现：本次不评估收益、回撤、胜率或分段 alpha。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| B5JS JSON 契约 | 定义输入字段 | `EX-20260619T010219Z-main-B5JS` |
| 完整订单意图样例 | 正控：应通过 schema/observation/order_intent 三层门禁 | `${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260618T105950Z-main-7FY3/EX-20260619T011815Z-main-G7S8/sample_dry_run.json` |
| 空订单样例单测 | 负控：只能通过观察门禁，不能通过订单意图门禁 | `${LEGACY_QUANT_PLATFORM_ROOT}/src/tests/scripts/test_analyze_g7s8_live_dry_run_json_gate.py` |
| 缺字段样例单测 | 负控：不能通过 schema 门禁 | `${LEGACY_QUANT_PLATFORM_ROOT}/src/tests/scripts/test_analyze_g7s8_live_dry_run_json_gate.py` |

## 6. 竞争性解释

即使结果符合预期，也可能是：

- 合成样例通过不等于真实 QMT dry-run 一定字段完整。
- 有订单意图不等于有成交，也不等于滑点可接受。
- 本机仍缺 `LIVE_TRADING_ROOT`，所以 G7S8 不能替代真实观察流。

## 7. 证伪条件

出现以下情况，本假设不通过：

- 脚本不能解析 B5JS 规定的顶层字段。
- 空订单 JSON 被误判为 `order_intent_gate_pass=true`。
- 缺字段 JSON 被误判为 `schema_gate_pass=true`。
- 脚本需要连接数据库、QMT 或执行回测才可运行。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 不适用 | 本实验只解析 dry-run JSON，不生成交易信号 |
| 信号生成和成交价格不存在同 bar 泄漏 | 不适用 | 不评估收益或成交价格 |
| 股票池或 ETF 池不存在未来成分泄漏 | 不适用 | 不读取或修改股票池/ETF 池 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 不读取财务、宏观或估值数据 |
| Shadow 或观察信号未被当成默认交易信号 | 通过 | 脚本只输出门禁 CSV，不改策略配置 |

负控或错位检查：

- 本实验的负控是空订单与缺字段 JSON；收益负控留到真实观察实验。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 不适用 | 无策略参数 |
| 样本内、验证集、样本外划分清楚 | 不适用 | 无样本拟合 |
| 邻近参数敏感性合理 | 不适用 | 无连续参数 |
| 成本、滑点或换手扰动已检查 | 不适用 | 不评估收益 |
| 已做消融或负控 | 通过 | 单测覆盖空订单只过观察门禁、缺字段不通过 schema 门禁 |
| 未只报告最优结果 | 通过 | 记录合成样例与负控测试，不存在多结果挑选 |

证据等级：`L1`，工程解析门禁，不是策略有效性证据。

## 10. 子代理调用记录

适配判断：`不适合调用`

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：当前多代理工具只有在用户显式要求子代理/委派/并行 agent 时才允许 spawn，本轮没有该授权；主控：main；时间：2026-06-19T01:21:08Z
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-EXEMPT-20260619T011300Z-main-DRYJSON | 无 | SUBTASK-DRYRUN-JSON-GATE-EXEMPT | 无 | 2026-06-19T01:21:08Z | B5JS 实验记录；`${LEGACY_QUANT_PLATFORM_ROOT}/scripts/research` 样例脚本；`${LEGACY_QUANT_PLATFORM_ROOT}/src/tests/scripts` 测试样例 | 本实验记录；`${LEGACY_QUANT_PLATFORM_ROOT}/scripts/research/analyze_g7s8_live_dry_run_json_gate.py`; `${LEGACY_QUANT_PLATFORM_ROOT}/src/tests/scripts/test_analyze_g7s8_live_dry_run_json_gate.py` | `PYTHONPATH=src python3 -m pytest src/tests/scripts/test_analyze_g7s8_live_dry_run_json_gate.py -q`; `py_compile`; 样例 JSON 门禁 | 只判断 JSON 解析门禁，不判断策略收益或真实实盘有效性 | 合成样例不能替代真实 QMT dry-run | 主控复核输出，修正了 `pindex=0` 被空值化的问题并复测通过 | G7S8 通过工程门禁；只补齐外部观察入口，不改变 7FY3 park 状态 |

台账行：已同步 `01_台账/子代理调用台账.csv`。

## 11. 执行记录

### 平台配置

```text
${LEGACY_QUANT_PLATFORM_ROOT}/scripts/research/analyze_g7s8_live_dry_run_json_gate.py
${LEGACY_QUANT_PLATFORM_ROOT}/src/tests/scripts/test_analyze_g7s8_live_dry_run_json_gate.py
```

### 运行命令

```bash
cd '/mnt/e/量化平台_V1.4.0' && PYTHONPATH=src python3 -m pytest src/tests/scripts/test_analyze_g7s8_live_dry_run_json_gate.py -q
cd '/mnt/e/量化平台_V1.4.0' && PYTHONPATH=src python3 -m py_compile scripts/research/analyze_g7s8_live_dry_run_json_gate.py src/tests/scripts/test_analyze_g7s8_live_dry_run_json_gate.py
cd '/mnt/e/量化平台_V1.4.0' && PYTHONPATH=src python3 scripts/research/analyze_g7s8_live_dry_run_json_gate.py --input-json results/v2/research/RD-20260618T105950Z-main-7FY3/EX-20260619T011815Z-main-G7S8/sample_dry_run.json --output-dir results/v2/research/RD-20260618T105950Z-main-7FY3/EX-20260619T011815Z-main-G7S8 2>&1 | tee results/v2/research/RD-20260618T105950Z-main-7FY3/EX-20260619T011815Z-main-G7S8/run_g7s8_json_gate.log
```

### 可见进度与日志

- 是否过程可见：`是`
- 日志路径：`${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260618T105950Z-main-7FY3/EX-20260619T011815Z-main-G7S8/run_g7s8_json_gate.log`
- 查看进度命令：前台运行，无后台进度。
- 异常判断：任一单测失败、样例门禁未通过或脚本依赖 QMT/数据库，则实验不通过；发现 `pindex=0` 被空值化后已修复并复测。
- 后台回测豁免：不适用，前台运行脚本且不回测。

```text
后台回测豁免：不适用；本次不是回测，且脚本前台运行。
```

### 结果路径

```text
${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260618T105950Z-main-7FY3/EX-20260619T011815Z-main-G7S8/summary.json
${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260618T105950Z-main-7FY3/EX-20260619T011815Z-main-G7S8/dry_run_json_gate.csv
${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260618T105950Z-main-7FY3/EX-20260619T011815Z-main-G7S8/orders.csv
${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260618T105950Z-main-7FY3/EX-20260619T011815Z-main-G7S8/records.csv
${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260618T105950Z-main-7FY3/EX-20260619T011815Z-main-G7S8/run_g7s8_json_gate.log
```

## 12. 实际观察

| 指标 | 基准 | 本次 | 变化 | 解释 |
| --- | --- | --- | --- | --- |
| 脚本单测 | 无解析门禁测试 | `4 passed` | 改善 | 覆盖完整订单、空订单、缺字段和输出落盘 |
| schema 门禁 | 无 | `schema_pass_count=1` | 改善 | 样例 JSON 满足 B5JS 顶层字段 |
| observation 门禁 | 无 | `observation_pass_count=1` | 改善 | 样例含事件、记录和组合快照 |
| order intent 门禁 | 无 | `order_intent_pass_count=1` | 改善 | 样例含可归因订单意图 |
| 子账户归因 | 初版输出 `pindex=0` 被空值化 | 复测后 `pindex=0` 保留 | 改善 | 虚拟子账户字段可用于后续归因 |

## 13. 支持证据

- `${LEGACY_QUANT_PLATFORM_ROOT}/scripts/research/analyze_g7s8_live_dry_run_json_gate.py` 只读解析 JSON，不连接 QMT/数据库。
- `${LEGACY_QUANT_PLATFORM_ROOT}/src/tests/scripts/test_analyze_g7s8_live_dry_run_json_gate.py` 覆盖完整订单、空订单、缺字段和输出文件。
- 样例输出 `summary.json`：`input_file_count=1`、`schema_pass_count=1`、`observation_pass_count=1`、`order_intent_pass_count=1`、`total_order_count=1`。
- 样例 `orders.csv` 保留 `order_id=sample-dry-run-1`、`symbol=510300.XSHG`、`pindex=0`、`created_at=2026-06-19T09:31:00`。

## 14. 反对证据

- 输入仍是合成 JSON，不是真实 QMT dry-run。
- 没有成交、滑点、盘口或逐笔数据。
- 即使未来真实 JSON 通过 `order_intent_gate_pass`，也只说明有订单意图，不说明交易信号有效或可 production promote。

## 15. 偏差诊断

实验前预测基本成立。唯一新增发现是初版解析器用 `or` 处理字段时会把 `pindex=0` 当作空值，影响虚拟子账户归因；已新增 `_pick_first_any` 并在单测中断言 `pindex == "0"`，复测通过。

## 16. 研究判断

建议状态：`observe`

理由：G7S8 补齐了 B5JS 之后的解析门禁，未来真实 dry-run JSON 可以被稳定分层为 schema 证据、观察证据和订单意图证据。但当前仍没有真实 dry-run、成交或滑点，所以 7FY3 继续 `park`，不能改实盘、shadow 或 production promote。

## 17. 下一步

下一轮最值得做的是拿真实 QMT dry-run JSON 跑 G7S8：

```powershell
& 'C:\Python311\python.exe' src/run_v2_live.py --config configs/v2_portfolio_smallcap_etf_dual_pool_50_50.json --dry-run-once --force-events --output-json results/v2/live_dry_run/portfolio_latest_dry_run.json
python scripts/research/analyze_g7s8_live_dry_run_json_gate.py --input-json results/v2/live_dry_run/portfolio_latest_dry_run.json --output-dir results/v2/research/RD-20260618T105950Z-main-7FY3/<NEXT_EX_ID>
```

它能减少的不确定性是：真实 live runner 是否能产出可归因订单意图；如果能，再把 `orders.csv` 关联 KFSQ/A22 触发日，做外部观察验证。
