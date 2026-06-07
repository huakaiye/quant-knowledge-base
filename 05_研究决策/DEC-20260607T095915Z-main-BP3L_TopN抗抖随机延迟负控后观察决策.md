---
type: 研究决策
dec_id: DEC-20260607T095915Z-main-BP3L
rd_ids: [RD-20260605T115651Z-main-EXE0]
ex_ids:
  - EX-20260606T140752Z-main-TC8U
  - EX-20260607T083033Z-main-C35J
decision: observe
owner: main
created_at: 2026-06-07T09:59:15Z
updated_at: 2026-06-07T18:06:48+08:00
impact: direction
subagent_call_ids:
  - SUB-20260607T083000Z-main-TC8U-ROBUSTCHECK
  - SUB-20260607T102400Z-main-C35J-RESULTCHECK
subagent_exemption:
tags: [双池轮动, TopN抗抖, 换仓确认, 负控, observe]
---

# TopN抗抖随机延迟负控后观察决策

## 关联链接

- 受影响方向：[[02_研究方向/RD-20260605T115651Z-main-EXE0_双池轮动执行与换仓模块|双池轮动执行与换仓模块]]
- 关键实验：[[04_实验记录/EX-20260606T140752Z-main-TC8U_TopN抗抖换仓formal AB预注册|TC8U TopN抗抖换仓formal AB预注册]]
- 关键实验：[[04_实验记录/EX-20260607T083033Z-main-C35J_TopN抗抖切换延迟负控与2024归因|C35J TopN抗抖切换延迟负控与2024归因]]
- 路线预注册：[[04_实验记录/EX-20260606T134047Z-main-HPHZ_五方向接手证据映射与首轮路线预注册|五方向接手证据映射与首轮路线预注册]]
- 研究驾驶舱：[[00_入口/研究驾驶舱|研究驾驶舱]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 决策结论

`observe`

允许：把 TopN 抗抖和切换延迟作为执行模块的观察边界和后续机制研究线索。

不允许：把 `top3_gap050`、`top3_gap050_confirm1` 或 `top3_gap050_random50` 写入默认交易逻辑、shadow 或实盘；也不允许围绕本轮 random50 继续后验扩大 seed、概率、冷却期网格。

路线状态：方向 4 不 promote。若继续，只能新开“换仓确认机制”预注册，并先解释 2022_2023 失败与 seed 稳健性。

## 这个节点是什么

TC8U 证明 TopN 抗抖能减少换仓，但收益不够稳定，尤其 2024 落后 baseline。C35J 进一步问：这个效果是不是 TopN/gap 机制独有，还是普通延迟换仓也能做到？

答案是：普通随机延迟也能在 3/4 分段复制并超过 Top3/gap，因此 TopN/gap 的机制解释被负控混淆。本节点把这个结论固化为 `observe`，防止把少换仓的偶然路径误升级为默认交易逻辑。

## 相比上一个节点改变了什么

- TC8U 的判断从“成本扰动后仍 3/4 分段不弱，但不能 promote”进一步降级为“机制被随机延迟负控混淆”。
- Top3/gap 的 2024 落后已通过 C35J 归因确认主要来自持仓错位，不是费用吞噬。
- random50 的高收益不能当成新候选，因为它是固定 seed 负控，且 2022_2023 大幅失败。

## 子代理依据来源

适配判断：`适合调用`

调用状态：`called`

子代理豁免：

```text
不适用
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-20260607T083000Z-main-TC8U-ROBUSTCHECK | Descartes | SUBTASK-20260607T083000Z-main-TC8U-ROBUSTCHECK | gpt-5.3-codex-spark | 2026-06-07T08:30:00Z | 当前状态、研究驾驶舱、TC8U 实验卡、平台 scripts/configs/results | 无 | 无回测 | 只读核对，不做路线生杀 | 平台没有现成 random delay/cooldown/2024 attribution 产物；2024 归因有事后解释风险 | 主控复核后新开 C35J 并完成 formal | 支持把 TC8U 下一步收束为最小负控和 2024 归因；最终 observe 判断由主控基于 C35J 结果给出 |
| SUB-20260607T102400Z-main-C35J-RESULTCHECK | Godel | SUBTASK-20260607T102400Z-main-K6P8_子查_C35J结果复核 | inherited | 2026-06-07T10:24:00Z | C35J summary、comparison CSV、segment metrics 和 2024 attribution summary | 无 | `Test-Path`、JSON/CSV 读取与重新聚合 | 只读核对与数字摘录，不做路线生杀 | 未逐个复核 16 个 run_dir；2024 attribution 只读 | 主控采纳其 16/16、missing 为空、CSV 与 summary 自洽的结论 | 支持把 BP3L 固化为 observe，而不是 promote 或继续后验扩网格 |

台账行：已同步 `01_台账/子代理调用台账.csv`。

## 支持证据

- C35J strict summary 通过：`expected_runs=16`、`completed_runs=16`、`missing=[]`。
- `top3_gap050` 相比 baseline：3/4 分段 final 不低、四段合计 final 多 `4830.17`、交易少 `243`，说明它确实有降交易效果。
- `top3_gap050_random50` 相比 Top3/gap：3/4 分段 final 不低、3/4 分段 MDD 不差，四段合计 final 多 `93692.92`、交易少 `202`，触发 C35J 预注册证伪条件。
- `random50` 修复 Top3/gap 的 2024 相对亏损：2024 final 比 Top3/gap 多 `6024.54`；2025_20260519 比 Top3/gap 多 `90487.98`。
- 2024 只读归因显示 Top3/gap 费用少约 `742.47`，但持仓差异日合计少 `13776.13`，说明问题主要来自持仓错位。

## 反对证据

- `random50` 在 2022_2023 失败严重：相对 baseline 少 `31158.35`，相对 Top3/gap 少 `33873.65`，MDD 也更差。
- `confirm1` 只有 1/4 分段 final 不低于 Top3/gap，四段合计少 `74532.00`，说明简单确认延迟不是稳定改进。
- random50 是固定 seed 的负控，不是可解释交易规则；把它作为候选会引入更强的路径依赖和后验选择风险。
- TC8U/C35J 尚未完成 seed 敏感性、冷却期邻域、A23 组合交互和完整未来函数提升审计，因此不能进入 promote。

## 边界

这个决策不能说明“随机延迟有 alpha”，也不能说明 TopN 抗抖完全无价值。它只能说明：现有 Top3/gap 的收益改善不足以证明机制独有，且被普通延迟负控混淆。

本决策也不改变 hard5 或 A23 默认逻辑。A23 的成本/换手约束、事件归因和组合交互必须另开实验。

## 后续动作

- 停止围绕 TC8U TopN/gap 继续扩排名、比例、分差、seed 或冷却期网格。
- 如果继续方向 4，新开“换仓确认机制”预注册，先做 seed 敏感性、2022 失败归因、成本扰动和错位负控。
- 将 C35J 结果同步到研究驾驶舱、当前状态、实验台账和决策台账。
- 平台新增的切换延迟参数保持默认关闭，只作为研究配置使用。

## 需要同步更新

- [x] 研究方向页
- [x] 研究驾驶舱
- [x] 实验台账
- [x] 决策台账
- [x] 子代理调用台账
- [ ] 术语库，本轮无新增术语
