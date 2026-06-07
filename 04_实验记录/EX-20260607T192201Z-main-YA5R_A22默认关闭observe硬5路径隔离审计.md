---
type: 实验记录
ex_id: EX-20260607T192201Z-main-YA5R
rd_id: RD-20260605T133318Z-main-H6V3
status: active
stage: preregistered_pending_run
owner: main
created_at: 2026-06-07T19:22:01Z
updated_at: 2026-06-07T19:25:00Z
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
quality_gate: preregistered_strict_8run_shadow_isolation
subagent_call_ids:
  - SUB-20260608T032000Z-main-A22OBS-MIN
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

我们原本预计：`hard5_shadow_on` 和 `hard5_shadow_off` 四个分段的交易产物应完全一致；`hard5_shadow_on` 应能稳定写出 A22 shadow 日志，并且 `signal_date <= observe_date <= trade_date` 或至少不出现 `signal_date` 晚于观察/交易日。

实际看到：待执行。

这说明：待执行。

但还不能说明：即使通过，也只说明 hard5 默认路径的 shadow-only 工程隔离成立；不能证明 A22 cap70 应替代 hard5，也不能替代真实实盘系统 dry-run。

下一步要做：先生成 2 个 formal 变体 x 4 个分段的配置，执行可见 WSL 回测并汇总 strict gates。

## 2. 研究背景

本实验属于 [[02_研究方向/RD-20260605T133318Z-main-H6V3_双池轮动score过热拥挤机制模块|H6V3 score 过热拥挤机制模块]]。上游 [[04_实验记录/EX-20260607T154134Z-main-QTFV_A22原生forward shadow边界验证预注册|QTFV]] 已证明 native A22 在 `max_score=9999 + conditional_hot_state` 路径下 live 可复现 A22N，shadow_on/off 不改变交易产物。[[04_实验记录/EX-20260607T190303Z-main-NR75_A22生产前默认关闭与未来函数静态门禁|NR75]] 又证明源码和非研究配置默认仍停在 hard5。

但 QTFV 不是 hard5 默认生产路径。YA5R 的作用是补一个更贴近默认策略的动态门禁：从 A11 hard5 四段配置派生，只打开 A22 shadow 观察，不打开 A22 live，也不打开 legacy A13。若 shadow_on/off 交易产物一致，才支持后续把 A22 作为 hard5 路径下默认关闭 observe 信号继续 dry-run。

## 3. 实验前假设

在 `max_score=5`、`score_hot_filter_mode=hard_cap` 的默认 hard5 路径下，`r010a22_hot_score_budget_shadow_enabled=true` 只会写观察日志，不会改变 targets、weights、orders、trades、equity、positions 或 subportfolio equity。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：`all_gates_pass=true`，8 个 formal run 都存在 summary、run.log、manifest，且 manifest 中 config sha 与实际配置一致。
- 交易行为：四段 `hard5_shadow_on` 与 `hard5_shadow_off` 的 `orders.json`、`trades.csv`、`equity_curve.csv`、`positions.csv`、`subportfolio_equity.csv` hash 全一致；`orders_changed_by_shadow=0`。
- 风险表现：本轮不比较收益优劣，只要求 shadow_on/off 的 final、MDD、交易数、费用与交易产物一致；`hard5_shadow_off` 应尽量复现 A11 hard5 既有基线。
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
- A11 既有 hard5 结果如果与 YA5R shadow_off 不一致，可能来自平台代码漂移或旧结果时间差，需要单独解释，不能简单归因到 A22。
- 本轮仍是回测平台 dry-run/formal，不是 `${LIVE_TRADING_ROOT}` 真实部署包或券商 dry-run。

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
| 数据时间戳只使用当时可得信息 | 待检查 | 汇总脚本检查 A22 shadow payload 中 `signal_date`、`observe_date`、`trade_date` 顺序 |
| 信号生成和成交价格不存在同 bar 泄漏 | 待检查 | 本轮不新增交易信号；仅检查 shadow 不改变交易产物 |
| 股票池或 ETF 池不存在未来成分泄漏 | 待检查 | 复用 A11 hard5 四段配置，不新增 ETF 池 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | A22 score-cap 不新增财务、宏观或估值数据 |
| Shadow 或观察信号未被当成默认交易信号 | 待检查 | shadow_on/off 交易产物 hash 和 `orders_changed_by_shadow` 严格比对 |

负控或错位检查：

- `hard5_shadow_off` 是 shadow 关闭对照。
- `hard5_shadow_on` 只打开 `r010a22_hot_score_budget_shadow_enabled`，不打开 A22 live。
- `double_on_guard` 只生成不运行，检查 A13/A22 live 双开能否被静态识别。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | 本轮只有两个 formal 变体：shadow_off、shadow_on；不调 cap、score 阈值或分段 |
| 样本内、验证集、样本外划分清楚 | 通过 | 固定四段：2020_2021、2022_2023、2024、2025_20260519；本轮不是收益优化 |
| 邻近参数敏感性合理 | 不适用 | 不做参数寻优 |
| 成本、滑点或换手扰动已检查 | 不适用 | 本轮要求同一配置开关前后交易产物完全一致，成本不应变化 |
| 已做消融或负控 | 待检查 | shadow_off 对照与 double-on guard |
| 未只报告最优结果 | 待检查 | 汇总 8 个 formal run 和 4 个 guard，不筛选分段 |

证据等级：`L2_engineering_hard5_shadow_isolation_preregistered`

## 10. 子代理调用记录

适配判断：`适合调用`

调用状态：`called`

子代理豁免：

```text
不适用。本轮已调用子代理；子代理只做路径、字段和最小门禁清单，最终预注册、脚本实现、未来函数审计和研究判断由主控负责。
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-20260608T032000Z-main-A22OBS-MIN | Kuhn | SUBTASK-A22OBS-MIN | gpt-5.3-codex-spark | 2026-06-07T19:20:00Z | A22N/QTFV/NR75 脚本、summary 和 hard5 路径清单 | 无 | 无 | 返回 A22 默认关闭 observe/dry-run 最小字段、shadow_on/off hash 门禁、double-on guard 和日期顺序检查建议 | 只能做路径和字段清单，不能判断生产放行；hard5 路径可能只能观察 post-hard5 target | 主控采纳最小门禁，并补充 hard5 路径的证据边界 | 帮助限定 YA5R 的 strict gates，不改变 HH4B observe 决策 |

台账行：待同步 `01_台账/子代理调用台账.csv`。

## 11. 执行记录

### 平台配置

```text
计划生成脚本：${QUANT_PLATFORM_ROOT}/scripts/research/generate_ya5r_a22_hard5_observe_configs.py
计划运行脚本：${QUANT_PLATFORM_ROOT}/scripts/research/run_ya5r_a22_hard5_observe.sh
计划汇总脚本：${QUANT_PLATFORM_ROOT}/scripts/research/summarize_ya5r_a22_hard5_observe.py
配置根：${QUANT_PLATFORM_ROOT}/configs/research/R010-A22/hard5_default_observe/EX-20260607T192201Z-main-YA5R/
```

### 运行命令

```bash
cd '${QUANT_PLATFORM_ROOT}'
PYTHONIOENCODING=utf-8 python3 -m py_compile scripts/research/generate_ya5r_a22_hard5_observe_configs.py scripts/research/summarize_ya5r_a22_hard5_observe.py
PYTHONUNBUFFERED=1 PYTHONIOENCODING=utf-8 python3 scripts/research/generate_ya5r_a22_hard5_observe_configs.py
DRY_RUN=1 bash scripts/research/run_ya5r_a22_hard5_observe.sh
PYTHONUNBUFFERED=1 PYTHONIOENCODING=utf-8 bash scripts/research/run_ya5r_a22_hard5_observe.sh
PYTHONUNBUFFERED=1 PYTHONIOENCODING=utf-8 python3 scripts/research/summarize_ya5r_a22_hard5_observe.py --strict
```

### 可见进度与日志

- 是否过程可见：`是`
- 日志路径：`${QUANT_PLATFORM_ROOT}/results/v2/research/R010-A22/hard5_default_observe/EX-20260607T192201Z-main-YA5R/logs/formal/<STAMP>/`
- 查看进度命令：`Get-Content ${QUANT_PLATFORM_ROOT}/results/v2/research/R010-A22/hard5_default_observe/EX-20260607T192201Z-main-YA5R/logs/formal/<STAMP>/<variant>_<segment>.run.log -Tail 80`
- 异常判断：待执行。
- 后台回测豁免：

```text
不适用。计划前台可见运行，不后台执行。
```

### 结果路径

```text
待执行后生成：
${QUANT_PLATFORM_ROOT}/results/v2/research/R010-A22/hard5_default_observe/EX-20260607T192201Z-main-YA5R/formal/
${QUANT_PLATFORM_ROOT}/results/v2/research/R010-A22/hard5_default_observe/EX-20260607T192201Z-main-YA5R/summary/formal/summary.json
```

## 12. 实际观察

| 指标 | 基准 | 本次 | 变化 | 解释 |
| --- | --- | --- | --- | --- |
| all_gates_pass | 应为 true | 待执行 | 待执行 | strict 总门禁 |
| shadow_on/off hash | 4/4 应一致 | 待执行 | 待执行 | 核心隔离证据 |
| A22 shadow 日志 | 4/4 应可见 | 待执行 | 待执行 | 默认关闭 observe 可用性 |
| 日期顺序 | 4/4 应通过 | 待执行 | 待执行 | 未来函数边界 |
| double-on guard | 4/4 应检出 | 待执行 | 待执行 | 互斥负控 |

## 13. 支持证据

- 待执行。

## 14. 反对证据

- 预注册阶段已知边界：hard5 路径下 A22 shadow 观察 post-hard5 target，不是 raw Top1 高分候选完整预算建议。
- 本轮不检查 `${LIVE_TRADING_ROOT}` 真实实盘系统。

## 15. 偏差诊断

待执行后填写。

## 16. 研究判断

建议状态：`observe`

理由：预注册阶段不改变 HH4B。只有 strict 全通过后，才支持 A22 在 hard5 默认路径继续默认关闭 observe 或实盘系统 dry-run；无论结果如何，本轮都不允许 production promote。

## 17. 下一步

若 YA5R 通过，下一轮优先做真实 `${LIVE_TRADING_ROOT}` 配置后的只读 dry-run 门禁，或新 forward 样本观察日志审计；若 YA5R 失败，则回滚 A22 hard5 observe 路径，先定位 shadow 日志调用顺序或配置污染问题。
