---
type: 研究决策
dec_id: DEC-20260613T122346Z-main-X7PJ
rd_ids: [RD-20260613T110126Z-main-FWZE]
ex_ids: [EX-20260613T110139Z-main-7HKT, EX-20260614T040739Z-main-HMZ3, EX-20260614T042453Z-main-LKLT, EX-20260614T070420Z-main-MJU9, EX-20260614T083146Z-main-R7N7, EX-20260617T152809Z-main-JVTQ]
decision: revise
owner: main
created_at: 2026-06-13T12:23:46Z
updated_at: 2026-06-17T15:36:00Z
impact: direction
subagent_call_ids: [SUB-20260613T113000Z-main-7HKTQA, SUB-20260614T040600Z-main-HMZ3RO, SUB-20260614T042100Z-main-LKLTRO]
subagent_exemption:
tags: [ETF, 动态池, 资金热度, 复权门禁, data-gate, revise]
---

# 动态资金热度全量复权门禁失败后暂停formal

## 关联链接

- 受影响方向：[[02_研究方向/RD-20260613T110126Z-main-FWZE_双池轮动动态资金热度单模块消融|动态资金热度单模块消融]]
- 关键实验：[[04_实验记录/EX-20260613T110139Z-main-7HKT_动态资金热度复权门禁与单模块消融预注册|7HKT 动态资金热度复权门禁与单模块消融]]
- 上一张决策：[[05_研究决策/DEC-20260613T064749Z-main-LYS9_动态池资金热度因子复现后路线判断|LYS9 动态池资金热度复现后路线判断]]
- 后续实验：[[04_实验记录/EX-20260614T040739Z-main-HMZ3_ETF复权断点分类与可见日黑名单预注册|HMZ3 ETF 复权断点分类与可见日黑名单]]
- 后续实验：[[04_实验记录/EX-20260614T042453Z-main-LKLT_ETF断点可见性证明与门禁V2预注册|LKLT ETF 断点可见性证明与门禁 V2]]
- 后续实验：[[04_实验记录/EX-20260617T152809Z-main-JVTQ_R7N7同口径隔离后复权门禁重跑|JVTQ R7N7 同口径隔离后复权门禁重跑]]
- 研究驾驶舱：[[00_入口/研究驾驶舱|研究驾驶舱]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 决策结论

`revise`

7HKT 全 ETF、全区间复权/份额断点门禁失败后，动态池/资金热度单模块消融曾暂不进入收益 formal。HMZ3、LKLT、MJU9 和 R7N7 的后续诊断缩小了问题范围；JVTQ 已确认 `R7N7-v1` 在历史同口径层面覆盖 MJU9/HMZ3 高风险阻断项。

这不是否决动态池或资金热度因子，也不是放开 live/实盘边界。当前决策修订为：允许另开 baseline/B0/G0/A1/A2/A3/A4 同口径历史收益消融预注册；所有变体必须应用同一套 `R7N7-v1` 历史局部剔除窗口。`source_repair_required_rows=37`、`live_repair_gate_pass=false`，所以仍不允许 shadow、实盘、live 自动过滤或源数据已修复表述。

## 这个节点是什么

这个节点处理的是 H35F 复现失败后的下一步：我们没有继续照搬公开聚宽完整策略，而是打算只测试“动态候选池”和“资金热度因子”两个模块。正式比较收益之前，先检查 ETF 日线数据有没有复权或份额折算断点。

检查结果显示，问题不是单一 `515050.XSHG` 的孤例，而是全 ETF 样本里有多处异常。因此现在最重要的不是马上跑收益，而是先把数据门禁修好。

## 相比上一个节点改变了什么

- LYS9 只判断“公开完整策略整包不接入”，仍允许继续研究资金热度单模块。
- X7PJ 将 7HKT 从“已预注册、可进入门禁”推进到“门禁失败、formal 暂停”。
- 下一步从“生成动态池/资金热度 formal 配置”改为“先分类、修复或过滤 ETF 复权/份额断点”。

## 子代理依据来源

适配判断：`适合调用`

调用状态：`called`

子代理豁免：

```text
无。已调用 Locke 只读复核门禁输出。
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-20260613T113000Z-main-7HKTQA | Locke | SUBTASK-7HKT-GATE-AUDIT | 继承主线程 | 2026-06-13T11:30:00Z | 7HKT `overview.json`、`etf_adjustment_breaks.csv` | 无 | 只读核对 | 只核对门禁输出，不判断资金热度有效性 | 未运行回测，不能给收益结论 | 主控复核其统计并采纳“119 条断点、109 只 ETF、`gate_pass=false`” | 直接支持本决策暂停 formal |
| SUB-20260614T040600Z-main-HMZ3RO | Arendt | SUBTASK-20260614-7HKT-BREAK-CLASSIFY-RO | 继承主线程 | 2026-06-14T04:06:00Z | 7HKT/HMZ3/X7PJ 相关文档和平台结果 | 无 | 只读核对 | 只复核断点分类维度，不判断收益 | 原始 only-factor 不能全部误判为高风险 | 主控采纳 `116/119` 乘积连续、`3` 条 factor-only 均为 `515050.XSHG` | 支持缩小数据问题范围，但不恢复 formal |
| SUB-20260614T042100Z-main-LKLTRO | Carver | SUBTASK-20260614-GATEV2-VISIBILITY-RO | 继承主线程 | 2026-06-14T04:21:00Z | 7HKT/HMZ3 实验记录、X7PJ 决策、平台脚本和结果 CSV/JSON | 无 | 只读核对 | 只复核 V2 可见性边界，不判断资金热度有效性 | 未来闭合窗口不能直接转实盘过滤 | 主控采纳事件日不可同日过滤、状态窗口不可 live 原样使用的边界 | 支持继续暂停 formal，下一步源头修复或保守隔离 |

台账行：已同步 `01_台账/子代理调用台账.csv`。

## 支持证据

- 7HKT 全量门禁扫描 `1665` 只 ETF，发现 `119` 条异常断点，覆盖 `109` 只 ETF，`gate_pass=false`。
- `reason_counts` 为：`factor_jump=119`、`real_close_jump=111`、`pre_close_gap=111`。
- 用户截图相关的 `515050.XSHG` 不是唯一问题：它自身出现 4 条断点，日期为 2024-02-01、2025-01-02、2026-05-06、2026-05-13。
- `515050.XSHG` 在 2026-05-13 同时触发 `factor_jump;real_close_jump;pre_close_gap`，真实收盘从 `3.33` 到 `1.156`，`preclose_gap=-0.6667`。
- 更严重断点还包括 `510150.XSHG` 2021-05-31 `factor_ratio=12.0672`、`159943.XSHE` 2021-10-22 `factor_ratio=11.8198`、`511030.XSHG` 2025-03-19 `factor_ratio=0.1000`。
- 7HKT 预注册证伪条件明确写了：若复权/份额断点门禁失败且无法用信号日前可得信息修复或过滤，就停止 formal，不写收益结论。
- HMZ3 后续分类显示：`119` 条 finding 中 `116` 条 factor 与真实价乘积连续，`3` 条 factor-only 高风险异常全部来自 `515050.XSHG`。
- LKLT 后续可见性 V2 显示：3 条 factor-only 只能事件日收盘后识别，最早下一交易日 live block；`same_day_live_usable_rows=0`，`visibility_design_pass=true`，但 `formal_resume_gate_pass=false`。

## 反对证据

- 当前门禁阈值是诊断阈值，不等于最终数据修复方案；部分异常可能来自真实 ETF 份额折算，需要分类而不是简单删除。
- A1 动态池 only、A2 资金热度 only、A3 动态池 + 热度、A4 负控尚未运行，所以不能说动态池或资金热度没有价值。
- 现在只完成数据质量层面的阻断，还没有完成收益、回撤、换手、负控和成本扰动验证。

## 边界

这个决策不能说明资金热度因子无效，也不能说明动态候选池无效。它只说明：在当前 ETF 数据口径下，收益 formal 不能作为可信证据。

2026-06-14 补充 1：HMZ3 已把 `119` 条断点分成 `116` 条乘积连续和 `3` 条 factor-only 高风险异常；该结果帮助缩小数据问题，但仍未证明黑名单或清洗规则在信号日前可见，因此本决策的“暂停 formal”边界继续有效。

2026-06-14 补充 2：LKLT 已证明三条 `515050.XSHG` factor-only 不能过滤事件日当天交易，只能从事件日收盘后的下一交易日形成 live block 候选；两段状态窗口的闭合依赖未来事件，只能做历史污染定位，不能原样实盘过滤。因此本决策仍维持 `revise`，收益 formal 不恢复。

2026-06-17 补充 3：JVTQ 已把 `R7N7-v1` 接入 MJU9/7HKT/HMZ3/LKLT 同口径复核，MJU9 高风险残留 `0`、HMZ3 阻断类残留 `0`、变体覆盖失败 `0`、`same_day_live_usable_rows=0`，`historical_isolation_gate_pass=true`、`formal_resume_gate_pass=true`；但 `source_repair_required_rows=37`、`live_repair_gate_pass=false`。因此本决策的“暂停收益 formal”边界修订为：允许另开同口径历史收益消融预注册，不允许实盘/shadow/live 自动修复。

仍然不确定的内容包括：

- 哪些断点是真实份额折算，哪些是平台复权口径错误。
- 能否完成源头修复，解除 `37` 条高风险事件的 live/source repair 阻断。
- 在同口径历史隔离后，A1/A2/A3/A4 是否有任何分段能稳定优于当前双池基线。

## 后续动作

- 新开同口径历史收益消融预注册，baseline/B0/G0/A1/A2/A3/A4 必须全部应用 `R7N7-v1` 历史局部剔除窗口。
- 收益解释必须区分“剔除异常数据带来的改善”和“动态池/资金热度信号带来的改善”。
- 继续保留源头修复任务，优先处理 factor-only、factor_jump_missing_real 和 price_jump_without_factor 的平台数据口径。
- 不改实盘默认、不写 shadow、不把 `R7N7-v1` 写入 live 自动过滤或交易逻辑。

## 需要同步更新

- [x] 研究方向页
- [x] 研究驾驶舱
- [x] 实验台账
- [x] 决策台账
- [x] 子代理调用台账
- [x] 术语库无新增术语

