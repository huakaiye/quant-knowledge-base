---
type: 研究决策
dec_id: DEC-20260618T140056Z-main-FDSQ
rd_ids: [RD-20260614T115209Z-main-MCYG]
ex_ids:
  - EX-20260618T135410Z-main-CJC9
decision: revise
owner: main
created_at: 2026-06-18T14:00:56Z
updated_at: 2026-06-18T14:00:56Z
impact: direction
subagent_call_ids:
  - SUB-EXEMPT-20260618T135410Z-main-CJC9
subagent_exemption: 当前多代理工具要求用户显式授权子代理/委派/并行 agent；本轮用户未显式授权。
tags:
  - 非R方
  - 低滞后
  - hazard
  - 事件簇
  - revise
---

# 事件簇hazard只读接近但未通过后修订

## 关联链接

- 受影响方向：[[02_研究方向/RD-20260614T115209Z-main-MCYG_双池轮动动量崩溃事前暴露管理|RD-20260614T115209Z-main-MCYG 动量崩溃事前暴露管理]]
- 关键实验：[[04_实验记录/EX-20260618T135410Z-main-CJC9_组合层事件簇hazard只读面板|EX-20260618T135410Z-main-CJC9 组合层事件簇hazard只读面板]]
- 上一张决策：[[05_研究决策/DEC-20260618T134120Z-main-L8GT_组合层下尾经济损失校准失败后暂停|DEC-20260618T134120Z-main-L8GT 组合层下尾经济损失校准失败后暂停]]
- 后续实验：
- 研究驾驶舱：[[00_入口/研究驾驶舱|研究驾驶舱]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 决策结论

`revise`

CJC9 不通过只读质量门，不进入动作、shadow、observe 或实盘；但 `episode_age_hazard` 在 2025 强趋势段给出目前最清晰的非 R 方低滞后区分信号，允许新开更窄的只读审计。禁止在 CJC9 上直接调权重、窗口、top 比例或 seed。

## 这个节点是什么

这个节点处理的是：在 YCW5 固定经济损失排序失败后，我们换成“事件已经持续多久、是否成簇、状态是否退化”的生命周期问题。结果不是正式通过，但第一次出现了接近答案的线索。

对新手来说，区别是：以前很多实验在 2025 强趋势段都把风险排反；CJC9 的 `episode_age_hazard` 在 2025 反而能把高风险和低风险分出来。但它还没有跨段稳定打赢 K3YL/YCW5，也有日期簇和错位解释，所以只能修订继续。

## 相比上一个节点改变了什么

- 相比 YCW5：从固定横截面经济损失排序，改为事件持续时间/簇密度/hazard。
- 相比 Z78J：不再用 overheat + 趋势支撑的同字段守门，而是使用 episode age、连续 overheat/front_any/unfavorable、近期退化等生命周期字段。
- 路线状态从“经济损失排序 park”修订为“episode age/hazard 值得下一轮只读审计”。

## 子代理依据来源

适配判断：`适合调用`

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：当前多代理工具要求用户显式授权子代理/委派/并行 agent；本轮用户未显式授权；主控：main；时间：2026-06-18T13:54:10Z
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-EXEMPT-20260618T135410Z-main-CJC9 | 无 | SUBTASK-CJC9-EPISODE-HAZARD-EXEMPT | 无 | 2026-06-18T13:54:10Z | LJQ7 action panel；K3YL outputs；CJC9 summary/metrics/random controls；YCW5边界 | CJC9实验记录；本决策卡；台账待回填 | `PYTHONUNBUFFERED=1 PYTHONPATH=src python3 scripts/research/analyze_cjc9_episode_hazard_readonly.py` | 只判断只读 hazard 线索，不判断交易化 | 2025样本小、日期簇、错位负控、跨段竞争不足 | 主控已复核 | 支持 revise，不支持动作化 |

台账行：`SUB-EXEMPT-20260618T135410Z-main-CJC9` 已同步至 `01_台账/子代理调用台账.csv`。

## 支持证据

- `episode_age_hazard` 在 2025_20260519 表现强：AUC `0.7896`，top20 `bad10` 提升 `+36.01pct`，低风险桶 `bad10` 降低 `-45.81pct`，top20 趋势继续率低于基准 `-20.32pct`。
- `episode_age_hazard` 随机同规模负控较干净：bad p95 胜 `2/3`，loss p95 胜 `1/3`，且 2025 bad p95 胜。
- `cluster_decay_hazard` 跨段竞争指标好：Brier 对常数 `3/3`、K3YL `2/3`、R方 `3/3`、YCW5 proxy `2/3` 胜；top20 下尾损失提升 `3/3` 为正。

## 反对证据

- 总质量门 `readonly_pass=false`，没有任何单一候选同时通过 2025、竞争基准和随机负控。
- `cluster_decay_hazard` 随机同规模负控失败：bad p95 `0/3` 胜、loss p95 `1/3` 胜。
- `episode_age_hazard` 竞争门槛失败：Brier 对 K3YL `1/3` 胜、对 YCW5 proxy `1/3` 胜；10% check loss 对 K3YL `1/3` 胜。
- 2025 的 `episode_hazard_shift_prev1` 和 `shift_next1` 也有明显正提升，说明日期连续性可能解释部分效果。

## 边界

这个决策不能说明 CJC9 已可交易，也不能说明 episode age 可以直接变成降仓规则。它只说明：在当前所有非 R 方/低滞后尝试中，事件持续时间是目前最值得继续审计的线索。

仍然不确定：2025 强结果是真实生命周期机制，还是连续日期簇导致；episode age 哪个组成部分最有贡献；如果剔除连续日期或做 block bootstrap，效果是否仍保留。

## 后续动作

- 新开独立预注册实验，固定 `episode_age_hazard`，不调权重。
- 加强负控：prev1/next1、同段 block bootstrap、去连续日期抽样、按 episode 留一。
- 只读解释 A1/overheat/front_any/unfavorable 持续时间的贡献；如果解释不稳或负控复制，则 park。
- 在通过下一轮 L1 前，不允许动作 smoke、shadow、observe 或实盘改动。

## 需要同步更新

- [x] 研究方向页
- [x] 研究驾驶舱
- [x] 实验台账
- [x] 决策台账
- [x] 子代理调用台账
- [x] 术语库
