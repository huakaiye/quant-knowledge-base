---
type: 研究决策
dec_id: DEC-20260618T024516Z-main-UR6S
rd_ids: [RD-20260614T115209Z-main-MCYG]
ex_ids: [EX-20260617T220410Z-main-B6FL]
decision: revise
owner: main
created_at: 2026-06-18T02:45:16Z
updated_at: 2026-06-18T02:50:00Z
impact: direction
subagent_call_ids: [SUB-EXEMPT-20260617T220400Z-main-B6FL, SUB-EXEMPT-20260618T024500Z-main-UR6S]
subagent_exemption: 当前多代理工具要求用户显式授权子代理/委派/并行 agent；本轮没有该授权，主控执行并记录豁免。
tags: [双池轮动, 防御模块, 动量崩溃, 过热动量, formal失败, revise, no-live-change]
---

# 过热动量D2四段formal失败后暂停推广

## 关联链接

- 受影响方向：[[02_研究方向/RD-20260614T115209Z-main-MCYG_双池轮动动量崩溃事前暴露管理|MCYG 动量崩溃事前暴露管理]]
- 关键实验：[[04_实验记录/EX-20260617T220410Z-main-B6FL_过热动量D2四段formal与负控|B6FL 过热动量 D2 四段 formal 与负控]]
- 上一张决策：[[05_研究决策/DEC-20260617T215629Z-main-UARF_过热动量D2 smoke通过后进入formal|UARF 过热动量 D2 smoke 通过后进入 formal]]
- 后续实验：待新建只读概率/分位数风险面板
- 研究驾驶舱：[[00_入口/研究驾驶舱|研究驾驶舱]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 决策结论

`revise`

B6FL formal 失败后，`R010D_D2_OVERHEAT(cap=0.90, keep_current=true)` 暂停推广：不 promote、不 observe、不 shadow、不改实盘默认逻辑。MCYG 方向保留“事前风险暴露”问题，但从直接交易动作修订为只读概率/分位数风险预测。

## 这个节点是什么

这个节点处理的是“看到 2024 smoke 很好后，能不能把过热动量降 cap 变成通用防御规则”。B6FL 把它放到四段样本、延迟负控、随机负控和成本扰动中检验。

## 相比上一个节点改变了什么

- UARF 允许 D2-overheat 进入 formal 候选，但没有授权实盘或 shadow。
- B6FL 证明 2024 smoke 无法跨段稳定复现：2020_2021 与 2025_20260519 都失败。
- 因此候选从 `promote_candidate` 修订为 `revise`，只能保留为只读风险标签素材。

## 子代理依据来源

适配判断：`适合调用`

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：当前多代理工具要求用户显式授权子代理/委派/并行 agent；本轮没有该授权；主控：main；时间：2026-06-17T22:04:00Z
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `SUB-EXEMPT-20260617T220400Z-main-B6FL` | 无 | `SUBTASK-B6FL-PREREG-EXEMPT` | 无 | 2026-06-17T22:04:00Z | LIT/RD/EX 相关文档与平台配置 | 无子代理修改 | 无 | 豁免 | 无子代理并行复核 | 主控复核 summary、配置和台账 | 不支持 promote；仅记录流程豁免 |
| `SUB-EXEMPT-20260618T024500Z-main-UR6S` | 无 | `SUBTASK-B6FL-DECISION-EXEMPT` | 无 | 2026-06-18T02:45:00Z | B6FL summary、MCYG 方向、UR6S 决策 | 无子代理修改 | 无 | 豁免 | 无子代理并行复核 | 主控复核质量门和成本异常 | 支持 revise 决策记录，不作为策略有效性证据 |

台账行：已同步 `01_台账/子代理调用台账.csv`。

## 支持证据

- 2024 分段复现 XA5U：candidate final `181373.71` 高于 baseline `167005.22`，MDD 改善约 `4.20pp`。
- 2022_2023 candidate final `137972.89` 高于 baseline `131215.13`，说明 overheat-only 不完全是 2024 单段偶然。
- 四段触发次数均足够，候选不是没有实际触发的空规则。

## 反对证据

- 主候选只在 `2/4` 段跑赢 baseline，低于预注册 `3/4` 门槛。
- 主候选不低于 baseline 98% 只有 `2/4`，低于预注册 `4/4` 门槛。
- MDD 改善不低于 `0.5pp` 只有 `1/4`，低于预注册 `2/4` 门槛。
- random 负控只在 `2/4` 段低于候选，不能排除少换仓/低频降风险解释。
- 成本变体四段 final/MDD/交易数与候选完全相同，`cost_control_valid=false`，不能作为有效成本扰动。

## 边界

这个决策不能说明过热动量标签完全无价值。它只说明当前 `cap=0.90, keep_current=true` 的交易动作不稳，不能推广。

成本扰动质量门本轮无效，但候选在非成本主门槛已经失败，所以不需要为了否决候选立即补跑成本。未来如果要重新检验成本，必须新开或重新预注册有效成本配置，不能复用本轮成本结果。

## 后续动作

- MCYG 继续保留为 active，但下一步只做只读概率/分位数风险面板。
- 不扩 `top1_ret20/top1_slope10` 阈值、cap、`keep_current`、随机 seed 或成本口径。
- 不回到 Q88K 已失败的 PLS/Ridge/fixed blend 组合调参路线。
- 平台生成器已修正 B6FL 后续成本字段，但不覆盖本轮已运行配置。

## 需要同步更新

- [x] 研究方向页
- [x] 研究驾驶舱
- [x] 实验台账
- [x] 决策台账
- [x] 子代理调用台账
- [x] 术语库不需新增术语
