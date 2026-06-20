---
type: 研究决策
dec_id: DEC-20260617T212155Z-main-9PRQ
rd_ids: [RD-20260617T204310Z-main-Q88K]
ex_ids: [EX-20260617T210334Z-main-9VWX]
decision: park
owner: main
created_at: 2026-06-17T21:21:55Z
updated_at: 2026-06-17T21:24:00Z
impact: direction
subagent_call_ids: []
subagent_exemption: 当前可用 spawn_agent 工具要求只有用户显式要求子代理/委派/并行 agent 工作时才可调用；本轮用户未显式授权，主控直接执行并记录豁免。
tags: [双池轮动, 核心轮动, 非R方, fixed-blend, smoke-failed, park, no-live-change]
---

# 固定非R方blend 2024 smoke失败后暂停

## 关联链接

- 受影响方向：[[02_研究方向/RD-20260617T204310Z-main-Q88K_双池轮动顶刊非R方横截面排序|Q88K 双池轮动顶刊非R方横截面排序]]
- 关键实验：[[04_实验记录/EX-20260617T210334Z-main-9VWX_固定非R方blend组合级formal|9VWX 固定非R方blend组合级formal]]
- 上一张决策：[[05_研究决策/DEC-20260617T205354Z-main-W29B_非R方日频PLS失败后修订|W29B 非R方日频PLS失败后修订]]
- 后续实验：待另开不同机制方向；不在 Q88K 内扩 fixed blend
- 研究驾驶舱：[[00_入口/研究驾驶舱|研究驾驶舱]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 决策结论

`park`

Q88K 日频非 R² 横截面排序路线暂停。PLS/Ridge 已由 MTEX 证伪；fixed blend 虽在 MTEX 只读里有 H5 均值线索，但 9VWX 迁移到真实 2024 组合路径后 final 和 MDD 均显著差于 hard5。不得继续扩 fixed blend 权重、lookback、随机 seed、成本参数或候选池过滤。

## 这个节点是什么

这个决策处理 fixed blend 的“最后一次确认”：它不是再看 H5 事件均值，而是问这个信号真正接入双池轮动组合、和防御/执行模块一起跑 2024 压力段时，是否还能比 hard5 更好。

答案是否定的。工程上信号确实生效，但收益路径大幅变差，所以问题不是代码没跑到，而是这个排序方式不适合当前组合。

## 相比上一个节点改变了什么

- W29B 只把 PLS/Ridge 路线判为 `revise`，允许 fixed blend 另开确认实验。
- 9VWX 已完成平台实现、16 个配置生成和 2024 smoke。
- 2024 smoke 结果强反证 fixed blend：final `107562.26` 低于 hard5 `167005.22`，MDD `-33.78%` 差于 hard5 `-26.99%`。
- 因此 Q88K 从 `revise` 收口到 `park`。

## 子代理依据来源

适配判断：`适合调用，但系统工具边界禁止本轮调用`

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：当前可用 spawn_agent 工具要求只有用户显式要求子代理/委派/并行 agent 工作时才可调用；本轮用户未显式授权；主控：main；时间：2026-06-17T21:03:00Z
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 无 | 无 | 无 | 无 | 无 | 无 | 无 | 无 | 系统工具授权边界，不代表任务不适合子代理 | 主控需自行复核平台代码、日志、summary 和门禁 | 已复核编译、配置、`summary.json`、`logs.jsonl` 和汇总输出 | 支持 Q88K park |

台账行：不新增子代理调用台账；正文记录系统工具授权豁免。

## 支持证据

- 平台策略文件和 Q88K 生成/汇总脚本均通过 `py_compile`；运行脚本通过 `bash -n`。
- 生成 `16` 个研究配置，主候选、随机权重负控、成本扰动和 hard5 baseline 均为显式研究配置。
- 2024 smoke exit code `0`，生成完整回测产物。
- `logs.jsonl` 中出现 `Q88K诊断 fixed_non_r2_blend启用`，说明信号分支确实生效。

## 反对证据

- 2024 final：fixed blend `107562.26`，hard5 `167005.22`，差额 `-59442.96`。
- 2024 MDD：fixed blend `-33.78%`，hard5 `-26.99%`，恶化约 `6.79pp`。
- 2024 交易数：fixed blend `278`，hard5 约 `281`，说明失败不是单纯成本或换手过高导致。
- MTEX 的 H5 均值线索在组合路径中消失，说明只读标签和真实持仓目标函数差异很大。

## 边界

- 不能说明所有“非 R²”方向无效；只说明 Q88K 这一组日频固定特征 blend、PLS/Ridge 训练压缩路线不值得继续。
- 不是四段 formal 结论；本轮只跑了 2024 smoke。但 2024 是预注册风险关键段，已经足以阻断本候选进入全量 formal。
- 不能作为修改实盘、shadow 或 observe 的依据。
- 不能据此后验改 fixed blend 权重、lookback、特征池或 candidate gate。

## 后续动作

- 更新 Q88K 方向状态为 `park`。
- 更新 9VWX 实验为 `completed / engineering_smoke_economic_gate_failed`。
- 不继续运行 fixed blend 四段 formal、随机权重 formal 或成本扰动 formal。
- 不改默认 hard5，不写 shadow，不 observe。
- 若继续研究滞后问题，应另开不同机制方向，而不是在日频非 R² blend 上调参。

## 需要同步更新

- [x] 研究方向页
- [x] 研究驾驶舱
- [x] 实验台账
- [x] 决策台账
- [x] 子代理调用台账豁免正文
- [x] 术语库：本轮不新增术语
