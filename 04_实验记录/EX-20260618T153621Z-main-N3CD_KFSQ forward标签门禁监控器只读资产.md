---
type: 实验记录
ex_id: EX-20260618T153621Z-main-N3CD
rd_id: RD-20260614T115209Z-main-MCYG
status: completed
stage: readonly_tool_completed_forward_gate_monitor
owner: main
created_at: 2026-06-18T15:36:21Z
updated_at: 2026-06-18T15:39:00Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 防御模块事前暴露管理层
decision_ids: []
lit_ids: []
idea_ids: []
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths:
  - scripts/research/monitor_kfsq_forward_readiness.py
result_paths:
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T153621Z-main-N3CD/
summary_paths:
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T153621Z-main-N3CD/summary.json
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T153621Z-main-N3CD/readiness_by_run.csv
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T153621Z-main-N3CD/a1_candidate_readiness.csv
quality_gate: monitor_built_current_gate_not_ready
subagent_call_ids:
  - SUB-EXEMPT-20260618T153000Z-main-KFSQMON
subagent_exemption: 当前多代理工具要求用户显式授权子代理/委派/并行 agent；本轮用户未显式授权。
tags:
  - 非R方
  - 低滞后
  - forward
  - 数据门禁
  - 监控器
  - 只读
---

# KFSQ forward标签门禁监控器只读资产

## 关联链接

- 研究方向：[[02_研究方向/RD-20260614T115209Z-main-MCYG_双池轮动动量崩溃事前暴露管理|RD-20260614T115209Z-main-MCYG 动量崩溃事前暴露管理]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 来源实验：[[04_实验记录/EX-20260618T151314Z-main-KZF8_KFSQ confirmed_state forward外部验证数据门禁|EX-20260618T151314Z-main-KZF8 KFSQ forward 外部验证数据门禁]]
- 产生的决策：
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：KZF8 已经证明当前 forward H10 标签不足；我们是否能把“样本是否够”的判断做成稳定监控器，避免下一轮手工翻日志。  
我们原本预计：监控器应能读取任意 forward run 的 ACTION 日志和权益曲线，输出 H10 可标注 A1 行数、episode 数、还差多少行和 episode，以及当前 A1 行还需要多少未来交易日才能完整标注。  
实际看到：监控器成功扫描 KZF8 连续 forward run。当前 A1 总行 `7`，但剔除已回撤 5% 后的 KFSQ 候选只有 `3` 行、`1` 个 episode；H10 当前可标注 `0` 行、`0` 个 episode。  
这说明：即使等当前 3 条候选全部获得 H10 标签，也只有 `3` 行、`1` 个 episode，仍低于 `20/5` 门槛，还需要至少 `17` 条新的可标注候选行和 `4` 个新 episode。  
但还不能说明：监控器只判断数据门禁，不判断 KFSQ 是否有效，也不生成交易信号。  
下一步要做：以后每次有新的 forward/dry-run run 时先跑本监控器；只有 H10 行数和 episode 数都过门槛，才运行 KFSQ 外部验证。

## 2. 研究背景

本实验属于 [[02_研究方向/RD-20260614T115209Z-main-MCYG_双池轮动动量崩溃事前暴露管理|MCYG 动量崩溃事前暴露管理]]。KZF8 证明 KFSQ 外部验证需要等新样本，但如果每次都手工判断 A1/H10 标签是否够，容易误读空样本或重复跑无标签短窗。因此先做只读监控资产。

## 3. 实验前假设

固定 KFSQ 的 H10 数据门槛：A1 可标注行 `>=20` 且 A1 episode `>=5`；本实验只验证监控器能否稳定报告当前距离门槛还差多少。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：输出 `h10_labelable_rows`、`h10_labelable_episode_count`、`h10_rows_remaining_to_gate`、`h10_episodes_remaining_to_gate`、`h10_extra_trading_days_for_all_current_candidates`。
- 交易行为：无交易行为；不启动回测、不更新数据、不改策略、不生成信号。
- 风险表现：不评价风险表现，只评价标签可用性。
- 分段表现：当前只扫描 KZF8 连续 forward run；脚本应支持未来传入其他 run parent。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| KZF8 连续 forward run | 验证监控器能复现已知数据不足事实 | `${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T151314Z-main-KZF8/continuous_forward_hard5/forward_20260520_20260617/` |
| KZF8 summary | 对照 H10 行数/episode 为 0 的结论 | `${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T151314Z-main-KZF8/summary.json` |

## 6. 竞争性解释

即使结果符合预期，也可能是：

- 监控器通过只能说明工具可用，不能说明 KFSQ 有效。
- 如果未来 run 的 ACTION 日志字段变化，监控器可能需要更新解析字段。

## 7. 证伪条件

出现以下情况，本假设不通过：

- 无法解析 ACTION 日志或权益曲线。
- 无法输出 H10 labelable 行数和 episode 数。
- 对 KZF8 的 H10 数据不足事实复现错误。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 通过 | 只读读取 ACTION 与权益曲线，不生成新信号 |
| 信号生成和成交价格不存在同 bar 泄漏 | 不适用 | 不生成交易信号或成交 |
| 股票池或 ETF 池不存在未来成分泄漏 | 不适用 | 不重新选择股票池或 ETF 池 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 不使用财务、宏观或估值数据 |
| Shadow 或观察信号未被当成默认交易信号 | 通过 | 只读监控器，不写 shadow/observe/live 配置 |

负控或错位检查：

- 不评价信号，只做标签可用性检查。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | H10 行数门槛 `20`、episode 门槛 `5` 固定 |
| 样本内、验证集、样本外划分清楚 | 不适用 | 不训练、不验证模型，只判断 forward 标签就绪度 |
| 邻近参数敏感性合理 | 不适用 | 不扫参数 |
| 成本、滑点或换手扰动已检查 | 不适用 | 不评价收益 |
| 已做消融或负控 | 不适用 | 工具资产建设 |
| 未只报告最优结果 | 通过 | 输出所有扫描到的 run；当前 run_count=`1` |

证据等级：`L0-工具资产`。

## 10. 子代理调用记录

适配判断：`适合调用`

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：当前多代理工具要求用户显式授权子代理/委派/并行 agent；本轮用户未显式授权；主控：main；时间：2026-06-18T15:30:00Z
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-EXEMPT-20260618T153000Z-main-KFSQMON | 无 | SUBTASK-KFSQ-FORWARD-MONITOR-EXEMPT | 无 | 2026-06-18T15:30:00Z | KZF8 run；KZF8 summary；MCYG方向文档；N3CD summary/CSV | 本实验记录；平台监控脚本；台账已同步 | `PYTHONUNBUFFERED=1 PYTHONPATH=src python3 scripts/research/monitor_kfsq_forward_readiness.py` | 只建设数据门禁监控器，不判断信号有效性 | 日志字段变化、路径扫描错误 | 主控已复核 summary 和 CSV | 降低后续误判空样本风险 |

台账行：已同步至 `01_台账/子代理调用台账.csv`。

## 11. 执行记录

### 平台配置

```text
${QUANT_PLATFORM_ROOT}/scripts/research/monitor_kfsq_forward_readiness.py
```

### 运行命令

```bash
cd ${QUANT_PLATFORM_ROOT}
PYTHONUNBUFFERED=1 PYTHONPATH=src python3 scripts/research/monitor_kfsq_forward_readiness.py 2>&1 | tee results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T153621Z-main-N3CD/run_monitor.log
```

### 可见进度与日志

- 是否过程可见：`是`
- 日志路径：`${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T153621Z-main-N3CD/run_monitor.log`
- 查看进度命令：`Get-Content -Tail 80 "${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T153621Z-main-N3CD/run_monitor.log"`
- 异常判断：无异常退出；输出 `any_h10_gate_pass=false`
- 后台回测豁免：不适用，前台可见运行

### 结果路径

```text
${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T153621Z-main-N3CD/
```

## 12. 实际观察

| 指标 | 基准 | 本次 | 变化 | 解释 |
| --- | --- | --- | --- | --- |
| 扫描 run 数 | 至少 1 | `1` | 通过 | 成功识别 KZF8 运行目录 |
| ACTION 总行数 | KZF8 对照 | `21` | 复现 | 与 KZF8 连续 forward 一致 |
| A1 总行数 | KZF8 对照 | `7` | 复现 | ACTION 层 A1 样本存在 |
| KFSQ 候选 A1 行 | 未已回撤 5% | `3` | 关键新增拆解 | KFSQ 主宇宙比 A1 总行更窄 |
| 当前 H10 可标注行 | 门槛 `>=20` | `0` | 未过 | 和 KZF8 数据不足一致 |
| 当前 H10 可标注 episode | 门槛 `>=5` | `0` | 未过 | 无法外部验证 |
| 当前候选全部完成 H10 后 | 门槛 `20/5` | `3` 行、`1` episode | 仍不足 | 还需要 `17` 行和 `4` episode |
| 当前候选最早 H10 标签还需 | 无 | `2` 个未来交易日 | 诊断 | 2026-06-05 候选最早还差 2 个交易日 |
| 当前候选全部 H10 标签还需 | 无 | `8` 个未来交易日 | 诊断 | 2026-06-15 候选最晚还差 8 个交易日 |

## 13. 支持证据

- `summary.json` 为标准 JSON，并输出 `any_h10_gate_pass=false`。
- `readiness_by_run.csv` 显示 H10 labelable rows/episodes 为 `0/0`，当前候选全部标注后也只有 `3/1`。
- `a1_candidate_readiness.csv` 列出 3 条未已回撤 5% 的 A1 候选：2026-06-05、2026-06-09、2026-06-15。

## 14. 反对证据

- 监控器不是外部验证本身，不能证明 KFSQ 有效。
- 监控器依赖 ACTION 日志格式；若未来策略日志字段变化，需要同步调整。

## 15. 偏差诊断

结果符合预期。额外发现是：KFSQ 主宇宙不是所有 A1，而是 A1 且未已回撤 5%，所以当前可等待标注的候选只有 3 行。这解释了为什么 KZF8 的 A1 总行看似有 7 行，但真实外部验证样本更少。

## 16. 研究判断

建议状态：`tool_completed`

理由：N3CD 完成了 forward 标签门禁监控资产，可复用到后续 forward/dry-run。它不改变 KFSQ 候选状态，也不支持交易化。

## 17. 下一步

下一轮不是继续无标签短窗，而是在新的 forward/dry-run 结果出现后先跑本监控器。只有 `h10_labelable_rows>=20` 且 `h10_labelable_episode_count>=5` 时，才重新运行 KFSQ 外部验证脚本。
