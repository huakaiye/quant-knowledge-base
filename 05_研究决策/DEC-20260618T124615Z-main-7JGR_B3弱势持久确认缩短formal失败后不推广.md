---
type: 研究决策
dec_id: DEC-20260618T124615Z-main-7JGR
rd_ids:
  - RD-20260605T115651Z-main-DEF0
ex_ids:
  - EX-20260611T060247Z-main-592F
decision: park
owner: main
created_at: 2026-06-18T12:46:15Z
updated_at: 2026-06-18T12:46:15Z
impact: direction
subagent_call_ids:
  - SUB-EXEMPT-20260618T124615Z-main-7JGR
subagent_exemption: 当前 spawn_agent 工具要求用户显式授权子代理/委派/并行 agent；本轮用户未显式授权。
tags: [ETF双池, 防御模块, B3Gate, tiered-v2, 持久确认, 低滞后, park, no-live-change]
---

# B3弱势持久确认缩短formal失败后不推广

## 关联链接

- 受影响方向：[[02_研究方向/RD-20260605T115651Z-main-DEF0_双池轮动防御模块|双池轮动防御模块]]
- 关键实验：[[04_实验记录/EX-20260611T060247Z-main-592F_B3弱势持久确认缩短负控formal|B3弱势持久确认缩短负控 formal]]
- 前序成本门禁：[[04_实验记录/EX-20260608T041610Z-main-B3QC_B3Gate与TieredV2成本扰动formal|B3Gate 与 TieredV2 成本扰动 formal]]
- 前序滞后负控：[[04_实验记录/EX-20260608T110954Z-main-3MW6_B3Gate与TieredV2触发滞后一日负控formal|B3Gate 与 TieredV2 触发滞后一日负控 formal]]
- 研究驾驶舱：[[00_入口/研究驾驶舱|研究驾驶舱]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 决策结论

`park`

暂停 `fast_confirm3` 这条“把 B3 弱势持久确认从 `8/3/10/10` 缩短到 `3/2/3/3`”的推广路线。不改实盘、不 shadow、不 observe，不继续在 592F 上扫确认天数、连续天数、gate 累计天数、tiered 累计天数或 cap。

这不是废除 B3Gate/tiered-v2 防御骨架。B3QC 和 3MW6 仍支持原 tiered-v2 作为研究防御骨架：抗成本能力成立，及时触发有信息量。7JGR 只说明“当前 fast_confirm3 缩短确认实现”没有超过原 tiered-v2。

## 这个节点是什么

用户持续追问当前策略滞后性太大，前面非 R²、阶段转移、分钟路径、短半衰期、无交易带和微观数据路线都没有形成可交易方案。防御模块里仍有一个合理问题：B3/tiered-v2 是不是确认太慢？

592F 对这个问题做了正式回测：只改确认速度，不改风险 cap、不改 median/breadth/top5 阈值、不改策略源码，并加入 fast cap80 消融和 lag1 负控。

## 相比上一个节点改变了什么

- 592F 不再停留在预注册：12/12 formal 分段已补齐，`quality_gates.json` 已生成。
- `fast_confirm3_gate_pass=false`，因此不能把缩短确认写成候选改进。
- 发现一个有限正信息：fast tiered 相对 fast cap80 有收益增量，且 lag1 负控干净。
- 关键反对证据更强：fast tiered 复合收益低于原 tiered-v2，2025_20260519 也低于原 tiered-v2。

## 子代理依据来源

适配判断：`不适合调用`

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：当前可发现的子代理工具要求用户显式要求子代理/委派/并行 agent；本轮用户未显式授权；主控：main；时间：2026-06-18T12:46:15Z
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-EXEMPT-20260618T124615Z-main-7JGR | 无 | SUBTASK-7JGR-FAST-CONFIRM-PARK-EXEMPT | main | 2026-06-18T12:46:15Z | 592F 实验、592F 平台 summary、B3QC/3MW6 边界 | 本决策、实验记录、台账、入口页 | `run_b3fp_fast_persistence_formal.sh`、`summarize_b3fp_fast_persistence_formal.py` | 只判断 fast_confirm3 是否推广，不判断原 tiered-v2 生产 promote | 缺少子代理独立复核；但 formal 结果和汇总文件可复查 | 主控核对 12/12 summary、`quality_gates.json` 和 `log_audit.csv` | 形成本决策：park fast_confirm3 |

台账行：见 `01_台账/子代理调用台账.csv`。

## 支持证据

- 592F formal 12/12 分段完成，`fast_runs_completed=true`，`log_audit_ok=true`。
- fast tiered 拼接最大回撤 `-27.40%`，浅于原 tiered-v2 `-28.22%`。
- fast tiered 复合收益 `+1154.89%`，高于 fast cap80 `+1123.56%`，说明缩短确认下 tiered 分层仍有增量。
- lag1 负控通过：lag1 复合收益 `+1111.86%`，低于 fast tiered；2025_20260519 lag1 final `284353.24`，低于 fast tiered `298012.41`；`source_after_trade_count=0`。

## 反对证据

- fast tiered 复合收益 `+1154.89%`，低于原 tiered-v2 `+1215.07%`。
- fast tiered 相对原 tiered-v2 的分段 final 只有 `1/4` 不低，低于预注册 `3/4` 门槛。
- 2025_20260519 fast tiered final `298012.41`，比原 tiered-v2 `302895.29` 少 `4882.88`。
- `primary_beats_source=false`、`primary_beats_fast_cap80=false`、`fast_confirm3_gate_pass=false`。

## 边界

- 不能据此否定 B3Gate/tiered-v2 原防御骨架；原 tiered-v2 仍优于 fast_confirm3。
- 不能据此上线、shadow 或 observe fast_confirm3。
- 不能在 592F 结果上后验扩 `cum_days/consecutive_days/gate_cum_days/tiered_cum_days/cap` 网格。
- 不能把低回撤单独当成成功；本轮失败的核心是收益牺牲超过预注册容忍。

## 后续动作

- 防御模块最新边界改为：原 B3Gate/tiered-v2 继续保留为研究防御骨架，fast_confirm3 路线 park。
- 如继续解决滞后，只能另开“state-only extreme 事件归因”或更窄的极端状态审计，先证明触发缺口和收益/回撤损失存在，再谈动作。
- 不改实盘默认，不写 shadow，不 observe，不 production promote。

## 需要同步更新

- [x] 研究方向页
- [x] 研究驾驶舱
- [x] 实验台账
- [x] 决策台账
- [x] 子代理调用台账
- [x] 术语库
