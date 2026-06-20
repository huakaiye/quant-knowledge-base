---
type: 研究决策
dec_id: DEC-20260618T145429Z-main-VRMQ
rd_ids: [RD-20260614T115209Z-main-MCYG]
ex_ids:
  - EX-20260618T145033Z-main-KFSQ
decision: promote_candidate
owner: main
created_at: 2026-06-18T14:54:29Z
updated_at: 2026-06-18T14:54:29Z
impact: direction
subagent_call_ids:
  - SUB-EXEMPT-20260618T145033Z-main-KFSQ
subagent_exemption: 当前多代理工具要求用户显式授权子代理/委派/并行 agent；本轮用户未显式授权。
tags:
  - 非R方
  - 低滞后
  - episode级
  - 单组件
  - 外部验证候选
---

# confirmed_state单组件通过后进入外部验证候选

## 关联链接

- 受影响方向：[[02_研究方向/RD-20260614T115209Z-main-MCYG_双池轮动动量崩溃事前暴露管理|RD-20260614T115209Z-main-MCYG 动量崩溃事前暴露管理]]
- 关键实验：[[04_实验记录/EX-20260618T145033Z-main-KFSQ_confirmed_state单组件episode随机负控只读复核|EX-20260618T145033Z-main-KFSQ confirmed_state单组件episode随机负控只读复核]]
- 上一张决策：[[05_研究决策/DEC-20260618T144237Z-main-GNSM_生命周期双组件episode负控未过后暂停|DEC-20260618T144237Z-main-GNSM 生命周期双组件episode负控未过后暂停]]
- 后续实验：[[04_实验记录/EX-20260618T151314Z-main-KZF8_KFSQ confirmed_state forward外部验证数据门禁|EX-20260618T151314Z-main-KZF8 KFSQ forward 外部验证数据门禁]]
- 研究驾驶舱：[[00_入口/研究驾驶舱|研究驾驶舱]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 决策结论

`promote_candidate`

`confirmed_state_run_len` 单组件通过只读门槛，允许进入“外部验证候选”。这里的 `promote_candidate` 不是交易候选，不是 shadow/observe 候选，也不是实盘改动候选；它只表示下一步值得用新样本、真实观察流或 dry-run 日志做独立验证。

## 这个节点是什么

这个节点处理 2XKW 的后验诊断线索：双组件失败后，单独的 `confirmed_state_run_len` 是否比双组件更干净。结果显示它在下尾损失严重度上明显更强，并打败了随机和 shift。

## 相比上一个节点改变了什么

- 2XKW 的双组件 `state_lifecycle_pair` 被随机和 shift 复制，已 park。
- KFSQ 单组件在 pooled episode 下尾损失上过关：主分数 top20 下尾损失 lift `+4.65pct`，随机 p95 `+2.55pct`，shift_next1 `+2.58pct`。
- 证据仍降级，因为候选来自 2XKW 后验诊断。

## 子代理依据来源

适配判断：`适合调用`

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：当前多代理工具要求用户显式授权子代理/委派/并行 agent；本轮用户未显式授权；主控：main；时间：2026-06-18T14:50:33Z
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-EXEMPT-20260618T145033Z-main-KFSQ | 无 | SUBTASK-KFSQ-CONFIRMED-STATE-EXEMPT | 无 | 2026-06-18T14:50:33Z | 2XKW scored panel；KFSQ summary/CSV；MCYG方向文档 | KFSQ实验记录；本决策卡；平台只读脚本；台账已同步 | `PYTHONUNBUFFERED=1 PYTHONPATH=src python3 scripts/research/analyze_kfsq_confirmed_state_episode_readonly.py` | 只读单组件复核，不判断交易化 | 后验选择偏差、episode样本小、bad10随机持平 | 主控已复核 | 支持外部验证候选，不支持动作化 |

台账行：已同步至 `01_台账/子代理调用台账.csv`。

## 支持证据

- pooled OOS episode top20 下尾损失 lift `+4.65pct`，高于随机 p95 `+2.55pct`。
- 下尾损失 lift 高于 shift_prev1 `+2.19pct` 和 shift_next1 `+2.58pct`。
- low20 `bad10` lift `-38.84pct`，低于随机 low bad 5% 分位 `-24.55pct`。
- 2025 row 口径强：top20 `bad10` lift `+36.01pct`，low20 `-45.81pct`，top20 下尾损失 lift `+2.97pct`。
- 相比双组件，pooled 下尾损失 lift 从 `+2.55pct` 提升到 `+4.65pct`。

## 反对证据

- 候选来自 2XKW 后验诊断，不是独立先验发现。
- top20 `bad10` rate 与随机 p95 持平，主要优势来自下尾损失严重度，而不是事件发生率。
- OOS episode 只有 32 个，2025 只有 11 个 episode。
- 仍未经过外部样本、真实观察流、dry-run 或交易行为门禁。

## 边界

这个决策不能支持任何交易动作。不得进入 shadow、observe、实盘默认逻辑或动作 smoke。不得在当前样本继续调 `confirmed_state_run_len` 阈值、窗口、top比例或 seed。

## 后续动作

- 只允许新开外部验证或 forward/dry-run 只读记录。
- 验证目标固定：`confirmed_state_run_len` 单组件的 episode pooled 下尾损失是否继续打败随机和 shift。
- 若没有新样本，不继续在当前样本上优化。
- KZF8 已补第一轮 forward 数据门禁：当前 H10 标签不足，候选保留但不升级；下一次必须先满足 H10 可标注 A1 行 `>=20` 且 episode `>=5`。

## 需要同步更新

- [x] 研究方向页
- [x] 研究驾驶舱
- [x] 实验台账
- [x] 决策台账
- [x] 子代理调用台账
- [x] 术语库
