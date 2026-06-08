---
type: 实验记录
ex_id: EX-20260606T000758Z-main-VVVN
rd_id: RD-20260605T131301Z-main-KC7N
status: completed
stage: formal_completed_failed_no_promote
owner: main
created_at: 2026-06-06T00:07:58Z
updated_at: 2026-06-07T23:53:40Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 核心轮动风险预算模块
decision_ids: [DEC-20260605T235338Z-main-WVZZ, DEC-20260607T235302Z-main-8GQQ]
lit_ids: [LIT-20260603T000000Z-mig-1999MOSKOWITZ83801, LIT-20260605T133500Z-main-E46H, LIT-20260603T000000Z-mig-2015BARROSO7DA3F, LIT-20260603T000000Z-mig-2016DANIEL20500, LIT-20260605T133336Z-main-67C4]
idea_ids: []
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths:
  - configs/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/
result_paths:
  - results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/
summary_paths:
  - results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/summary/summary.json
quality_gate: preregistered_before_execution
subagent_call_ids:
  - SUB-20260608T061000Z-main-NEXTQ-QUEUE
  - SUB-20260608T062000Z-main-VVVN-PREFLIGHT
  - SUB-20260608T073000Z-main-VVVN-DOC-AUDIT
subagent_exemption:
tags: [双池轮动, 主题簇, 金融坏桶, 风险预算, formal-v2, AB, 非hard5, no-promote]
---

# 主题簇金融坏桶风险预算formal V2 AB预注册

## 关联链接

- 研究方向：[[02_研究方向/RD-20260605T131301Z-main-KC7N_双池轮动主题簇主线确认模块|双池轮动主题簇主线确认模块]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 前置实验：[[04_实验记录/EX-20260605T234635Z-main-CTRD_主题簇主线确认收益归因与负控预注册|主题簇主线确认收益归因与负控预注册]]
- 前置决策：[[05_研究决策/DEC-20260605T235338Z-main-WVZZ_主题簇强主线不作为正向放行条件|主题簇强主线不作为正向放行条件]]
- 来源文献或灵感：[[06_文献资料/08_已归档/LIT-20260603T000000Z-mig-1999MOSKOWITZ83801_L20260531-031DoIndustriesExplainMomentum|Do Industries Explain Momentum?]]；[[06_文献资料/00_待处理/LIT-20260605T133500Z-main-E46H_Time Series Momentum|Time Series Momentum]]；[[06_文献资料/08_已归档/LIT-20260603T000000Z-mig-2015BARROSO7DA3F_L20260521-003MomentumHasItsMoments|Momentum Has Its Moments]]；[[06_文献资料/08_已归档/LIT-20260603T000000Z-mig-2016DANIEL20500_L20260521-004MomentumCrashes|Momentum Crashes]]
- 产生的决策：[[05_研究决策/DEC-20260607T235302Z-main-8GQQ_主题簇金融风险预算formal失败后暂停决策|主题簇金融风险预算 formal 失败后暂停决策]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：把主题簇里的金融 top1 和过度主题集中当成风险标签后，做固定 70% 风险仓预算，是否能改善双池轮动的真实组合路径。  
我们原本预计：金融 top1 或高集中度不是加仓信号，而是更像追高、拥挤或风格切换风险；降低风险仓可能减少回撤，收益不能明显低于基准。  
实际看到：四段 formal V2 已全部完成，`summary.json` 显示 `missing_runs=[]`、`all_completed=true`、`error_count=0`。`financial_top1_cap70` 只有 1/4 分段收益高于 baseline，2/4 分段回撤改善，四段收益差合计约 `-8.50` 个百分点，触发 50 次；`financial_or_share_ge050_cap70` 虽然 4/4 分段回撤改善，但 0/4 分段收益高于 baseline，四段收益差合计约 `-69.82` 个百分点，触发 772 次。
这说明：主题风险预算的工程链路可运行，cap70 确实能降低暴露；但金融 top1 不是稳定可交易的降仓标签，高集中度 50% 阈值更严重，会把正常强趋势也当风险降仓。  
正式判断：本轮两个变体均不进入默认逻辑，也不进入 promote candidate。主题簇继续只保留为只读诊断和归因标签；如果未来还要研究交易化，必须新开更窄、更滞后且带负控的预注册实验，不能在本轮结果上后验扫阈值。

## 2. 研究背景

本实验属于 [[02_研究方向/RD-20260605T131301Z-main-KC7N_双池轮动主题簇主线确认模块|双池轮动主题簇主线确认模块]]。前置 `EX-20260605T234635Z-main-CTRD` 已经否定 `6p_same` 正向放行路线：强主题集中没有带来更好的 H10 组合路径；金融 top1 在 3/4 分段更弱，但样本较少。

顶刊启发只作为方向，不作为结论。行业动量文献说明主题层级值得观察；风险管理动量和动量崩盘文献提醒动量风险是状态相关的，因此本轮不做二元剔除，也不做主题加仓，只测试固定风险仓 cap。

## 3. 实验前假设

在 A11 cap5 tiered v2 四段基准上，若当日主题 shadow 显示 `r010theme_bad_theme_top1=true`，或 `r010theme_top_theme_share >= 0.50`，则把当日风险资产总仓位限制到 70%，其余保留为防御 ETF/现金处理逻辑。该规则应降低金融坏桶和过度集中状态下的路径风险，同时不能显著牺牲总收益。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：主变体 `financial_top1_cap70` 相对 A11 cap5 tiered v2，至少 3/4 分段最大回撤不恶化，且总收益不出现大幅损失。
- 指标：扩展变体 `financial_or_share_ge050_cap70` 若有效，应在回撤上进一步改善；若收益明显被压低，说明高集中度标签过宽。
- 交易行为：触发日 `applied_action` 应出现 `THEME_BUDGET` 后缀，`weights` 中风险仓合计应下降到不高于 70%。
- 风险表现：改善不能只来自 2020-2021 或 2025 单段，也不能只由极少触发日贡献。
- 分段表现：支持信号至少要在 3/4 分段方向一致；2024 和 2025-20260519 不能同时明显劣化。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| A11 cap5 tiered v2 baseline | 主基准，重跑同一份 A11 配置，只打开主题 shadow，不打开主题预算 | `${QUANT_PLATFORM_ROOT}/configs/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/baseline/` |
| `financial_top1_cap70` | 主变体，仅金融 top1 时把风险仓 cap 到 70% | `${QUANT_PLATFORM_ROOT}/configs/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/financial_top1_cap70/` |
| `financial_or_share_ge050_cap70` | 扩展变体，金融 top1 或主题集中度不低于 50% 时 cap 到 70% | `${QUANT_PLATFORM_ROOT}/configs/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/financial_or_share_ge050_cap70/` |
| B7VH/CTRD shadow 归因 | 解释触发依据，但不作为本轮交易结果 | `${QUANT_PLATFORM_ROOT}/results/v2/research/R010-THEME/EX-20260605T234635Z-main-CTRD/forward_attribution/` |

固定分段：

- `2020_2021`
- `2022_2023`
- `2024`
- `2025_20260519`

固定参数空间：

- `r010theme_risk_budget_enabled=true`
- `r010theme_risk_budget_cap=0.70`
- `r010theme_risk_budget_modes=["financial_top1", "financial_or_share_ge050"]`
- `r010theme_risk_budget_share_min=0.50`
- `r010theme_mainline_shadow_topn=10`
- `r010theme_mainline_same_count_min=6`
- `r010theme_mainline_bad_themes=["金融"]`

不允许本轮看结果后新增 60%、80%、0.40、0.60 等阈值网格。

## 6. 竞争性解释

即使结果符合预期，也可能是：

- 改善来自降低总风险仓，而不是主题标签本身。
- 金融 top1 触发样本较少，结果可能由少数年份或少数 ETF 驱动。
- 高集中度触发可能和 B3 全弱、A2 保留持仓、A22 高分预算等既有逻辑重叠。
- 70% cap 可能只是偶然适配当前成本和样本，邻近参数未验证前不能说明稳健。
- 主题词表仍来自 ETF 名称关键词，不能看结果后修改分类。

## 7. 证伪条件

出现以下情况，本假设不通过：

- 任一变体相对 A11 cap5 tiered v2 在 2 个及以上分段总收益明显下降，且回撤没有同步改善。
- 2024 或 2025-20260519 出现显著劣化，导致最近样本无法接受。
- `financial_top1_cap70` 触发次数过少，无法支撑正式判断，只能降级为探索观察。
- `financial_or_share_ge050_cap70` 的改善只来自降低暴露，且触发范围过宽导致收益被系统性压低。
- 日志无法证明触发时只使用当日已生成的主题 shadow 字段。
- 任何默认配置或实盘开关被意外改变。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 通过到本轮 formal 边界 | 四段触发记录来自当日 `raw_post_score_filter` 主题 shadow 字段；没有读取未来 H1/H5/H10 收益参与交易 |
| 信号生成和成交价格不存在同 bar 泄漏 | 通过到本轮 formal 边界 | 复用平台午后信号和既有成交流程，预算只改当日目标权重，不新增未来收益字段 |
| 股票池或 ETF 池不存在未来成分泄漏 | 沿用基准 | 不新增 ETF 池，不更新数据 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 不使用财务、宏观或估值数据 |
| Shadow 或观察信号未被当成默认交易信号 | 通过 | 新参数默认关闭；只在 `EX-20260606T000758Z-main-VVVN` 研究配置中打开；本轮结论不 promote |

负控或错位检查：

- 本轮 A/B 已失败，因此不继续做候选增强。若未来重启交易化主题风险预算，必须新开随机金融标签、错位主题标签或滞后一日标签负控。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | 只测两个固定变体，cap 固定 70%，share_min 固定 0.50 |
| 样本内、验证集、样本外划分清楚 | 通过 | 沿用 A11 四段 formal V2 |
| 邻近参数敏感性合理 | 不适用，不扩网格 | 两个预注册变体已失败；不得看结果后新增 60/80 或 0.45/0.55 阈值网格 |
| 成本、滑点或换手扰动已检查 | 不进入候选 | 两个变体收益证据不足，成本扰动不会把 no-promote 变成 promote；若未来重启需另开预注册 |
| 已做消融或负控 | 部分通过但不足以 promote | 本轮有 baseline A/B；因 A/B 失败，错位/随机标签只作为未来重启门槛 |
| 未只报告最优结果 | 通过 | 三组、四段、12 个 run 全部汇总，两个变体同时报告 |

证据等级：`L3_formal_v2_negative`。本轮证据用于否决交易化主题风险预算 cap70 变体，不用于证明主题标签完全无研究价值。

## 10. 子代理调用记录

调用状态：`called`

子代理豁免：

```text
不适用。早期 active 阶段曾因工具约束写过豁免；本次 completed/no-promote 收口已实际调用子代理，并同步台账。
```

| 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 主控-002-VVVN规范补齐 | 无 | 2026-06-06T01:08:00Z | `AGENTS.md`; `08_方法论/子代理调度规范.md`; `08_方法论/平台协作规范.md`; 本实验记录 | 本实验记录 | `pgrep`; `git status`; 文件读取 | 只做规范补齐和状态校正，不替代子查/子研审计 | 未调用子代理，正式 completed 前仍需子查路径/字段审计或重新写明豁免 | 主控确认本实验仍为 active，不能作为正式结论 | 不改变路线，不新增决策 |
| 主控-003-2025扩展变体 | 无 | 2026-06-06T01:24:18Z | 本实验记录；平台 `metrics.csv`; `metrics_vs_baseline.csv`; `summary.json`; 运行日志 | 本实验记录；实验台账；方向卡；入口状态和驾驶舱 | `Start-Process`; `pgrep`; `tail`; `summarize_r010theme_risk_budget.py` | 只追加 2025 smoke 观察，不做 completed 结论 | 未调用子代理；本轮补跑过程使用后台但已事前写豁免和日志路径 | 主控确认 `financial_or_share_ge050_cap70` 触发过宽、收益损失显著 | 不改变路线，不新增决策 |
| 主控-004-2024近端分段 | 无 | 2026-06-06T02:30:25Z | 平台 2024 三组运行日志；`metrics.csv`; `metrics_vs_baseline.csv`; `summary.json` | 本实验记录；实验台账；方向卡；入口状态和驾驶舱 | `run_r010theme_vvvn_2024_formal.sh`; `summarize_r010theme_risk_budget.py --segments 2024 2025_20260519` | 只追加 2024 近端 formal 观察，不做 completed 结论 | 未调用子代理；脚本末尾曾以逗号传参导致一次错误 summary，已修正并重跑覆盖 | 主控确认两组预算变体 2024+2025 收益均输 baseline | 不改变路线，不新增决策 |
| SUBTASK-NEXTQ-QUEUE | gpt-5.3-codex-spark | 2026-06-08T06:10:00Z | 研究驾驶舱、当前状态、实验/决策台账、A22/A23/LM3D/VVVN/JQBL 等候选记录 | 无 | 无回测，只读检索 | 只做下一队列清单，不做路线生杀 | 候选排序依赖当时文档状态，需主控复核 | 主控采纳 VVVN 为可立即补齐的 P1 队列之一，但最终判断来自 full formal summary | 支持启动 VVVN 剩余两段正式补跑 |
| SUBTASK-VVVN-PREFLIGHT | gpt-5.3-codex-spark | 2026-06-08T06:20:00Z | 本实验卡；VVVN 2020_2021、2022_2023 baseline/两变体配置；汇总脚本 | 无 | 无回测，只读核对 | 只核对配置字段、路径、脚本 strict 范围，不判断有效性 | 汇总 strict 只查 missing/error，不替代研究门槛 | 主控采纳其“6 条剩余配置齐全且符合预注册”的发现，随后前台可见运行 full formal | 支持把剩余两段作为合法预注册补跑，而不是新增网格 |
| SUBTASK-VVVN-DOC-AUDIT | gpt-5.3-codex-spark | 2026-06-08T07:30:00Z | 本实验卡、实验台账、KC7N 方向页、当前状态、研究驾驶舱、Canvas、决策目录 | 无 | `rg`、文件读取 | 只做文档缺口清单，不判断 promote/kill | 子代理看到的是文档旧状态；主控需结合已完成 full formal 更新 | 主控复核后采纳“需新建 VVVN 专用 DEC、更新台账/入口/Canvas”的流程建议 | 支持 completed/no-promote 收口和文档同步 |

台账行：已同步 `01_台账/子代理调用台账.csv`。

## 11. 执行记录

### 平台配置

```text
计划生成：
${QUANT_PLATFORM_ROOT}/configs/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/baseline/theme_baseline_tiered_v2_*.json
${QUANT_PLATFORM_ROOT}/configs/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/financial_top1_cap70/theme_financial_top1_cap70_tiered_v2_*.json
${QUANT_PLATFORM_ROOT}/configs/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/financial_or_share_ge050_cap70/theme_financial_or_share_ge050_cap70_tiered_v2_*.json

已生成 12 个配置：
${QUANT_PLATFORM_ROOT}/configs/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/
```

### 运行命令

```bash
计划：
wsl -- bash -c "cd /mnt/e/量化平台_V1.4.0 && PYTHONPATH=src python3 scripts/research/generate_r010theme_risk_budget_configs.py --ex-id EX-20260606T000758Z-main-VVVN"
wsl -- bash -c "cd /mnt/e/量化平台_V1.4.0 && PYTHONPATH=src python3 src/run_v2_backtest.py --config <config>"
wsl -- bash -c "cd /mnt/e/量化平台_V1.4.0 && PYTHONPATH=src python3 scripts/research/summarize_r010theme_risk_budget.py --ex-id EX-20260606T000758Z-main-VVVN --strict"

已执行 smoke：
wsl -- bash -c "cd /mnt/e/量化平台_V1.4.0 && PYTHONPATH=src PYTHONIOENCODING=utf-8 python3 src/run_v2_backtest.py --config configs/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/baseline/theme_baseline_tiered_v2_2025_20260519.json"
wsl -- bash -c "cd /mnt/e/量化平台_V1.4.0 && PYTHONPATH=src PYTHONIOENCODING=utf-8 python3 src/run_v2_backtest.py --config configs/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/financial_top1_cap70/theme_financial_top1_cap70_tiered_v2_2025_20260519.json"
wsl -- bash -lc "bash /mnt/e/量化平台_V1.4.0/scripts/research/run_r010theme_vvvn_financial_or_share_2025.sh"
wsl -- bash -lc "bash /mnt/e/量化平台_V1.4.0/scripts/research/run_r010theme_vvvn_2024_formal.sh"
wsl -- bash -c "cd /mnt/e/量化平台_V1.4.0 && PYTHONPATH=src PYTHONIOENCODING=utf-8 python3 scripts/research/summarize_r010theme_risk_budget.py --ex-id EX-20260606T000758Z-main-VVVN --segments 2025_20260519"
wsl -- bash -lc "cd /mnt/e/量化平台_V1.4.0 && PYTHONPATH=src PYTHONIOENCODING=utf-8 python3 scripts/research/summarize_r010theme_risk_budget.py --ex-id EX-20260606T000758Z-main-VVVN --segments 2024 2025_20260519"

已执行剩余两段 full formal：
wsl -- bash -lc "cd /mnt/e/quant_platform_v1_4_0_link && STAMP=20260607T222500Z PYTHONIOENCODING=utf-8 bash scripts/research/run_r010theme_vvvn_remaining_formal.sh"
```

### 可见进度与日志

- 是否过程可见：部分可见。baseline smoke 起初用前台命令运行，但 shell 超时后平台进程继续运行，主控通过 `pgrep`、`ps` 和平台 `logs.jsonl` 轮询进度；`financial_top1_cap70` smoke 曾用 `Start-Process -WindowStyle Hidden` 后台运行，并写入 stdout/stderr 日志。`financial_or_share_ge050_cap70` smoke 在事前写明后台豁免后运行，使用 `PYTHONUNBUFFERED=1 + tee` 写逐日进度日志。
- 日志路径：
  - `${QUANT_PLATFORM_ROOT}/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/baseline/2025_20260519/9c503d35bed2426d8bef809dcacac59a/logs.jsonl`
  - `${QUANT_PLATFORM_ROOT}/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/financial_top1_cap70/2025_20260519/f4a48fa9e9014c84a9d1d2515c544656/logs.jsonl`
  - `${QUANT_PLATFORM_ROOT}/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/run_financial_top1_2025.stderr.log`
  - `${QUANT_PLATFORM_ROOT}/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/run_financial_top1_2025.stdout.log`
  - `${QUANT_PLATFORM_ROOT}/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/run_financial_or_share_ge050_2025.run.log`
  - `${QUANT_PLATFORM_ROOT}/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/run_baseline_2024.run.log`
  - `${QUANT_PLATFORM_ROOT}/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/run_financial_top1_cap70_2024.run.log`
  - `${QUANT_PLATFORM_ROOT}/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/run_financial_or_share_ge050_cap70_2024.run.log`
  - `${QUANT_PLATFORM_ROOT}/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/run_financial_or_share_ge050_2025.wrapper.out.log`
  - `${QUANT_PLATFORM_ROOT}/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/run_financial_or_share_ge050_2025.wrapper.err.log`
  - `${QUANT_PLATFORM_ROOT}/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/run_2024_formal.wrapper.out.log`
  - `${QUANT_PLATFORM_ROOT}/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/run_2024_formal.wrapper.err.log`
- 查看进度命令：

```bash
wsl -- bash -c "pgrep -af 'EX-20260606T000758Z-main-VVVN|run_v2_backtest.py' || true"
wsl -- bash -c "tail -n 50 /mnt/e/量化平台_V1.4.0/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/<variant>/<segment>/<job_id>/logs.jsonl"
```

- 异常判断：若 `pgrep` 无进程且目标结果目录无 `summary.json`，判定运行失败或被中断；若 `logs.jsonl` 日期长期不推进且 CPU 接近 0，判定疑似卡住。
- 后台回测豁免：

```text
历史执行整改说明：financial_top1_cap70 的 2025 smoke 在新规范重读前使用了后台运行，未事前写后台回测豁免。该进程已完成，无残留。后续正式四段必须改用 PYTHONUNBUFFERED=1 + tee 的过程可见命令；若确需后台运行，必须事前写明进程标识、日志路径、查看进度命令、停止方式和预计耗时。
进程标识：历史 WSL PID 26591，已结束。
日志路径：${QUANT_PLATFORM_ROOT}/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/run_financial_top1_2025.stderr.log
查看进度：wsl -- bash -c "pgrep -af 'EX-20260606T000758Z-main-VVVN|run_v2_backtest.py' || true"
停止方式：无残留进程；若未来后台运行，使用 wsl -- bash -c "kill <pid>"。
预计耗时：2025 单段约 10-15 分钟；四段全量预计显著更长。

本轮追加后台豁免：`financial_or_share_ge050_cap70` 2025 smoke 因 PowerShell/WSL inline 引号两次失败，改为平台脚本 `${QUANT_PLATFORM_ROOT}/scripts/research/run_r010theme_vvvn_financial_or_share_2025.sh` 后后台运行；后台仅用于持续轮询进度。Windows wrapper 进程见当轮终端记录，WSL Python PID 为 28536，已完成；日志为 `run_financial_or_share_ge050_2025.run.log`，停止方式为 `wsl -- bash -lc "kill <pid>"`。

2024 formal 预执行后台豁免：计划运行 `${QUANT_PLATFORM_ROOT}/scripts/research/run_r010theme_vvvn_2024_formal.sh`，顺序执行 baseline、`financial_top1_cap70`、`financial_or_share_ge050_cap70` 三份 2024 已预注册配置；后台原因是预计耗时 30 分钟以上，后台仅用于主控轮询。日志路径为 `run_baseline_2024.run.log`、`run_financial_top1_cap70_2024.run.log`、`run_financial_or_share_ge050_cap70_2024.run.log`，查看进度命令为 `wsl -- bash -lc "pgrep -af 'run_r010theme_vvvn_2024_formal|theme_.*_2024|run_v2_backtest.py' || true"`，停止方式为 `wsl -- bash -lc "kill <pid>"`。

2024 formal 执行结果：WSL 脚本 PID 30003，三组均已完成。baseline job_id 为 `1750ed82f73d425ba053de68378afd17`，`financial_top1_cap70` job_id 为 `899e5759499a4f5bbaaa1bf8fad3042d`，`financial_or_share_ge050_cap70` job_id 为 `45d9c5ec4a854a60a4f708b16efad76e`。脚本末尾第一次汇总误用 `--segments 2024,2025_20260519`，已修正为 `--segments 2024 2025_20260519` 并重跑覆盖 summary。

2026-06-08 剩余两段 formal 执行说明：最初两次 `nohup` 尝试未产生有效进程或日志，不计入回测；随后两次 `Start-Process` 包装运行因脚本路径未解析成功而失败，Windows PID `12028` 与 `37884` 均不计入有效回测。最终改为前台可见 WSL 命令，通过 ASCII junction `E:\quant_platform_v1_4_0_link` 进入同一平台目录，stamp 为 `20260607T222500Z`。该次顺序执行 `baseline`、`financial_top1_cap70`、`financial_or_share_ge050_cap70` 在 `2020_2021` 与 `2022_2023` 两段的 6 条预注册配置，并在脚本末尾运行 `summarize_r010theme_risk_budget.py --strict` 汇总四段。日志路径为 `${QUANT_PLATFORM_ROOT}/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/logs/formal_remaining/20260607T222500Z/`。
```

### 结果路径

```text
计划：
${QUANT_PLATFORM_ROOT}/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/
${QUANT_PLATFORM_ROOT}/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/summary/

已产出：
${QUANT_PLATFORM_ROOT}/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/baseline/2020_2021/9301b9a2ac7d4368a93f586c37b3bb13/
${QUANT_PLATFORM_ROOT}/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/baseline/2022_2023/9576b1af82c14c1ca8e360a0682ee569/
${QUANT_PLATFORM_ROOT}/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/baseline/2024/1750ed82f73d425ba053de68378afd17/
${QUANT_PLATFORM_ROOT}/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/baseline/2025_20260519/9c503d35bed2426d8bef809dcacac59a/
${QUANT_PLATFORM_ROOT}/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/financial_top1_cap70/2020_2021/4114ed06cdba417db02629b119259e5f/
${QUANT_PLATFORM_ROOT}/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/financial_top1_cap70/2022_2023/b33daece35a04f3f8f221dadadc3f650/
${QUANT_PLATFORM_ROOT}/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/financial_top1_cap70/2024/899e5759499a4f5bbaaa1bf8fad3042d/
${QUANT_PLATFORM_ROOT}/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/financial_top1_cap70/2025_20260519/f4a48fa9e9014c84a9d1d2515c544656/
${QUANT_PLATFORM_ROOT}/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/financial_or_share_ge050_cap70/2020_2021/1720677983524fdab12b5277027fcb41/
${QUANT_PLATFORM_ROOT}/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/financial_or_share_ge050_cap70/2022_2023/445061171c31403c9ffc87011d3077cf/
${QUANT_PLATFORM_ROOT}/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/financial_or_share_ge050_cap70/2024/45d9c5ec4a854a60a4f708b16efad76e/
${QUANT_PLATFORM_ROOT}/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/financial_or_share_ge050_cap70/2025_20260519/8d1bc1cebd6f41efbbfb59b613941d6d/
${QUANT_PLATFORM_ROOT}/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/summary/summary.json
${QUANT_PLATFORM_ROOT}/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/summary/metrics.csv
${QUANT_PLATFORM_ROOT}/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/summary/metrics_vs_baseline.csv
${QUANT_PLATFORM_ROOT}/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/summary/theme_budget_records.csv
```

## 12. 实际观察

| 分段 | 变体 | final value | total return | max drawdown | trades | 风险预算触发 | 相对 baseline 解释 |
| --- | --- | ---: | ---: | ---: | ---: | ---: | --- |
| 2020_2021 | baseline | `225079.60` | `1.2507960` | `-0.2067800` | `561` | `0` | 主基准，486 条主题 shadow |
| 2020_2021 | `financial_top1_cap70` | `226851.52` | `1.2685152` | `-0.2085414` | `575` | `8` | 收益高 `0.0177192`，最大回撤差 `0.0017614` |
| 2020_2021 | `financial_or_share_ge050_cap70` | `222574.33` | `1.2257433` | `-0.1771155` | `632` | `160` | 收益低 `0.0250527`，最大回撤改善 `0.0296645` |
| 2022_2023 | baseline | `131214.63` | `0.3121463` | `-0.2712650` | `454` | `0` | 主基准，484 条主题 shadow |
| 2022_2023 | `financial_top1_cap70` | `127731.10` | `0.2773110` | `-0.2667112` | `461` | `21` | 收益低 `0.0348353`，最大回撤改善 `0.0045538` |
| 2022_2023 | `financial_or_share_ge050_cap70` | `120060.91` | `0.2006091` | `-0.2254544` | `491` | `291` | 收益低 `0.1115372`，最大回撤改善 `0.0458107` |
| 2024 | baseline | `167005.22` | `0.6700522` | `-0.2699355` | `281` | `0` | 主基准，242 条主题 shadow |
| 2024 | `financial_top1_cap70` | `162145.99` | `0.6214599` | `-0.2668755` | `288` | `5` | 收益低 `0.0485923`，最大回撤改善 `0.0030600` |
| 2024 | `financial_or_share_ge050_cap70` | `150671.61` | `0.5067161` | `-0.2559100` | `315` | `160` | 收益低 `0.1633361`，最大回撤改善 `0.0140255` |
| 2025_20260519 | baseline | `317973.61` | `2.1797361` | `-0.1656700` | `464` | `0` | 主基准，330 条主题 shadow |
| 2025_20260519 | `financial_top1_cap70` | `316042.77` | `2.1604277` | `-0.1656887` | `470` | `16` | 收益低 `0.0193084`，最大回撤略差 `0.0000186` |
| 2025_20260519 | `financial_or_share_ge050_cap70` | `278150.17` | `1.7815017` | `-0.1361449` | `509` | `161` | 收益低 `0.3982344`，最大回撤改善 `0.0295251` |

四段合计看，`financial_top1_cap70` 触发 50 次，只有 2020_2021 收益高于 baseline；四段收益差合计约 `-0.0850168`，回撤仅 2/4 分段改善。`financial_or_share_ge050_cap70` 触发 772 次，4/4 分段最大回撤改善，但 0/4 分段收益高于 baseline，四段收益差合计约 `-0.6981604`。高集中度规则的回撤改善主要来自系统性降暴露，代价是明显错过强趋势收益，不满足本轮“不能明显牺牲总收益”的预测。

## 13. 支持证据

- 平台策略已新增默认关闭的 `r010theme_risk_budget_enabled`，默认参数不影响生产。
- 生成脚本已产出 baseline 和两个固定变体的四段配置，共 12 个 JSON。
- 四段三组全部完成，`summary.json` 显示 `missing_runs=[]`、`all_completed=true`、`error_count=0`。
- `financial_top1_cap70` 触发记录显示 `applied_action=A0+THEME_BUDGET`，`weights` 从金融 top1 100% 变为金融 top1 70% + 防御 ETF 30%，实现符合预注册。
- `financial_or_share_ge050_cap70` 能改善四段最大回撤，说明交易化 cap 链路确实能改变组合风险暴露。

## 14. 反对证据

- `financial_top1_cap70` 只有 1/4 分段收益高于 baseline，四段收益差合计约 `-0.0850168`；回撤只 2/4 分段改善，未通过预注册“至少 3/4 分段方向一致”的要求。
- `financial_top1_cap70` 的唯一收益改善来自 2020_2021，但该段最大回撤反而更深；2022_2023、2024、2025_20260519 三段收益均低于 baseline。
- `financial_or_share_ge050_cap70` 虽 4/4 分段改善回撤，但 0/4 分段收益高于 baseline，四段收益差合计约 `-0.6981604`，2025_20260519 单段收益差达到 `-0.3982344`。
- 高集中度扩展四段触发 772 次，远高于金融 top1 的 50 次，说明 `top_theme_share>=0.50` 对双池 ETF 过于宽，容易把正常主线行情也打成风险。
- 两个变体都增加交易数：`financial_top1_cap70` 四段各增加 6-14 笔，`financial_or_share_ge050_cap70` 各增加 34-71 笔；这与“更稳且低扰动”的预期不一致。

## 15. 偏差诊断

前置 CTRD 显示金融 top1 的 H10 事件后路径较弱，但交易化 cap70 在四段组合路径中没有稳定收益优势，说明事件后均值弱不等于组合层降仓一定有效。扩展规则的偏差更明显：`top_theme_share>=0.50` 在 ETF 双池中触发太频繁，虽然降低了暴露和最大回撤，但把 2024 Q4 和 2026 年 3 月后的强趋势段收益明显削弱，属于典型的过宽风险标签。

## 16. 研究判断

最终状态：`completed / formal_completed_failed_no_promote`

理由：四段三组 formal V2 已完成且汇总严格通过完整性门槛，但两个交易化预算变体均未满足事前预测。`financial_top1_cap70` 不具备稳定收益和回撤优势；`financial_or_share_ge050_cap70` 的回撤改善来自过宽降暴露，机会成本过大。  
路线结论：不 promote、不默认打开、不继续在本轮参数附近扫阈值。主题簇保留为只读诊断和归因维度；交易化风险预算路线暂停，见 [[05_研究决策/DEC-20260607T235302Z-main-8GQQ_主题簇金融风险预算formal失败后暂停决策|8GQQ 决策]]。

## 17. 下一步

- 停止 `financial_top1_cap70` 和 `financial_or_share_ge050_cap70` 进入默认逻辑、shadow 或实盘。
- 不做 60/80 cap、0.45/0.55 share_min、更多主题词或更多阈值的后验网格。
- 若未来继续主题簇方向，只能新开预注册：更窄标签、滞后一日触发、随机/错位主题负控、成本扰动、以及和 A22/A23 的交互消融都必须事前写清。
- 更新 KC7N 方向页、实验台账、决策台账、驾驶舱、当前状态和 Canvas。
