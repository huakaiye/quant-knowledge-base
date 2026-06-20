---
type: 实验记录
ex_id: EX-20260619T040913Z-main-8SH4
rd_id: RD-20260605T133318Z-main-H6V3
status: completed
stage: engineering_observation_gate_negative_control_passed_not_strategy_validation
owner: main
created_at: 2026-06-19T04:09:13Z
updated_at: 2026-06-19T12:15:00+08:00
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 核心轮动风控诊断模块
decision_ids: []
lit_ids: []
idea_ids:
  - MECH-20260619T025934Z-main-DQUM
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths:
  - 不适用；只读解析 dry-run JSON 与状态 CSV
result_paths:
  - results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T040913Z-main-8SH4/
summary_paths:
  - results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T040913Z-main-8SH4/summary.json
quality_gate: engineering_gate_passed_negative_control_no_strategy_validation
subagent_call_ids:
  - SUB-EXEMPT-20260619T041000Z-main-8SH4-GATE
subagent_exemption: 当前可用子代理工具的使用规则要求用户明确要求子代理才可 spawn；本轮主控执行并登记豁免。
tags: [双池轮动, hard5, 反弹修复, dry-run, 观察门禁, 工程证据]
---

# hard5修复误杀dry-run观察门禁

## 关联链接

- 研究方向：[[02_研究方向/RD-20260605T133318Z-main-H6V3_双池轮动score过热拥挤机制模块|双池轮动 score 过热拥挤机制模块]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 来源机制：[[07_因子数据灵感/03_机制/MECH-20260619T025934Z-main-DQUM_hard5过热概率与反弹修复状态框架|hard5 过热概率与反弹修复状态框架]]
- 前置真实路径实验：[[04_实验记录/EX-20260619T035511Z-main-96SF_hard5真实持仓修复误杀路径索引只读面板|96SF hard5 真实持仓修复误杀路径索引]]
- dry-run 前置链路：[[04_实验记录/EX-20260619T011815Z-main-G7S8_V2 dry-run JSON证据解析门禁|G7S8]]；[[04_实验记录/EX-20260619T014937Z-main-96B8_B5JS G7S8 48VR端到端链路预检|96B8]]；[[04_实验记录/EX-20260619T020248Z-main-3F8Q_QMT dry-run真实采集前置检查|3F8Q]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：未来拿到真实 QMT dry-run JSON 后，我们能不能把订单和 hard5 修复状态关联起来，专门识别 `held_repair`、`rebuy_repair`、`new_buy_repair` 和 `chase_hot`。  
我们原本预计：现有 G7S8 样例 JSON 应能通过订单意图门禁；96SF 的真实路径事件面板应能作为状态源读入；但样例订单不是 hard5 修复事件，所以不应被误匹配。  
实际看到：JSON schema、订单意图和状态源三层都通过；1 条样例订单、178 条 96SF 状态源，匹配数为 0，状态为 `no_repair_order_match`。  
这说明：观察链路已经能防止把无关 dry-run 订单误归因为 hard5 修复误杀。  
但还不能说明：真实实盘中存在有效 `held_repair` 样本，也不能说明续持例外、cap30 修复预算或任何 hard5 修改有效。  
下一步要做：等 Windows + Python 3.11 + 可见 QMT userdata 环境生成真实 dry-run JSON 后，用本门禁重跑；只有真实观察流累计到足够 `held_repair` 样本，才新开外部验证。

## 2. 研究背景

[[04_实验记录/EX-20260619T035511Z-main-96SF_hard5真实持仓修复误杀路径索引只读面板|96SF]] 已经把历史 hard5 路径里的修复误杀问题压到很窄：真实 `held_repair` 只有 2 个事件，H10 相对 hard5 实际路径平均 `-11.80pp`，不能支持 hold-only 续持例外。当前还能继续推进的不是再扫日频阈值，而是把未来真实 dry-run 或成交日志接入观察链路。

本实验新增平台脚本：

```text
scripts/research/analyze_8sh4_hard5_repair_dry_run_observation_gate.py
src/tests/scripts/test_analyze_8sh4_hard5_repair_dry_run_observation_gate.py
```

它复用 G7S8 的 JSON 解析，额外读取 hard5 修复状态 CSV，并输出订单与修复状态的关联结果。

## 3. 实验前假设

如果 hard5 修复误杀后续只能依赖真实观察流推进，那么平台应先具备一个只读门禁：能读真实 dry-run JSON，能读 96SF 或未来实盘观察状态源，并且不会把无关订单误匹配成 `held_repair`。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：G7S8 `schema_gate_pass_all=true`，`order_intent_gate_pass_any=true`，8SH4 `state_gate_pass=true`。
- 交易行为：样例 JSON 有 1 条订单，但由于它不是 96SF 状态源对应日期和标的，`match_count=0`。
- 风险表现：不会产生伪造的 `held_repair` 匹配。
- 分段表现：本实验不做历史分段收益，只做工程负控。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| G7S8 样例 JSON | 验证 JSON schema 与订单意图解析 | `results/v2/research/RD-20260618T105950Z-main-7FY3/EX-20260619T011815Z-main-G7S8/sample_dry_run.json` |
| 96SF 真实路径事件面板 | 作为 hard5 修复状态源真实格式 | `results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T035511Z-main-96SF/hard5_truepath_repair_index/truepath_event_panel.csv` |
| 单元测试正控 | 验证同日同标的 `held_repair` 能匹配 | `src/tests/scripts/test_analyze_8sh4_hard5_repair_dry_run_observation_gate.py` |
| 样例负控 | 验证无关订单不会误匹配 | 本实验主运行 |

## 6. 竞争性解释

即使结果符合预期，也可能是：

- 这只是工程链路通过，不代表真实 QMT JSON 会包含足够字段。
- 96SF 面板是历史回测路径，不是真实 dry-run 当日状态。
- 样例 JSON 是合成样例，不能代表真实订单、撤单、成交或滑点生命周期。
- 没有匹配只能证明无误匹配，不能证明未来有有效 `held_repair`。

## 7. 证伪条件

出现以下情况，本假设不通过：

- G7S8 schema 或订单意图门禁失败。
- 96SF 状态源无法读入或无法识别显式 `rule_*` 规则。
- 样例 JSON 被误匹配为 hard5 修复事件。
- 单元测试不能覆盖正控匹配、负控不匹配和缺状态源失败。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 通过但仅限工程门禁 | 脚本只读 dry-run JSON 的 `current_dt/created_at` 与状态 CSV 的 `trade_date`，不生成交易信号 |
| 信号生成和成交价格不存在同 bar 泄漏 | 不适用 | 不计算收益、不运行回测、不撮合成交 |
| 股票池或 ETF 池不存在未来成分泄漏 | 不适用 | 不构造股票池或 ETF 池 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 不读取财务、宏观或估值数据 |
| Shadow 或观察信号未被当成默认交易信号 | 通过 | 结果明确标记 `strategy_validation=false`，不改变默认 hard5 |

负控或错位检查：

- 主运行使用 G7S8 样例订单对 96SF 真实格式状态源，预期 `match_count=0`；结果通过。
- 单元测试包含 symbol mismatch 负控，`--expect-no-match` 返回 0。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | 只有 `window_days=0` 和显式状态分类，未扫阈值 |
| 样本内、验证集、样本外划分清楚 | 不适用 | 工程门禁，不做收益估计 |
| 邻近参数敏感性合理 | 不适用 | 不做策略参数 |
| 成本、滑点或换手扰动已检查 | 不适用 | 不做交易绩效 |
| 已做消融或负控 | 通过 | 样例负控和单元测试负控 |
| 未只报告最优结果 | 通过 | 本实验没有优化目标，报告唯一主运行 |

证据等级：`L1_engineering_gate`。只证明链路可用和负控不误匹配，不支持策略升级。

## 10. 子代理调用记录

适配判断：`适合调用，但当前工具规则不允许`

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：当前可用子代理工具的使用规则要求用户明确要求子代理才可 spawn；本轮主控执行并登记豁免。；主控：Codex；时间：2026-06-19T04:10:00Z
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-EXEMPT-20260619T041000Z-main-8SH4-GATE | 无 | SUBTASK-HARD5-REPAIR-DRYRUN-GATE | 无 | 2026-06-19T04:10:00Z | H6V3、MECH-DQUM、96SF、G7S8、96B8、3F8Q、平台脚本与测试 | 本实验、平台 8SH4 脚本和测试 | py_compile、pytest、8SH4 样例负控运行 | 只判断观察门禁，不判断策略有效 | 无真实 QMT JSON；样例 JSON 为合成样例 | 主控复核 summary、测试和负控结果 | 支持下一步等待真实 dry-run JSON，不改变 hard5 |

台账行：已同步 `01_台账/子代理调用台账.csv`。

## 11. 执行记录

### 平台配置

```text
不适用；只读解析 dry-run JSON 与状态 CSV。
```

### 运行命令

```bash
wsl -- bash -lc "cd '/mnt/e/量化平台_V1.4.0' && mkdir -p 'results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T040913Z-main-8SH4' && PYTHONPATH=src PYTHONUNBUFFERED=1 python3 scripts/research/analyze_8sh4_hard5_repair_dry_run_observation_gate.py --input-json results/v2/research/RD-20260618T105950Z-main-7FY3/EX-20260619T011815Z-main-G7S8/sample_dry_run.json --state-csv results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T035511Z-main-96SF/hard5_truepath_repair_index/truepath_event_panel.csv --output-dir results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T040913Z-main-8SH4 --require-order-intent --require-state --expect-no-match 2>&1 | tee 'results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T040913Z-main-8SH4/run_8sh4_observation_gate.log'"
```

### 可见进度与日志

- 是否过程可见：是。
- 日志路径：`results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T040913Z-main-8SH4/run_8sh4_observation_gate.log`
- 查看进度命令：`cat results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T040913Z-main-8SH4/run_8sh4_observation_gate.log`
- 异常判断：退出码非 0、`schema_gate_pass_all=false`、`state_gate_pass=false` 或 `--expect-no-match` 下 `match_count>0` 均视为失败。
- 后台回测豁免：无，前台可见运行。

### 结果路径

```text
results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T040913Z-main-8SH4/summary.json
results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T040913Z-main-8SH4/g7s8/
results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T040913Z-main-8SH4/repair_state_rows.csv
results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T040913Z-main-8SH4/repair_order_matches.csv
results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T040913Z-main-8SH4/unmatched_orders.csv
results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T040913Z-main-8SH4/run_8sh4_observation_gate.log
```

### 验证命令

```bash
wsl -- bash -lc "cd '/mnt/e/量化平台_V1.4.0' && PYTHONPATH=src python3 -m py_compile scripts/research/analyze_8sh4_hard5_repair_dry_run_observation_gate.py && PYTHONPATH=src python3 -m pytest -q src/tests/scripts/test_analyze_8sh4_hard5_repair_dry_run_observation_gate.py src/tests/scripts/test_analyze_g7s8_live_dry_run_json_gate.py src/tests/scripts/test_analyze_48vr_dry_run_order_signal_join.py src/tests/scripts/test_run_7fy3_dry_run_evidence_chain.py"
```

结果：`16 passed in 0.76s`。

## 12. 实际观察

| 指标 | 基准 | 本次 | 变化 | 解释 |
| --- | --- | --- | --- | --- |
| schema_gate_pass_all | 期望 true | true | 通过 | JSON schema 可读 |
| order_intent_gate_pass_any | 期望 true | true | 通过 | 样例 JSON 有 1 条订单意图 |
| state_gate_pass | 期望 true | true | 通过 | 96SF 状态源 178 行可读 |
| order_count | 1 | 1 | 符合 | 样例订单保留 |
| state_row_count | 178 | 178 | 符合 | 读取 96SF 事件面板 |
| class_counts | 参考 96SF 显式规则 | `held_repair=2`、`rebuy_repair=1`、`new_buy_repair=51`、`chase_hot=124` | 基本对齐 | 主类按显式规则优先；多规则重叠只记一个主类 |
| match_count | 期望 0 | 0 | 负控通过 | 样例订单未被误匹配为修复误杀 |
| repair_match_gate_pass | 期望 false | false | 符合 | 没有真实 held/rebuy 修复订单 |

## 13. 支持证据

- 平台脚本 `analyze_8sh4_hard5_repair_dry_run_observation_gate.py` 已通过 `py_compile`。
- 8SH4、G7S8、48VR、96B8 合计 16 个单元测试通过。
- 主运行输出 `status=no_repair_order_match`、`match_count=0`，符合负控预期。
- 输出保留 G7S8 子目录、状态行、匹配行、未匹配订单和总摘要，后续真实 JSON 可复用同一链路。

## 14. 反对证据

- 本实验没有真实 QMT dry-run JSON；输入 JSON 是 G7S8 合成样例。
- 当前本机 `${LIVE_TRADING_ROOT}` 未配置，3F8Q 也显示 WSL 环境缺 Windows、Python 3.11 和可见 QMT 路径。
- `match_count=0` 不能说明没有误杀，只说明这份样例不会误匹配。
- 96SF 历史结论仍然有效：真实历史 `held_repair` 仅 2 个且 H10 均负。

## 15. 偏差诊断

实验前预测和实际结果一致。唯一需要注意的是，8SH4 的 `class_counts` 是观察门禁主类统计，用于检查状态 CSV 能否被读入和分类；它不是新的收益面板，也不能替代 96SF 的规则收益摘要。

## 16. 研究判断

建议状态：`observe_engineering_gate_only`

理由：8SH4 补齐了 hard5 修复误杀方向下一步所需的工程入口，但没有提供任何新的收益证据。当前 hard5 修复放行、cap30 修复预算和 hold-only 续持例外仍暂停。

## 17. 下一步

下一轮最值得做的是在 Windows + Python 3.11 + 可见 QMT userdata 环境生成真实 dry-run JSON，然后运行：

```text
B5JS --output-json -> 8SH4 hard5 repair observation gate
```

如果真实观察流中 `held_repair` H10 可标注达到至少 20 行且不少于 5 个 episode，再新开外部验证实验；否则继续只做观察样本积累。
