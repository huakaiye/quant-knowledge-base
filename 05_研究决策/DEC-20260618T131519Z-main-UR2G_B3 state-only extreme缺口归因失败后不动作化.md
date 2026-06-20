---
type: 研究决策
dec_id: DEC-20260618T131519Z-main-UR2G
rd_ids:
  - RD-20260605T115651Z-main-DEF0
ex_ids:
  - EX-20260618T130636Z-main-28Z4
decision: park
owner: main
created_at: 2026-06-18T13:15:19Z
updated_at: 2026-06-18T13:15:47Z
impact: direction
subagent_call_ids:
  - SUB-EXEMPT-20260618T130701Z-main-28Z4
subagent_exemption: "当前多代理工具要求用户显式授权子代理/委派/并行 agent；本轮用户未显式授权；主控：main；时间：2026-06-18T13:07:01Z"
tags:
  - B3
  - tiered-v2
  - state-only-extreme
  - low-lag
  - park
---

# B3 state-only extreme缺口归因失败后不动作化

## 关联链接

- 受影响方向：[[02_研究方向/RD-20260605T115651Z-main-DEF0_双池轮动防御模块|RD-20260605T115651Z-main-DEF0 双池轮动防御模块]]
- 关键实验：[[04_实验记录/EX-20260618T130636Z-main-28Z4_B3 state-only extreme触发缺口归因|EX-20260618T130636Z-main-28Z4 B3 state-only extreme触发缺口归因]]
- 上一张决策：[[05_研究决策/DEC-20260618T124615Z-main-7JGR_B3弱势持久确认缩短formal失败后不推广|DEC-20260618T124615Z-main-7JGR B3弱势持久确认缩短formal失败后不推广]]
- 后续实验：暂不从本事件口径进入动作 smoke
- 研究驾驶舱：[[00_入口/研究驾驶舱|研究驾驶舱]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 决策结论

`park`

`state-only extreme` 缺口归因失败，不进入动作 smoke，不 shadow，不 observe，不改实盘；不得用该事件口径绕过 B3/tiered-v2 的弱势持久确认。

## 这个节点是什么

用户关心当前策略是否因为 R 方/确认链条太滞后而错过更早风险。本节点检查的不是 R 方拟合，而是 B3 防御模块中一种更早的“状态极端但动作未触发”日期：如果这些日期之后明显更容易亏损，就可能存在低滞后动作缺口；如果没有，就说明原确认链条在过滤噪声。

## 相比上一个节点改变了什么

- [[05_研究决策/DEC-20260618T124615Z-main-7JGR_B3弱势持久确认缩短formal失败后不推广|7JGR]] 已经否定了 fast_confirm3 缩短确认。
- 本决策进一步否定了“绕过确认，直接用 state-only extreme 提前防御”的只读前置证据。
- B3/tiered-v2 当前不再沿 `state-only extreme` 继续扫阈值、cap、confirm 天数或动作化。

## 子代理依据来源

适配判断：`适合调用`

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：当前多代理工具要求用户显式授权子代理/委派/并行 agent；本轮用户未显式授权；主控：main；时间：2026-06-18T13:07:01Z
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-EXEMPT-20260618T130701Z-main-28Z4 | 无 | SUBTASK-28Z4-STATE-ONLY-EXTREME-EXEMPT | 无 | 2026-06-18T13:07:01Z | 592F/7JGR链路、B3QC tiered-v2 run_dir、28Z4 summary/event/segment/random | 实验与决策记录 | WSL 只读分析脚本 | 豁免不提供独立策略证据 | 缺少子代理复核 | 主控复核四类输出和质量门 | 支持本决策 park |

台账行：已同步 `01_台账/子代理调用台账.csv`。

## 支持证据

- 28Z4 成功解析 4 段原 B3QC tiered-v2 formal：2020_2021、2022_2023、2024、2025_20260519，共 1542 个 ACTION payload。
- 事件覆盖不是问题：`state_only_extreme_days=919`，覆盖 4 段，`coverage_pass=true`。
- 只读质量门失败：`readonly_gate_pass=false`，其中 `risk_lift_pass=false`、`segment_pass=false`、`shift_control_pass=false`、`random_control_pass=false`。
- 全样本未来 10 日 DD5 率：state-only extreme 22.85%，quiet control 24.91%，DD5 lift 为 -2.06pp。
- 前移一日错位负控 DD5 率 24.65%，高于主事件；随机同数量抽样 DD5 均值 24.42%，也高于主事件。

## 反对证据

- 2024 分段中 state-only extreme 确实更差：DD5 lift +4.70pp，future_min_ret_10d_delta -0.784pp。
- 2025_20260519 的 DD5 lift 为 +2.70pp，但路径最差收益均值反而略好，不能支持动作化。
- top events 中存在 2024-01-22/23/24 等真实风险日，说明标签并非完全无意义，只是作为全局动作触发不稳定。

## 边界

这个决策不能说明：

- 不能否定所有低滞后防御研究。
- 不能否定 B3/tiered-v2 原策略。
- 不能证明持久确认天数永远最优。
- 不能用来推出新的实盘开关、shadow、observe 或参数微调。

这个决策只说明：

- 在当前四段 formal 与预注册判据下，`state-only extreme` 不具备足够稳定的未来回撤指向性。
- 不应沿同一事件口径继续做阈值、cap、confirm 天数或随机 seed 扫描。

## 后续动作

- 关闭 `state-only extreme` 动作化路线。
- 保留该字段为诊断标签，不作为交易触发。
- 若继续低滞后防御研究，需要换独立机制，例如真实组合层损失暴露、事件簇 hazard、或新数据源；必须另开预注册实验并设置错位/随机负控。

## 需要同步更新

- [x] 研究方向页
- [x] 研究驾驶舱
- [x] 实验台账
- [x] 决策台账
- [x] 子代理调用台账
- [x] 术语库
