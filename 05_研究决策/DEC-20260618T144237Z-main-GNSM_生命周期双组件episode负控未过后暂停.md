---
type: 研究决策
dec_id: DEC-20260618T144237Z-main-GNSM
rd_ids: [RD-20260614T115209Z-main-MCYG]
ex_ids:
  - EX-20260618T143708Z-main-2XKW
decision: park
owner: main
created_at: 2026-06-18T14:42:37Z
updated_at: 2026-06-18T14:42:37Z
impact: direction
subagent_call_ids:
  - SUB-EXEMPT-20260618T143708Z-main-2XKW
subagent_exemption: 当前多代理工具要求用户显式授权子代理/委派/并行 agent；本轮用户未显式授权。
tags:
  - 非R方
  - 低滞后
  - episode级
  - 随机负控
  - park
---

# 生命周期双组件episode负控未过后暂停

## 关联链接

- 受影响方向：[[02_研究方向/RD-20260614T115209Z-main-MCYG_双池轮动动量崩溃事前暴露管理|RD-20260614T115209Z-main-MCYG 动量崩溃事前暴露管理]]
- 关键实验：[[04_实验记录/EX-20260618T143708Z-main-2XKW_生命周期双组件episode级随机负控只读复核|EX-20260618T143708Z-main-2XKW 生命周期双组件episode级随机负控只读复核]]
- 上一张决策：[[05_研究决策/DEC-20260618T142119Z-main-NWY3_episode_age稳定性审计严格随机未过后修订|DEC-20260618T142119Z-main-NWY3 episode_age稳定性审计严格随机未过后修订]]
- 后续实验：
- 研究驾驶舱：[[00_入口/研究驾驶舱|研究驾驶舱]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 决策结论

`park`

暂停 `state_lifecycle_pair = unfavorable_run_len + confirmed_state_run_len` 双组件方案。它在 episode pooled 上看起来强，但随机同规模和 `shift_next1` 都能复制主结果，不能作为动作、shadow、observe 或实盘依据。

生命周期方向不 kill。`confirmed_state_only` 在 2XKW 诊断中下尾损失分离更强，但这是后验观察，必须新开预注册，只能只读复核。

## 这个节点是什么

这个节点处理 M3VC 之后的“压缩机制”问题：如果五组件 episode age 太复杂，两个最直观的状态持续时间组件是否更干净。结果显示：不是组件数量问题，episode 级随机和状态自相关仍然能解释主要表现。

## 相比上一个节点改变了什么

- 相比 M3VC：从五组件 `episode_age_hazard` 压缩为两个状态生命周期组件。
- 结果更明确地证伪“双组件能解决随机负控”的假设。
- 新增一个诊断线索：`confirmed_state_only` 可能比双组件更值得单独复核，但不能在本实验中后验升级。

## 子代理依据来源

适配判断：`适合调用`

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：当前多代理工具要求用户显式授权子代理/委派/并行 agent；本轮用户未显式授权；主控：main；时间：2026-06-18T14:37:08Z
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-EXEMPT-20260618T143708Z-main-2XKW | 无 | SUBTASK-2XKW-LIFECYCLE-PAIR-EXEMPT | 无 | 2026-06-18T14:37:08Z | LJQ7 action panel；2XKW summary/CSV；MCYG方向文档 | 2XKW实验记录；本决策卡；平台只读脚本；台账待回填 | `PYTHONUNBUFFERED=1 PYTHONPATH=src python3 scripts/research/analyze_2xkw_lifecycle_pair_episode_readonly.py` | 只读机制压缩复核，不判断交易化 | episode随机复制、shift复制、单组件后验择优 | 主控已复核 | 支持 park，不支持动作化 |

台账行：`SUB-EXEMPT-20260618T143708Z-main-2XKW` 已同步至 `01_台账/子代理调用台账.csv`。

## 支持证据

- pooled episode top20 `bad10` lift 为 `+32.59pct`，top20 下尾损失 lift 为 `+2.55pct`。
- 2025 不反向：episode top20 `bad10` lift `+12.12pct`，separated row top20 `bad10` lift `+17.83pct`，low20 `-27.63pct`。
- `confirmed_state_only` 诊断下尾损失 lift `+4.65pct`，提示状态持续时间仍可作为后续只读线索。

## 反对证据

- episode pooled 随机负控复制：random top `bad10` p95 与主分数同为 `+32.59pct` lift。
- random tail loss p95 `+2.66pct`，高于主分数 `+2.55pct`。
- `shift_next1` 复制主结果：top20 `bad10` lift `+32.59pct`，下尾损失 lift `+2.58pct`。
- 双组件未显示相对 `confirmed_state_only` 的稳定增量。

## 边界

这个决策不能说明生命周期方向完全无效；只能说明“双组件等权”不能解决事件级随机和错位问题。也不能把 `confirmed_state_only` 直接升级，因为它是在本实验后看到的诊断结果。

## 后续动作

- park 双组件方案。
- 若继续，只允许新开 `confirmed_state_run_len` 单组件只读复核，明确写成来自 2XKW 诊断的后验候选。
- 不交易化、不 shadow、不 observe、不改实盘。
- 不扫 `unfavorable/confirmed` 权重、不扫 top 比例、不换 seed。

## 需要同步更新

- [x] 研究方向页
- [x] 研究驾驶舱
- [x] 实验台账
- [x] 决策台账
- [x] 子代理调用台账
- [x] 术语库
