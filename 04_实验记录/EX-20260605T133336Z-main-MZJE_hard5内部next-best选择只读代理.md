---
type: 实验记录
ex_id: EX-20260605T133336Z-main-MZJE
rd_id: RD-20260605T133318Z-main-H6V3
status: completed
stage: readonly_done
owner: main
created_at: 2026-06-05T13:33:36Z
updated_at: 2026-06-05T13:33:36Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 核心轮动风控诊断模块
decision_ids: [DEC-20260605T133351Z-main-ECU2]
lit_ids: [LIT-20260605T133336Z-main-67C4]
idea_ids: []
platform_project: E:\量化平台_V1.4.0
config_paths: []
result_paths:
  - E:/量化平台_V1.4.0/results/v2/research/R010-A15/hard5_next_best_proxy/
summary_paths:
  - E:/量化平台_V1.4.0/results/v2/research/R010-A15/hard5_next_best_proxy/next_best_summary.json
quality_gate: readonly_reject_trade_candidate_keep_diagnostic
legacy_research_id: R20260605-095
legacy_direction_id: R010-A15
tags: [双池轮动, score-cap, hard5, next-best, 只读审计]
---

# hard5 内部 next-best 选择只读代理

## 关联链接

- 研究方向：[[02_研究方向/RD-20260605T133318Z-main-H6V3_双池轮动score过热拥挤机制模块]]
- 上一实验：[[04_实验记录/EX-20260605T133336Z-main-UBVU_非金融高分放行关键窗口失败复核]]
- 产生的决策：[[05_研究决策/DEC-20260605T133351Z-main-ECU2_hard5 next-best通用selector不晋级]]

## 1. 新手摘要

这次实验想知道：raw Top1 因 `score >= 5` 被 hard5 过滤时，是否可以不放行 raw Top1，而是在 `score < 5` 候选池里选一个更好的 next-best 标的。  
我们原本预计：用 R2、成交量惩罚或同主题排序，可能比当前 hard5_first 更好。  
实际看到：最好的 `r2_first` H10 均值相对 hard5 为 `+1.8034%`，但胜率只有 `39.76%`，且 2024 分段为 `-4.3112%`。  
这说明：通用 next-best selector 不能晋级。  
下一步要做：拆分资产属性，避免把商品 LOF、债券 ETF、跨境 ETF 和权益主题 ETF 混在一起。

## 2. 研究背景

A14 已经证明粗主题放行失败。A15 把问题缩到 hard5 过滤事件内部，只比较 `score < 5` 的 Top10 候选，检验是否能替换当前 hard5_first。

## 3. 实验前假设

如果 hard5_first 只是机械选择第一个 `score < 5` 候选，那么使用 R2、成交量或主题信息的 selector 可能提升被过滤事件后的 H10 前瞻收益。

## 4. 实验前预测

- 合格 selector 的 H10 diff mean 应为正。
- H10 win rate 应达到 55% 以上。
- 2024、2025、2026_to_date 不应出现明显负段。
- 若只均值为正但胜率低或分段不稳，只能保留诊断。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| hard5_first | 当前 hard5 选择的替代目标 | R010-A15 event panel |
| score_volume_penalty | 成交量惩罚版 | R010-A15 event panel |
| score_r2_volume | 分数、R2、成交量综合 | R010-A15 event panel |
| r2_first | R2 优先 | R010-A15 event panel |
| low_volume_r2 | 低成交量冲击下 R2 优先 | R010-A15 event panel |
| same_theme_score_r2_volume | 同主题内排序 | R010-A15 event panel |
| anti_cluster_score_r2 | 反拥挤主题数量过滤 | R010-A15 event panel |
| mid_score_r2 | 中等分数与 R2 | R010-A15 event panel |

## 6. 竞争性解释

- close-to-close 前瞻收益不是组合回测收益。
- selector 改善可能来自切入债券或低波资产，而非更好动量排序。
- 主题标签过粗，`其他` 桶不是稳定主题。
- 少数 2025/2026 商品事件可能拉高均值。

## 7. 证伪条件

若最佳 selector 同时不满足胜率和分段稳定性，则不进入 formal。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 初步通过 | 读取既有 R010-A11 top_candidates 和 daily_events |
| 信号生成和成交价格不存在同 bar 泄漏 | 待 formal 复核 | 本实验仅事件级前瞻代理 |
| ETF 池不存在未来成分泄漏 | 待平台复核 | 沿用 R010-A11 静态候选 |
| Shadow 或观察信号未被当成默认交易信号 | 通过 | 未改策略，未生成 formal 配置 |

负控或错位检查：以 hard5_first 为零差基准，所有 selector 仅相对它比较。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 部分通过 | 固定 8 个简单 selector |
| 样本内、验证集、样本外划分清晰 | 部分通过 | 做了 2024/2025/2026 分段 |
| 成本、滑点或换手扰动已检查 | 未完成 | 只读事件代理 |
| 已做消融或负控 | 通过 | hard5_first 基准和多 selector 对照 |
| 未只报告最优结果 | 通过 | 全部 selector 结果记录 |

证据等级：L1-L2。适合诊断，不适合交易晋级。

## 10. 执行记录

### 平台配置

```text
不适用。只读脚本未生成 formal 配置。
```

### 运行命令

```bash
python E:/量化平台_V1.4.0/scripts/research/analyze_r010a15_hard5_next_best_proxy.py
```

### 结果路径

```text
E:/量化平台_V1.4.0/results/v2/research/R010-A15/hard5_next_best_proxy/
```

## 11. 实际观察

事件数：212。候选行数：2120。

| selector | H10 diff mean vs hard5 | H10 win rate vs hard5 | changed rate |
| --- | ---: | ---: | ---: |
| hard5_first | 0.0000% | 0.00% | 0.00% |
| score_volume_penalty | +0.4403% | 16.27% | 21.70% |
| score_r2_volume | +0.7099% | 22.29% | 25.94% |
| r2_first | +1.8034% | 39.76% | 56.13% |
| low_volume_r2 | +1.2401% | 38.55% | 53.77% |
| same_theme_score_r2_volume | +1.6599% | 15.15% | 20.28% |
| anti_cluster_score_r2 | +1.4204% | 27.71% | 37.74% |
| mid_score_r2 | +0.7840% | 25.30% | 41.04% |

`r2_first` 分段：

| segment | events | H10 diff mean | win rate | changed rate |
| --- | ---: | ---: | ---: | ---: |
| 2024 | 37 | -4.3112% | 8.70% | 37.84% |
| 2025 | 109 | +2.2558% | 33.73% | 44.04% |
| 2026_to_date | 66 | +3.5216% | 60.00% | 86.36% |

## 12. 支持证据

- `r2_first` 虽有正均值，但胜率和分段稳定性不足。
- 2024 明确为负，不能作为默认交易候选。
- 所有通用 selector 都未通过 H10 胜率 55% 和无负段门槛。

## 13. 反对证据

- 2026_to_date 的 `r2_first` 对 commodity_lof 事件表现较好，说明局部资产属性可能存在研究价值。
- `same_theme_score_r2_volume` 在 2025 commodity_lof 上均值较强，但后续 A18 显示这是粗主题标签导致的混合效应。

## 14. 偏差诊断

实验前预期 next-best 排序可能能修复 hard5_first 的机械性，但实际表现说明 selector 改善不稳定。更重要的是，A15 暴露出 `其他` 主题中混入商品 LOF、债券 ETF 和跨境 ETF，需要先做资产属性分层。

## 15. 研究判断

建议状态：`kill` 通用 selector，`observe` 资产属性诊断。

理由：通用 selector 不晋级，但事件面板可作为后续 A18 输入。

## 16. 下一步

进入 [[04_实验记录/EX-20260605T133336Z-main-DMB9_资产属性标签审计与hard5事件拆分]]，先修正资产属性标签。

## 子代理调用记录

- 调用状态：exempt
- 子代理豁免：历史实验记录在子代理强制门禁生效前创建；主控：main；时间：2026-06-06T00:23:50Z
- 后续要求：若本实验用于新决策、路线升级或当前最佳策略判断，必须补充子代理复核记录并同步 `01_台账/子代理调用台账.csv`。
