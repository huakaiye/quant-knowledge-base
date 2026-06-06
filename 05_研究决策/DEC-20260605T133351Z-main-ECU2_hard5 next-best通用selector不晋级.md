---
type: 研究决策
dec_id: DEC-20260605T133351Z-main-ECU2
rd_ids: [RD-20260605T133318Z-main-H6V3]
ex_ids: [EX-20260605T133336Z-main-MZJE]
decision: kill
owner: main
created_at: 2026-06-05T13:33:51Z
updated_at: 2026-06-05T13:33:51Z
impact: direction
legacy_decision_id: D20260605-R010A15-001
tags: [双池轮动, score-cap, hard5, next-best, 过热拥挤]
---

# hard5 next-best 通用 selector 不晋级

## 关联链接

- 受影响方向：[[02_研究方向/RD-20260605T133318Z-main-H6V3_双池轮动score过热拥挤机制模块]]
- 关键实验：[[04_实验记录/EX-20260605T133336Z-main-MZJE_hard5内部next-best选择只读代理]]
- 后续实验：[[04_实验记录/EX-20260605T133336Z-main-DMB9_资产属性标签审计与hard5事件拆分]]
- 研究驾驶舱：[[00_入口/研究驾驶舱]]

## 决策结论

`kill`

通用 next-best selector 不进入 formal，不替代 hard5。

## 这个节点是什么

这个节点检验 raw Top1 因 `score >= 5` 被过滤时，是否能在 `score < 5` 的候选里用 R2、成交量、同主题或反拥挤排序挑出更好的替代目标。

## 相比上一个节点改变了什么

- 旧假设：hard5_first 可能太机械，next-best selector 能改善。
- 新结论：全局 selector 不稳定，胜率和分段均不够。

## 支持证据

- 最优均值 selector `r2_first` 的 H10 diff mean 为 `+1.8034%`，但胜率只有 `39.76%`。
- `r2_first` 在 2024 分段 H10 diff mean 为 `-4.3112%`。
- 所有 selector 都未达到 H10 胜率 55% 和无负段门槛。

## 反对证据

- 2026 commodity_lof 局部样本中 `r2_first` 有正贡献。
- 这提示资产属性分层可能有价值，但不能支持通用 selector 上线。

## 边界

该决策不否定“在特定资产属性或特定市场状态下选择替代目标”的研究，只否定不分层的通用 selector。

## 后续动作

- 转向资产属性标签审计。
- 在资产属性分层之前，不再开发新的通用 next-best 排序器。

## 需要同步更新

- [x] 研究方向页
- [ ] 研究驾驶舱
- [x] 实验台账
- [x] 决策台账
- [ ] 术语库

## 子代理依据来源

- 适配判断：历史豁免
- 调用状态：exempt
- 子代理豁免：历史决策在子代理默认优先门禁生效前创建；主控：main；时间：2026-06-06T01:03:42Z
- 后续要求：若本决策用于新实验、路线升级、当前最佳策略判断或实盘边界变更，必须补充子代理复核记录并同步 `01_台账/子代理调用台账.csv`。
