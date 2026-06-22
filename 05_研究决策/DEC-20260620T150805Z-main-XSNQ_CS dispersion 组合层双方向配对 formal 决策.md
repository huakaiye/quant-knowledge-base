---
type: 研究决策
dec_id: DEC-20260620T150805Z-main-XSNQ
rd_ids: [RD-20260620T052147Z-main-8AB7]
ex_ids: [EX-20260620T094932Z-main-S8BP]
decision: park
owner: main
created_at: 2026-06-20T15:08:05Z
updated_at: 2026-06-20T18:30:00Z
impact: direction
subagent_call_ids: [SUB-20260620T130000Z-main-A7K3, SUB-20260620T150000Z-main-D4E6, SUB-20260620T153000Z-main-E7F8]
subagent_exemption: park 决策、参数矩阵必要性评估、顶刊新立项方向选择由主控承担；SUB-A7K3/D4E6/E7F8 只做数值提取/现状盘点/灵感储备，不独立决定决策状态；主控：main；时间：2026-06-20T18:30:00Z
tags: [CS-dispersion, 组合层开关, park, 参数矩阵无必要, 顶刊新立项, 隔夜收益, p_repair]
---

# CS dispersion 组合层双方向配对 formal 决策

## 关联链接

- 受影响方向：[[02_研究方向/RD-20260620T052147Z-main-8AB7_双池轮动横截面离散度组合层保守开关|双池轮动横截面离散度组合层保守开关]]
- 关键实验：[[04_实验记录/EX-20260620T094932Z-main-S8BP_CS dispersion 组合层双方向配对 formal|S8BP CS dispersion formal]]
- 上一张决策：[[05_研究决策/DEC-20260620T063105Z-main-7TBK_横截面离散度observeM10正交性成立|DEC-7TBK CS dispersion 升级 promote_candidate]]
- 后续实验：[[07_因子数据灵感/03_机制/MECH-20260620T154044Z-main-MATN_顶刊灵感1 隔夜收益知情交易 Lou Polk Skouras 2019|MECH-MATN 隔夜收益知情交易]]（首选新立项）
- 研究驾驶舱：[[00_入口/研究驾驶舱|研究驾驶舱]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 决策结论

`park`

CS dispersion 组合层双方向配对 formal 两个候选（loosen-on-low / loosen-on-high）均未通过预注册证伪条件（4/4 final + 3/4 MDD + cost2x 稳健）。CS dispersion 方向暂停，不 promote_candidate，不复活单独 formal。

## 这个节点是什么

本决策处理"CS dispersion 横截面离散度作为 hard5 组合层保守开关是否可行"。BL8Y 只读面板全门槛通过后（DEC-7TBK 升 promote_candidate），本轮把它接进策略做对标 hard5 的四段 formal（双方向配对：低离散放行 vs 高离散放行）。32 段回测（4 变体 × 4 段 × 2 成本）结果：两候选均未过门槛，CS dispersion 组合层开关单独使用不可行。

## 相比上一个节点改变了什么

- DEC-7TBK（上一节点）：BL8Y 只读面板全门槛通过，升 promote_candidate，CS dispersion 看似有希望。
- 本节点：formal 回测证伪——组合层标量信号在实际策略中不稳建（早段过度放行输、晚段适度放行赢，无法两全）。CS dispersion 从 promote_candidate 降为 park。
- 改变了"CS dispersion 是 MECH-DQUM `p_crash` 可直接落地字段"的预期：它单独不可行，仅保留作未来双概率联合的候选条件先验。

## 子代理依据来源

适配判断：`适合调用`

调用状态：`called`

子代理豁免：park 决策、参数矩阵评估、新立项方向由主控承担；子代理只做支撑。

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-20260620T130000Z-main-A7K3 | 待返回 | SUBTASK-A7K3 BL8Y decile切点阈值提取 | explore | 2026-06-20T13:00:00Z | bl8y_2020_panel_v2 | 无 | python3 pandas | 仅提供阈值数值 | 切点为全样本冻结值 | 采纳 low=0.0112/high=0.0148 冻结 | 冻结预注册阈值 |
| SUB-20260620T150000Z-main-D4E6 | 待返回 | SUBTASK-D4E6 术语库与方向页现状 | explore | 2026-06-20T15:00:00Z | 术语库/8AB7/BL8Y | 无 | 无 | 现状盘点 | 无 | 据此规划同步 | 不影响决策 |
| SUB-20260620T153000Z-main-E7F8 | 待返回 | SUBTASK-E7F8 顶刊机制灵感储备 | explore | 2026-06-20T15:30:00Z | 文献库/WebSearch | 无 | 无 | Top3 灵感 | 论文卷期待复核 | 采纳 MATN 为首选新立项 | 决定 park 后转向方向 |

台账行：[[01_台账/子代理调用台账.csv|子代理调用台账]] 已登记 3 行。

## 支持证据

- **evidence_complete=True**：32 段 summary 全在，cost_fields_ok=True，strict_missing=0（修复 summarize 脚本 exit_status 读取 bug 后），数据完整可信。
- **gate 有独立信息量**：cand≠ref 通过（low 差异 32%、high 差异 47%）。ref_a22_cap70 无条件放行惨败（2025 段 -81%、MDD -55.7%），证明 dispersion gate 确实在区分，非单纯 cap70 驱动。
- **cand_low 2025 段大幅领先**：+33%（cost1x）、+34%（cost2x），方向一致且成本稳健。说明 dispersion 信号在 2025 段有正向价值。
- **两 cand 互为负控通过**：low（2/4）和 high（1/4）不同时满足，符合"桶方向有区分度"预期。

## 反对证据（为何不能 promote）

- **cand_low 未达 4/4**：2020_2021（-22%）、2022_2023（-8%）两段输 hard5。早段过度放行引入弱标的。
- **cand_high 更差**：仅 1/4 段赢，2025 段惨败（-44%，MDD -45.9%），高离散日放行了爆炸性冲顶标的。
- **根本矛盾**：CS dispersion 是组合层标量，无法区分"低离散=普涨健康（2020 牛市）"vs"低离散=普涨冲顶（2025 结构分化）"。同一状态在不同时段含义相反，阈值无法两全。

## 边界

这个决策不能说明什么？
- 不能说明"横截面离散度信号完全无用"——cand≠ref 通过、2025 段 +33% 说明它有局部信息量。
- 不能说明"MECH-DQUM 框架失败"——只是 `p_crash` 的组合层单字段不可行，框架其他字段（p_overheat/p_repair）不受影响。
- 不能说明"BL8Y 只读面板结论错"——BL8Y 验证的是高分事件 H10 effect（事件级），formal 验证的是组合层放行对全组合的副作用，两者口径不同。BL8Y 的事件级 effect 仍成立，只是无法直接迁移为组合层开关。

哪些内容仍然不确定？
- CS dispersion 作为"双概率联合的条件先验"（非单独开关）是否有价值——未验证，留作未来。
- 阈值漂移（2023 中位数 0.0108 < 阈值）是否在其他口径下可缓解——未验证，但评估为参数矩阵无意义（见下）。

## 参数矩阵回测必要性评估（objective 第3项）

**结论：无必要。**

- 阈值漂移确实存在（BL8Y 事件级 2020 中位数 0.0194、2023 中位数 0.0108），但**调阈值/窗口无法解决核心矛盾**——问题是"低离散含义时段依赖"（2020 牛市普涨健康 vs 2025 结构分化冲顶），不是"阈值卡错"。
- 在早段调高阈值减少触发 = 用结果反推参数 = 过拟合（违反预注册硬规则"不看结果后调"）。
- 扫阈值（0.009/0.011/0.013）和窗口（15/20/25）无法让一个组合层标量同时适应两种相反的普涨含义。
- 因此不启动参数矩阵回测，直接进入改进方向分析。

## 后续动作（objective 第4项：分析改进 + 顶刊新立项）

**改进方向分析**：核心矛盾是"组合层标量无法区分普涨类型"。改进需要**比组合层标量更细粒度的信号**——个股层信号（能区分每只标的的上涨是知情延续还是噪声追高）。

**顶刊新立项（从顶刊灵感储备 Top 3 选择）**：

1. **首选立项：MECH-MATN 隔夜收益知情交易**（Lou Polk Skouras 2019 RFS）——个股层信号，与 MAX/CS dispersion/GSADF 三维完全正交，数据链路最干净（jq_bar_daily 已有 open/close/pre_close），直接喂 `p_repair`。解决 CS dispersion 无法回答的"高分标的上涨是知情延续还是噪声追高"。前置：数据门禁（隔夜字段质量）。
2. **次选储备：MECH-2JVB 拥挤度同质化**（Stein 2009 AER）——组合层但看"多标的同步结构"，需先做与 CS dispersion 消融确认非镜像。
3. **数据门禁前置：MECH-XPVF ETF 份额变动**（Ben-David 2018 JF）——若平台有 ETF 份额历史则立项，否则 park。

**新立项执行**：本轮先完成 MECH-MATN 灵感文件（已存档），正式 RD 立项和数据门禁实验作为下一轮工作（不在本 DEC 展开实验，避免跨方向混跑）。

## 需要同步更新

- [x] 研究方向页 8AB7（status→park，current_best_ex_id 保留 BL8Y，新增 S8BP 到已完成实验表，current_decision_id→XSNQ）
- [x] 研究驾驶舱（CS dispersion 方向状态更新为 park）
- [x] 实验台账（S8BP 行更新为 park/completed）
- [x] 决策台账（新增 XSNQ 行）
- [x] 子代理调用台账（A7K3/D4E6/E7F8 已登记）
- [x] 术语库（新增 CS dispersion/横截面离散度/MAX/GSADF/p_overheat/p_crash/p_repair/MECH-DQUM 词条）
- [x] 文档方向符号修正（DEC-7TBK/驾驶舱/BL8Y §16 的"低离散保守"表述更正）
- [x] 研究进展板 Canvas / 研究图谱重建
