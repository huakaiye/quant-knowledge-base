---
type: 实验记录
ex_id: EX-20260607T192201Z-main-YA5R
rd_id: RD-20260605T133318Z-main-H6V3
status: completed
stage: formal_strict_pass_hard5_shadow_isolation
owner: main
created_at: 2026-06-07T19:22:01Z
updated_at: 2026-06-07T21:40:17Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 核心轮动风控诊断模块
decision_ids: [DEC-20260607T185223Z-main-HH4B]
lit_ids: []
idea_ids: []
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths:
  - ${QUANT_PLATFORM_ROOT}/configs/research/R010-A22/hard5_default_observe/EX-20260607T192201Z-main-YA5R/formal/
  - ${QUANT_PLATFORM_ROOT}/configs/research/R010-A22/hard5_default_observe/EX-20260607T192201Z-main-YA5R/guard/
result_paths:
  - ${QUANT_PLATFORM_ROOT}/results/v2/research/R010-A22/hard5_default_observe/EX-20260607T192201Z-main-YA5R/formal/
  - ${QUANT_PLATFORM_ROOT}/results/v2/research/R010-A22/hard5_default_observe/EX-20260607T192201Z-main-YA5R/logs/formal/
summary_paths:
  - ${QUANT_PLATFORM_ROOT}/results/v2/research/R010-A22/hard5_default_observe/EX-20260607T192201Z-main-YA5R/summary/formal/summary.json
quality_gate: formal_strict_12of12_all_pass_hard5_shadow_isolation
subagent_call_ids:
  - SUB-20260608T032000Z-main-A22OBS-MIN
  - SUB-20260608T054000Z-main-YA5R-VERIFY
subagent_exemption:
tags: [双池轮动, A22, hard5, observe, shadow, 默认关闭, 未来函数审计]
---

# A22默认关闭observe硬5路径隔离审计

## 关联链接

- 研究方向：[[02_研究方向/RD-20260605T133318Z-main-H6V3_双池轮动score过热拥挤机制模块|双池轮动 score 过热拥挤机制模块]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 上游 A22 等价：[[04_实验记录/EX-20260607T131209Z-main-A22N_A22原生字段等价审计预注册|A22N]]
- 上游 shadow 边界：[[04_实验记录/EX-20260607T154134Z-main-QTFV_A22原生forward shadow边界验证预注册|QTFV]]
- 上游静态门禁：[[04_实验记录/EX-20260607T190303Z-main-NR75_A22生产前默认关闭与未来函数静态门禁|NR75]]
- 当前观察决策：[[05_研究决策/DEC-20260607T185223Z-main-HH4B_A22原生forward shadow边界通过后观察决策|HH4B observe 决策]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：A22 作为默认关闭观察信号放进 hard5 默认路径时，是否只写观察日志，不影响买卖、持仓、净值和订单。

实验结果通过。四个分段的 `hard5_shadow_on` 与 `hard5_shadow_off` 最终权益、最大回撤、交易数、费用和五类交易产物 hash 全部一致；`hard5_shadow_off` 也 4/4 完全复现既有 A11 hard5 基准。严格汇总显示 `all_gates_pass=true`、`strict_failed=[]`，12 个门禁全部通过。

这说明：A22 可以在 hard5 默认路径下继续作为默认关闭 observe 信号运行，观察日志不会污染默认 hard5 交易结果。

但还不能说明：YA5R 没有批准 A22 cap70 替代 hard5，也没有批准生产切换。hard5 默认路径会先过滤高分目标，所以本轮 shadow 看到的是 post-hard5 final target；四段 shadow 记录都有，但 trigger 全为 0，主要证明工程隔离和日志边界，不证明 raw Top1 高分预算建议完整有效。

下一步：如果继续推进 A22，只能做真实 `${LIVE_TRADING_ROOT}` 配置后的只读 dry-run 门禁，或新 forward 样本观察日志审计；默认生产仍保留 hard5。

## 2. 研究背景

本实验属于 [[02_研究方向/RD-20260605T133318Z-main-H6V3_双池轮动score过热拥挤机制模块|H6V3 score 过热拥挤机制模块]]。上游 [[04_实验记录/EX-20260607T154134Z-main-QTFV_A22原生forward shadow边界验证预注册|QTFV]] 已证明 native A22 在 `max_score=9999 + conditional_hot_state` 路径下 live 可复现 A22N，shadow_on/off 不改变交易产物。[[04_实验记录/EX-20260607T190303Z-main-NR75_A22生产前默认关闭与未来函数静态门禁|NR75]] 又证明源码和非研究配置默认仍停在 hard5。

但 QTFV 不是 hard5 默认生产路径。YA5R 的作用是补一个更贴近默认策略的动态门禁：从 A11 hard5 四段配置派生，只打开 A22 shadow 观察，不打开 A22 live，也不打开 legacy A13。若 shadow_on/off 交易产物一致，才支持后续把 A22 作为 hard5 路径下默认关闭 observe 信号继续 dry-run。

## 3. 实验前假设

在 `max_score=5`、`score_hot_filter_mode=hard_cap` 的默认 hard5 路径下，`r010a22_hot_score_budget_shadow_enabled=true` 只会写观察日志，不会改变 targets、weights、orders、trades、equity、positions 或 subportfolio equity。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：`all_gates_pass=true`，8 个 formal run 都存在 summary、run.log、manifest，且 manifest 中 config sha 与实际配置一致。
- 交易行为：四段 `hard5_shadow_on` 与 `hard5_shadow_off` 的 `orders.json`、`trades.csv`、`equity_curve.csv`、`positions.csv`、`subportfolio_equity.csv` hash 全一致；`orders_changed_by_shadow=0`。
- 风险表现：本轮不比较收益优劣，只要求 shadow_on/off 的 final、MDD、交易数、费用与交易产物一致；`hard5_shadow_off` 应复现 A11 hard5 既有基线。
- 分段表现：2020_2021、2022_2023、2024、2025_20260519 四段都应通过；2024 可能没有 A22 trigger，但仍应有 shadow 观察日志。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| A11 hard5 既有四段配置 | 生成 YA5R hard5 shadow_on/off 的来源 | `${QUANT_PLATFORM_ROOT}/configs/research/R010-A11/score_hot_backtest/r010a11_score_hot_hard5_tiered_v2_<segment>.json` |
| A11 hard5 既有四段结果 | 检查派生 shadow_off 是否复现默认 hard5 行为 | `${QUANT_PLATFORM_ROOT}/results/v2/research/R010-A11/score_hot_backtest/hard5/<segment>/` |
| YA5R hard5_shadow_off | A22 shadow 关闭动态对照 | `${QUANT_PLATFORM_ROOT}/configs/research/R010-A22/hard5_default_observe/EX-20260607T192201Z-main-YA5R/formal/hard5_shadow_off/` |
| YA5R hard5_shadow_on | A22 shadow-only 观察组 | `${QUANT_PLATFORM_ROOT}/configs/research/R010-A22/hard5_default_observe/EX-20260607T192201Z-main-YA5R/formal/hard5_shadow_on/` |
| YA5R double_on_guard | 静态互斥负控，只生成不运行 | `${QUANT_PLATFORM_ROOT}/configs/research/R010-A22/hard5_default_observe/EX-20260607T192201Z-main-YA5R/guard/` |

## 6. 竞争性解释

即使结果符合预期，也可能是：

- hard5 已先过滤掉 `score>=5` 目标，A22 shadow 日志看到的是 post-hard5 final target，不是 raw Top1 高分候选。因此本轮只证明 hard5 默认路径隔离，不证明 A22 对 raw 高分候选的完整预算建议。
- shadow_on/off 一致可能只是因为 shadow 函数没有触发预算建议，而不是因为所有潜在订单路径都被覆盖。
- 本轮仍是回测平台 formal/dry-run，不是 `${LIVE_TRADING_ROOT}` 真实部署包或券商 dry-run。

## 7. 证伪条件

出现以下情况，本假设不通过：

- 任一 formal 配置中 `max_score != 5`、`score_hot_filter_mode != hard_cap`、A13 live 开启或 A22 live 开启。
- `hard5_shadow_on` 与 `hard5_shadow_off` 任一分段的 orders/trades/equity/positions/subportfolio hash 不一致。
- 任一 shadow 日志出现 `orders_changed_by_shadow=true`。
- 任一分段没有 A22 shadow 日志，或 shadow 日志中 `signal_date` 晚于 observe/trade 日期。
- double-on guard 未能静态识别 A13 与 A22 live 同时开启。
- 回测 run.log 出现 traceback/error，或 manifest config sha 与实际配置不一致。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 通过 | 四段 shadow 日志 `date_violation_count=0`，`shadow_date_order_ok_4of4=true` |
| 信号生成和成交价格不存在同 bar 泄漏 | 通过本轮隔离要求 | 本轮不新增交易信号；shadow_on/off 五类交易产物 hash 4/4 一致 |
| 股票池或 ETF 池不存在未来成分泄漏 | 未新增风险 | 复用 A11 hard5 四段配置，不新增 ETF 池 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | A22 score-cap 不新增财务、宏观或估值数据 |
| Shadow 或观察信号未被当成默认交易信号 | 通过 | `shadow_on_orders_changed=0`，A13/A22 live 指纹 8/8 缺失 |

负控或错位检查：

- `hard5_shadow_off` 是 shadow 关闭对照。
- `hard5_shadow_on` 只打开 `r010a22_hot_score_budget_shadow_enabled`，不打开 A22 live。
- `double_on_guard` 只生成不运行，四段均静态检出 A13 与 A22 live 双开。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | 本轮只有两个 formal 变体：shadow_off、shadow_on；不调 cap、score 阈值或分段 |
| 样本内、验证集、样本外划分清楚 | 通过 | 固定四段：2020_2021、2022_2023、2024、2025_20260519；本轮不是收益优化 |
| 邻近参数敏感性合理 | 不适用 | 不做参数寻优 |
| 成本、滑点或换手扰动已检查 | 不适用 | 本轮要求同一配置开关前后交易产物完全一致，成本不应变化 |
| 已做消融或负控 | 通过 | shadow_off 对照与 double-on guard |
| 未只报告最优结果 | 通过 | 汇总 8 个 formal run 和 4 个 guard，不筛选分段 |

证据等级：`L2_engineering_hard5_shadow_isolation`

## 10. 子代理调用记录

适配判断：`适合调用`

调用状态：`called`

子代理豁免：

```text
不适用。本轮已调用子代理；子代理只做路径、字段、门禁和结果自洽核对，最终预注册、脚本实现、未来函数审计和研究判断由主控负责。
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-20260608T032000Z-main-A22OBS-MIN | Kuhn | SUBTASK-A22OBS-MIN | gpt-5.3-codex-spark | 2026-06-07T19:20:00Z | A22N/QTFV/NR75 脚本、summary 和 hard5 路径清单 | 无 | 无 | 返回 A22 默认关闭 observe/dry-run 最小字段、shadow_on/off hash 门禁、double-on guard 和日期顺序检查建议 | 只能做路径和字段清单，不能判断生产放行；hard5 路径可能只能观察 post-hard5 target | 主控采纳最小门禁，并补充 hard5 路径的证据边界 | 帮助限定 YA5R 的 strict gates，不改变 HH4B observe 决策 |
| SUB-20260608T054000Z-main-YA5R-VERIFY | Plato | SUBTASK-YA5R-VERIFY | gpt-5.3-codex-spark | 2026-06-07T21:40:00Z | YA5R summary.json、segment_metrics、shadow_on_off_hash、hard5_baseline_reproduction、guard_audit | 无 | 无 | 确认 summary 与四张 CSV 自洽，8 行 formal 完整，四段 hash/基准/guard 全通过 | 只读复核，不做 production promote 或未来函数最终裁决 | 主控采纳为结果自洽复核，并保留 production 边界 | 支持 YA5R completed 收口，不改变 HH4B observe 决策 |

台账行：已同步 `01_台账/子代理调用台账.csv`。

## 11. 执行记录

### 平台配置

```text
生成脚本：${QUANT_PLATFORM_ROOT}/scripts/research/generate_ya5r_a22_hard5_observe_configs.py
运行脚本：${QUANT_PLATFORM_ROOT}/scripts/research/run_ya5r_a22_hard5_observe.sh
汇总脚本：${QUANT_PLATFORM_ROOT}/scripts/research/summarize_ya5r_a22_hard5_observe.py
配置根：${QUANT_PLATFORM_ROOT}/configs/research/R010-A22/hard5_default_observe/EX-20260607T192201Z-main-YA5R/
```

### 运行命令

```bash
cd '${QUANT_PLATFORM_ROOT}'
PYTHONIOENCODING=utf-8 python3 -m py_compile scripts/research/generate_ya5r_a22_hard5_observe_configs.py scripts/research/summarize_ya5r_a22_hard5_observe.py
PYTHONUNBUFFERED=1 PYTHONIOENCODING=utf-8 python3 scripts/research/generate_ya5r_a22_hard5_observe_configs.py
DRY_RUN=1 bash scripts/research/run_ya5r_a22_hard5_observe.sh
STAMP=20260607T193000Z VARIANTS='hard5_shadow_off' SEGMENTS='2020_2021 2022_2023 2024 2025_20260519' PYTHONIOENCODING=utf-8 bash scripts/research/run_ya5r_a22_hard5_observe.sh
STAMP=20260607T193000Z VARIANTS='hard5_shadow_on' SEGMENTS='2020_2021 2022_2023 2024 2025_20260519' PYTHONIOENCODING=utf-8 bash scripts/research/run_ya5r_a22_hard5_observe.sh
PYTHONUNBUFFERED=1 PYTHONIOENCODING=utf-8 python3 scripts/research/summarize_ya5r_a22_hard5_observe.py --strict
```

实际执行中，为避免长段超时，2022_2023 的 `hard5_shadow_on` 和 2025_20260519 的 `hard5_shadow_on` 曾按单变体单分段重新前台执行；最终 8 个 formal run 均有 `exit_status=0`、run.log 和 manifest。

### 可见进度与日志

- 是否过程可见：`是`
- 日志路径：`${QUANT_PLATFORM_ROOT}/results/v2/research/R010-A22/hard5_default_observe/EX-20260607T192201Z-main-YA5R/logs/formal/20260607T193000Z/`
- 查看进度命令：`Get-Content ${QUANT_PLATFORM_ROOT}/results/v2/research/R010-A22/hard5_default_observe/EX-20260607T192201Z-main-YA5R/logs/formal/20260607T193000Z/<variant>_<segment>.run.log -Tail 80`
- 异常判断：`run_logs_ok_8of8=true`，`manifest_config_sha_match_8of8=true`。
- 后台回测豁免：

```text
不适用。本轮前台可见运行，未后台执行。
```

### 结果路径

```text
${QUANT_PLATFORM_ROOT}/results/v2/research/R010-A22/hard5_default_observe/EX-20260607T192201Z-main-YA5R/formal/
${QUANT_PLATFORM_ROOT}/results/v2/research/R010-A22/hard5_default_observe/EX-20260607T192201Z-main-YA5R/summary/formal/summary.json
```

## 12. 实际观察

### Strict gates

| 门禁 | 结果 |
| --- | --- |
| all_runs_present_8of8 | true |
| config_fields_ok_8of8 | true |
| run_logs_ok_8of8 | true |
| manifest_config_sha_match_8of8 | true |
| a13_a22_live_fingerprints_absent_8of8 | true |
| shadow_on_off_trade_outputs_match_4of4 | true |
| shadow_orders_changed_false_4of4 | true |
| shadow_logs_visible_4of4 | true |
| shadow_filter_mode_hard_cap_visible_4of4 | true |
| shadow_date_order_ok_4of4 | true |
| hard5_shadow_off_matches_a11_4of4 | true |
| double_on_guard_detected_4of4 | true |

`all_gates_pass=true`，`strict_failed=[]`。

### 分段结果

| 分段 | final | MDD | 交易数 | shadow 记录 | trigger | orders_changed | skip_reason |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| 2020_2021 | 225079.60 | -20.6780% | 561 | 486 | 0 | 0 | `no_hot_score_target=486` |
| 2022_2023 | 131214.63 | -27.1265% | 454 | 484 | 0 | 0 | `no_hot_score_target=484` |
| 2024 | 167005.22 | -26.9936% | 281 | 242 | 0 | 0 | `no_hot_score_target=240; action_scope=2` |
| 2025_20260519 | 317973.61 | -16.5670% | 464 | 330 | 0 | 0 | `no_hot_score_target=330` |

四段 `hard5_shadow_on` 与 `hard5_shadow_off` 的 final/MDD/交易数/费用差异全部为 0；orders/trades/equity/positions/subportfolio 五类 hash 全部一致。四段 `hard5_shadow_off` 与 A11 hard5 基准的 final/MDD/交易数/费用差异也全部为 0，五类 hash 全部一致。

## 13. 支持证据

- `summary.json`：`expected_rows=8`、`completed_rows=8`、`all_gates_pass=true`、`strict_failed=[]`。
- `shadow_on_off_hash.csv`：四段 final/MDD/trades/fee diff 全为 0，五类 hash 全为 true，`date_order_ok=true`。
- `hard5_baseline_reproduction.csv`：四段 `hard5_shadow_off` 完全复现 A11 hard5 baseline。
- `guard_audit.csv`：四段 `double_on_guard` 均检测到 A13 live 与 A22 live 双开。
- Plato 子代理复核：summary 与四张 CSV 自洽，未发现阻断问题。

## 14. 反对证据

- hard5 路径下 A22 shadow 观察 post-hard5 target，不是 raw Top1 高分候选完整预算建议。
- 四段 `shadow_on_triggers=0`，因此本轮没有覆盖 A22 预算实际改权重的动态路径，只覆盖默认 hard5 路径下 shadow-only 不改交易产物。
- 本轮不检查 `${LIVE_TRADING_ROOT}` 真实实盘系统。

## 15. 偏差诊断

主要偏差来自验证边界而非结果失败。YA5R 的核心价值是默认 hard5 路径隔离：它证明打开 A22 shadow 记录不会污染 hard5 交易结果。由于 hard5 会先把高分目标过滤掉，日志中出现的 `no_hot_score_target` 是预期现象；这也解释了为什么 trigger 为 0 不能被误读为 A22 cap70 无效。

运行层面存在一次长段组合命令超时后的单段重跑，但 strict summary 逐段检查 run.log、manifest、config sha 和结果 hash，最终 8 个 formal run 均完整。

## 16. 研究判断

建议状态：`observe`

理由：YA5R 通过 hard5 默认路径 dynamic shadow 隔离门禁，补齐 NR75 静态门禁之后的关键工程证据。它支持 A22 以 `r010a22_hot_score_budget_*` 原生字段继续默认关闭观察、实盘系统 dry-run 或新 forward 样本门禁。

不新增研究决策卡。本轮不改变 HH4B 的 observe 决策，也不推动 production promote；默认策略仍保留 `hard_cap/max_score=5`。

## 17. 下一步

- 若继续 A22 工程推进，优先做 `${LIVE_TRADING_ROOT}` 配置后的只读 dry-run 门禁，检查实盘系统是否也保持默认关闭、路径可移植、日志可见且不发真实订单。
- 若继续研究收益有效性，必须另开新 forward 样本门禁或生产前观察实验，不能把 YA5R 的 shadow 隔离结果当作收益结论。
- 不继续扩 A23 换手约束，也不把 YA5R 作为默认 hard5 切换依据。
