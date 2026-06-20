---
type: 研究决策
dec_id: DEC-20260618T142119Z-main-NWY3
rd_ids: [RD-20260614T115209Z-main-MCYG]
ex_ids:
  - EX-20260618T141233Z-main-M3VC
decision: revise
owner: main
created_at: 2026-06-18T14:21:19Z
updated_at: 2026-06-18T14:21:51Z
impact: direction
subagent_call_ids:
  - SUB-EXEMPT-20260618T141233Z-main-M3VC
subagent_exemption: 当前多代理工具要求用户显式授权子代理/委派/并行 agent；本轮用户未显式授权。
tags:
  - 非R方
  - 低滞后
  - hazard
  - 事件簇
  - revise
  - 随机负控
---

# episode_age稳定性审计严格随机未过后修订

## 关联链接

- 受影响方向：[[02_研究方向/RD-20260614T115209Z-main-MCYG_双池轮动动量崩溃事前暴露管理|RD-20260614T115209Z-main-MCYG 动量崩溃事前暴露管理]]
- 关键实验：[[04_实验记录/EX-20260618T141233Z-main-M3VC_episode_age hazard稳定性与错位簇审计|EX-20260618T141233Z-main-M3VC episode_age hazard稳定性与错位簇审计]]
- 上一张决策：[[05_研究决策/DEC-20260618T140056Z-main-FDSQ_事件簇hazard只读接近但未通过后修订|DEC-20260618T140056Z-main-FDSQ 事件簇hazard只读接近但未通过后修订]]
- 后续实验：
- 研究驾驶舱：[[00_入口/研究驾驶舱|研究驾驶舱]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 决策结论

`revise`

M3VC 不能升级为 `promote_candidate`。`episode_age_hazard` 在 raw、separated bucket、block bootstrap 和组件拆解上都很接近，但按严格口径，去连续日期和 episode 聚合后的同规模随机负控可以复制结果，因此不能说它已经超越 R 方、K3YL 或可以交易化。

允许保留“状态生命周期/episode age”作为 MCYG 当前最接近的非 R 方低滞后方向；禁止在本样本继续扫权重、窗口、top 比例或 seed；禁止动作 smoke、shadow、observe、实盘改动。

## 这个节点是什么

这个节点处理的是 CJC9 之后最关键的问题：`episode_age_hazard` 在 2025 真的有机制，还是只是连续日期和少数 episode 把结果堆出来。

对新手来说，M3VC 的意义是：我们没有被漂亮的 `+36.01pct` raw 提升带走，而是把它拆成“连续日期去掉后还剩多少、按 episode 看还剩多少、随机同规模能不能撞出来”。结果说明这条线有价值，但还没足够干净。

## 相比上一个节点改变了什么

- 相比 CJC9：从“发现 episode_age 近候选”进入“固定分数后的稳定性审计”。
- 更严格地处理随机负控：raw 通过不够，去连续日期和 episode 聚合也必须打败随机。
- 结论从“可能接近”修正为“机制近但严格随机未过”，下一步不能靠调参，只能靠外部/事件级验证。

## 子代理依据来源

适配判断：`适合调用`

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：当前多代理工具要求用户显式授权子代理/委派/并行 agent；本轮用户未显式授权；主控：main；时间：2026-06-18T14:12:33Z
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-EXEMPT-20260618T141233Z-main-M3VC | 无 | SUBTASK-M3VC-EPISODE-STABILITY-EXEMPT | 无 | 2026-06-18T14:12:33Z | CJC9 outputs；LJQ7 action panel；M3VC summary/CSV；MCYG方向文档 | M3VC实验记录；本决策卡；平台只读脚本；台账待回填 | `PYTHONUNBUFFERED=1 PYTHONPATH=src python3 scripts/research/analyze_m3vc_episode_age_stability_readonly.py` | 只读稳定性审计，不判断交易化 | 日期簇、episode小样本、随机复制、状态自相关 | 主控收紧随机门槛后重跑并复核 | 支持 revise，不支持动作化 |

台账行：`SUB-EXEMPT-20260618T141233Z-main-M3VC` 已同步至 `01_台账/子代理调用台账.csv`。

## 支持证据

- raw 2025 强：top20 `bad10` 从基准 `54.90%` 到 `90.91%`，提升 `+36.01pct`；low20 `bad10` 仅 `9.09%`，降低 `-45.81pct`。
- 去连续 top 选择后仍强：`separated_bucket_gap5` top20 `bad10` 提升 `+26.92pct`，low20 降低 `-18.54pct`。
- 5日 block bootstrap 稳：top20 `bad10` lift 5% 分位 `+15.33pct`，low20 lift 95% 分位 `-14.62pct`。
- 组件不完全单点依赖：4个组件达到支持阈值，leave-one-out 6行保留方向。

## 反对证据

- 总门槛 `readonly_pass=false`，失败原因是 `random_gate=false`。
- `calendar_thin_gap5` 只有 17 行、top_n=4；主分数 top lift `+8.82pct`，但随机 top p95 `+33.82pct`。
- `episode_level` 只有 11 个 episode、top_n=3；主分数 top lift `+45.45pct`，随机 top p95 同为 `+45.45pct`。
- `shift_prev1` raw 仍有 `+26.92pct`，说明状态自相关/日期簇解释不能完全排除。
- episode 聚合下 top 桶 `trend_good10_lift` 为 `+12.12pct`，坏路径和趋势继续可能在同一 episode 内并存，不能直接降仓。

## 边界

这个决策不能说明 `episode_age_hazard` 已经可用，也不能说明它已通过样本外、成本扰动、交易行为或未来函数最终审计。它只说明：在当前非 R 方方向里，状态生命周期是最接近答案的线索，但仍缺事件级有效样本。

不允许的动作：

- 不改实盘默认逻辑。
- 不开 shadow/observe。
- 不做动作 smoke。
- 不在同一结果上继续扫权重、窗口、top 比例或随机 seed。

## 后续动作

- 优先做事件级外部验证：扩大到更多组合、更长历史或新数据流，目标是打败 episode-level 随机负控。
- 若没有外部样本，只能新开“更少组件机制压缩”的只读复核，重点检验 `unfavorable_run_len` 与 `confirmed_state_run_len` 是否能在 episode-level 上过随机，而不是追求 raw top 指标更高。
- 等待真实观察流或 dry-run 日志时，可只记录分数，不改变交易。

## 需要同步更新

- [x] 研究方向页
- [x] 研究驾驶舱
- [x] 实验台账
- [x] 决策台账
- [x] 子代理调用台账
- [x] 术语库
