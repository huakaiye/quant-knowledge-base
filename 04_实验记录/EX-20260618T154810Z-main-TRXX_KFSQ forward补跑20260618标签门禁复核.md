---
type: 实验记录
ex_id: EX-20260618T154810Z-main-TRXX
rd_id: RD-20260614T115209Z-main-MCYG
status: completed
stage: readonly_completed_insufficient_forward_h10_labels_no_action
owner: main
created_at: 2026-06-18T15:48:10Z
updated_at: 2026-06-18T15:56:00Z
strategy_id: 双池轮动
module_type: 外部验证数据门禁
decision_ids: []
lit_ids: []
idea_ids: []
platform_project: ${LEGACY_QUANT_PLATFORM_ROOT}
config_paths:
  - configs/research/RD-20260614T115209Z-main-MCYG/EX-20260618T154810Z-main-TRXX/trxx_continuous_forward_hard5_20260520_20260618.json
result_paths:
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T154810Z-main-TRXX/
summary_paths:
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T154810Z-main-TRXX/readiness_monitor/summary.json
quality_gate: h10_gate_failed_insufficient_labels
subagent_call_ids:
  - SUB-EXEMPT-20260618T154500Z-main-NXTV
subagent_exemption: 当前多代理工具要求用户显式授权子代理/委派/并行 agent；本轮用户未显式授权。
tags:
  - MCYG
  - KFSQ
  - forward
  - readonly
  - label_gate
---

# KFSQ forward补跑20260618标签门禁复核

## 关联链接

- 研究方向：[[02_研究方向/RD-20260614T115209Z-main-MCYG_双池轮动动量崩溃事前暴露管理|MCYG 双池轮动动量崩溃事前暴露管理]]
- 策略档案：
- 来源文献或灵感：
- 产生的决策：
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]
- 上游实验：[[04_实验记录/EX-20260618T145033Z-main-KFSQ_confirmed_state单组件episode随机负控只读复核|KFSQ confirmed_state 单组件复核]]；[[04_实验记录/EX-20260618T151314Z-main-KZF8_KFSQ confirmed_state forward外部验证数据门禁|KZF8 forward 外部验证数据门禁]]；[[04_实验记录/EX-20260618T153621Z-main-N3CD_KFSQ forward标签门禁监控器只读资产|N3CD forward 标签门禁监控器]]

## 1. 新手摘要

这次实验想知道：平台日线数据已经到 2026-06-18 后，把 KZF8 连续 forward hard5 从 2026-06-17 补跑到 2026-06-18，KFSQ 的 H10 外部验证标签是否已经够用。  
我们原本预计：只多 1 个交易日，最多让最早的未成熟 H10 标签少等 1 天，但不会达到 H10 `>=20` 行且 `>=5` episode 的外部验证门槛。  
实际看到：TRXX 成功补跑到 2026-06-18，连续 forward 行数从 `21` 增到 `22`，最终权益 `107639.51`，交易数 `35`。N3CD 监控器显示 H10 仍为 `0` 行、`0` episode，`h10_gate_pass=false`。  
这说明：新增 1 个交易日确实把最早候选的 H10 等待天数从 `2` 天缩到 `1` 天，但没有改变数据门禁结论。KFSQ 仍只是外部验证候选，不能升级。  
但还不能说明：KFSQ 有效、可交易、可 shadow、可 observe 或可替换 R 方/现有 hard5 策略。  
下一步要做：等待更长 forward、真实观察流或 dry-run 记录；只有 N3CD 显示 H10 `>=20` 行且 `>=5` episode 后，才重新运行 KFSQ 外部验证。

## 2. 研究背景

本实验属于 [[02_研究方向/RD-20260614T115209Z-main-MCYG_双池轮动动量崩溃事前暴露管理|MCYG]]。KFSQ 已在历史只读 OOS 上成为 `confirmed_state_run_len` 外部验证候选，但 [[04_实验记录/EX-20260618T151314Z-main-KZF8_KFSQ confirmed_state forward外部验证数据门禁|KZF8]] 显示截至 2026-06-17，H10 可标注 A1 行和 episode 都是 0。随后 [[04_实验记录/EX-20260618T153621Z-main-N3CD_KFSQ forward标签门禁监控器只读资产|N3CD]] 把门禁自动化，并指出最早一个候选还差 2 个交易日。

本轮先盘点平台数据和 forward 结果：ClickHouse 日线表已到 2026-06-18，现有 forward 结果最晚到 2026-06-17。因此可以做一次只读补跑，目的不是寻找更优收益，而是确认“新增 1 日数据后，标签门禁是否仍不足”。

## 3. 实验前假设

新增 2026-06-18 一天 forward 数据后，KFSQ H10 标签成熟度会小幅推进，但仍不足以启动正式外部验证。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：TRXX 连续 forward 行数应从 KZF8 的 `21` 增至约 `22`；H10 `h10_gate_pass=false`；H10 可标注行数和 episode 仍低于 `20/5`。
- 交易行为：只运行 hard5 基线，不新增信号、不写 shadow/observe/live 配置、不改变默认策略。
- 风险表现：不以收益好坏作决策；仅记录 final、交易数和 ACTION 分布作为一致性检查。
- 分段表现：2026-05-20 至 2026-06-18 单段；若最早候选仍未 H10 可标注，则下一次至少等到 2026-06-19 后再监控。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| KZF8 连续 forward hard5 | 对照 2026-06-17 截止时的 ACTION、A1 候选和 H10 不足结论 | `${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T151314Z-main-KZF8/` |
| N3CD 监控器 | 统一计算 H10 标签门禁，避免手工翻日志误判 | `${LEGACY_QUANT_PLATFORM_ROOT}/scripts/research/monitor_kfsq_forward_readiness.py` |
| 平台日线表 | 确认 2026-06-18 数据已存在 | ClickHouse `quant.jq_bar_daily` |

## 6. 竞争性解释

即使结果符合预期，也可能是：

- 新增 2026-06-18 只有 1 天，样本不足只是时间窗口太短，不代表 KFSQ 无效。
- forward 的 A1 触发稀疏，H10 门槛可能长期受限于事件数而非模型本身。
- 若某个标签突然成熟，也可能只是单个 episode，不应被当成稳定外部验证。

## 7. 证伪条件

出现以下情况，本假设不通过：

- 2026-06-18 补跑失败，或 ACTION 日志/权益曲线缺失，导致不能复算门禁。
- 监控器显示 H10 `>=20` 行且 `>=5` episode，则“仍不足”的预测被证伪，应立即转入正式外部验证分析。
- 补跑窗口或配置意外改变 hard5 基线逻辑、启用 shadow/observe/live 或引入新策略参数。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 通过 | 补跑使用 2026-05-20 至 2026-06-18 的历史日线/分钟数据；本轮只读查询表尾日期，没有更新外部数据 |
| 信号生成和成交价格不存在同 bar 泄漏 | 通过 | 复用 KZF8 hard5 基线策略和平台回测引擎；本实验不新增信号逻辑 |
| 股票池或 ETF 池不存在未来成分泄漏 | 通过 | 复用既有双池策略池配置；本实验不新增池成分逻辑 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 本实验不使用财务、宏观或估值字段 |
| Shadow 或观察信号未被当成默认交易信号 | 通过 | 配置中 `r010a22_hot_score_budget_shadow_enabled=false`，不写 shadow/observe/live |

负控或错位检查：

- 负控不在本实验展开；本实验只做数据门禁补跑。若 H10 样本足够，后续正式外部验证必须重新运行 KFSQ 的随机/shift 负控。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | 无参数搜索；仅把 KZF8 forward end 从 2026-06-17 延到 2026-06-18 |
| 样本内、验证集、样本外划分清楚 | 通过 | KFSQ 历史校准截至 2026-05-19；TRXX 是 2026-05-20 至 2026-06-18 forward 门禁 |
| 邻近参数敏感性合理 | 不适用 | 本实验不调参数 |
| 成本、滑点或换手扰动已检查 | 不适用 | 本实验不评价收益优劣 |
| 已做消融或负控 | 不适用 | 本实验只验证标签门禁；H10 样本不足时不应运行正式外部验证负控 |
| 未只报告最优结果 | 通过 | 单一预注册窗口，不筛选收益 |

证据等级：`L1` 数据门禁复核，不构成策略有效性证据。

## 10. 子代理调用记录

适配判断：适合调用，但当前工具环境受限。

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：当前多代理工具要求用户显式授权子代理/委派/并行 agent；本轮用户未显式授权；主控：main；时间：2026-06-18T15:45:00Z
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-EXEMPT-20260618T154500Z-main-NXTV | 无 | SUBTASK-NEXT-EVIDENCE-ROUTE-EXEMPT | 无 | 2026-06-18T15:45:00Z | KZF8/N3CD 记录；平台日线表；forward equity 目录；KZF8 配置 | 本实验记录；TRXX 平台配置；N3CD 监控器路径解析修复 | ClickHouse 只读盘点；TRXX 补跑；N3CD 监控器 | 只判断标签门禁，不判断 KFSQ 有效性 | 单日补跑仍没有成熟 H10 标签 | 主控已复核 summary、readiness CSV 和候选明细 | 维持等待；不升级 KFSQ，不判死 KFSQ |

台账行：

见 `01_台账/子代理调用台账.csv`。

## 11. 执行记录

### 平台配置

```text
${LEGACY_QUANT_PLATFORM_ROOT}/configs/research/RD-20260614T115209Z-main-MCYG/EX-20260618T154810Z-main-TRXX/trxx_continuous_forward_hard5_20260520_20260618.json
```

### 运行命令

```bash
cd ${QUANT_PLATFORM_ROOT}
PYTHONUNBUFFERED=1 PYTHONPATH=src python3 src/run_v2_backtest.py --config configs/research/RD-20260614T115209Z-main-MCYG/EX-20260618T154810Z-main-TRXX/trxx_continuous_forward_hard5_20260520_20260618.json 2>&1 | tee results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T154810Z-main-TRXX/run_continuous_forward_hard5.log
PYTHONUNBUFFERED=1 PYTHONPATH=src python3 scripts/research/monitor_kfsq_forward_readiness.py --run-parent results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T154810Z-main-TRXX/continuous_forward_hard5/forward_20260520_20260618 --output-dir results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T154810Z-main-TRXX/readiness_monitor 2>&1 | tee results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T154810Z-main-TRXX/run_readiness_monitor.log
```

### 可见进度与日志

- 是否过程可见：是，使用 `PYTHONUNBUFFERED=1` 和 `tee`。
- 日志路径：`${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T154810Z-main-TRXX/run_continuous_forward_hard5.log`；`${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T154810Z-main-TRXX/run_readiness_monitor.log`
- 查看进度命令：`Get-Content -Tail 80 "${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T154810Z-main-TRXX/run_continuous_forward_hard5.log"`
- 异常判断：回测非 0 退出、无 `logs.jsonl`、无 `equity_curve.csv`、监控器无法识别 ACTION、H10 门禁计算缺字段。
- 后台回测豁免：不适用；本实验前台可见运行。
- 运行异常：首次运行监控器时发现相对 `--run-parent` 会触发 `Path.relative_to` 失败；已把 `monitor_kfsq_forward_readiness.py` 的 `run_parent` 和 `output_dir` 解析改为 `.expanduser().resolve()`，`py_compile` 通过，并用同一相对命令重跑成功。

### 结果路径

```text
${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T154810Z-main-TRXX/
${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T154810Z-main-TRXX/readiness_monitor/summary.json
${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T154810Z-main-TRXX/readiness_monitor/readiness_by_run.csv
${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T154810Z-main-TRXX/readiness_monitor/a1_candidate_readiness.csv
```

## 12. 实际观察

| 指标 | 基准 | 本次 | 变化 | 解释 |
| --- | --- | --- | --- | --- |
| forward 截止日 | KZF8：2026-06-17 | TRXX：2026-06-18 | +1 个交易日 | 平台日线表已到 2026-06-18，补跑成功 |
| forward 行数 | `21` | `22` | +1 | 新增 2026-06-18 一行 |
| 最终权益 | `104976.11` | `107639.51` | +`2663.40` | 仅作路径一致性记录，不作为策略优劣结论 |
| 交易数 | `35` | `35` | 0 | 新增日无新增成交 |
| ACTION 分布 | A0/A1/A2=`6/7/8` | A0/A1/A2=`6/7/9` | A2 +1 | 新增日为 A2 |
| KFSQ A1 候选行 | `3` | `3` | 0 | 剔除已回撤 5% 后，候选仍只有 3 行 |
| KFSQ A1 episode | `1` | `1` | 0 | 候选仍集中在同一 episode |
| H10 可标注行/episode | `0/0` | `0/0` | 0 | 外部验证门槛仍不满足 |
| 最早 H10 候选还需交易日 | `2` | `1` | -1 | 2026-06-05 候选还差 1 个交易日 |
| 当前候选全部标注后的 projected H10 | `3/1` | `3/1` | 0 | 即使等到现有候选成熟，也仍差 `17` 行和 `4` 个 episode |

## 13. 支持证据

- 回测报告目录：`${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T154810Z-main-TRXX/continuous_forward_hard5/forward_20260520_20260618/d2ac12ae618c4380b0b96f3ab0a444ec/`。
- `readiness_by_run.csv` 显示：`rows=22`，`a1_candidate_rows_not_already_dd5=3`，`a1_episode_count=1`，`h10_labelable_rows=0`，`h10_labelable_episode_count=0`，`h10_gate_pass=False`。
- `a1_candidate_readiness.csv` 显示三个候选日期仍分别需要 H10 额外交易日：2026-06-05 需 `1` 天，2026-06-09 需 `3` 天，2026-06-15 需 `7` 天。
- 监控器修复后 `python3 -m py_compile scripts/research/monitor_kfsq_forward_readiness.py` 通过。

## 14. 反对证据

- 没有反对“数据仍不足”的证据。
- 本实验也没有支持“KFSQ 有效或无效”的证据；H10 仍为空，不能做指标胜负判断。
- 即使现有 3 个候选未来全部成熟，也只有 `3` 行、`1` episode，仍远低于 `20/5`。

## 15. 偏差诊断

实验前预测与实际结果一致：多 1 个交易日只能缩短等待天数，不能让 H10 门槛通过。额外发现是 N3CD 监控器的相对路径兼容性不足，已修复；这属于工具可用性问题，不影响 KFSQ 数据门禁结论。

## 16. 研究判断

建议状态：TRXX 自身为 `readonly_completed_insufficient_forward_h10_labels_no_action`；不新建决策卡，沿用 [[05_研究决策/DEC-20260618T152400Z-main-6JF6_KFSQ forward外部验证数据不足后继续等待新样本|6JF6]] 的路线判断。

理由：H10 可标注行和 episode 仍为 `0/0`，没有资格判断 KFSQ 通过或失败。KFSQ 保留外部验证候选，但不得动作化、shadow、observe 或改默认逻辑。

## 17. 下一步

下一轮先不再滚动无标签短窗。等至少 2026-06-19 后可用 N3CD 复查最早候选是否成熟；但正式外部验证必须等 H10 可标注行 `>=20` 且 episode `>=5`。如果要更快推进，应优先接入真实观察流、dry-run 或更长 forward 记录，而不是继续在 `confirmed_state_run_len` 上调阈值、窗口或 top 比例。
