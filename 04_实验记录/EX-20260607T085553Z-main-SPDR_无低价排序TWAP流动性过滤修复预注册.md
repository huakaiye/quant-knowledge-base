---
type: 实验记录
ex_id: EX-20260607T085553Z-main-SPDR
rd_id: RD-20260603T000000Z-mig-HD5EEBAA8D5EEB
status: completed
stage: completed_failed_simple_capacity_repair
owner: main
created_at: 2026-06-07T08:55:53Z
updated_at: 2026-06-07T17:20:00+08:00
strategy_id:
module_type: microcap_no_low_liquidity_twap_repair
decision_ids:
  - DEC-20260607T084625Z-main-582N
  - DEC-20260607T091838Z-main-YMEP
lit_ids:
  - LIT-20260607T081500Z-main-JQML
idea_ids: []
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths:
  - configs/research/RD-20260603T000000Z-mig-HD5EEBAA8D5EEB/EX-20260607T085553Z-main-SPDR/public_micro_no_low_liquidity_twap.json
result_paths:
  - results/v2/research/RD-20260603T000000Z-mig-HD5EEBAA8D5EEB/EX-20260607T085553Z-main-SPDR/
summary_paths:
  - results/v2/research/RD-20260603T000000Z-mig-HD5EEBAA8D5EEB/EX-20260607T085553Z-main-SPDR/summary/twap_scorecard.csv
  - results/v2/research/RD-20260603T000000Z-mig-HD5EEBAA8D5EEB/EX-20260607T085553Z-main-SPDR/summary/twap_variant_segment_metrics.csv
  - results/v2/research/RD-20260603T000000Z-mig-HD5EEBAA8D5EEB/EX-20260607T085553Z-main-SPDR/summary/twap_future_function_audit.json
quality_gate: completed_failed_buy_completion_and_exposure
subagent_call_ids:
  - SUB-20260607T090000Z-main-NOLOW-REPAIRCHECK
subagent_exemption:
tags:
  - 微盘
  - 无低价排序
  - TWAP
  - 流动性过滤
  - 失败
---

# 无低价排序TWAP流动性过滤修复预注册

## 关联链接

- 研究方向：[[02_研究方向/RD-20260603T000000Z-mig-HD5EEBAA8D5EEB_小市值T0——研究总结|小市值 T0]]
- 来源实验：[[04_实验记录/EX-20260607T081421Z-main-S5D6_微盘市值篮子TWAP容量感知修复预注册|S5D6 微盘市值篮子 TWAP 容量感知修复]]
- 来源决策：[[05_研究决策/DEC-20260607T084625Z-main-582N_微盘TWAP容量修复后观察决策|582N 微盘 TWAP 容量修复后观察决策]]
- 本轮决策：[[05_研究决策/DEC-20260607T091838Z-main-YMEP_无低价排序TWAP简单容量修复失败决策|YMEP 无低价排序 TWAP 简单容量修复失败决策]]
- 来源文章：[[06_文献资料/00_待处理/LIT-20260607T081500Z-main-JQML_聚宽公开微盘低价涨停保护策略|聚宽公开微盘低价涨停保护策略]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

S5D6 证明 `strict_base` 经过 TWAP 后可以观察，但也发现更有潜力的是 `no_low_price_sort`：它收益更高、回撤更低，只是买入完成率差一点，没有过 95% 门槛。

本实验尝试最小修复：历史流动性过滤和 10:00-10:45 宽买入窗口。结果显示，收益和回撤仍强，但所有候选买入完成率都只有 `94.08%-94.29%`，没有过 `95%`。平均持仓数也只有约 `33-40`，低于预注册的 45。

结论：无低价排序版本的收益种子仍然强，但“简单过滤/延长 15 分钟窗口”不能修复容量。下一步如果继续，必须新开分日建仓或盘口级执行实验；不能继续小幅调窗口。

## 2. 研究方向 ID

`RD-20260603T000000Z-mig-HD5EEBAA8D5EEB`

## 3. 本次假设

`no_low_price_sort` 的失败主要是少数目标股历史同窗口容量不足，而不是无低价排序信号本身不可交易。加入信号日前历史流动性过滤，或把买入窗口从 30 分钟拉长到 45 分钟，应能把买入完成率推过 95%，同时保留相对 `strict_base` 的收益优势。

## 4. 实验前预测

- 5 日历史过滤更贴近近期容量，可能比 20 日过滤保留更多标的，但稳定性更弱。
- 20 日历史过滤更稳健，可能提高买入完成率，但可能因目标列表减少而牺牲部分收益。
- 10:00-10:45 宽窗口不改变目标列表，若通过成交门槛，说明主要问题是窗口太短；若收益明显变差，说明价格漂移不可忽略。
- p05 + 20 日过滤用于判断轻微提高参与率是否足以修复成交，不使用 p10，避免用较激进参与率硬冲门槛。

## 5. 基准对照

| 基准 | 作用 | 指标 |
| --- | --- | --- |
| S5D6 `strict_base_p03` | 当前可观察基准 | 收益 `+453.73%`、最大回撤 `-20.98%`、买入完成率 `95.44%` |
| S5D6 `no_low_price_sort_p03/p05/p10` | 待修复对象 | 收益 `+625.42%/+612.46%/+600.02%`，买入完成率 `94.06%-94.57%` |
| S5D6 `stock80` | 扩持仓数失败对照 | 买入完成率约 `91%` |

## 6. 竞争性解释

- 历史流动性过滤可能只是降低仓位暴露，而不是修复执行。
- 45 分钟窗口可能引入新的价格漂移，收益改善或恶化不一定来自容量。
- 真实盘口容量可能明显小于分钟成交额模型。
- `no_low_price_sort` 的高收益可能来自微盘市值暴露，和排序规则无关。

## 7. 证伪条件

本实验若出现以下任一情况，不得升级：

- 所有候选买入完成率仍低于 `95%`。
- 通过成交门槛的候选收益低于 `+453.73%`。
- 最大回撤差于 `-25%`。
- 2025_20260605 分段收益低于 `-5%`。
- 平均持仓数低于 45，说明过滤导致暴露不足。
- 子代理或主控发现历史流动性过滤读取了 `signal_date` 之后的数据。

## 8. 平台配置与结果路径

配置路径：

```text
configs/research/RD-20260603T000000Z-mig-HD5EEBAA8D5EEB/EX-20260607T085553Z-main-SPDR/public_micro_no_low_liquidity_twap.json
```

结果路径：

```text
results/v2/research/RD-20260603T000000Z-mig-HD5EEBAA8D5EEB/EX-20260607T085553Z-main-SPDR/
```

## 9. 预注册候选

| 变体 | 目标列表 | 买入窗口 | 参与率 | 历史过滤 |
| --- | --- | --- | ---: | --- |
| `no_low_hl5d_w30_p03` | `no_low_price_sort` | 10:00-10:30 | 3% | 5 日同窗口 |
| `no_low_hl20d_w30_p03` | `no_low_price_sort` | 10:00-10:30 | 3% | 20 日同窗口 |
| `no_low_w45_p03` | `no_low_price_sort` | 10:00-10:45 | 3% | 无 |
| `no_low_hl20d_w30_p05` | `no_low_price_sort` | 10:00-10:30 | 5% | 20 日同窗口 |

## 10. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 历史流动性过滤 | pass_design | `history_liquidity_filter` 只使用 `signal_date` 前 5 或 20 个交易日同窗口分钟 `turnover`。 |
| 买入执行 | pass_design | `execute_twap_buy` 只使用执行日 `buy_window` 内分钟 `turnover/open_price` 和停牌/涨跌停条件。 |
| 涨停开板卖出 | pass_design | 沿用 S5D6 修正版，只使用 `limitup_sell_window` 内分钟状态。 |
| 输出审计 | not_live_ready | 仍为分钟 K 线容量模拟，不含盘口队列、封单、撤单重试和真实冲击成本。 |

审计文件状态：`public_micro_twap_repair_checked_not_live_ready`

## 11. 子代理调用记录

适配判断：适合调用。涉及新配置是否复用已有脚本、历史流动性过滤是否事前可得、候选矩阵是否过度扩展。

调用状态：`called`

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-20260607T090000Z-main-NOLOW-REPAIRCHECK | Averroes | SUBTASK-20260607T090000Z-main-NLRC_子查_无低价排序容量修复配置审计 | gpt-5.3-codex-spark | 2026-06-07T09:00:00Z | TWAP 脚本、S5D6 配置与 summary | 无 | 只读核对 | 只给配置和风险建议，不判断策略有效性 | 宽窗口改变价格路径；分日建仓需要新脚本；分钟模型仍非盘口级 | 已采纳并收窄为 4 组 | 限制本轮不使用 p10 和分日建仓 |

台账行：已同步 `01_台账/子代理调用台账.csv`。

## 12. 执行记录

### Smoke

```bash
PYTHONUNBUFFERED=1 PYTHONPATH=src python3 scripts/research/backtest_public_micro_twap_repair.py --config configs/research/RD-20260603T000000Z-mig-HD5EEBAA8D5EEB/EX-20260607T085553Z-main-SPDR/public_micro_no_low_liquidity_twap.json --smoke 2>&1 | tee results/v2/research/RD-20260603T000000Z-mig-HD5EEBAA8D5EEB/EX-20260607T085553Z-main-SPDR/smoke.log
```

### 正式回测

第一次正式运行完成计算后因配置缺 `segments` 在写 summary 阶段报错，记为工程设置问题，不作为正式结论。补齐 `segments` 后用 `set -o pipefail` 重跑成功。

```bash
set -o pipefail
PYTHONUNBUFFERED=1 PYTHONPATH=src python3 scripts/research/backtest_public_micro_twap_repair.py --config configs/research/RD-20260603T000000Z-mig-HD5EEBAA8D5EEB/EX-20260607T085553Z-main-SPDR/public_micro_no_low_liquidity_twap.json 2>&1 | tee results/v2/research/RD-20260603T000000Z-mig-HD5EEBAA8D5EEB/EX-20260607T085553Z-main-SPDR/public_micro_no_low_liquidity_twap_rerun.log
```

## 13. 实际观察

| 变体 | 总收益 | 最大回撤 | Sharpe | 2025_20260605 | 买入完成率 | 卖出完成率 | 平均持仓数范围 | 通过 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| `no_low_hl5d_w30_p03` | `+629.68%` | `-18.81%` | `1.954` | `+29.58%` | `94.23%` | `97.66%` | `33.06-39.75` | 否 |
| `no_low_hl20d_w30_p03` | `+625.64%` | `-18.42%` | `1.969` | `+28.30%` | `94.08%` | `97.62%` | `33.78-39.76` | 否 |
| `no_low_w45_p03` | `+610.55%` | `-18.55%` | `1.955` | `+27.94%` | `94.24%` | `97.72%` | `33.75-39.76` | 否 |
| `no_low_hl20d_w30_p05` | `+612.73%` | `-18.55%` | `1.951` | `+27.33%` | `94.29%` | `98.75%` | `33.73-39.71` | 否 |

## 14. 支持证据

- 收益和回撤仍强，所有候选收益均高于 S5D6 `strict_base_p03`。
- 2025_20260605 近端分段均为正，说明不是单纯远端历史贡献。
- 卖出完成率均高于 `95%`。

## 15. 反对证据

- 所有候选买入完成率仍低于 `95%`，核心证伪条件触发。
- 平均持仓数低于 45，说明历史过滤没有健康修复容量，而是降低了暴露后仍没过门槛。
- 10:00-10:45 宽窗口只把买入完成率提高到 `94.24%`，不能解释为窗口太短即可修复。

## 16. 研究判断

建议状态：`revise`

无低价排序收益种子仍然保留，但本轮“简单历史过滤/45 分钟窗口”修复失败。后续不得继续在 5 日、20 日、30 分钟、45 分钟附近做小网格；如果继续，必须新开更大结构变化的分日建仓或盘口级容量实验。

## 17. 下一步

优先级降低。微盘路线当前保留 S5D6 `strict_base` 默认关闭观察；`no_low_price_sort` 只有在愿意实现分日建仓、真实盘口队列或更严格成交模型时才继续推进。
