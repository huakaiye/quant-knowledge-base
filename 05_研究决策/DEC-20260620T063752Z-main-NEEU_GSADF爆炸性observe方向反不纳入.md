---
type: 研究决策
dec_id: DEC-20260620T063752Z-main-NEEU
rd_ids: [RD-20260620T052601Z-main-3B2X, RD-20260605T133318Z-main-H6V3]
ex_ids: [EX-20260620T052616Z-main-UEAC]
decision: observe
owner: main
created_at: 2026-06-20T06:37:52Z
updated_at: 2026-06-20T08:30:00Z
impact: direction
subagent_call_ids: []
subagent_exemption: 决策由主控承担；主控：main；时间：2026-06-20T08:30:00Z
tags: [双池轮动, hard5, GSADF, PSY, 爆炸性, observe, 方向反, 不纳入, 错位负控反转]
---

# GSADF 爆炸性 observe 方向反不纳入

## 关联链接

- 受影响方向：[[02_研究方向/RD-20260620T052601Z-main-3B2X_双池轮动GSADF爆炸性泡沫检测|双池轮动 GSADF 爆炸性泡沫检测]]（3B2X）、[[02_研究方向/RD-20260605T133318Z-main-H6V3_双池轮动score过热拥挤机制模块|双池轮动 score 过热拥挤机制模块]]（H6V3）
- 关键实验：[[04_实验记录/EX-20260620T052616Z-main-UEAC_GSADF爆炸性泡沫只读面板预注册|UEAC GSADF 爆炸性泡沫只读面板]]
- 兄弟决策：[[05_研究决策/DEC-20260620T062621Z-main-Z8MP_FZM4MAX彩票式过热observeA28二元版优先|FZM4 MAX observe]]、[[05_研究决策/DEC-20260620T063105Z-main-7TBK_横截面离散度observeM10正交性成立|BL8Y CS dispersion observe]]
- 研究驾驶舱：[[00_入口/研究驾驶舱|研究驾驶舱]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 决策结论

`observe`

## 这个节点是什么

UEAC 用 Phillips-Shi-Yu 2015 的 GSADF 递归爆炸性检测作为过程层维度。结果：方向与预测相反——高爆炸性桶 H10 effect +0.022 < 低爆炸性桶 +0.059，爆炸性反而后续更好。GSADF 不适合作为 hard5 过热撤离信号，不纳入 MECH-DQUM `p_overheat` 字段。三个正交维度全部执行完毕。

## 相比上一个节点改变了什么

- GSADF 不纳入 MECH-DQUM `p_overheat` 字段（方向反）。
- ETF 的"爆炸性"是趋势加速良性阶段而非泡沫尾声——与个股泡沫检测适用场景不同，这是有价值的证伪。
- 纯 numpy 简化 ADF 实现有不确定性（statsmodels 不可用），反转可能是实现误差，需后续用严格 PSY 仿真临界值确认。
- 三个正交维度全部执行完毕，进入综合判断阶段：MAX（方向支持，A28 二元版）+ CS dispersion（方向支持，M10 正交）+ GSADF（方向反，不纳入）。

## 子代理依据来源

适配判断：`不适合调用`

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：UEAC 回测执行和结果分析由主控承担；主控：main；时间：2026-06-20T08:30:00Z
```

## 支持证据

- GSADF 特征计算成功：211/212 有效，纯 numpy ADF 可行。
- 未来函数审计通过。
- 方向相反本身是有价值的证伪：排除 GSADF 作为 hard5 过热撤离信号的可行性。

## 反对证据

- 方向与预测相反：爆炸性反而后续更好。
- 高爆炸性桶胜率仅 50%。
- 错位负控第三次反转。
- 简化 ADF 实现有不确定性。

## 边界

这个决策不能说明什么？哪些内容仍然不确定？

- 方向反转可能是纯 numpy 简化 ADF 的实现误差，非严格 PSY 仿真临界值。若未来 statsmodels 可用，需重跑确认。
- GSADF 不纳入 p_overheat，不等于"爆炸性检测概念无价值"——在个股泡沫检测场景可能仍有效，只是 ETF 场景不适用。

## 后续动作

- 3B2X 方向保持 active，UEAC 记为 observe（方向反）。
- GSADF 不纳入 MECH-DQUM 字段池，作为方法资产保留。
- 三个正交维度综合判断：组合 MAX + CS dispersion 做 MECH-DQUM 双概率软预算只读复核。
- 新开方法论实验研究"错位负控反转的系统性原因"（FZM4/BL8Y/UEAC 三次一致）。

## 需要同步更新

- [x] 研究方向页
- [x] 研究驾驶舱
- [x] 实验台账
- [x] 决策台账
- [x] 子代理调用台账（无新增）
