---
type: 研究决策
dec_id: DEC-20260621T024805Z-main-CHCD
rd_ids: [RD-20260619T083919Z-main-WEMY]
ex_ids: [EX-20260621T015355Z-main-F44P]
decision: park
owner: main
created_at: 2026-06-21T02:48:05Z
updated_at: 2026-06-22T09:30:00Z
impact: direction
subagent_call_ids: [SUB-20260621T011000Z-main-G4H7]
subagent_exemption: park 决策、参数矩阵评估、bug 诊断、新立项方向由主控承担；SUB-G4H7 只做检索盘点，不独立决定决策状态；主控：main；时间：2026-06-22T09:30:00Z
tags: [frozen-veto, A28, m14, m04, m12, m01, park, 参数矩阵无必要, 实现bug, 顶刊新立项, 隔夜收益]
---

# A29 frozen-veto 组合层双方向配对 formal 决策

## 关联链接

- 受影响方向：[[02_研究方向/RD-20260619T083919Z-main-WEMY_双池轮动A股撤离追高状态机|双池轮动 A 股撤离追高状态机]]
- 关键实验：[[04_实验记录/EX-20260621T015355Z-main-F44P_A29 frozen-veto 组合层双方向配对 formal|EX-F44P A29 frozen-veto formal]]
- 上一张决策：[[05_研究决策/DEC-20260619T114146Z-main-5E5G_A28量价结构门禁通过后转过热veto正式实验|DEC-5E5G A28 通过后转 A29]]
- 姊妹方向（CS dispersion，同样 park）：[[05_研究决策/DEC-20260620T150805Z-main-XSNQ_CS dispersion 组合层双方向配对 formal 决策|DEC-XSNQ CS dispersion park]]
- 后续新立项：[[07_因子数据灵感/03_机制/MECH-20260620T154044Z-main-MATN_顶刊灵感1 隔夜收益知情交易 Lou Polk Skouras 2019|MECH-MATN 隔夜收益知情交易]]
- 研究驾驶舱：[[00_入口/研究驾驶舱|研究驾驶舱]]

## 决策结论

`park`

A29 frozen-veto 组合层 formal 联合 veto 候选未通过预注册证伪条件（2/4 final，2/4 MDD），且发现实现 bug（m14/m04/m01 口径失真）。frozen-veto 方向暂停，不 promote_candidate，不复活单独 formal。

## 这个节点是什么

本决策处理"A28 四个 strong veto 作为 hard5 组合层 gate 是否可行"。DEC-5E5G 既定动作，A28 全门槛通过后新开 A29 formal。56 段回测（7 变体×4段×2成本，并行执行约 90 分钟）结果：联合 veto 仅 2/4 段赢 hard5（2020_2021/2024 赢，2022_2023/2025 输），2025 段惨败（-66%，MDD -70%）。同时发现实现 bug：m14/m04/m01 因全池聚合口径失真（ETF 达不到个股级阈值），结果不可信；m12 主导联合 veto 且 2025 段误伤修复反弹。

## 相比上一个节点改变了什么

- DEC-5EG（上一节点）：A28 全门槛通过，升 A29 formal 候选，veto 看似有希望。
- 本节点：formal 证伪——veto 信号在 2025 强反弹环境误伤修复反弹（与 CS dispersion 问题对称：CS dispersion 早段输晚段赢，veto 早段赢晚段输）。WEMY 从 revise 降为 park。
- 改变了"frozen-veto 能直接回答何时该撤离追高"的预期：单独使用不可行。

## 子代理依据来源

适配判断：`适合调用`

调用状态：`called`（G4H7 检索已完成）

子代理豁免：park 决策、bug 诊断、参数矩阵评估、新立项方向由主控承担；子代理只做检索盘点。

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-20260621T011000Z-main-G4H7 | 待返回 | SUBTASK-G4H7 A29前置检索 | explore | 2026-06-21T01:10:00Z | WEMY/DEC-5E5G/A28脚本/S8BP | 无 | 无 | 检索盘点 | 无 | 采纳为预注册依据 | 不影响决策 |

## 支持证据

- **veto gate 有独立信息量**：cand≠ref 通过（0.78 差异）。ref_a22 无条件放行 2025 段崩盘（59923），veto gate 机制不同。
- **联合 veto 在 2020_2021 和 2024 段赢 hard5**：+15.6% 和 +8.1%，说明 veto 在牛市普涨和震荡市能改善选股。
- **m12 主导符合 A28 实证**：m12 样本最厚（70 事件），单独 m12 与联合 veto 结果几乎相同。

## 反对证据（为何不能 promote）

- **2025 段全面惨败**：联合 veto 106689 vs hard5 317974（-66%，MDD -70.1%）。veto 误伤 2025 强反弹环境的修复反弹标的。
- **2022_2023 段也输**：联合 veto 82709 vs hard5 131215（-37%）。
- **不满足证伪条件**：2/4 final（需 4/4），2/4 MDD（需 3/4）。
- **实现 bug**：m14/m04/m01 因全池聚合口径失真（ETF 达不到个股级 atr20 0.035 / max_ret20 0.08 阈值），242 日全部 loosen 从不命中，结果等同无条件 cap70。这 3 个 veto 的真实效果无法从本轮结果判断。

## 边界

不能说明什么？
- 不能说明"veto 信号完全无用"——cand≠ref 通过、2020/2024 段赢说明 m12 有局部价值。
- 不能说明"m14/m04/m01 veto 无效"——因实现 bug（全池聚合口径），它们的真实效果未验证。
- 不能说明"A28 只读面板结论错"——A28 是事件级（只对高分标的算），A29 是组合层（全池聚合），口径不一致是 bug 而非 A28 错误。

哪些内容仍然不确定？
- m14/m04/m01 修复口径后（只对高分候选算）是否有额外贡献——未验证，留作 follow-up。
- veto 信号在 2025 段误伤修复反弹的根因——是"veto 阈值在 ETF 上不适配"还是"2025 强反弹本质不同于过热"——需 MECH-MATN 隔夜收益信号区分。

## 参数矩阵回测必要性评估（objective 第3项）

**结论：无必要。**
- veto 阈值 frozen（DEC-5E5G "不调"）。
- 核心矛盾是"同一 veto 信号在不同时段含义相反"（2020 过热 vs 2025 修复），非阈值问题。
- m12 的 2025 段惨败已证明 veto 在强反弹环境误伤修复，调阈值无法解决。

## 后续动作（objective 第4项：改进分析 + 顶刊新立项）

**改进方向分析**：veto 和 CS dispersion 共同失败的核心矛盾是"同一信号在不同时段含义相反"。改进需要能区分"过热（该保守）vs 修复（该放行）"的信号。

**顶刊新立项**：MECH-MATN 隔夜收益知情交易（Lou Polk Skouras 2019 RFS）——用隔夜/日内收益分解判断"上涨是知情延续（修复）还是噪声追高（过热）"。与 MAX/CS dispersion/GSADF/frozen-veto 完全正交（日内结构维度）。灵感文件已存档，待数据门禁后正式立项。

**WEMY 方向**：park。A28 的 4 veto 留作未来 MECH-DQUM 多信号联合的候选组件，但本轮不展开。若未来修复 m14/m04/m01 口径后重验，需新开 EX（不在本 DEC 范围）。

## 需要同步更新

- [x] 研究方向页 WEMY（status→park，current_decision_id→CHCD）
- [x] 研究驾驶舱（A29 veto 方向状态更新为 park）
- [x] 实验台账（F44P 行更新为 park/completed）
- [x] 决策台账（新增 CHCD 行）
- [x] 子代理调用台账（G4H7 已登记）
- [x] 术语库（新增 m14/m04/m12/m01/frozen-veto 词条）
- [x] 研究进展板 Canvas / 研究图谱重建
