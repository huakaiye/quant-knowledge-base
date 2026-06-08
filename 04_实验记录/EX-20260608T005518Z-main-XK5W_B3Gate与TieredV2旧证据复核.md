---
type: 实验记录
ex_id: EX-20260608T005518Z-main-XK5W
rd_id: RD-20260605T115651Z-main-DEF0
status: completed
stage: readonly_legacy_review_completed_baseline_skeleton_kept
owner: main
created_at: 2026-06-08T00:55:18Z
updated_at: 2026-06-08T01:12:30Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 防御模块
decision_ids: [DEC-20260608T005556Z-main-U7FN]
lit_ids: []
idea_ids: []
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths:
  - configs/research/R010-B3/r010b3_all_weak_persist_limited2_gate_median_or_breadth_cap80_2025_20260519.json
  - configs/research/R010-B4/r010b4_b3_gate_tiered_v2_2025_20260519.json
  - configs/research/R010-B4/r010b4_b3_gate_tiered_v2_2024.json
  - configs/research/R010-B4/r010b4_b3_gate_tiered_v2_2022_2023.json
  - configs/research/R010-B4/r010b4_b3_gate_tiered_v2_2020_2021.json
result_paths:
  - results/v2/research/R010-B4/tiered_v2_split_summary/
  - results/v2/research/R010-B4/tiered_v2_live_mapping_audit/
  - results/v2/research/R010-B4/tiered_v2_live_enabled_audit/
  - results/v2/research/R010-B3/gate_live_mapping_audit/
  - results/v2/research/R010-B3/live_strategy_audit/
  - results/v2/research/R010-B3/gate_live_observation/offline_replay/
summary_paths:
  - results/v2/research/R010-B4/tiered_v2_split_summary/summary.json
  - results/v2/research/R010-B4/tiered_v2_live_mapping_audit/summary.json
  - results/v2/research/R010-B4/tiered_v2_live_enabled_audit/summary.json
  - results/v2/research/R010-B3/gate_live_mapping_audit/summary.json
  - results/v2/research/R010-B3/live_strategy_audit/summary.json
  - results/v2/research/R010-B3/gate_live_observation/offline_replay/summary.json
quality_gate: readonly_pass_baseline_skeleton_no_new_alpha_promotion
subagent_call_ids:
  - SUB-20260608T004300Z-main-B34A
  - SUB-20260608T004300Z-main-B34B
subagent_exemption:
tags: [双池轮动, 防御模块, R010-B3, R010-B4, B3Gate, tiered-v2, 旧库复核]
---

# B3Gate与TieredV2旧证据复核

## 关联链接

- 研究方向：[[02_研究方向/RD-20260605T115651Z-main-DEF0_双池轮动防御模块|双池轮动防御模块]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 来源旧方向：[[02_研究方向/RD-20260603T000000Z-mig-ETF7D5F7_B3Gate+Tiered-v2——防守系统研究总结|B3 Gate + Tiered-v2 防守系统研究总结]]
- 来源旧实验：[[04_实验记录/EX-20260601T000000Z-mig-R20260601028R010B405D28_R20260601-028R010B4B3Gate强度分层研究|R010B4 B3Gate 强度分层研究]]
- 来源旧实验：[[04_实验记录/EX-20260601T000000Z-mig-R20260601029R010B4TIEREDBD1A7_R20260601-029R010B4B3Gate强度分层TieredV2预注册|R010B4 B3Gate 强度分层 TieredV2 预注册]]
- 产生的决策：[[05_研究决策/DEC-20260608T005556Z-main-U7FN_B3Gate与TieredV2复核后保留为防御骨架决策|B3Gate 与 TieredV2 复核后保留为防御骨架决策]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：旧库里已经实盘化过的 B3Gate 与 tiered-v2，能不能在新库里继续当作防御模块事实源。  
我们原本预计：如果它真的有效，应能在四段样本中降低回撤，并且不会明显错过 2025 强趋势。  
实际看到：tiered-v2 相对 B3-gate-cap80 的四段拼接收益从 `+1351.04%` 提高到 `+1468.34%`，拼接最大回撤从 `-30.00%` 改善到 `-27.13%`；但 2020_2021 回撤几乎没有改善，2022_2023 收益低于 cap80 约 `1.01pp`。  
这说明：B3Gate/tiered-v2 可以保留为当前 A11/A22/A23 研究的防御仓位骨架，因为它不是“选更强 ETF”，而是在市场全弱且 breadth/median 条件差时降低风险仓。  
但还不能说明：tiered-v2 是新的 alpha、可以继续降到 cap50/cap40、可以脱离 hard5/A22 直接声明最优策略，或已经完成完整成本扰动和未来函数 promote 审计。  
下一步要做：防御模块若继续推进，优先做 A1/A2 动作链或静态平均仓位四段对照，不在 B3/tiered-v2 的旧参数上后验扩网格。

## 2. 研究背景

本实验属于防御模块 `RD-20260605T115651Z-main-DEF0`。ARBE/DYSF 已把 R010-C/C1 收口为日志层观察，不能交易化；防御模块剩下的关键旧链条是 R010-B3 的 B3 gate 和 R010-B4 的 tiered-v2 分层强度防守。

本轮只做只读复核，不运行新回测，不更新数据，不修改平台策略代码。目标是把旧库“已采纳/实盘启用”的表达翻译成新库可审计边界：它可作为当前研究的防御骨架和基准组成，但不是新库新 promotion。

## 3. 实验前假设

B3Gate/tiered-v2 的旧平台证据若能通过新库只读复核，应支持“保留为防御仓位骨架”；若分段收益或回撤出现两个以上明显劣化、2025 强趋势被明显错过，或 live 映射/源码边界与旧结论冲突，则不能保留为当前基准组成。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：tiered-v2 四段拼接收益和回撤优于 B3-gate-cap80，且至少 3/4 分段不出现明显收益/回撤双杀。
- 交易行为：B3 先识别全弱持续状态，tiered-v2 只在 B3 gate active 后进一步把 cap80 分为 normal/strong/extreme，而不是改变 Top1 选股。
- 风险表现：2024 这类压力段应有明显回撤改善。
- 分段表现：2025 强趋势段不能被明显错过；若局部回撤改善很小，应作为边界写明。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| A2-slope004 | 不带 B3 gate 的上游动作基准 | `results/v2/research/R010-B2/a2_env_relative_slope004_*` |
| B3-gate-cap80 | B3 gate 基础防守，对照 tiered-v2 | `results/v2/research/R010-B3/all_weak_persist_limited2_gate_median_or_breadth_cap80_*` |
| B3-gate-cap70/cap60 | 静态更低仓位强度对照 | `results/v2/research/R010-B4/tiered_v2_split_summary/segment_overall_metrics.csv` |
| B3-gate-tiered-v1 | 旧分层规则对照 | `results/v2/research/R010-B4/tiered_v2_split_summary/compound_summary.csv` |
| B3-gate-tiered-v2 | 本次复核对象 | `results/v2/research/R010-B4/tiered_v2_split_summary/summary.json` |
| live mapping/enabled audit | 核对默认关闭映射与后续启用审计 | `results/v2/research/R010-B4/tiered_v2_live_mapping_audit/summary.json`; `results/v2/research/R010-B4/tiered_v2_live_enabled_audit/summary.json` |

## 6. 竞争性解释

即使旧证据看起来支持 tiered-v2，也可能是：

- 分层降仓的收益改善来自平均仓位下降，而不是状态识别本身。
- 2024 压力段权重过大，掩盖 2020_2021 与 2022_2023 的弱点。
- 旧实验网格经过多轮淘汰后存在后验选择风险。
- 成本扰动没有以完整撮合方式覆盖 tiered-v2，换手和仓位变化的真实成本仍可能高估。
- live enabled 代表当时用户授权启用，不等于新库已经完成当前生产 promote 审计。

## 7. 证伪条件

出现以下情况，本假设不通过：

- 两个以上分段相对 B3-gate-cap80 同时出现收益明显下降且回撤没有改善。
- 2025_20260519 相对 B3-gate-cap80 收益显著下降，说明强趋势被防御误伤。
- live mapping 或 enabled 审计显示开关、日志、实际风险仓使用分层 cap 不一致。
- 源码显示 tiered-v2 依赖未来数据或在 B3 gate 未 active 时仍改变风险仓。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 初筛通过 | 源码 `_derive_r010b3_all_weak_persistence_labels` 使用 `context.current_dt.date()` 更新状态，只累积当日和历史全弱状态；静态检索未在 B3/B4 逻辑附近发现 `shift(-)`、`bfill/backfill` 等典型未来取值。 |
| 信号生成和成交价格不存在同 bar 泄漏 | 部分通过 | 平台配置为日频 + 分钟执行，manifest 和既有 V2 回测包存在；本轮未重跑成交对齐审计，不能替代 promote 级未来函数审计。 |
| 股票池或 ETF 池不存在未来成分泄漏 | 部分通过 | 沿用既有双池 ETF 配置与 R010-B2/B3/B4 结果，本轮不新增 ETF 池。 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | B3/tiered-v2 不使用财务、宏观或估值数据。 |
| Shadow 或观察信号未被当成默认交易信号 | 通过但需区分时间线 | 2026-06-02 02:53 的 mapping audit 为 `default_closed=true`、`direct_live_enable=false`；同日 10:01 的 enabled audit 为 21/21 pass 且 `default_live_enabled=true`，说明旧链条经历“默认关闭映射”到“用户授权启用”两个阶段。 |

负控或错位检查：

- 本轮未新增错位负控；只引用旧平台分段、动作日和静态源码证据。因此证据等级不升到 L4/L5。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 部分通过 | 旧迁移实验中有 R010B4 tiered-v2 预注册记录，但仍是旧库迁移口径。 |
| 样本内、验证集、样本外划分清楚 | 部分通过 | 使用 `2020_2021`、`2022_2023`、`2024`、`2025_20260519` 四段拆分；本轮未新增样本外。 |
| 邻近参数敏感性合理 | 部分通过 | cap60/cap70/cap80、tiered-v1/tiered-v2 已并列比较；但没有当前新库重新预注册的完整敏感性网格。 |
| 成本、滑点或换手扰动已检查 | 不足 | 配置含 `commission_rate=0.0001`、`fixed_slippage_spread=0`；B3 cap90 有 5/10bps 旧审计，但 tiered-v2 本身缺完整成本翻倍/滑点扰动重新撮合。 |
| 已做消融或负控 | 部分通过 | A2-slope004、B3-gate-cap80、静态 cap 与 tiered-v1 构成消融对照；缺错位/随机负控。 |
| 未只报告最优结果 | 部分通过 | 本轮同时列出 2020_2021、2022_2023、2024、2025_20260519 的支持与反对证据。 |

证据等级：`L2_readonly_platform_review`。可以作为当前研究骨架事实，不足以作为新生产 promote。

## 10. 子代理调用记录

适配判断：适合调用。B3/B4 旧链条涉及路径清单、平台结果、映射审计和迁移资产，适合拆给子代理做只读清单和路径核对。

调用状态：called

子代理豁免：无。

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-20260608T004300Z-main-B34A | Singer | SUBTASK-20260608T004300Z-main-B3B4资产清单 | gpt-5.3-codex-spark | 2026-06-08T00:43:00Z | 旧库复核队列、迁移台账、B3/B4 迁移页、B3/tiered-v2 术语页 | 无 | 只读检索 | 输出 20 条旧库资产清单，标注迁移状态和优先级 | 只做清单，不做结论 | 主控采纳其迁移资产范围，重点更新旧方向、旧实验、旧决策和术语边界 | 帮助避免漏掉旧库资产状态 |
| SUB-20260608T004300Z-main-B34B | Goodall | SUBTASK-20260608T004300Z-main-B3B4平台结果清单 | gpt-5.3-codex-spark | 2026-06-08T00:43:00Z | `${QUANT_PLATFORM_ROOT}` 下 R010-B3/R010-B4 配置、结果、审计脚本清单 | 无 | 只读路径检索 | 只提供路径和核验建议，不做研究判断 | 需主控读取 summary/CSV 后确认 | 主控采纳其路径清单，并逐项读取 summary、CSV、配置和源码 | 帮助确定复核证据范围 |

台账行：已同步 `01_台账/子代理调用台账.csv`。

## 11. 执行记录

### 平台配置

```text
只读复核，未运行新回测。
读取配置：
configs/research/R010-B3/r010b3_all_weak_persist_limited2_gate_median_or_breadth_cap80_2025_20260519.json
configs/research/R010-B4/r010b4_b3_gate_tiered_v2_2025_20260519.json
```

### 运行命令

```powershell
Get-Content ${QUANT_PLATFORM_ROOT}\results\v2\research\R010-B4\tiered_v2_split_summary\summary.json
Import-Csv ${QUANT_PLATFORM_ROOT}\results\v2\research\R010-B4\tiered_v2_split_summary\compound_summary.csv
Import-Csv ${QUANT_PLATFORM_ROOT}\results\v2\research\R010-B4\tiered_v2_split_summary\segment_overall_metrics.csv
Import-Csv ${QUANT_PLATFORM_ROOT}\results\v2\research\R010-B4\tiered_v2_split_summary\segment_action_day_metrics.csv
Get-Content ${QUANT_PLATFORM_ROOT}\results\v2\research\R010-B4\tiered_v2_live_mapping_audit\summary.json
Get-Content ${QUANT_PLATFORM_ROOT}\results\v2\research\R010-B4\tiered_v2_live_enabled_audit\summary.json
Get-Content ${QUANT_PLATFORM_ROOT}\results\v2\research\R010-B3\gate_live_mapping_audit\summary.json
Get-Content ${QUANT_PLATFORM_ROOT}\results\v2\research\R010-B3\live_strategy_audit\summary.json
rg -n "r010b3_all_weak|r010b3_gate_tiered|shift\(-|bfill|backfill" ${QUANT_PLATFORM_ROOT}\src\strategies\research\etf_dual_pool_r010b_action_ablation.py
```

### 可见进度与日志

- 是否过程可见：是，均为前台只读命令。
- 日志路径：不适用。
- 查看进度命令：不适用。
- 异常判断：未运行新回测，无后台任务。
- 后台回测豁免：

```text
后台回测豁免：本轮未运行回测，只读取既有平台产物。
```

### 结果路径

```text
results/v2/research/R010-B4/tiered_v2_split_summary/
results/v2/research/R010-B4/tiered_v2_live_mapping_audit/
results/v2/research/R010-B4/tiered_v2_live_enabled_audit/
results/v2/research/R010-B3/gate_live_mapping_audit/
results/v2/research/R010-B3/live_strategy_audit/
```

## 12. 实际观察

| 指标 | 基准 | 本次 | 变化 | 解释 |
| --- | --- | --- | --- | --- |
| 四段拼接收益 | B3-gate-cap80 `+1351.04%` | B3-gate-tiered-v2 `+1468.34%` | `+117.30pp` | 旧结论的收益改善可复核。 |
| 四段拼接最大回撤 | B3-gate-cap80 `-30.00%` | B3-gate-tiered-v2 `-27.13%` | 改善 `+2.88pp` | 防御骨架有效性有支持证据。 |
| 动作日统计 | gate active `66` 天 | tiered-v2 强化动作 `22` 天 | 动作日胜率 `77.27%`，平均超额 `+0.2670pp` | 分层只在少数 B3 active 日进一步降仓。 |
| 2020_2021 | cap80 收益 `+121.56%`、MDD `-20.67%` | tiered-v2 收益 `+125.08%`、MDD `-20.68%` | 收益高 `+3.52pp`，回撤略差 | 不构成回撤改善。 |
| 2022_2023 | cap80 收益 `+32.23%`、MDD `-28.02%` | tiered-v2 收益 `+31.21%`、MDD `-27.13%` | 收益低 `-1.01pp`，回撤改善 `+0.89pp` | 防御有效但有机会成本。 |
| 2024 | cap80 收益 `+62.02%`、MDD `-30.00%` | tiered-v2 收益 `+67.01%`、MDD `-26.99%` | 收益高 `+4.98pp`，回撤改善 `+3.01pp` | 压力段支持最强。 |
| 2025_20260519 | cap80 收益 `+205.70%`、MDD `-16.57%` | tiered-v2 收益 `+217.97%`、MDD `-16.57%` | 收益高 `+12.28pp`，回撤几乎不变 | 没有明显错过强趋势。 |
| live mapping | `default_closed=true`、17/17 pass | 之后 enabled audit 21/21 pass、`default_live_enabled=true` | 时间线从默认关闭映射到用户授权启用 | 新库记录应区分两阶段。 |
| B3 live mapping | 25/25 pass | `gate_mapped=true`、`gap_count=0` | 映射一致 | 支持 B3 作为骨架。 |

## 13. 支持证据

- `tiered_v2_split_summary/summary.json` 给出 `decision=promote_candidate_default_closed`，所有核心 checks 为 true。
- `compound_summary.csv` 显示 tiered-v2 相对 cap80 四段拼接收益多 `117.30pp`，最大回撤改善 `2.88pp`。
- `total_action_day_metrics.csv` 显示 tiered-v2 gate active 66 天、stronger action 22 天、动作日胜率 `77.27%`。
- `tiered_v2_live_enabled_audit/summary.json` 显示 21/21 pass，B3 gate 和 tiered-v2 默认开启、shadow 默认关闭、未引入 R026 交易动作开关。
- `gate_live_mapping_audit/summary.json` 显示 B3 gate 25/25 pass，未混入 R026、A1/A3/A4、R010-D/E 动作。
- 源码 `_evaluate_r010b3_gate_tiered_strength` 要求 B3 persistence active 后才评估 tiered-v2，extreme/strong cap 通过 `min(current_cap, cap)` 降低风险暴露。

## 14. 反对证据

- 2020_2021 的 tiered-v2 最大回撤 `-20.678%` 略差于 cap80 的 `-20.672%`，不能说四段都改善回撤。
- 2022_2023 的 tiered-v2 收益 `+31.21%` 低于 cap80 的 `+32.23%`，且动作日累计边际很薄。
- 2025_20260519 回撤改善只有约 `0.004pp`，强趋势段收益提高主要说明没有误伤，不代表防御能力更强。
- tiered-v2 缺完整 cost2x/slip2bps 重新撮合、错位负控和新库重新预注册参数敏感性。
- 旧 live enabled 审计证明当时用户授权启用，不等于当前新库允许直接 production promote。

## 15. 偏差诊断

实验前预期“至少 3/4 分段不明显双杀”成立，但“回撤普遍改善”只在 2022_2023、2024、2025_20260519 部分成立，2020_2021 不成立。旧库“四段验证通过”的表达需要收紧为：总体拼接和关键压力段支持，但局部分段有机会成本与弱改善。

## 16. 研究判断

建议状态：`revise_baseline_skeleton_kept`

理由：B3Gate/tiered-v2 的既有平台证据足以支撑它继续作为当前双池轮动防御仓位骨架和 A11/A22/A23 研究基底；但证据不足以支持“新库新 alpha promote”或进一步后验降低 cap。旧库 live 启用记录保留为历史事实，当前研究库只采纳其骨架边界。

## 17. 下一步

防御模块下一步不继续扩 B3/tiered-v2 参数；若继续方向 3，应新开以下之一：

- A1/A2 动作链复核，确认旧防御动作中哪些是真正改变目标仓位的有效动作。
- 静态平均仓位四段对照，用同平均仓位拆出“状态识别”与“单纯低仓位”贡献。
- 触发滞后一日负控，检查 B3/tiered-v2 是否依赖同日冲击而非提前风险识别。
