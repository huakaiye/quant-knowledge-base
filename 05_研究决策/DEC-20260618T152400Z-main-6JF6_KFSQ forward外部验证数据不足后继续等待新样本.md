---
type: 研究决策
dec_id: DEC-20260618T152400Z-main-6JF6
rd_ids: [RD-20260614T115209Z-main-MCYG]
ex_ids:
  - EX-20260618T151314Z-main-KZF8
  - EX-20260618T145033Z-main-KFSQ
decision: promote_candidate
owner: main
created_at: 2026-06-18T15:24:00Z
updated_at: 2026-06-18T15:24:00Z
impact: direction
subagent_call_ids:
  - SUB-EXEMPT-20260618T151000Z-main-EXTV
subagent_exemption: 当前多代理工具要求用户显式授权子代理/委派/并行 agent；本轮用户未显式授权。
tags:
  - 非R方
  - 低滞后
  - forward
  - 外部验证
  - 数据门禁
  - 不动作化
---

# KFSQ forward外部验证数据不足后继续等待新样本

## 关联链接

- 受影响方向：[[02_研究方向/RD-20260614T115209Z-main-MCYG_双池轮动动量崩溃事前暴露管理|RD-20260614T115209Z-main-MCYG 动量崩溃事前暴露管理]]
- 关键实验：[[04_实验记录/EX-20260618T151314Z-main-KZF8_KFSQ confirmed_state forward外部验证数据门禁|EX-20260618T151314Z-main-KZF8 KFSQ confirmed_state forward 外部验证数据门禁]]
- 上一张决策：[[05_研究决策/DEC-20260618T145429Z-main-VRMQ_confirmed_state单组件通过后进入外部验证候选|DEC-20260618T145429Z-main-VRMQ confirmed_state 单组件通过后进入外部验证候选]]
- 后续实验：
- 研究驾驶舱：[[00_入口/研究驾驶舱|研究驾驶舱]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 决策结论

`promote_candidate`

这里的 `promote_candidate` 不是说 KZF8 外部验证通过，而是说：KFSQ 的 `confirmed_state_run_len` 外部验证候选资格保留；KZF8 只证明当前 forward 样本没有足够 H10 标签，不能升级，也不能判死。

## 这个节点是什么

这个节点处理“KFSQ 是否已经有足够新样本做外部验证”。我们补了一个连续 hard5 forward 窗口，避免 LWC4/8UP9 两段净值重置，但发现 A1 主宇宙太少、太晚，H10 可标注样本为 0。

## 相比上一个节点改变了什么

- VRMQ 让 KFSQ 进入外部验证候选，但尚未验证。
- KZF8 尝试用 2026-05-20 到 2026-06-17 的 forward 连续窗口验证。
- 结果不是通过或失败，而是数据门禁不足：H10 可标注行数 `0`，episode 数 `0`；H5 也只有 `2` 行和 `1` 个 episode。

## 子代理依据来源

适配判断：`适合调用`

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：当前多代理工具要求用户显式授权子代理/委派/并行 agent；本轮用户未显式授权；主控：main；时间：2026-06-18T15:10:00Z
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-EXEMPT-20260618T151000Z-main-EXTV | 无 | SUBTASK-KFSQ-EXTERNAL-VALIDATION-EXEMPT | 无 | 2026-06-18T15:10:00Z | KFSQ/2XKW 输出；KZF8 forward run；summary/CSV | KZF8实验记录；本决策；台账 | `run_v2_backtest.py --config ...kzf8...json`；`analyze_kzf8_kfsq_forward_validation_readonly.py` | 只判断外部验证数据门禁，不判断交易化 | H10 主宇宙为空，不能误判通过/失败 | 主控已复核 | 支持候选保留但继续等待新样本 |

台账行：已同步至 `01_台账/子代理调用台账.csv`。

## 支持证据

- 连续 forward hard5 回测成功，窗口覆盖 2026-05-20 到 2026-06-17，共 `21` 个交易日，final `104976.11`。
- ACTION 分布为 A0/A1/A2 = `6/7/8`，脚本能正常解析状态和 `confirmed_state_run_len`。
- 数据门禁失败是清晰事实：H10 可标注 A1 行数 `0`，H10 episode 数 `0`，低于预注册门槛 `20/5`。
- 因为空样本不能评价指标，所以 KZF8 没有反证 KFSQ。

## 反对证据

- 没有任何 H10 外部指标，不能说 KFSQ 通过外部验证。
- H5 虽有 `2` 行，但全在 `1` 个 episode 内，不能替代 H10 主门槛。
- 当前平台数据截至 2026-06-17，无法在不更新数据的前提下继续延长 forward 标签。

## 边界

这个决策不能支持任何交易动作。不得进入 shadow、observe、实盘默认逻辑或动作 smoke。不得因为 KZF8 数据不足就在当前样本继续调 `confirmed_state_run_len` 的阈值、窗口、top 比例、seed 或 episode 定义。仍然不确定的是：等新样本足够后，KFSQ 是否还能打败 episode pooled 随机和 shift。

## 后续动作

- 保留 KFSQ 为外部验证候选。
- 等真实观察流、dry-run 或 forward 样本积累到 H10 可标注 A1 行数 `>=20` 且 A1 episode 数 `>=5` 后，用同一脚本复验。
- 若希望更快推进，应先建设 dry-run 日志记录层，而不是继续滚动无标签短窗。

## 需要同步更新

- [x] 研究方向页
- [x] 研究驾驶舱
- [x] 实验台账
- [x] 决策台账
- [x] 子代理调用台账
- [x] 术语库
