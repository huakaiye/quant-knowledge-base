---
type: 研究决策
dec_id: DEC-20260608T072559Z-main-B3QC
rd_ids: [RD-20260605T115651Z-main-DEF0]
ex_ids: [EX-20260608T041610Z-main-B3QC]
decision: continue_negative_control
owner: main
created_at: 2026-06-08T07:25:59Z
updated_at: 2026-06-08T07:25:59Z
impact: direction
subagent_call_ids:
  - SUB-20260608T062000Z-main-B3QC-QA
subagent_exemption:
tags: [双池轮动, 防御模块, B3Gate, tiered-v2, 成本扰动, 负控]
---

# B3Gate与TieredV2成本扰动通过后继续负控决策

## 关联链接

- 受影响方向：[[02_研究方向/RD-20260605T115651Z-main-DEF0_双池轮动防御模块|双池轮动防御模块]]
- 关键实验：[[04_实验记录/EX-20260608T041610Z-main-B3QC_B3Gate与TieredV2成本扰动formal|B3Gate 与 TieredV2 成本扰动 formal]]
- 前置骨架决策：[[05_研究决策/DEC-20260608T005556Z-main-U7FN_B3Gate与TieredV2复核后保留为防御骨架决策|B3Gate 与 TieredV2 保留为防御骨架决策]]
- 当前 A1 边界：[[05_研究决策/DEC-20260608T040036Z-main-WAHD_A1静态仓位负控失败后暂停交易化决策|A1 静态仓位负控失败后暂停交易化决策]]
- 研究驾驶舱：[[00_入口/研究驾驶舱|研究驾驶舱]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 决策结论

`continue_negative_control`

B3Gate/tiered-v2 通过 cost2x/slip2bps 成本扰动 formal，可以继续作为双池轮动防御仓位骨架进入下一道质量门禁。下一道门禁必须是触发滞后一日负控，不能在本轮结果上 production promote，也不能扩 cap、阈值、状态标签或旧组合动作。

## 这个节点是什么

这个节点处理 B3Gate/tiered-v2 的一个关键质量缺口：旧证据显示它比 B3-gate-cap80 更稳，但如果交易成本翻倍并加 2bps 滑点，优势是否还存在。

B3QC 的答案是：成本压力下优势仍存在。因此本节点不是否决 tiered-v2，而是把它从“旧证据保留骨架”推进到“成本门禁通过但仍需负控”。

## 相比上一个节点改变了什么

- U7FN 只能说 B3Gate/tiered-v2 可保留为防御骨架，但缺完整成本扰动和错位负控。
- B3QC 补齐成本扰动，8/8 formal 完成，成本门禁通过。
- 本决策允许继续投入触发滞后一日负控；但仍不允许把 tiered-v2 写成默认生产逻辑或继续后验扩参。
- WAHD 已暂停 A1 cap-only 交易化，当前 DEF0 的可继续质量门禁重点转回 B3Gate/tiered-v2 的触发有效性。

## 子代理依据来源

适配判断：适合调用。formal 完成后的文档字段、台账同步和流程缺口适合拆出只读审计。

调用状态：called

子代理豁免：不适用。新建子代理受线程上限限制，主控复用现有 `Bohr` 线程完成审计。

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-20260608T062000Z-main-B3QC-QA | Bohr | SUBTASK-20260608T062000Z-B3QC-doc-ledger-audit | inherited | 2026-06-08T06:20:00Z | B3QC 实验卡、实验台账、formal 路径摘要 | 无 | 只读审计 | 只检查 formal 收尾字段，不做路线判断 | formal 后需主控补齐结果段、decision_id 和台账 | 主控独立读取平台 summary、quality gates、segment/compound 对照和日期审计 | 支持把 B3QC 收口为成本门禁通过并进入滞后负控 |

台账行：已同步 `01_台账/子代理调用台账.csv`。

## 支持证据

- `tiered_v2_cost2x_slip2bps` 四段拼接收益 `12.1507`，高于 `cap80_cost2x_slip2bps` 的 `11.3111`。
- 成本扰动后 tiered-v2 拼接最大回撤 `-28.22%`，好于 cap80 的 `-30.37%`。
- tiered-v2 相对 cap80 分段 final `3/4` 不低，满足预注册门槛。
- tiered-v2 相对 cap80 分段 MDD `3/4` 不差，满足预注册门槛。
- 2025_20260519 强趋势段 final `302895.29`，高于 cap80 `290673.46`，没有明显错过强趋势。
- 日期审计覆盖 8 个 run、3084 条 action，`violation_count=0`、`min_lag_days=1`。

## 反对证据

- 2020_2021 tiered-v2 MDD `-21.69%`，差于 cap80 `-21.20%`。
- 2022_2023 tiered-v2 final `124873.95`，低于 cap80 `125775.05`。
- 2025_20260519 的 MDD 改善极小，只能说明没有明显误伤，不足以说明强趋势段防御贡献强。
- 成本扰动不是触发错位负控；仍不能排除 tiered-v2 的收益来自状态标签过宽、平均仓位变化或后验路径依赖。

## 边界

这个决策不能说明：

- 不能说明当前默认策略已经切换到 B3Gate/tiered-v2。
- 不能说明 tiered-v2 可以继续降到 cap50/cap40 或扩阈值。
- 不能说明 R026、A1、A3、A4、B5 或 C1 旧动作可以合并进当前交易逻辑。
- 不能替代触发滞后一日负控、实盘 dry-run 或生产前未来函数门禁。

## 给新手的短总结

B3Gate/tiered-v2 这次像是“抗成本检查”过关：手续费翻倍、加 2bps 滑点后，它整体仍比固定 cap80 更好。但研究上还差一步最关键的追问：如果风险触发晚一天，它还会不会同样有效。若晚一天也有效，就说明它可能不是靠及时识别风险赚钱，而是靠别的更粗糙因素。

## 后续动作

- 新开 B3Gate/tiered-v2 触发滞后一日负控 formal。
- 不扩 B3/tiered-v2 cap、breadth、median、top5 或 persistence 阈值。
- 不改生产默认、不做 live enable、不声明当前最有效策略。
- 若滞后一日负控失败，再考虑进入生产前静态门禁、默认关闭 observe 或 forward/OOS；若滞后负控仍有效，优先重审状态标签和过拟合风险。

## 需要同步更新

- [x] 研究方向页
- [x] 研究驾驶舱
- [x] 实验台账
- [x] 决策台账
- [x] 子代理调用台账
- [x] 策略档案
- [x] 术语库：未新增术语，不需要更新
