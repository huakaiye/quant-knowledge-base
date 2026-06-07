---
type: 研究决策
dec_id: DEC-20260607T185223Z-main-HH4B
rd_ids: [RD-20260605T133318Z-main-H6V3]
ex_ids: [EX-20260607T154134Z-main-QTFV]
decision: observe
status: active
owner: main
created_at: 2026-06-07T18:52:23Z
updated_at: 2026-06-07T18:52:23Z
impact: engineering
subagent_call_ids:
  - SUB-20260607T154000Z-main-A22FS-ENTRY
  - SUB-20260607T154800Z-main-A22FS-MIN
  - SUB-20260607T183800Z-main-QTFV-VERIFY
subagent_exemption:
tags: [双池轮动, score过热, A22, 原生字段, forward边界, shadow边界, 默认关闭观察]
---

# A22原生forward shadow边界通过后观察决策

## 关联链接

- 受影响方向：[[02_研究方向/RD-20260605T133318Z-main-H6V3_双池轮动score过热拥挤机制模块|双池轮动 score 过热拥挤机制模块]]
- 关键实验：[[04_实验记录/EX-20260607T154134Z-main-QTFV_A22原生forward shadow边界验证预注册|QTFV A22 原生 forward/shadow 边界验证]]
- 上游实验：[[04_实验记录/EX-20260607T131209Z-main-A22N_A22原生字段等价审计预注册|A22N 原生字段等价审计]]；[[04_实验记录/EX-20260607T152511Z-main-EKZ8_A22原生字段日志与未来函数二次审计|EKZ8 日志/日期审计]]
- 上一张决策：[[05_研究决策/DEC-20260607T151252Z-main-A22N_A22原生字段等价通过后工程化决策|A22N 原生字段等价通过后工程化决策]]
- 后续实验：待新开生产前 forward/未来函数门禁时再登记
- 研究驾驶舱：[[00_入口/研究驾驶舱|研究驾驶舱]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 决策结论

`observe`

A22 cap70 可以使用 `r010a22_hot_score_budget_*` 原生字段进入默认关闭观察。观察含义是：允许记录 A22 native live/shadow 预算建议、触发状态和日期边界，允许继续做生产前门禁；不允许把 A22 cap70 直接切换为默认交易逻辑，不允许因为 QTFV 通过而废除 hard5。

当前默认生产边界仍是 hard5。A22 仍只是 hard5 替代研究的首选挑战者。

## 这个节点是什么

QTFV 处理的是工程边界问题：A22 已经从旧 A13 字段复用迁移到原生字段，现在还要确认它在 live 和 shadow 两种运行方式下不会偷偷改变交易路径。

结果显示：native live 能复现 A22N；shadow_on/off 只改变日志，不改变订单、成交、净值或持仓；双开 A13+A22 的配置能被 guard 检出。因此 A22 可以继续作为默认关闭观察对象。

## 相比上一个节点改变了什么

- A22N 决策只允许做原生字段/日志清理；本决策进一步允许默认关闭观察。
- EKZ8 只读审计确认日志和可见日期顺序；QTFV 进一步用 12 个 formal 回测确认 live/shadow 工程隔离。
- A22 从“需要 forward/shadow 边界验证”变为“边界验证已通过，但仍不得生产 promote”。
- A23 仍保留为 broad-blowoff 风险解释和备用挑战者，不新开专属换手约束 formal。

## 子代理依据来源

适配判断：`适合调用`

调用状态：`called_completed_with_one_errored`

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-20260607T154000Z-main-A22FS-ENTRY | Archimedes | SUBTASK-20260607T154000Z-main-A22FS_子查_A22_native_forward_shadow脚本边界 | gpt-5.3-codex-spark | 2026-06-07T15:40:00Z | 平台 forward/shadow/observe 脚本、A22/A22N 脚本和策略源码 | 无 | 只读检索 | context length exceeded，未形成可用交付物 | 无结论可采纳 | 主控关闭调用并改用更小任务重试 | 不影响决策，只作为失败调用记录 |
| SUB-20260607T154800Z-main-A22FS-MIN | Pascal | SUBTASK-20260607T154800Z-main-A22FS_子查_最小脚本清单 | gpt-5.3-codex-spark | 2026-06-07T15:48:00Z | `scripts/research` 中 A22/A22N 与 shadow/forward 相关脚本 | 无 | 只读检索 | 确认 A22N 链路可作为模板；旧 B5/THEME shadow 脚本不是 drop-in | 旧 shadow 脚本硬编码旧实验路径 | 主控采纳并新建 QTFV 专用脚本 | 支持用专用脚本跑 QTFV |
| SUB-20260607T183800Z-main-QTFV-VERIFY | Planck | SUBTASK-20260607T183800Z-QTFV-SUMMARY-CHECK | gpt-5.3-codex-spark | 2026-06-07T18:38:00Z | QTFV summary、live_vs_a22n、shadow_on_off_hash、guard_audit 和 QTFV 文档 | 无 | 只读复核 | 确认 10 个 gates 全 true、live 四段完全复现、shadow_on/off hash 全一致、guard 4/4 检出 | 未做最终研究决策和未来函数最终裁决 | 主控采纳为 formal 收口复核证据 | 支持 `observe`，不支持 `promote` |

台账行：已同步 `01_台账/子代理调用台账.csv`。

## 支持证据

- QTFV strict summary：12/12 formal 完成，`all_gates_pass=true`，10 个 gates 全 true。
- `native_a22_live` 四段与 A22N native 完全一致：final/MDD/trades/fee 差值均为 0，关键 hash 全一致。
- `a20_unbudgeted_shadow_on/off` 四段 orders/trades/equity/positions/subportfolio_equity 归一化 hash 全一致，`shadow_on_orders_changed=0`。
- 2024 零触发负控通过：`shadow_on_triggers=0`，shadow_on/off 交易产物一致。
- 四段 `double_on_guard` 都存在且检出 A13+A22 双开，不进入 formal 回测组。

证据路径：

```text
${QUANT_PLATFORM_ROOT}/results/v2/research/R010-A22/native_forward_shadow/EX-20260607T154134Z-main-QTFV/summary/formal/summary.json
${QUANT_PLATFORM_ROOT}/results/v2/research/R010-A22/native_forward_shadow/EX-20260607T154134Z-main-QTFV/summary/formal/live_vs_a22n.csv
${QUANT_PLATFORM_ROOT}/results/v2/research/R010-A22/native_forward_shadow/EX-20260607T154134Z-main-QTFV/summary/formal/shadow_on_off_hash.csv
${QUANT_PLATFORM_ROOT}/results/v2/research/R010-A22/native_forward_shadow/EX-20260607T154134Z-main-QTFV/summary/formal/guard_audit.csv
```

## 反对证据

- QTFV 不是收益优越性实验，不能证明 A22 已经比 hard5 更适合默认生产。
- QTFV 的 2025_20260519 只是近端 forward-like 边界，不是真实未来样本。
- QTFV 只检查可见日期和 shadow 隔离，不替代完整未来函数审计、实盘配置映射或成交模型审计。
- shadow_on/off 使用 A20 unbudgeted 路径观察 A22 预算建议，不等同于 hard5 生产路径。

## 边界

本决策不能说明 A22 可以实盘、可以 shadow 改单、可以替代 hard5、可以废除 score hard cap，也不能说明 A22 没有任何未来函数风险。

本决策只说明：在本次固定四段 formal 中，A22 native live/shadow 工程边界干净，允许默认关闭观察和继续做生产前门禁。

## 后续动作

1. 保持 A22 shadow 默认关闭，观察日志不得改变订单或目标权重。
2. 若要继续推进 A22，必须新开生产前 forward/未来函数门禁，覆盖默认 hard5 路径、实盘配置映射和完整成交边界。
3. 不新开 A23 专属换手约束 formal，不继续扩大 A23 阈值网格。
4. QTFV 结果可以作为后续 A22 生产前门禁的工程前置证据引用。

## 需要同步更新

- [x] 研究方向页
- [x] 研究驾驶舱
- [x] 实验台账
- [x] 决策台账
- [x] 子代理调用台账
- [x] 术语库无需新增术语
