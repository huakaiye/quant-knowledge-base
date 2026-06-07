---
type: 实验记录
ex_id: EX-20260606T140752Z-main-TC8U
rd_id: RD-20260605T115651Z-main-EXE0
status: active
stage: formal_cost_completed_c35j_negative_control_observe_no_promote
owner: main
created_at: 2026-06-06T14:07:52Z
updated_at: 2026-06-07T18:06:48+08:00
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 执行与换仓模块
decision_ids:
  - DEC-20260607T095915Z-main-BP3L
lit_ids: []
idea_ids: []
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths:
  - configs/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/formal/
  - configs/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/formal_cost2x_slip2bps/
  - configs/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/formal_cost2x_commission/
  - configs/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/formal_delay_negative_control/
  - scripts/research/generate_tc8u_topn_antishake_configs.py
result_paths:
  - results/v2/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/formal/
  - results/v2/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/logs/formal/
  - results/v2/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/formal_cost2x_slip2bps/
  - results/v2/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/logs/formal_cost2x_slip2bps/
  - results/v2/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/formal_cost2x_commission/
  - results/v2/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/logs/formal_cost2x_commission/
  - results/v2/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/formal_delay_negative_control/
  - results/v2/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/logs/formal_delay_negative_control/
summary_paths:
  - results/v2/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/summary/summary.json
  - results/v2/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/summary_cost2x_slip2bps/summary.json
  - results/v2/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/summary_cost2x_commission/summary.json
  - scripts/research/summarize_tc8u_topn_antishake.py
quality_gate: L2_formal_cost_completed_c35j_negative_control_observe_no_promote
subagent_call_ids:
  - SUB-20260606T140000Z-main-TOPN
  - SUB-20260606T150000Z-main-TC8U-AUDIT
  - SUB-20260607T040000Z-main-TC8U-COSTCHECK
subagent_exemption:
tags: [双池轮动, TopN抗抖, 执行模块, formal完成, 成本扰动完成, 负控完成, observe]
---

# TopN抗抖换仓formal AB预注册

## 关联链接

- 研究方向：[[02_研究方向/RD-20260605T115651Z-main-EXE0_双池轮动执行与换仓模块|双池轮动执行与换仓模块]]
- 父方向：[[02_研究方向/RD-20260605T115651Z-main-DP00_双池轮动策略|双池轮动策略]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 上游路线预注册：[[04_实验记录/EX-20260606T134047Z-main-HPHZ_五方向接手证据映射与首轮路线预注册|五方向接手证据映射与首轮路线预注册]]
- 下游负控：[[04_实验记录/EX-20260607T083033Z-main-C35J_TopN抗抖切换延迟负控与2024归因|C35J TopN 抗抖切换延迟负控与 2024 归因]]
- 研究决策：[[05_研究决策/DEC-20260607T095915Z-main-BP3L_TopN抗抖随机延迟负控后观察决策|BP3L TopN 抗抖随机延迟负控后观察决策]]
- Top4 反证：[[04_实验记录/EX-20260606T012550Z-main-LM3D_动量评分尺度与Top4排名权重预注册|动量评分尺度与 Top4 排名权重预注册]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：当前持仓如果仍在 Top3/Top5 且分数没有明显落后，继续持有是否能减少无意义换仓。
我们原本预计：它应该主要降低交易次数和成本敏感性，而不是显著改变选股逻辑。
实际看到：base-cost formal 已完成 20/20；成本扰动子集 `baseline_top1_hard5`、`top3_ratio070_gap050_veto`、`top5_ratio070_veto` 在 `formal_cost2x_slip2bps` 和 `formal_cost2x_commission` 均完成 12/12 strict 汇总。
这说明：TopN 抗抖确实能减少换仓噪声；`top3_ratio070_gap050_veto` 在两组成本扰动中都只有 2024 一个分段 final 低于 baseline，更适合作为后续负控候选。`top5_ratio070_veto` 合计收益更高且 MDD 四段都不差，但 2020_2021 与 2022_2023 仍低于 baseline，不能 promote。
对新手来说：少换仓不是天然更好，它可能是在强趋势里减少噪声，也可能是在趋势切换时反应变慢。
下游 C35J 已完成切换延迟负控：固定 seed 的 `random50` 能在 3/4 分段复制并超过 Top3/gap，说明 TopN/gap 的机制解释被普通延迟混淆，不能 promote。TC8U 自身的 `formal_delay_negative_control` 还在后台补完整 20/20，用来确认脚本和口径层面的稳健性。
下一步要做：不再扩大 TopN 网格；等待 TC8U 自身负控 20/20 后只做严格汇总，不把随机延迟、confirm1 或 Top3/gap 写入默认交易逻辑。若要叠加 A23，必须新开组合交互实验。

## 2. 研究背景

`EX-20260606T012550Z-main-LM3D` 已经否定 Top4 等权、Top4 `40/30/20/10` 和取消 hard5 上限进入默认逻辑。
因此本实验不研究“多买几个 ETF”，只研究“仍主要 Top1，但当前持仓还在候选前列时是否延迟换仓”。

平台 `src/strategies/research/etf_dual_pool_topn_vol_scaled.py` 已有 `choose_targets_with_topn_hold`。本轮补了 `strategy_params.topn_hold` 参数覆盖能力，并通过 `src/tests/strategies/test_etf_dual_pool_topn_hold.py` 10 项测试。

## 3. 实验前假设

低分差、低名次抖动的切换日里，继续持有仍在 Top3/Top5 的旧持仓，可以降低换手和交易次数；如果真实趋势已经切换，Top1 领先会通过分数比例或急跌否决迫使换仓。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：TopN 变体的四段 final 不应明显低于同策略文件 `baseline_top1_hard5`。
- 交易行为：TopN 变体交易数应低于 baseline，日志中应出现 `topn_retained`。
- 风险表现：MDD 不应明显恶化；急跌否决触发日不应继续保留旧持仓。
- 分段表现：2025_20260519 强趋势段不能明显落后；2022_2023 不能因抗抖持有弱势旧标的而放大回撤。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| baseline_top1_hard5 | 同一策略文件、关闭 TopN，隔离策略文件差异 | `configs/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/formal/baseline_top1_hard5/` |
| top3_ratio070_veto | 当前持仓在 Top3 且分数 >= Top1 的 70% 时保留 | `configs/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/formal/top3_ratio070_veto/` |
| top3_ratio085_veto | 更严格分数比例，检验是否只靠宽松滞后获益 | `configs/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/formal/top3_ratio085_veto/` |
| top5_ratio070_veto | 更宽排名保留，检验 Top5 是否过度滞后 | `configs/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/formal/top5_ratio070_veto/` |
| top3_ratio070_gap050_veto | Top3 + 比例 + 绝对分差上限，检验“新第一名必须明显强” | `configs/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/formal/top3_ratio070_gap050_veto/` |
| hard5/A23 | 外部参考，不作为本轮同文件直接基准 | `results/v2/research/R010-A23/state_tier_hot_budget/` |

## 6. 竞争性解释

即使结果符合预期，也可能是：

- 交易减少来自策略文件差异或参数覆盖错误，而不是 TopN 抗抖。
- 收益改善来自更少交易成本，而不是持仓延续本身。
- TopN 只在 2025 强趋势段减少噪声，无法跨段稳定。
- `top5_ratio070` 可能隐藏真实趋势切换，表面少换仓但损失未来收益。

## 7. 证伪条件

出现以下情况，本假设不通过：

- 两个以上分段 final 明显低于 baseline_top1_hard5。
- 交易数下降但 MDD 没改善且收益明显下降。
- 2025_20260519 强趋势段跟不上 baseline 或 A23 外部参考。
- 只有 `top5_ratio070` 有效而 `top3` 邻近参数失败，说明可能是偶然滞后。
- 后续成本加倍后优势消失；本卡未做成本扰动前不得 promote。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 待检查 | formal 结果完整，但尚未逐字段审计 manifest 与数据输入 |
| 信号生成和成交价格不存在同 bar 泄漏 | 待检查 | 沿用 V2 JoinQuant bridge 与原策略调仓流程，需后续专项复核 |
| 股票池或 ETF 池不存在未来成分泄漏 | 待检查 | 使用既有动态池逻辑；后续需复核动态池不是结束日快照 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 本策略不使用财务宏观估值数据 |
| Shadow 或观察信号未被当成默认交易信号 | 已限制 | 本实验为 formal A/B，但不修改生产默认 |

负控或错位检查：

- baseline_top1_hard5 关闭 TopN。
- `top3_ratio085_veto` 与 `top3_ratio070_gap050_veto` 做邻近收紧。
- 成本扰动已完成 `formal_cost2x_slip2bps` 与 `formal_cost2x_commission` 子集；旧 commission summary 曾被上午 stale run 污染，已用 2026-06-07 下午干净重跑覆盖并抽样确认 `fee` 翻倍。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 已预注册 | 5 个变体固定，不看结果后扩网格 |
| 样本内、验证集、样本外划分清楚 | 部分完成 | 四段固定：2020_2021、2022_2023、2024、2025_20260519 |
| 邻近参数敏感性合理 | 部分完成 | ratio 0.70/0.85、Top3/Top5、gap 0/0.50 |
| 成本、滑点或换手扰动已检查 | 已完成子集 | `formal_cost2x_slip2bps` 与 `formal_cost2x_commission` 均完成 baseline + Top3/gap + Top5 的 12/12 strict 汇总；不是全 5 个 TopN 变体成本矩阵 |
| 已做消融或负控 | 已完成下游负控，TC8U 自身补跑中 | baseline 与邻近收紧完成；C35J `confirm1/random50` 16/16 strict 完成并触发 observe；TC8U `formal_delay_negative_control` 背景补跑中 |
| 未只报告最优结果 | 已满足 | 汇总脚本输出全部 base-cost 变体 |

证据等级：`L2_formal_cost_completed_c35j_negative_control_observe_no_promote`

## 10. 子代理调用记录

适配判断：`适合调用`

调用状态：`called`

子代理豁免：

```text
不适用
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-20260606T140000Z-main-TOPN | Cicero | SUBTASK-20260606T140000Z-main-TOPN | gpt-5.3-codex-spark | 2026-06-06T14:00:00Z | 平台 TopN 策略、测试、生成与汇总脚本、配置根 | 无 | 无长回测 | 只读核对，不做最终判断 | `cooldown` 字段不存在，需用 rank/ratio/gap 表达 | 主控采纳其“20 个 formal 配置已存在/可执行”核对，并补 `strategy_params.topn_hold` 覆盖测试 | 支持本卡进入 formal A/B |
| SUB-20260606T150000Z-main-TC8U-AUDIT | Curie | SUBTASK-20260606T150000Z-main-TC8U-AUDIT | gpt-5.3-codex-spark | 2026-06-06T15:00:00Z | `summary.json`、`comparison_vs_baseline.csv`、20 个 status、实验卡 | 无 | 无长回测 | 只读核对，不做 promote/revise/kill | 只按已给证伪条件判断，不替代主控决策 | 主控复核其 20/20、自洽、证伪条件清单；采纳其对 `top3_ratio070_gap050_veto` 的审计优先级建议 | 把成本审计候选从单一 Top5 改为 Top5 + Top3/gap 双候选 |
| SUB-20260607T040000Z-main-TC8U-COSTCHECK | Ramanujan | SUBTASK-20260607T040000Z-main-TC8U-COSTCHECK | gpt-5.3-codex-spark | 2026-06-07T04:00:00Z | TC8U 实验卡、成本配置、runner/summary 脚本、既有 status/summary | 无 | 无长回测 | 只读核对成本扰动待跑集合与旧 summary 污染风险 | 不判断 promote；提醒 stale partial dirs 会污染判断 | 主控采纳其“12 个子集、strict 后仍需 fee 抽样、旧 commission summary 无效”的建议 | 先完成 slip2bps，再补跑干净 commission-only；成本结论改用下午 clean run |

台账行：已补 `01_台账/子代理调用台账.csv`。

## 11. 执行记录

### 平台配置

```text
configs/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/formal/
configs/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/formal_cost2x_slip2bps/
configs/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/formal_cost2x_commission/
```

### 运行命令

```bash
python scripts/research/generate_tc8u_topn_antishake_configs.py
PHASE=formal VARIANTS='<variant>' SEGMENTS='<segment>' bash scripts/research/run_tc8u_topn_antishake_formal.sh
python scripts/research/summarize_tc8u_topn_antishake.py --output-dir results/v2/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/summary
```

成本扰动配置命令：

```bash
python scripts/research/generate_tc8u_topn_antishake_configs.py --phase formal_cost2x_slip2bps
python scripts/research/generate_tc8u_topn_antishake_configs.py --phase formal_cost2x_commission
PHASE=formal_cost2x_slip2bps VARIANTS='baseline_top1_hard5 top3_ratio070_gap050_veto top5_ratio070_veto' PYTHONUNBUFFERED=1 bash scripts/research/run_tc8u_topn_antishake_formal.sh
PHASE=formal_cost2x_commission VARIANTS='baseline_top1_hard5 top3_ratio070_gap050_veto top5_ratio070_veto' PYTHONUNBUFFERED=1 bash scripts/research/run_tc8u_topn_antishake_formal.sh
python scripts/research/summarize_tc8u_topn_antishake.py --phase formal_cost2x_slip2bps --variants baseline_top1_hard5 top3_ratio070_gap050_veto top5_ratio070_veto --output-dir results/v2/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/summary_cost2x_slip2bps --strict
python scripts/research/summarize_tc8u_topn_antishake.py --phase formal_cost2x_commission --variants baseline_top1_hard5 top3_ratio070_gap050_veto top5_ratio070_veto --output-dir results/v2/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/summary_cost2x_commission --strict
```

### 可见进度与日志

- 是否过程可见：`formal base-cost`、`formal_cost2x_slip2bps`、`formal_cost2x_commission` 均使用 `PYTHONUNBUFFERED=1` 与 runner/log/status 记录；commission 干净重跑期间通过 `Get-Content <runner_log> -Tail 80` 监控。
- 日志路径：`results/v2/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/logs/formal/`、`logs/formal_cost2x_slip2bps/`、`logs/formal_cost2x_commission/`
- 查看进度命令：`Get-Content <log> -Tail 80`
- 异常判断：base-cost 20 个 `.status` 均为 `0`；两组成本扰动子集 12/12 `.status=0`，strict summary `missing=[]`；commission 旧 summary 作废，以 2026-06-07 14:15-16:14 的 clean rerun 为准
- 后台回测豁免：

```text
commission-only clean rerun 因 12 段耗时较长，使用 WSL 后台进程并持续读取 runner 日志监控。
Windows PID: 49504；WSL parent PID: 133275；runner PID: 133283；完成后无残留 run_v2_backtest 进程。
日志：results/v2/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/logs/formal_cost2x_commission/runner_20260607T_commission_wslcd.log
查看：Get-Content -Encoding UTF8 <runner_log> -Tail 80
停止方式（运行中）：Stop-Process -Id 49504，或在 WSL 中 kill 133275/133283。
```

### 结果路径

```text
results/v2/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/formal/
results/v2/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/formal_cost2x_slip2bps/
results/v2/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/formal_cost2x_commission/
results/v2/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/summary/
results/v2/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/summary_cost2x_slip2bps/
results/v2/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/summary_cost2x_commission/
```

## 12. 实际观察

base-cost formal 完成 20/20，`completed_runs=20`、`missing=[]`、20 个 status 全部为 `0`。

| 变体 | final 不低于 baseline 分段数 | MDD 不差于 baseline 分段数 | 交易数下降分段数 | 四段 final 差额合计 | 四段交易差额合计 | 主观察 |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| `top3_ratio070_veto` | 2/4 | 2/4 | 4/4 | +3,412.21 | -373 | 触发“两段 final 低于 baseline”，且 2020 收益和回撤同时变差，降优先级 |
| `top3_ratio085_veto` | 3/4 | 2/4 | 4/4 | -1,732.70 | -261 | 收紧后收益合计转负，不作为首选候选 |
| `top5_ratio070_veto` | 2/4 | 4/4 | 4/4 | +16,431.01 | -474 | 交易下降最多、回撤四段都不差，但 2020/2022 final 低于 baseline，不能 promote |
| `top3_ratio070_gap050_veto` | 3/4 | 2/4 | 4/4 | +4,830.17 | -243 | 只 2024 final 低于 baseline，2025 未掉队；作为较稳妥成本审计候选 |

关键逐段事实：

- `top5_ratio070_veto`：2025_20260519 final 比 baseline 高 `40,460.96`，MDD 改善 `0.0113`，交易少 `125`；2020_2021 和 2022_2023 final 分别低 `23,425.18`、`8,107.84`，但 MDD 均改善。
- `top3_ratio070_gap050_veto`：2020_2021、2022_2023、2025_20260519 final 分别高 `6,348.83`、`2,715.30`、`9,542.17`；2024 低 `13,776.13`。
- 所有 TopN 变体 2025_20260519 均未掉队，说明强趋势段没有被完全错过。
成本扰动子集完成情况：

| 成本扰动 | 完成 | 变体 | `top3_ratio070_gap050_veto` 观察 | `top5_ratio070_veto` 观察 |
| --- | ---: | --- | --- | --- |
| `formal_cost2x_slip2bps` | 12/12 | baseline + Top3/gap + Top5 | 3/4 final 不低于 baseline，交易少 `243`，四段 final 合计多 `10464.85`；2024 仍低于 baseline，2020/2025 MDD 略差 | 2/4 final 不低于 baseline，交易少 `474`，四段 final 合计多 `28620.10`；2020/2022 final 低于 baseline，MDD 4/4 不差 |
| `formal_cost2x_commission` | 12/12 | baseline + Top3/gap + Top5 | 3/4 final 不低于 baseline，交易少 `243`，四段 final 合计多 `9215.28`；2024 仍低于 baseline，2020/2025 MDD 略差 | 2/4 final 不低于 baseline，交易少 `474`，四段 final 合计多 `25626.05`；2020/2022 final 低于 baseline，MDD 4/4 不差 |

commission-only 逐段事实：

- `top3_ratio070_gap050_veto`：2020_2021 final 多 `7593.33`、2022_2023 多 `3645.71`、2024 少 `13061.08`、2025_20260519 多 `11037.32`。
- `top5_ratio070_veto`：2020_2021 final 少 `19329.58`、2022_2023 少 `6429.50`、2024 多 `8214.09`、2025_20260519 多 `43171.04`。
- 费用抽样：base-cost baseline 2020 前两笔 `fee=10.0/9.84`；clean commission-only 和 slip2bps baseline 2020 前两笔 `fee=20.0/19.68`；commission-only Top5 2025 前两笔 `fee=19.99/20.46`，确认成本扰动生效。

## 13. 支持证据

- 平台已有 `choose_targets_with_topn_hold`，本轮新增 `strategy_params.topn_hold` 覆盖能力。
- `python -m pytest src/tests/strategies/test_etf_dual_pool_topn_hold.py -q` 通过 10/10。
- 20 个 base-cost formal 回测均有 `.status=0`。
- 两组成本扰动子集均 strict 通过：`expected_runs=12`、`completed_runs=12`、`missing=[]`。
- `topn_retained` 合计：Top3/0.70 为 266 次，Top3/0.85 为 186 次，Top5/0.70 为 342 次，Top3/0.70/gap0.50 为 182 次。

## 14. 反对证据

- `top3_ratio070_veto` 与 `top5_ratio070_veto` 均触发“两段以上 final 低于 baseline”的证伪条件。
- `top3_ratio085_veto` 四段 final 合计为负，说明不是简单收紧就能稳健。
- Top5 在 base-cost、slip2bps 和 commission-only 三种成本口径下均只有 2/4 分段 final 不低于 baseline，不能通过预注册收益门槛。
- Top3/gap 虽在三种成本口径下保持 3/4 分段 final 不低于 baseline，但 2024 final 明显低于 baseline，且 MDD 只有 2/4 不差。
- C35J 随机延迟负控已触发机制混淆：`random50` 相对 Top3/gap 为 3/4 分段 final 不低、3/4 分段 MDD 不差，四段合计 final 多 `93692.92`；因此 Top3/gap 不能 promote。
- TC8U 自身 `formal_delay_negative_control` 尚未完成 20/20；截至 2026-06-07T18:06:48+08:00 为 7/20 完成，当前 `top3_ratio070_gap050_veto/2025_20260519` 约 23%，完成前只作为运行中交叉核对，不新增结论。
- 本实验不能直接证明 A23 与 TopN 叠加有效。

## 15. 偏差诊断

- 本卡已完成成本扰动子集，但不是全 5 个 TopN 变体的完整成本矩阵；成本结论仅覆盖 baseline + Top3/gap + Top5。
- `top5_ratio070_veto` 的合计收益最高，但两个历史分段 final 低于 baseline，可能是反应变慢换来的 2025 噪声收益。
- `top3_ratio070_gap050_veto` 证伪触发较少，但 MDD 仅 2/4 不差，且 2024 final 明显低于 baseline。
- 早上的 commission summary 曾因旧 run/stale status 产生污染，已用下午 clean rerun 覆盖；后续引用必须使用 `summary_cost2x_commission` 中 2026-06-07 14:15-16:14 的 run_dir。

## 16. 研究判断

建议状态：`observe / cost_completed_negative_control_triggered_no_promote`

理由：TopN 抗抖证明了“减少换仓”这个执行效果，也证明 Top3/gap 和 Top5 在两类成本扰动下没有因成本加倍而整体崩掉。但它仍没有证明“稳定提升收益”：Top5 在 2020/2022 两段持续低于 baseline；Top3/gap 在 2024 明显低于 baseline 且 MDD 稳定性不足。下游 C35J 又显示普通随机延迟能在 3/4 分段复制并超过 Top3/gap，机制解释被负控混淆。因此不改默认 hard5/A23，已同步 [[05_研究决策/DEC-20260607T095915Z-main-BP3L_TopN抗抖随机延迟负控后观察决策|BP3L observe 决策]]。

## 17. 下一步

1. 等待 TC8U `formal_delay_negative_control` 补完 20/20；完成后必须显式传入 5 个负控变体做 strict summary，避免 summary 脚本默认变体污染。
2. 不继续扩大 TopN 排名、比例、分差、seed 或冷却期网格；TopN/gap、confirm1、random50 均不进入默认交易逻辑。
3. 若继续方向 4，只能新开“换仓确认机制”预注册，并先做 seed 敏感性、2022 失败归因、成本扰动和错位负控。
4. A23 或 hard5 默认逻辑不因 TC8U/C35J 改动；A23 组合交互必须另开实验。
