---
type: 实验记录
ex_id: EX-20260629T100000Z-main-A2SENS
rd_id: RD-20260605T115651Z-main-DEF0
status: completed
stage: formal_completed_参数稳健性确认_breadth冗余线索
owner: main
created_at: 2026-06-29T10:00:00Z
updated_at: 2026-06-29T10:30:00Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 防御模块
decision_ids:
  - DEC-20260627T073551Z-main-DTH2
lit_ids: []
idea_ids: []
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths:
  - ${QUANT_PLATFORM_ROOT}/configs/research/R010-DEFENSE/rule_a_idle/EX-20260627T053730Z-main-JTX7/formal/trend_break/sens_th15_br04/
  - ${QUANT_PLATFORM_ROOT}/configs/research/R010-DEFENSE/rule_a_idle/EX-20260627T053730Z-main-JTX7/formal/trend_break/sens_th15_br05/
  - ${QUANT_PLATFORM_ROOT}/configs/research/R010-DEFENSE/rule_a_idle/EX-20260627T053730Z-main-JTX7/formal/trend_break/sens_th15_br06/
  - ${QUANT_PLATFORM_ROOT}/configs/research/R010-DEFENSE/rule_a_idle/EX-20260627T053730Z-main-JTX7/formal/trend_break/sens_th20_br04/
  - ${QUANT_PLATFORM_ROOT}/configs/research/R010-DEFENSE/rule_a_idle/EX-20260627T053730Z-main-JTX7/formal/trend_break/sens_th20_br06/
  - ${QUANT_PLATFORM_ROOT}/configs/research/R010-DEFENSE/rule_a_idle/EX-20260627T053730Z-main-JTX7/formal/trend_break/sens_th25_br04/
  - ${QUANT_PLATFORM_ROOT}/configs/research/R010-DEFENSE/rule_a_idle/EX-20260627T053730Z-main-JTX7/formal/trend_break/sens_th25_br05/
  - ${QUANT_PLATFORM_ROOT}/configs/research/R010-DEFENSE/rule_a_idle/EX-20260627T053730Z-main-JTX7/formal/trend_break/sens_th25_br06/
result_paths:
  - ${QUANT_PLATFORM_ROOT}/results/v2/research/R010-DEFENSE/rule_a_idle/EX-20260627T053730Z-main-JTX7/formal/trend_break/sens_*/
quality_gate: 通过_参数稳健性确认_但breadth冗余线索待P4消融验证
subagent_call_ids: []
subagent_exemption: 子代理豁免：本实验数据汇总简单(9点连乘对比)由主控直接完成，定论(参数稳健性/breadth冗余线索)由主控承担；主控：main；时间：2026-06-29T10:00:00Z
tags: [防御模块, A2趋势破位, 参数敏感性, threshold, breadth, 9点网格, OFAT, 参数稳健性, breadth冗余, 中心点最优, A2SENS]
---

# A2 参数敏感性 9 点网格：中心点最优，breadth 关冗余线索

> 本实验是 A2（趋势破位）的参数敏感性验证。对 threshold∈{1.5,2.0,2.5}×breadth∈{0.4,0.5,0.6} 共 9 点网格跑 cost1x 四段回测（中心点复用已有 A2 cost1x 结果，新跑 32 段）。**结论：A2 参数稳健性好（9 点连乘 CV 仅 5.6%），中心点 (2.0,0.5) 恰好是 9 点最优。但发现 breadth 关几乎不敏感（偏差仅 -1%~-3%），暗示广度关可能冗余——此线索待 P4 消融实验验证。**

## 1. 实验前预注册（每轮实验硬规则）

- **研究方向 ID**：RD-20260605T115651Z-main-DEF0（下限空仓/防御模块）
- **本次假设**：A2 的收益在 threshold/breadth 邻域扰动下保持稳定（CV<15%），中心点不是过拟合的孤立峰。
- **实验前预测**：9 点连乘 CV 在 5-15% 之间；中心点 (2.0,0.5) 处于较好但未必最优的位置；breadth 比 threshold 更敏感（因 breadth 直接控制触发频率）。
- **基准对照**：A2 cost1x 中心点 (2.0,0.5) 四段连乘 18.719x。
- **竞争性解释**：① 中心点过拟合（孤立峰，邻域骤降）；② threshold 过敏感（U 型深谷）；③ breadth 冗余（变化无影响）。
- **证伪条件**：若 CV>20%（参数不稳），或中心点是孤立峰（邻域骤降>30%），则参数稳健性证伪。
- **计划使用的平台配置/结果路径**：sens_th{15,20,25}_br{04,05,06}/ 各 4 段，cost1x 口径。

## 2. 实验配置

基于 A2 cost1x 配置生成 8 个非中心变体（中心点 2.0/0.5 复用已有结果），每个变体 4 段，共 32 段。配置生成修正了 P2 的 name/output_dir 漏改 bug（本次 name 和 output_dir 都正确指向 sens_* 目录）。

## 3. 回测执行

- 32 段并行回测（max-parallel=6，分 6 批），07:42 启动，约 10:00 全部完成，总耗时约 138 分钟。
- 全程实时进度监控，无卡住，32/32 段成功完成。

## 4. 结果（核心数据）

### 4.1 9 点网格连乘/MDD 对比

| 网格 | 连乘 | 年化(6.39yr) | 平均MDD | 最差MDD | vs中心 |
| --- | --- | --- | --- | --- | --- |
| th=1.5 br=0.4 | 16.700x | 55.4% | -20.3% | -22.7% | -10.8% |
| th=1.5 br=0.5 | 16.097x | 54.5% | -20.3% | -22.7% | -14.0% |
| th=1.5 br=0.6 | 16.813x | 55.5% | -20.3% | -22.7% | -10.2% |
| th=2.0 br=0.4 | 18.520x | 57.9% | -19.0% | -21.1% | -1.1% |
| **th=2.0 br=0.5 ⭐** | **18.719x** | **58.2%** | -19.4% | -21.4% | **+0.0%（最优）** |
| th=2.0 br=0.6 | 18.094x | 57.3% | -19.0% | -21.1% | -3.3% |
| th=2.5 br=0.4 | 16.643x | 55.3% | -19.0% | -21.1% | -11.1% |
| th=2.5 br=0.5 | 15.978x | 54.3% | -19.0% | -21.1% | -14.6% |
| th=2.5 br=0.6 | 17.135x | 56.0% | -18.8% | -21.1% | -8.5% |

### 4.2 稳健性指标

- 9 点连乘：min 15.978 / max 18.719 / 均值 17.189 / 标准差 0.959 / **CV = 5.6%**。
- **中心点 (2.0,0.5) = 18.719x 是 9 点最优**。
- 所有 9 点 MDD 在 -18.8%~-22.7% 区间，回撤维度也稳健。

### 4.3 单参数敏感性（OFAT）

**threshold 敏感性（固定 br=0.5）**：
- th=1.5: 16.097x（-14.0%）
- th=2.0: 18.719x（基准）
- th=2.5: 15.978x（-14.6%）
- **U 型曲线，中心点恰好峰顶，两侧各降 ~14%**

**breadth 敏感性（固定 th=2.0）**：
- br=0.4: 18.520x（-1.1%）
- br=0.5: 18.719x（基准）
- br=0.6: 18.094x（-3.3%）
- **近乎平坦，breadth 阈值变化影响极小**

## 5. 实际观察 vs 预测

**部分一致，部分证伪。**
- ✅ 一致：CV=5.6% < 15%，参数稳健性假设成立。
- ✅ 一致：中心点不是孤立峰（邻域最差也只 -14.6%，非骤降）。
- ❌ 证伪：预测"breadth 比 threshold 更敏感"，**实际相反**——threshold 敏感（U 型 -14%），breadth 几乎不敏感（-1%~-3%）。这暗示 breadth 关可能冗余（详见第 7 节）。

## 6. 机制分析

### 6.1 threshold 为何呈 U 型（th=2.0 最优）

threshold 控制分数关（最高分<threshold 才触发空仓）：
- th=1.5（更易触发）：过度防御，误伤增多（类似 RA5 的问题），收益降 -14%。
- th=2.0（当前）：平衡点，恰好躲过真熊市又不误伤。
- th=2.5（更难触发）：防御不足，躲不过部分大跌，收益降 -14.6%。

U 型对称（两侧降幅接近），说明 2.0 是真正的机制平衡点，不是过拟合的尖峰。

### 6.2 breadth 为何不敏感

breadth 控制广度关（涨的票占比<breadth 才触发）。三关是 AND 逻辑（同时满足才触发）：
- 当 threshold=2.0 + 趋势关（hs300 跌破且斜率<0）已满足时，市场通常已经全面下跌，此时 breadth<0.4/0.5/0.6 几乎都会满足（全面下跌时涨的票本来就少）。
- 所以 breadth 阈值在 0.4-0.6 范围内"有就行，具体多少无所谓"——它很少成为三关里的瓶颈关。

**这暗示 breadth 关可能是冗余的**：在 threshold + 趋势关已经过滤的情况下，breadth 关很少改变最终触发决策。此假设待 P4 消融实验（ablation_no_breadth）验证。

## 7. 对决策的影响

1. **参数稳健性确认**：A2 的收益不会因参数小幅变化而崩溃（CV 5.6%），这降低了"参数过拟合"的担忧。中心点 th=2.0/br=0.5 的选择是合理的（U 型峰顶，非孤立峰）。
2. **threshold 选择有事后风险但可接受**：th=2.0 继承自 RA6 对 RA5 的 OFAT（非看 A2 结果后调参），且 U 型对称说明是机制平衡点，过拟合风险低。但样本外验证仍需观察 th=2.0 是否在新行情下仍优。
3. **~~breadth 冗余线索~~（已被 P4 消融推翻，见下方纠正）**：~~若 P4 消融确认去 breadth 后收益几乎不变，则可考虑简化 A2 为"分数关 + 趋势关"两关结构~~。

> ⚠️ **2026-06-29 P4 消融纠正**：本节"breadth 冗余线索"猜测已被 [[04_实验记录/EX-20260629T110000Z-main-A2ABLATION|EX-A2ABLATION]] 推翻。P4 消融显示**去 breadth 关收益暴跌 -35.5%（最关键关）**。教训："参数不敏感"（P3 测阈值 0.4-0.6 变化）≠"机制冗余"（P4 测有无）——breadth 阈值多少无所谓，但有没有这道关至关重要。A2 三关结构不可简化。

## 8. 对新手的短总结

A2 的两个核心参数（threshold=2.0 分数阈值、breadth=0.5 广度阈值）在邻域扰动下表现稳健——9 个参数组合的年化收益变化系数仅 5.6%，不会因为参数微调就大幅波动。threshold=2.0 恰好是最优点（两侧都变差约 14%，是对称的 U 型，说明是真正的平衡点而非碰巧）。但发现 breadth 参数几乎不影响结果（变化仅 1-3%），暗示广度关可能是冗余的——这个猜测会在消融实验里验证。

## 9. 下一步

- P4 消融实验验证 breadth 冗余假设（ablation_no_breadth 若收益≈A2 则确认冗余）。
- threshold 的 U 型敏感度（±14%）需在样本外验证中观察是否稳定。
- 本结果与 P2（成本扰动）共同构成 A2 的"机制稳健性"证据：参数稳健（P3）+ 但成本敏感（P2），说明 A2 的弱点在交易成本而非参数选择。

## 10. 是否需要研究决策卡

否。本实验确认参数稳健性，不改变决策状态。breadth 冗余线索待 P4 确认后再决定是否简化结构。

## 11. 关联链接

- [[04_实验记录/EX-20260627T053730Z-main-JTX7|EX-JTX7]]（A2 主实验，中心点参数来源）
- [[04_实验记录/EX-20260628T230000Z-main-A2COST|EX-A2COST]]（成本扰动，A2 弱点在成本）
- [[04_实验记录/EX-20260627T063703Z-main-XSFC|EX-XSFC]]（A2n 邻域，slope_window 敏感性）
- [[05_研究决策/DEC-20260627T073551Z-main-DTH2_A2趋势破位升级RA5第三维L2robustness更新shadow配置|DEC-DTH2]]（A2 决策卡）
