---
type: 实验记录
ex_id: EX-20260606T140752Z-main-TC8U
rd_id: RD-20260605T115651Z-main-EXE0
status: active
stage: formal_base_completed_cost_blocked
owner: main
created_at: 2026-06-06T14:07:52Z
updated_at: 2026-06-06T18:35:00Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 执行与换仓模块
decision_ids: []
lit_ids: []
idea_ids: []
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths:
  - configs/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/formal/
  - configs/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/formal_cost2x_slip2bps/
  - configs/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/formal_cost2x_commission/
  - scripts/research/generate_tc8u_topn_antishake_configs.py
result_paths:
  - results/v2/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/formal/
  - results/v2/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/logs/formal/
summary_paths:
  - results/v2/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/summary/summary.json
  - results/v2/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/summary_cost2x_slip2bps/summary.json
  - results/v2/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/summary_cost2x_commission/summary.json
  - scripts/research/summarize_tc8u_topn_antishake.py
quality_gate: L2_formal_base_completed_cost_blocked_no_promote
subagent_call_ids:
  - SUB-20260606T140000Z-main-TOPN
  - SUB-20260606T150000Z-main-TC8U-AUDIT
subagent_exemption:
tags: [双池轮动, TopN抗抖, 执行模块, formal完成, 成本待补]
---

# TopN抗抖换仓formal AB预注册

## 关联链接

- 研究方向：[[02_研究方向/RD-20260605T115651Z-main-EXE0_双池轮动执行与换仓模块|双池轮动执行与换仓模块]]
- 父方向：[[02_研究方向/RD-20260605T115651Z-main-DP00_双池轮动策略|双池轮动策略]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 上游路线预注册：[[04_实验记录/EX-20260606T134047Z-main-HPHZ_五方向接手证据映射与首轮路线预注册|五方向接手证据映射与首轮路线预注册]]
- Top4 反证：[[04_实验记录/EX-20260606T012550Z-main-LM3D_动量评分尺度与Top4排名权重预注册|动量评分尺度与 Top4 排名权重预注册]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：当前持仓如果仍在 Top3/Top5 且分数没有明显落后，继续持有是否能减少无意义换仓。
我们原本预计：它应该主要降低交易次数和成本敏感性，而不是显著改变选股逻辑。
实际看到：base-cost formal 已完成 20/20；所有 TopN 变体四段交易数都下降，2025_20260519 都没有错过强趋势。
这说明：TopN 抗抖确实能减少换仓噪声，但不能直接升级为默认规则，因为 `top3_ratio070_veto` 和 `top5_ratio070_veto` 都有两个分段 final 低于 baseline。
对新手来说：少换仓不是天然更好，它可能是在强趋势里减少噪声，也可能是在趋势切换时反应变慢。
下一步要做：等 WSL 平台空闲后补成本扰动；当前只能把 `top3_ratio070_gap050_veto` 和 `top5_ratio070_veto` 留作候选观察，不能 promote。

## 2. 研究背景

`EX-20260606T012550Z-main-LM3D` 已经否定 Top4 等权、Top4 `40/30/20/10` 和取消 hard5 上限进入默认逻辑。
因此本实验不研究“多买几个 ETF”，只研究“仍主要 Top1，但当前持仓还在候选前列时是否延迟换仓”。

平台 `src/strategies/research/etf_dual_pool_topn_vol_scaled.py` 已有 `choose_targets_with_topn_hold`。本轮补了 `strategy_params.topn_hold` 参数覆盖能力，并通过 `src/tests/strategies/test_etf_dual_pool_topn_hold.py` 10 项测试。

## 3. 实验前假设

低分差、低名次抖动的切换日里，继续持有仍在 Top3/Top5 的旧持仓，可以降低换手和交易次数；如果真实趋势已经切换，Top1 领先会通过分数比例或急跌否决迫使换仓。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：TopN 变体的四段 final 不应明显低于同策略文件 `baseline_top1_hard5`。
- 交易行为：TopN 变体交易数应低于 baseline，日志中应出现 `topn_retained`。
- 风险表现：MDD 不应明显恶化；急跌否决触发日不应继续保留旧持仓。
- 分段表现：2025_20260519 强趋势段不能明显落后；2022_2023 不能因抗抖持有弱势旧标的而放大回撤。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| baseline_top1_hard5 | 同一策略文件、关闭 TopN，隔离策略文件差异 | `configs/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/formal/baseline_top1_hard5/` |
| top3_ratio070_veto | 当前持仓在 Top3 且分数 >= Top1 的 70% 时保留 | `configs/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/formal/top3_ratio070_veto/` |
| top3_ratio085_veto | 更严格分数比例，检验是否只靠宽松滞后获益 | `configs/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/formal/top3_ratio085_veto/` |
| top5_ratio070_veto | 更宽排名保留，检验 Top5 是否过度滞后 | `configs/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/formal/top5_ratio070_veto/` |
| top3_ratio070_gap050_veto | Top3 + 比例 + 绝对分差上限，检验“新第一名必须明显强” | `configs/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/formal/top3_ratio070_gap050_veto/` |
| hard5/A23 | 外部参考，不作为本轮同文件直接基准 | `results/v2/research/R010-A23/state_tier_hot_budget/` |

## 6. 竞争性解释

即使结果符合预期，也可能是：

- 交易减少来自策略文件差异或参数覆盖错误，而不是 TopN 抗抖。
- 收益改善来自更少交易成本，而不是持仓延续本身。
- TopN 只在 2025 强趋势段减少噪声，无法跨段稳定。
- `top5_ratio070` 可能隐藏真实趋势切换，表面少换仓但损失未来收益。

## 7. 证伪条件

出现以下情况，本假设不通过：

- 两个以上分段 final 明显低于 baseline_top1_hard5。
- 交易数下降但 MDD 没改善且收益明显下降。
- 2025_20260519 强趋势段跟不上 baseline 或 A23 外部参考。
- 只有 `top5_ratio070` 有效而 `top3` 邻近参数失败，说明可能是偶然滞后。
- 后续成本加倍后优势消失；本卡未做成本扰动前不得 promote。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 待检查 | formal 结果完整，但尚未逐字段审计 manifest 与数据输入 |
| 信号生成和成交价格不存在同 bar 泄漏 | 待检查 | 沿用 V2 JoinQuant bridge 与原策略调仓流程，需后续专项复核 |
| 股票池或 ETF 池不存在未来成分泄漏 | 待检查 | 使用既有动态池逻辑；后续需复核动态池不是结束日快照 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 本策略不使用财务宏观估值数据 |
| Shadow 或观察信号未被当成默认交易信号 | 已限制 | 本实验为 formal A/B，但不修改生产默认 |

负控或错位检查：

- baseline_top1_hard5 关闭 TopN。
- `top3_ratio085_veto` 与 `top3_ratio070_gap050_veto` 做邻近收紧。
- 成本扰动配置已生成但运行受平台环境阻塞，完成前不升级结论。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 已预注册 | 5 个变体固定，不看结果后扩网格 |
| 样本内、验证集、样本外划分清楚 | 部分完成 | 四段固定：2020_2021、2022_2023、2024、2025_20260519 |
| 邻近参数敏感性合理 | 部分完成 | ratio 0.70/0.85、Top3/Top5、gap 0/0.50 |
| 成本、滑点或换手扰动已检查 | 未完成 | 成本配置 dry-run 通过，但正式运行中断 |
| 已做消融或负控 | 部分完成 | baseline 与邻近收紧完成；随机延迟待补 |
| 未只报告最优结果 | 已满足 | 汇总脚本输出全部 base-cost 变体 |

证据等级：`L2_formal_base_completed_cost_blocked_no_promote`

## 10. 子代理调用记录

适配判断：`适合调用`

调用状态：`called`

子代理豁免：

```text
不适用
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-20260606T140000Z-main-TOPN | Cicero | SUBTASK-20260606T140000Z-main-TOPN | gpt-5.3-codex-spark | 2026-06-06T14:00:00Z | 平台 TopN 策略、测试、生成与汇总脚本、配置根 | 无 | 无长回测 | 只读核对，不做最终判断 | `cooldown` 字段不存在，需用 rank/ratio/gap 表达 | 主控采纳其“20 个 formal 配置已存在/可执行”核对，并补 `strategy_params.topn_hold` 覆盖测试 | 支持本卡进入 formal A/B |
| SUB-20260606T150000Z-main-TC8U-AUDIT | Curie | SUBTASK-20260606T150000Z-main-TC8U-AUDIT | gpt-5.3-codex-spark | 2026-06-06T15:00:00Z | `summary.json`、`comparison_vs_baseline.csv`、20 个 status、实验卡 | 无 | 无长回测 | 只读核对，不做 promote/revise/kill | 只按已给证伪条件判断，不替代主控决策 | 主控复核其 20/20、自洽、证伪条件清单；采纳其对 `top3_ratio070_gap050_veto` 的审计优先级建议 | 把成本审计候选从单一 Top5 改为 Top5 + Top3/gap 双候选 |

台账行：已补 `01_台账/子代理调用台账.csv`。

## 11. 执行记录

### 平台配置

```text
configs/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/formal/
configs/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/formal_cost2x_slip2bps/
configs/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/formal_cost2x_commission/
```

### 运行命令

```bash
python scripts/research/generate_tc8u_topn_antishake_configs.py
PHASE=formal VARIANTS='<variant>' SEGMENTS='<segment>' bash scripts/research/run_tc8u_topn_antishake_formal.sh
python scripts/research/summarize_tc8u_topn_antishake.py --output-dir results/v2/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/summary
```

成本扰动配置命令：

```bash
python scripts/research/generate_tc8u_topn_antishake_configs.py --phase formal_cost2x_slip2bps
python scripts/research/generate_tc8u_topn_antishake_configs.py --phase formal_cost2x_commission
```

### 可见进度与日志

- 是否过程可见：`formal base-cost 已使用 PYTHONUNBUFFERED=1 + tee`
- 日志路径：`results/v2/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/logs/formal/`
- 查看进度命令：`Get-Content <log> -Tail 80`
- 异常判断：base-cost 20 个 `.status` 均为 `0`，summary/trades/logs 齐全；成本阶段无完成 run
- 后台回测豁免：

```text
不适用，正式 base-cost 回测均前台可见执行。
```

### 结果路径

```text
results/v2/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/formal/
results/v2/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/summary/
results/v2/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/summary_cost2x_slip2bps/
results/v2/research/R010-TOPN/EX-20260606T140752Z-main-TC8U/summary_cost2x_commission/
```

## 12. 实际观察

base-cost formal 完成 20/20，`completed_runs=20`、`missing=[]`、20 个 status 全部为 `0`。

| 变体 | final 不低于 baseline 分段数 | MDD 不差于 baseline 分段数 | 交易数下降分段数 | 四段 final 差额合计 | 四段交易差额合计 | 主观察 |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| `top3_ratio070_veto` | 2/4 | 2/4 | 4/4 | +3,412.21 | -373 | 触发“两段 final 低于 baseline”，且 2020 收益和回撤同时变差，降优先级 |
| `top3_ratio085_veto` | 3/4 | 2/4 | 4/4 | -1,732.70 | -261 | 收紧后收益合计转负，不作为首选候选 |
| `top5_ratio070_veto` | 2/4 | 4/4 | 4/4 | +16,431.01 | -474 | 交易下降最多、回撤四段都不差，但 2020/2022 final 低于 baseline，不能 promote |
| `top3_ratio070_gap050_veto` | 3/4 | 2/4 | 4/4 | +4,830.17 | -243 | 只 2024 final 低于 baseline，2025 未掉队；作为较稳妥成本审计候选 |

关键逐段事实：

- `top5_ratio070_veto`：2025_20260519 final 比 baseline 高 `40,460.96`，MDD 改善 `0.0113`，交易少 `125`；2020_2021 和 2022_2023 final 分别低 `23,425.18`、`8,107.84`，但 MDD 均改善。
- `top3_ratio070_gap050_veto`：2020_2021、2022_2023、2025_20260519 final 分别高 `6,348.83`、`2,715.30`、`9,542.17`；2024 低 `13,776.13`。
- 所有 TopN 变体 2025_20260519 均未掉队，说明强趋势段没有被完全错过。
- 成本扰动尝试：`formal_cost2x_slip2bps` 与 `formal_cost2x_commission` 均已生成并 dry-run 通过，但实际回测在 baseline 2020/2024 早段无 traceback 中断；现场存在无关 A23 WSL 回测进程，且 `dmesg` 有 Python/WSL 内核告警。成本扰动记为平台环境阻塞，不能作为有效结果。

## 13. 支持证据

- 平台已有 `choose_targets_with_topn_hold`，本轮新增 `strategy_params.topn_hold` 覆盖能力。
- `python -m pytest src/tests/strategies/test_etf_dual_pool_topn_hold.py -q` 通过 10/10。
- 20 个 base-cost formal 回测均有 `.status=0`。
- `topn_retained` 合计：Top3/0.70 为 266 次，Top3/0.85 为 186 次，Top5/0.70 为 342 次，Top3/0.70/gap0.50 为 182 次。

## 14. 反对证据

- `top3_ratio070_veto` 与 `top5_ratio070_veto` 均触发“两段以上 final 低于 baseline”的证伪条件。
- `top3_ratio085_veto` 四段 final 合计为负，说明不是简单收紧就能稳健。
- 成本扰动未完成，成本优势不能确认。
- 没有随机延迟和冷却期 live 实现负控。
- 本实验不能直接证明 A23 与 TopN 叠加有效。

## 15. 偏差诊断

- 本卡是 base-cost formal，不是成本稳健性完成证据。
- `top5_ratio070_veto` 的合计收益最高，但两个历史分段 final 低于 baseline，可能是反应变慢换来的 2025 噪声收益。
- `top3_ratio070_gap050_veto` 证伪触发较少，但 MDD 仅 2/4 不差，且 2024 final 明显低于 baseline。
- 成本扰动中断发生在 baseline，不是 TopN 特有；应等无关 A23 任务结束后重跑，或单独排查 WSL/ClickHouse 内存状态。

## 16. 研究判断

建议状态：`observe / robustness_pending`

理由：TopN 抗抖证明了“减少换仓”这个执行效果，但没有证明“稳定提升收益”。`top3_ratio070_gap050_veto` 和 `top5_ratio070_veto` 可进入成本扰动与随机延迟负控；`top3_ratio070_veto` 降优先级。未完成成本扰动前不得 promote，也不得改默认 hard5/A23。

## 17. 下一步

1. 等 WSL 平台空闲后重跑 `formal_cost2x_commission` 与 `formal_cost2x_slip2bps`，先跑 baseline + `top3_ratio070_gap050_veto` + `top5_ratio070_veto`。
2. 若成本扰动仍中断，单独开平台工程排障卡，检查 `risk_config.execution`、内存维护和 ClickHouse 连接池。
3. 追加随机延迟换仓或冷却期负控；完成前不新开更大 TopN 网格。
4. 若成本扰动通过，再考虑把 TopN 与 A23 作为组合交互实验，而不是直接替换 hard5。
