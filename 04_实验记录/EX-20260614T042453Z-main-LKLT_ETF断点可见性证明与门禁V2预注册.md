---
type: 实验记录
ex_id: EX-20260614T042453Z-main-LKLT
rd_id: RD-20260613T110126Z-main-FWZE
status: completed
stage: visibility_gate_v2_completed_formal_still_blocked
owner: main
created_at: 2026-06-14T04:24:53Z
updated_at: 2026-06-14T04:45:00Z
strategy_id:
module_type: 数据门禁与复权断点可见性治理
decision_ids:
  - DEC-20260613T122346Z-main-X7PJ
lit_ids: []
idea_ids: []
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths:
  - scripts/research/audit_lklt_etf_adjustment_visibility_v2.py
result_paths:
  - results/v2/research/RD-20260613T110126Z-main-FWZE/EX-20260614T042453Z-main-LKLT/diagnostic/visibility_gate_v2/
summary_paths:
  - results/v2/research/RD-20260613T110126Z-main-FWZE/EX-20260614T042453Z-main-LKLT/summary/
quality_gate: visibility_design_pass_but_formal_still_blocked
subagent_call_ids: [SUB-20260614T042100Z-main-LKLTRO]
subagent_exemption:
tags: [ETF, 复权断点, 可见性, 数据门禁, 未来函数, diagnostic]
---

# ETF断点可见性证明与门禁V2预注册

## 关联链接

- 研究方向：[[02_研究方向/RD-20260613T110126Z-main-FWZE_双池轮动动态资金热度单模块消融|动态资金热度单模块消融]]
- 前序实验：[[04_实验记录/EX-20260613T110139Z-main-7HKT_动态资金热度复权门禁与单模块消融预注册|7HKT 动态资金热度复权门禁]]
- 前序实验：[[04_实验记录/EX-20260614T040739Z-main-HMZ3_ETF复权断点分类与可见日黑名单预注册|HMZ3 ETF 复权断点分类]]
- 前序决策：[[05_研究决策/DEC-20260613T122346Z-main-X7PJ_动态资金热度全量复权门禁失败后暂停formal|X7PJ 暂停 formal 决策]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 来源文献或灵感：HMZ3 的 `bad_symbol_windows.csv` 和 `cleaning_policy.json`。
- 产生的决策：沿用 X7PJ，暂无新决策。
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：HMZ3 找到的 `515050.XSHG` factor-only 异常，哪些只能用于历史污染定位，哪些能在真实交易中“发现以后从下一交易日开始”过滤。

我们原本预计：事件日当天的 factor、close、pre_close 至少要收盘后才完整，所以不能用它们过滤事件日当天交易；最多只能从下一交易日开始形成 live block 候选。

实际看到：脚本读取 HMZ3 的 `119` 行分类和 `5` 条坏窗口，得到 `3` 条 factor-only live block 候选；`same_day_live_usable_rows=0`，三条候选的最早可用日期分别是 `2024-02-02`、`2025-01-03`、`2026-05-07`。

这说明：V2 的可见性设计通过，因为它没有把事件日当天或未来闭合窗口当成可交易过滤。但 `formal_resume_gate_pass=false`，因为 factor-only 仍需源头修复或保守隔离，`116` 条乘积连续断点也还没有公告或源数据可见性证明。

但还不能说明：这不证明资金热度因子有效，也不允许恢复 B0/A1/A2/A3/A4 收益 formal，更不能改实盘。

下一步要做：先处理 `515050.XSHG` 源头修复或保守隔离规则，再用同一口径重跑 B0/G0 数据门禁；只有门禁通过，才进入动态池/资金热度单模块收益消融。

## 2. 研究背景

7HKT 全量 ETF 复权断点门禁失败，HMZ3 进一步把 `119` 条断点分成 `116` 条乘积连续和 `3` 条 `515050.XSHG` factor-only 高风险异常。X7PJ 决定暂停收益 formal。

本实验承接 HMZ3 的下一步，但只做可见性证明，不跑 B0/A1/A2/A3/A4 收益。核心是避免一个常见错误：看完整段历史后发现某个窗口有问题，就把这个窗口原样当成实盘过滤规则。实盘只能在信息出现以后行动，不能回到事件日前。

## 3. 实验前假设

HMZ3 的历史坏窗口可以被拆成两类：一类是只能用于历史评估剔除或人工修复的事后窗口；另一类是 factor-only 事件收盘后才可见、最早从下一交易日开始生效的 live block 候选。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：`same_day_live_usable_rows=0`；`factor_only_rows=3`；每条 factor-only 都有 `earliest_live_effective_date`。
- 交易行为：不产生交易，不生成收益 formal，不改变实盘或 shadow。
- 风险表现：`historical_exclusion_windows_v2.csv` 明确标注历史窗口不能原样用于 live；`live_block_candidates_v2.csv` 明确从事件日后的下一交易日开始。
- 分段表现：2024、2025、2026 三个 factor-only 事件均应被标记为需要源数据修复或保守隔离。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| `HMZ3_classified` | 断点分类输入 | `results/v2/research/RD-20260613T110126Z-main-FWZE/EX-20260614T040739Z-main-HMZ3/diagnostic/break_classification/classified_breaks.csv` |
| `HMZ3_bad_windows` | 坏窗口输入 | `results/v2/research/RD-20260613T110126Z-main-FWZE/EX-20260614T040739Z-main-HMZ3/diagnostic/break_classification/bad_symbol_windows.csv` |
| `LKLT_visibility_v2` | 本轮输出，不含收益结论 | `results/v2/research/RD-20260613T110126Z-main-FWZE/EX-20260614T042453Z-main-LKLT/diagnostic/visibility_gate_v2/` |

## 6. 竞争性解释

即使结果符合预期，也可能是：

- 平台当前静态数据库已经被事后修订，不能证明历史实盘当天已经能看到同样 factor。
- ETF 份额折算公告可能在事件日前可得，但本轮没有抓取公告源，不能把 `inverse_consistent` 自动升级为 live 过滤。
- factor-only 事件可能是数据源补丁或平台复权实现问题，应优先修复数据，而不是永久黑名单。
- 历史剔除窗口能改善回测曲线，但如果使用未来结束日，会构成未来函数。

## 7. 证伪条件

出现以下情况，本假设不通过：

- V2 输出把事件日当天标成可交易过滤可用。
- V2 对状态窗口使用未来结束日生成 live block 或 live unblock。
- 任一 factor-only 事件缺少下一交易日 live 生效日。
- 脚本不能复现 HMZ3 的 `3` 条 factor-only 和 `5` 条坏窗口候选。
- 诊断结果被用来恢复收益 formal 或修改实盘默认逻辑。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 部分通过 | `live_block_candidates_v2.csv` 仅允许事件日收盘后识别，下一交易日生效；同日过滤为 `false`。 |
| 信号生成和成交价格不存在同 bar 泄漏 | 不适用 | 本轮不生成交易信号。 |
| 股票池或 ETF 池不存在未来成分泄漏 | 通过 | 只读 HMZ3 已生成分类，不重构候选池。 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 只使用 ETF 行情、factor 和交易日历。 |
| Shadow 或观察信号未被当成默认交易信号 | 通过 | 本轮不写 shadow，不改实盘。 |

负控或错位检查：

- 本轮不做收益负控；若后续把 live block 候选接入回测，必须另开实验并做错位/滞后检查。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | 不扫参数，只按 HMZ3 分类和交易日历转换。 |
| 样本内、验证集、样本外划分清楚 | 不适用 | 本轮是数据可见性诊断，不评价收益。 |
| 邻近参数敏感性合理 | 不适用 | 无参数搜索。 |
| 成本、滑点或换手扰动已检查 | 不适用 | 不交易。 |
| 已做消融或负控 | 不适用 | 本轮为门禁前置诊断。 |
| 未只报告最优结果 | 通过 | 输出全量 `119` 行可见性审计、`5` 条历史窗口和 `3` 条 live 候选。 |

证据等级：`L1_data_visibility_diagnostic_preregistered`

## 10. 子代理调用记录

适配判断：`适合调用`

调用状态：`called`

子代理豁免：

```text
无。已调用 Carver 只读复核门禁 V2 可见性边界。
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-20260614T042100Z-main-LKLTRO | Carver | SUBTASK-20260614-GATEV2-VISIBILITY-RO | 继承主线程 | 2026-06-14T04:21:00Z | 7HKT/HMZ3 实验记录、X7PJ 决策、7HKT/HMZ3 平台脚本与 CSV/JSON 结果 | 无 | 只读核对，未运行回测 | 只提供可见性边界建议，不做路线生杀 | 未来数据窗口不能直接转成实盘过滤；`515050` factor-only 必须先证明可见性或做源头修复 | 主控采纳“事件日不可同日过滤、状态窗口不可 live 原样使用、factor-only 需源头修复”的边界，并在脚本输出中补齐 `known_at`、`first_live_usable_date`、`future_data_used` 字段 | 支持 LKLT 完成可见性设计，但 formal 仍暂停 |

台账行：已同步 `01_台账/子代理调用台账.csv`。

## 11. 执行记录

### 平台配置

```text
scripts/research/audit_lklt_etf_adjustment_visibility_v2.py
```

### 运行命令

```bash
wsl -- bash -lc "cd '/mnt/e/量化平台_V1.4.0' && PYTHONPATH=src python3 -m py_compile scripts/research/audit_lklt_etf_adjustment_visibility_v2.py"

wsl -- bash -lc "cd '/mnt/e/量化平台_V1.4.0' && mkdir -p results/v2/research/RD-20260613T110126Z-main-FWZE/EX-20260614T042453Z-main-LKLT/logs && set -o pipefail && PYTHONUNBUFFERED=1 PYTHONPATH=src python3 scripts/research/audit_lklt_etf_adjustment_visibility_v2.py 2>&1 | tee results/v2/research/RD-20260613T110126Z-main-FWZE/EX-20260614T042453Z-main-LKLT/logs/lklt_visibility_gate_v2.run.log"
```

### 可见进度与日志

- 是否过程可见：是，使用 `PYTHONUNBUFFERED=1` 与 `tee`。
- 日志路径：`results/v2/research/RD-20260613T110126Z-main-FWZE/EX-20260614T042453Z-main-LKLT/logs/lklt_visibility_gate_v2.run.log`
- 查看进度命令：前台看终端输出，或读取上述日志。
- 异常判断：输入 CSV 不存在、factor-only 数不是 `3`、坏窗口不是 `5`、脚本退出非 0，均视为失败。
- 后台回测豁免：无；本轮不后台运行。

WSL 输出仍有本机 localhost/NAT 乱码提示，但命令退出码为 `0`；不影响本脚本结果。

### 结果路径

```text
results/v2/research/RD-20260613T110126Z-main-FWZE/EX-20260614T042453Z-main-LKLT/diagnostic/visibility_gate_v2/
```

## 12. 实际观察

| 指标 | 基准 | 本次 | 变化 | 解释 |
| --- | --- | --- | --- | --- |
| 分类输入行数 | HMZ3 `119` | `119` | 一致 | V2 没有漏读分类输入 |
| 坏窗口输入 | HMZ3 `5` | `5` | 一致 | 3 条单日 factor-only + 2 段状态窗口 |
| factor-only 行数 | HMZ3 `3` | `3` | 一致 | 全部为 `515050.XSHG` |
| live block 候选 | 预期 `3` | `3` | 符合 | 三条 factor-only 事件均可在事件日收盘后形成下一交易日候选 |
| 同日可交易过滤 | 预期 `0` | `0` | 符合 | 没有把事件日当天过滤当成可交易规则 |
| 最早 live 生效日 | 需为事件日后一交易日 | `2024-02-02`、`2025-01-03`、`2026-05-07` | 符合 | 事件日当天不可回避，只能事后阻断 |
| 可见性设计 | 预期通过 | `visibility_design_pass=true` | 符合 | 历史窗口和 live 候选已分离 |
| formal 恢复 | 预期仍阻断 | `formal_resume_gate_pass=false` | 符合 | 数据源修复和公告可见性仍未完成 |

## 13. 支持证据

- 新增脚本：`scripts/research/audit_lklt_etf_adjustment_visibility_v2.py`。
- 语法检查通过：`python3 -m py_compile scripts/research/audit_lklt_etf_adjustment_visibility_v2.py`。
- 运行日志：`results/v2/research/RD-20260613T110126Z-main-FWZE/EX-20260614T042453Z-main-LKLT/logs/lklt_visibility_gate_v2.run.log`。
- 概览：`results/v2/research/RD-20260613T110126Z-main-FWZE/EX-20260614T042453Z-main-LKLT/diagnostic/visibility_gate_v2/visibility_gate_v2_overview.json`。
- 可见性审计：`results/v2/research/RD-20260613T110126Z-main-FWZE/EX-20260614T042453Z-main-LKLT/diagnostic/visibility_gate_v2/visibility_audit.csv`。
- 历史剔除窗口：`results/v2/research/RD-20260613T110126Z-main-FWZE/EX-20260614T042453Z-main-LKLT/diagnostic/visibility_gate_v2/historical_exclusion_windows_v2.csv`。
- live 候选：`results/v2/research/RD-20260613T110126Z-main-FWZE/EX-20260614T042453Z-main-LKLT/diagnostic/visibility_gate_v2/live_block_candidates_v2.csv`。
- 事件上下文：`results/v2/research/RD-20260613T110126Z-main-FWZE/EX-20260614T042453Z-main-LKLT/diagnostic/visibility_gate_v2/source_context_event_panel.csv`。
- 摘要：`results/v2/research/RD-20260613T110126Z-main-FWZE/EX-20260614T042453Z-main-LKLT/summary/lklt_visibility_gate_v2_summary.md`。

## 14. 反对证据

- `known_at` 仍是基于当前平台落库数据推断的“事件日收盘后”，不能证明历史实盘当天平台已经有相同 factor。
- 状态窗口的闭合日依赖未来事件，只能做历史污染定位，不能做 live unblock。
- `2026-05-13` 虽然是乘积连续回切，但它只能在发生后作为复核线索，不能提前解除 `2026-05-06` 后的风险。
- `116` 条乘积连续断点仍未完成公告或源数据可见性证明，不能直接转成交易过滤。

## 15. 偏差诊断

实验前预测基本成立：V2 成功把历史窗口和 live 候选分开，并把同日过滤禁止掉。偏差在于子代理建议字段名更直接，本轮脚本初版使用了等价字段；主控已补齐 `known_at`、`first_live_usable_date`、`future_data_used`，并重跑输出。

## 16. 研究判断

建议状态：`completed_visibility_design_pass_formal_still_blocked`

理由：LKLT 已经证明“不能用坏窗口原样做实盘黑名单”的边界，并给出三条可从下一交易日开始的 live block 候选。但这只是可见性设计通过，不是数据修复完成。X7PJ 的 formal 暂停继续有效。

## 17. 下一步

下一轮应新开 `515050.XSHG` 源头修复或保守隔离规则实验：

- 若能修复平台 factor/真实价口径，先修复后重跑 7HKT/HMZ3/LKLT 门禁。
- 若短期无法修复，只能预注册一个对 B0/G0 和所有候选变体同口径的保守隔离规则。
- 只有同口径门禁通过，才允许恢复动态池/资金热度收益 formal。

