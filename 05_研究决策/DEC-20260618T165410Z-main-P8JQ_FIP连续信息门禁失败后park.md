---
type: 研究决策
dec_id: DEC-20260618T165410Z-main-P8JQ
rd_ids: [RD-20260618T164000Z-main-FIPQ]
ex_ids: [EX-20260618T164015Z-main-HPTL]
decision: park
owner: main
created_at: 2026-06-18T16:54:10Z
updated_at: 2026-06-18T17:10:00Z
impact: direction
subagent_call_ids: []
subagent_exemption: "当前多代理工具只有在用户显式要求子代理/委派/并行 agent 时才允许 spawn，本轮没有该授权；主控：main；时间：2026-06-18T16:54:10Z"
tags: [双池轮动, 核心轮动, 非R方, 低滞后, Frog-in-the-Pan, park, 决策]
---

# FIP连续信息门禁失败后park

## 关联链接

- 受影响方向：[[02_研究方向/RD-20260618T164000Z-main-FIPQ_双池轮动FIP连续信息低滞后门禁|双池轮动 FIP 连续信息低滞后门禁]]
- 关键实验：[[04_实验记录/EX-20260618T164015Z-main-HPTL_FIP连续信息score5到6只读门禁|HPTL FIP 连续信息 score5 到 6 只读门禁]]
- 来源文献：[[06_文献资料/08_已归档/LIT-20260603T000000Z-mig-2014DAFROGINTHEPANB412A_L20260521-011FroginthePanContinuousInformationandMomentum|Frog in the Pan: Continuous Information and Momentum]]
- 上一张决策：无
- 后续实验：无
- 研究驾驶舱：[[00_入口/研究驾驶舱|研究驾驶舱]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 决策结论

`park`

## 这个节点是什么

本决策处理的是一个新的非 R 方低滞后候选：Frog-in-the-Pan 连续信息门禁。它不再看 R 方拟合优度，而是用上涨连续性和跳涨集中度判断 `5<=score<6` 的高分候选是否应被 hard5 放行。

## 相比上一个节点改变了什么

- 新增 FIPQ 方向并完成 HPTL 只读门禁。
- 结果显示 FIP 有全样本正均值，但跨阶段不稳，不能进入组合级 formal。
- 本方向从 `active` 直接转为 `park`，避免继续在 FIP 阈值和窗口上后验调参。

## 子代理依据来源

适配判断：`适合调用，但系统规则禁止未授权 spawn`

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：当前多代理工具只有在用户显式要求子代理/委派/并行 agent 时才允许 spawn，本轮没有该授权；主控：main；时间：2026-06-18T16:54:10Z。
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-EXEMPT-20260618T164015Z-main-HPTL | 无 | SUBTASK-FIP-CONTINUITY-GATE-EXEMPT | 无 | 2026-06-18T16:40:15Z | 研究库入口与方法论；FIP 文献卡；R010-A12 旧库记录；平台代理脚本；HPTL summary/CSV | HPTL 实验记录；FIPQ 方向；HPTL 汇总脚本；研究只读池解析兼容修复；本决策；台账已同步 | `analyze_r010a12_literature_hot_gate.py`; `summarize_hptl_fip_continuity_gate.py` | 只读门禁，不判断交易化 | 旧库迁移线索、日收盘代理偏差、分段不稳 | 主控已复核 summary、checks、事件和分段 CSV | 支持 park FIPQ，不支持 formal |

台账行：`01_台账/子代理调用台账.csv` 已登记。

## 支持证据

- 差异事件 `104` 个，超过预注册门槛 `80`。
- H5/H10 差异均值为正：`+1.0084pct` / `+1.1308pct`。
- 0bps/10bps 权益代理相对 hard5 为正：`+8.9901%` / `+10.0860%`。
- 目标一致率 `93.35%`，说明 FIP 是低扰动修补。

## 反对证据

- 固定门禁 `gate_pass=false`。
- H10 差异胜率只有 `50.49%`，低于 `52%` 门槛。
- H5 正分段只有 `1/4`，低于 `3/4` 门槛。
- 0bps 权益正分段只有 `2/4`，低于 `3/4` 门槛。
- 2020_2021 权益代理相对 hard5 为 `-8.1397%`，2024 为 `-0.7111%`。
- FIP 的权益代理弱于状态门控和综合门控，不能证明连续信息是当前最强独立机制。

## 边界

这个决策不能说明 FIP 理论本身错误，也不能说明连续信息在个股、其他 ETF 池或其他频率无效。它只说明：当前双池 ETF、日收盘只读代理、`5<=score<6` 放行口径下，FIP 不具备进入组合级 formal 的稳定性。

## 后续动作

- FIPQ 方向 park。
- HPTL 不进入 formal、shadow、observe 或实盘默认逻辑。
- 不扫 `up_share20`、`jump_ratio20`、`max_abs_ret20`、`ret5`、score 分段、窗口或综合 lit_gate 权重。
- 非 R 方低滞后研究继续等待 KFSQ 外部样本，或等待真实盘口/逐笔/订单簿/成交滑点/dry-run 数据后新开独立方向。

## 需要同步更新

- [x] 研究方向页
- [x] 研究驾驶舱
- [x] 当前状态
- [x] 实验台账
- [x] 决策台账
- [x] 子代理调用台账
- [x] 术语库
