---
type: 实验记录
ex_id: EX-20260605T151211Z-main-JDPL
rd_id: RD-20260605T133318Z-main-H6V3
status: completed
stage: formal_key_window_done
owner: main
created_at: 2026-06-05T15:12:11Z
updated_at: 2026-06-05T15:40:00Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 核心轮动风控诊断模块
decision_ids: [DEC-20260605T151211Z-main-YFNK]
lit_ids: [LIT-20260605T133336Z-main-67C4]
idea_ids: []
platform_project: 'E:\量化平台_V1.4.0'
config_paths:
  - 'E:\量化平台_V1.4.0\configs\research\R010-A17\conditional_hot_state'
result_paths:
  - 'E:\量化平台_V1.4.0\results\v2\research\R010-A17\conditional_hot_state'
summary_paths:
  - 'E:\量化平台_V1.4.0\results\v2\research\R010-A17\conditional_hot_state\conditional_v1\2025_20260519\cee31a9eba3347409be8093aacc21220\summary.json'
  - 'E:\量化平台_V1.4.0\results\v2\research\R010-A17\conditional_hot_state\conditional_v2_smooth\2025_20260519\18492641e0a14b8dbbb8636e6399878f\summary.json'
quality_gate: L2_formal_key_window
tags: [双池轮动, score-cap, hard5, A17, formal-v2, 过热拥挤]
---

# 条件化 score 过热过滤 formal V2 关键窗口回测

## 关联链接

- 研究方向：[[02_研究方向/RD-20260605T133318Z-main-H6V3_双池轮动score过热拥挤机制模块]]
- 前置实验：[[04_实验记录/EX-20260605T135028Z-main-76GD_score大于5过滤状态面板诊断]]
- 产生的决策：[[05_研究决策/DEC-20260605T151211Z-main-YFNK_A17条件化hard5不晋级且保留hard5基线]]
- 文献映射：[[06_文献资料/00_待处理/LIT-20260605T133336Z-main-67C4_score过热拥挤机制文献映射]]

## 1. 新手摘要

这次实验想知道：能不能把“score 大于 5 就直接过滤”的 hard5，改成“只有接近 252 日高点、成交额冲击、路径异常时才过滤”。

实际结果分成两端：`conditional_v1` 太松，放出了大量异常高分和路径跳变标的，关键窗口总收益 `-63.40%`、最大回撤 `-76.54%`；修复实现问题后的 `conditional_v2_smooth` 产生了非 hard5 的经济路径，但总收益 `+199.88%` 低于 hard5 的 `+217.97%`，最大回撤 `-20.51%` 深于 hard5 的 `-16.57%`。

结论：A17 这组条件化 hard5 不晋级，不能替代默认 hard5。当前也不能简单废除 hard5。下一步应转向两个更可检验的方向：先做复权/异常价格闸，防止 v1 暴露的 ETF 份额调整风险；再研究非二元过热预算或仓位缩放，而不是继续做粗放行/粗过滤。

## 2. 实验前假设

A16 显示 `score > 5` 单独硬过滤存在明显机会成本，212 个 hard5 事件中 raw Top1 的 H10 均值约 `+1.98%`，hard5 备选约 `-0.96%`。因此本轮假设是：如果用近 252 日高点、成交量冲击和平滑路径来确认真实过热，就能放行一部分被误杀的强趋势，同时不引入 v1 类尾部风险。

## 3. 对照设计

| 变体 | 定义 | 目的 |
| --- | --- | --- |
| A11 hard5 | 默认 `score_hot_filter_mode=hard_cap, max_score=5` | 当前正式基线 |
| A17 conditional_v1 | `max_score=9999`，仅在近高点且成交量冲击时过滤 | 测试弱条件门能否释放机会 |
| A17 conditional_v2_smooth | v1 + `R2>=0.82`、`-2%<=ret5<=12%`、20 日跳变限制 | 屏蔽异常暴涨、急跌和复权错配 |
| A12 lit_gate6 | 文献变量启发的 6 分门控 | 作为收益/回撤 trade-off 参照 |

## 4. 执行记录

```powershell
python -m py_compile 'src\strategies\research\etf_dual_pool_r010b_action_ablation.py' 'scripts\research\build_r010a17_conditional_hot_configs.py'
python 'scripts\research\build_r010a17_conditional_hot_configs.py'
$env:PYTHONPATH='src'; python 'src/run_v2_backtest.py' --config 'configs/research/R010-A17/conditional_hot_state/conditional_v2_smooth/r010a17_conditional_v2_smooth_tiered_v2_2025_20260519.json' --dry-run --allow-non-wsl
$env:PYTHONPATH='src'; python 'src/run_v2_backtest.py' --config 'configs/research/R010-A17/conditional_hot_state/conditional_v2_smooth/r010a17_conditional_v2_smooth_tiered_v2_2025_20260519.json' --allow-non-wsl
```

关键平台改动均为 default-off：默认 `max_score=5`、`score_hot_filter_mode=hard_cap` 不变；A17 只通过配置启用 `conditional_hot_state`。

## 5. 关键窗口结果

区间：`2025-01-01` 至 `2026-05-19`，初始资金 `100000`。

| 变体 | 最终权益 | 总收益 | 年化 | 最大回撤 | 成交笔数 | job |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| A11 hard5 | 317,973.61 | +217.97% | +131.89% | -16.57% | 464 | b89a2425e70f4b6e85f9450e3316cdeb |
| A11 hard6 | 205,102.76 | +105.10% | +68.59% | -24.89% | 456 | c204507a87db48bda8ecb4d8d8b6793b |
| A11 quality_gate6 | 232,029.74 | +132.03% | +84.41% | -23.34% | 430 | 74e1538bbc55478a8d5a5da7c5f8e4c4 |
| A12 lit_gate6 | 275,761.66 | +175.76% | +109.08% | -14.97% | 449 | 9f4aa8ef962545ba966e5f1aa2c18486 |
| A17 conditional_v1 | 36,598.01 | -63.40% | -51.85% | -76.54% | 247 | cee31a9eba3347409be8093aacc21220 |
| A17 conditional_v2_smooth | 299,881.10 | +199.88% | +122.22% | -20.51% | 372 | 18492641e0a14b8dbbb8636e6399878f |

## 6. 实现与路径审计

- 第一轮 `conditional_v2_smooth` 运行 `193d654e34104cda996eeb47e491f512` 与 hard5 完全一致。复核发现 `_score_hot_conditional_state_passes` 引用了 `r2` 却没有从调用方传入，导致该结果不能作为研究证据。
- 修复签名并重新运行后，有效 job 为 `18492641e0a14b8dbbb8636e6399878f`。
- 修复后 `conditional_v2_smooth` 与 hard5 不是同一条经济路径：最终权益低 `18,092.51`，权益差异最大绝对值 `59,594.20`。
- 修复后交易数从 hard5 的 `464` 降至 `372`，说明门控确实改变了选标和换手，但没有带来收益或回撤改善。

## 7. 失败归因

`conditional_v1` 放行过多异常高分：

| 运行 | 状态日 | top1_score>=5 | abs(ret5)>12% | R2<0.82 | abs(ret20)>20% |
| --- | ---: | ---: | ---: | ---: | ---: |
| hard5 | 330 | 0 | 0 | 0 | 0 |
| A17 conditional_v1 | 330 | 236 | 71 | 86 | 201 |
| A17 conditional_v2_smooth | 330 | 148 | 0 | 0 | 118 |

典型样本：

- `2025-01-02`，`515050.XSHG`，`score=15.1058`、`ret5=+187.37%`、`R2=0.2055`、`ret20=+208.31%`。v1 放行，v2_smooth 和 hard5 均过滤。
- `2025-01-23`，`520830.XSHG`，`score=12.0739`、`ret5=+7.73%`、`R2=0.8514`、`ret20=+25.92%`。v2_smooth 放行，说明修复后该门控不再退化为 hard5。
- `2025-10-17`，`161226.XSHE`，`score=14.4518`、`ret5=+14.39%`、`R2=0.8603`。v1 放行，v2_smooth 因 ret5 上限过滤。
- v1 在 `2026-05-06` 暴露 515050 的复权/份额调整风险：买入价约 `3.022`，后续持仓 `avg_cost` 变成 `9.066` 且数量缩到约三分之一，价格仍约 `3.036`，形成单日约 `-65.78%` 的组合跌幅。这更像数据/复权处理风险被放大，而不能只解释为市场风险。

## 8. 研究判断

建议状态：`kill` A17 当前两组替代实现。

理由：

- v1 证伪“弱条件门足够识别过热”，它引入了远大于 hard5 的尾部风险。
- v2_smooth 证伪“简单加平滑约束即可替代 hard5”，因为修复后虽然产生了非 hard5 经济路径，但收益低于 hard5、回撤深于 hard5。
- A12 lit_gate6 在关键窗口回撤较浅，但收益显著低于 hard5，暂时只能作为风险收益 trade-off 候选，不能直接替代 hard5。

## 9. 边界

本实验不能说明 hard5 是最终最优机制。A16 仍然显示 `score > 5` 单独硬过滤有机会成本。A17 只能说明：当前这两种条件化门控没有找到可交易替代规则，默认 hard5 不应被仓促废除。

## 10. 下一步

1. 停止运行 `conditional_v1_commodity_relaxed`。v1 已经在关键窗口严重失败，商品放宽只会扩大风险暴露。
2. 新开数据/复权/异常价格闸实验：识别 ret5、ret20、价格/份额跳变、成交价和持仓成本错配，先防止 hard5 取消后暴露隐性数据风险。
3. 新开非二元过热预算实验：把 `score>5` 从“买/不买”改为仓位缩放、冷却期、波动预算或分层执行，而不是继续二元过滤。
4. 对 A12 lit_gate6 做四段收益/回撤 trade-off 复核，确认它是否可作为低回撤候选，而不是 hard5 替代。

## 子代理调用记录

- 调用状态：exempt
- 子代理豁免：历史实验记录在子代理强制门禁生效前创建；主控：main；时间：2026-06-06T00:23:50Z
- 后续要求：若本实验用于新决策、路线升级或当前最佳策略判断，必须补充子代理复核记录并同步 `01_台账/子代理调用台账.csv`。
