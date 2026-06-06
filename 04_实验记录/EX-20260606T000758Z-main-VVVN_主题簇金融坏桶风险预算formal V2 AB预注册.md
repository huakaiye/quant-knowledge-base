---
type: 实验记录
ex_id: EX-20260606T000758Z-main-VVVN
rd_id: RD-20260605T131301Z-main-KC7N
status: active
stage: partial_smoke_completed_full_formal_pending
owner: main
created_at: 2026-06-06T00:07:58Z
updated_at: 2026-06-06T01:08:00Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 核心轮动风险预算模块
decision_ids: [DEC-20260605T235338Z-main-WVZZ]
lit_ids: [LIT-20260603T000000Z-mig-1999MOSKOWITZ83801, LIT-20260605T133500Z-main-E46H, LIT-20260603T000000Z-mig-2015BARROSO7DA3F, LIT-20260603T000000Z-mig-2016DANIEL20500, LIT-20260605T133336Z-main-67C4]
idea_ids: []
platform_project: E:\量化平台_V1.4.0
config_paths:
  - E:/量化平台_V1.4.0/configs/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/
result_paths:
  - E:/量化平台_V1.4.0/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/
summary_paths:
  - E:/量化平台_V1.4.0/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/summary/summary.json
quality_gate: preregistered_before_execution
subagent_call_ids: []
subagent_exemption: "子代理豁免：当前子代理工具约束要求只有用户明确要求调用子代理时才可 spawn；本实验仍为 active，未进入 completed；主控：main；时间：2026-06-06T01:08:00Z"
tags: [双池轮动, 主题簇, 金融坏桶, 风险预算, formal-v2, AB, 非hard5]
---

# 主题簇金融坏桶风险预算formal V2 AB预注册

## 关联链接

- 研究方向：[[02_研究方向/RD-20260605T131301Z-main-KC7N_双池轮动主题簇主线确认模块|双池轮动主题簇主线确认模块]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 前置实验：[[04_实验记录/EX-20260605T234635Z-main-CTRD_主题簇主线确认收益归因与负控预注册|主题簇主线确认收益归因与负控预注册]]
- 前置决策：[[05_研究决策/DEC-20260605T235338Z-main-WVZZ_主题簇强主线不作为正向放行条件|主题簇强主线不作为正向放行条件]]
- 来源文献或灵感：[[06_文献资料/08_已归档/LIT-20260603T000000Z-mig-1999MOSKOWITZ83801_L20260531-031DoIndustriesExplainMomentum|Do Industries Explain Momentum?]]；[[06_文献资料/00_待处理/LIT-20260605T133500Z-main-E46H_Time Series Momentum|Time Series Momentum]]；[[06_文献资料/08_已归档/LIT-20260603T000000Z-mig-2015BARROSO7DA3F_L20260521-003MomentumHasItsMoments|Momentum Has Its Moments]]；[[06_文献资料/08_已归档/LIT-20260603T000000Z-mig-2016DANIEL20500_L20260521-004MomentumCrashes|Momentum Crashes]]
- 产生的决策：
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：把主题簇里的金融 top1 和过度主题集中当成风险标签后，做固定 70% 风险仓预算，是否能改善双池轮动的真实组合路径。  
我们原本预计：金融 top1 或高集中度不是加仓信号，而是更像追高、拥挤或风格切换风险；降低风险仓可能减少回撤，收益不能明显低于基准。  
实际看到：已完成 2025_20260519 单段 smoke：baseline 正常产出 330 条主题 shadow；`financial_top1_cap70` 触发 16 次，能把风险仓从 100% 降到 70%，防御 ETF 补足 30%。但该单段相对 baseline 总收益低约 1.93 个百分点，最大回撤略差。  
这说明：实现链路可运行，预算字段可审计；但 2025 单段先给出反对信号，不能据此推进。  
但还不能说明：即使本轮 A/B 变好，也不能直接说明主题风险预算已可 promote，因为还缺成本扰动、邻近参数和更严格的负控。  
下一步要做：继续补齐剩余四段 formal V2 和高集中度扩展变体，完成后再做正式判断。

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
| A11 cap5 tiered v2 baseline | 主基准，重跑同一份 A11 配置，只打开主题 shadow，不打开主题预算 | `E:/量化平台_V1.4.0/configs/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/baseline/` |
| `financial_top1_cap70` | 主变体，仅金融 top1 时把风险仓 cap 到 70% | `E:/量化平台_V1.4.0/configs/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/financial_top1_cap70/` |
| `financial_or_share_ge050_cap70` | 扩展变体，金融 top1 或主题集中度不低于 50% 时 cap 到 70% | `E:/量化平台_V1.4.0/configs/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/financial_or_share_ge050_cap70/` |
| B7VH/CTRD shadow 归因 | 解释触发依据，但不作为本轮交易结果 | `E:/量化平台_V1.4.0/results/v2/research/R010-THEME/EX-20260605T234635Z-main-CTRD/forward_attribution/` |

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
| 数据时间戳只使用当时可得信息 | 部分通过 | 2025 smoke 中触发记录来自当日 `raw_post_score_filter` 主题 shadow 字段；全量四段仍待完成 |
| 信号生成和成交价格不存在同 bar 泄漏 | 部分通过 | 复用平台午后信号和既有成交流程，不引入未来收益；全量四段仍待完成 |
| 股票池或 ETF 池不存在未来成分泄漏 | 沿用基准 | 不新增 ETF 池，不更新数据 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 不使用财务、宏观或估值数据 |
| Shadow 或观察信号未被当成默认交易信号 | 部分通过 | 新参数默认关闭；只在 `EX-20260606T000758Z-main-VVVN` 生成配置中打开 |

负控或错位检查：

- 本轮不是归因面板，先做正式 A/B。若结果进入候选，下一轮必须增加随机金融标签或错位主题标签 A/B。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | 只测两个固定变体，cap 固定 70%，share_min 固定 0.50 |
| 样本内、验证集、样本外划分清楚 | 通过 | 沿用 A11 四段 formal V2 |
| 邻近参数敏感性合理 | 待检查 | 本轮不做，若候选有效再预注册 60/80 或 0.45/0.55 |
| 成本、滑点或换手扰动已检查 | 待检查 | 本轮先用 A11 默认成本，候选有效后再做扰动 |
| 已做消融或负控 | 部分待检查 | 有基准 A/B；错位/随机标签 A/B 留到下一轮 |
| 未只报告最优结果 | 待检查 | 目前只完成 2025 smoke；正式结论必须等待两个变体和四段全部输出 |

证据等级：预期最高 `L3_formal_v2_candidate`。本轮即使有效，也只能是候选，不能直接 `promote`。

## 10. 子代理调用记录

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：当前子代理工具约束要求只有用户明确要求调用子代理时才可 spawn；本轮先补齐 active 实验的规范字段和执行记录，不进入 completed，也不做路线决策；主控：main；时间：2026-06-06T01:08:00Z
```

| 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 主控-002-VVVN规范补齐 | 无 | 2026-06-06T01:08:00Z | `AGENTS.md`; `08_方法论/子代理调度规范.md`; `08_方法论/平台协作规范.md`; 本实验记录 | 本实验记录 | `pgrep`; `git status`; 文件读取 | 只做规范补齐和状态校正，不替代子查/子研审计 | 未调用子代理，正式 completed 前仍需子查路径/字段审计或重新写明豁免 | 主控确认本实验仍为 active，不能作为正式结论 | 不改变路线，不新增决策 |

台账行：不新增 `01_台账/子代理调用台账.csv`，因为本轮没有实际子代理调用；豁免已写入 frontmatter 和正文。若后续进入 completed，必须调用子查/子研或重新写明豁免，并满足健康检查。

## 11. 执行记录

### 平台配置

```text
计划生成：
E:/量化平台_V1.4.0/configs/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/baseline/theme_baseline_tiered_v2_*.json
E:/量化平台_V1.4.0/configs/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/financial_top1_cap70/theme_financial_top1_cap70_tiered_v2_*.json
E:/量化平台_V1.4.0/configs/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/financial_or_share_ge050_cap70/theme_financial_or_share_ge050_cap70_tiered_v2_*.json

已生成 12 个配置：
E:/量化平台_V1.4.0/configs/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/
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
wsl -- bash -c "cd /mnt/e/量化平台_V1.4.0 && PYTHONPATH=src PYTHONIOENCODING=utf-8 python3 scripts/research/summarize_r010theme_risk_budget.py --ex-id EX-20260606T000758Z-main-VVVN --segments 2025_20260519"
```

### 可见进度与日志

- 是否过程可见：部分可见。baseline smoke 起初用前台命令运行，但 shell 超时后平台进程继续运行，主控通过 `pgrep`、`ps` 和平台 `logs.jsonl` 轮询进度；`financial_top1_cap70` smoke 曾用 `Start-Process -WindowStyle Hidden` 后台运行，并写入 stdout/stderr 日志。
- 日志路径：
  - `E:/量化平台_V1.4.0/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/baseline/2025_20260519/9c503d35bed2426d8bef809dcacac59a/logs.jsonl`
  - `E:/量化平台_V1.4.0/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/financial_top1_cap70/2025_20260519/f4a48fa9e9014c84a9d1d2515c544656/logs.jsonl`
  - `E:/量化平台_V1.4.0/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/run_financial_top1_2025.stderr.log`
  - `E:/量化平台_V1.4.0/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/run_financial_top1_2025.stdout.log`
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
日志路径：E:/量化平台_V1.4.0/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/run_financial_top1_2025.stderr.log
查看进度：wsl -- bash -c "pgrep -af 'EX-20260606T000758Z-main-VVVN|run_v2_backtest.py' || true"
停止方式：无残留进程；若未来后台运行，使用 wsl -- bash -c "kill <pid>"。
预计耗时：2025 单段约 10-15 分钟；四段全量预计显著更长。
```

### 结果路径

```text
计划：
E:/量化平台_V1.4.0/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/
E:/量化平台_V1.4.0/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/summary/

已产出：
E:/量化平台_V1.4.0/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/baseline/2025_20260519/9c503d35bed2426d8bef809dcacac59a/
E:/量化平台_V1.4.0/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/financial_top1_cap70/2025_20260519/f4a48fa9e9014c84a9d1d2515c544656/
E:/量化平台_V1.4.0/results/v2/research/R010-THEME/EX-20260606T000758Z-main-VVVN/risk_budget/summary/summary.json
```

## 12. 实际观察

| 指标 | 基准 | 本次 | 变化 | 解释 |
| --- | --- | --- | --- | --- |
| 2025 final value | `317973.61` | `316042.77` | `-1930.84` | `financial_top1_cap70` 单段低于 baseline |
| 2025 total return | `2.1797361` | `2.1604277` | `-0.0193084` | 约低 1.93 个百分点 |
| 2025 max drawdown | `-0.1656700` | `-0.1656887` | `-0.0000186` | 回撤极小幅变差，不支持风控改善 |
| 2025 trades | `464` | `470` | `+6` | 降仓触发带来轻微换手增加 |
| 主题 shadow 记录 | `330` | `330` | 一致 | baseline 和预算变体均有完整主题记录 |
| 风险预算触发 | `0` | `16` | `+16` | 触发原因均为 `bad_theme_top1=金融` |

## 13. 支持证据

- 平台策略已新增默认关闭的 `r010theme_risk_budget_enabled`，默认参数不影响生产。
- 生成脚本已产出 baseline 和两个固定变体的四段配置，共 12 个 JSON。
- 2025 smoke 中，`financial_top1_cap70` 有 330 条预算检查、16 次触发、0 个日志错误。
- 触发记录显示 `applied_action=A0+THEME_BUDGET`，`weights` 从金融 top1 100% 变为金融 top1 70% + 防御 ETF 30%，实现符合预注册。

## 14. 反对证据

- 2025 smoke 中 `financial_top1_cap70` 总收益低于 baseline 约 1.93 个百分点。
- 2025 smoke 中最大回撤略差，未体现风险预算预期的回撤改善。
- 交易次数从 464 增至 470，说明降仓预算可能引入额外换手。
- 当前只完成 2025 单段和一个变体，不能支持正式结论。

## 15. 偏差诊断

当前只完成 2025 单段 smoke，不能替代四段 formal。偏差在于前置 CTRD 显示金融 top1 的 H10 事件后路径较弱，但交易化 cap70 在 2025 单段反而降低最终收益且回撤略差，说明事件后均值弱不等于组合路径中降仓一定有效。可能原因是金融 top1 触发时后续仍有趋势延续，或防御 ETF 替代收益不足，或降仓带来额外换手。

## 16. 研究判断

建议状态：`active / full_formal_pending`

理由：实现和 2025 单段 smoke 通过，但完整实验要求的 baseline、两个变体、四段 formal V2 尚未完成。当前 2025 单段对 `financial_top1_cap70` 不利，只能作为反对信号，不能写成正式结论。

## 17. 下一步

继续运行剩余 formal V2：

- `baseline` 的 2020_2021、2022_2023、2024。
- `financial_top1_cap70` 的 2020_2021、2022_2023、2024。
- `financial_or_share_ge050_cap70` 的四段。

全量完成后再用 `summarize_r010theme_risk_budget.py --strict` 汇总，并决定是否新建决策卡。
