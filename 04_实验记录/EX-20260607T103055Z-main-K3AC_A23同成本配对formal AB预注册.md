---
type: 实验记录
ex_id: EX-20260607T103055Z-main-K3AC
rd_id: RD-20260605T133318Z-main-H6V3
status: completed
stage: formal_strict_pass_a22_preferred_a23_marginal
owner: main
created_at: 2026-06-07T10:30:55Z
updated_at: 2026-06-07T21:01:08+08:00
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: score_hot_soft_budget_cost_pair
decision_ids:
  - DEC-20260607T102206Z-main-XBWS
  - DEC-20260607T125847Z-main-WQ8R
lit_ids: []
idea_ids: []
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths:
  - configs/research/R010-A23/paired_cost/EX-20260607T103055Z-main-K3AC/formal/
  - configs/research/R010-A23/state_tier_hot_budget/base70_blowoff92_m04_d09_cap60_cost2x_slip2bps/
  - scripts/research/generate_k3ac_a23_paired_cost_configs.py
  - scripts/research/run_k3ac_a23_paired_cost.sh
  - scripts/research/summarize_k3ac_a23_paired_cost.py
result_paths:
  - results/v2/research/R010-A23/paired_cost/EX-20260607T103055Z-main-K3AC/formal/
  - results/v2/research/R010-A23/paired_cost/EX-20260607T103055Z-main-K3AC/logs/formal/
  - results/v2/research/R010-A23/paired_cost/EX-20260607T103055Z-main-K3AC/summary/formal/
  - results/v2/research/R010-A23/state_tier_hot_budget/base70_blowoff92_m04_d09_cap60_cost2x_slip2bps/
summary_paths:
  - results/v2/research/R010-A23/paired_cost/EX-20260607T103055Z-main-K3AC/summary/formal/summary.json
quality_gate: L2_formal_strict_pass_a22_preferred_a23_marginal
subagent_call_ids:
  - SUB-20260607T104500Z-main-CST9
  - SUB-20260607T130000Z-main-RSLT
subagent_exemption:
tags: [双池轮动, score过热, A23, 同成本配对, cost2x, formal]
---

# A23同成本配对formal AB预注册

## 关联链接

- 研究方向：[[02_研究方向/RD-20260605T133318Z-main-H6V3_双池轮动score过热拥挤机制模块|双池轮动 score 过热拥挤机制模块]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 上游实验：[[04_实验记录/EX-20260607T101347Z-main-VX4J_A23事件归因与成本换手约束只读预注册|VX4J A23 事件归因与成本换手约束]]
- 上游决策：[[05_研究决策/DEC-20260607T102206Z-main-XBWS_A23事件归因后先做同成本配对决策|XBWS A23 先做同成本配对决策]]
- 结果决策：[[05_研究决策/DEC-20260607T125847Z-main-WQ8R_K3AC同成本通过后A22优先于A23决策|WQ8R K3AC 同成本后 A22 优先]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：A23 高成本失败是不是只是因为它被拿去和普通成本 A22 比，还是在同样高成本下也比 hard5 或 A22 差。  
我们原本预计：如果 A22/A23 的高分软预算真有结构价值，那么在同一个 `cost2x_slip2bps` 成本口径下，它们仍应比 hard5 更好；如果连同成本 hard5 都打不过，说明高分软预算对成本太脆弱。  
实际看到：K3AC strict 已完成 12/12，`strict_missing=[]`，所有门槛通过。A22 cap70 同成本相对 hard5 同成本 4/4 final 不低、4/4 MDD 不差，四段 final 合计多 `37591.85`；A23 同成本相对 hard5 同成本 4/4 final 不低、4/4 MDD 不差，四段 final 合计多 `37626.78`。  
这说明：高分软预算在同成本口径下确实优于 hard5，直接废除 hard5 不对，但用 A22 这种“高分少买一点”的方式比 hard5 一刀切更有证据。A23 虽然也通过 hard5 对照，但相对 A22 只多 `34.93`，其中 2025_20260519 还少 `287.02` 且 MDD 略深 `0.00020`，独立价值很小。  
但还不能说明：A22 已可直接上线；仍需未来函数审计、原生字段清理、forward/OOS 或生产 shadow 边界验证。  
下一步要做：把 A22 cap70 固化为 hard5 替代研究的首选挑战者，A23 只保留为 broad-blowoff 风险解释和备用挑战者；不继续为 A23 加复杂换手约束。

## 2. 研究背景

VX4J 已经把 A23 的路线收窄：A23 相对 A22 的独有贡献只来自 2020 的 3 个 broad-blowoff 触发，2025/2026 强趋势收益来自 A22/A23 共同的 base cap70。LVV7 的 `cost2x_slip2bps` 四段全部弱于普通成本 A22，但这不是公平同成本对比。本实验按照 XBWS 决策，先做 hard5、A22 cap70、A23 92/4/d09 的同成本配对。

## 3. 实验前假设

在统一 `commission_rate=0.0002`、`min_commission=5`、`slippage_bps=2.0` 的高成本口径下，A22 cap70 与 A23 92/4/d09 仍应保留相对 hard5 的主要收益优势；A23 不应相对 A22 出现新的系统性劣化。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：`a22_cap70_cost2x_slip2bps` 和 `a23_92_4_d09_cost2x_slip2bps` 至少各自 4/4 分段 final 不低于 `hard5_cost2x_slip2bps`。
- 交易行为：A22/A23 成本提高后交易路径可以因现金和股数略变，但不应出现大量额外换仓；交易数相对 hard5 不应成为主要收益来源。
- 风险表现：A22/A23 的 MDD 至少 3/4 分段不深于 hard5 同成本。
- 分段表现：2024 仍应作为负控段，hard5/A22/A23 在普通成本下相同；同成本下如果出现策略逻辑差异，优先检查配置。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| `hard5_cost2x_slip2bps` | 同成本默认语义基准 | `configs/research/R010-A23/paired_cost/EX-20260607T103055Z-main-K3AC/formal/hard5_cost2x_slip2bps/` |
| `a22_cap70_cost2x_slip2bps` | 同成本 soft budget 基准 | `configs/research/R010-A23/paired_cost/EX-20260607T103055Z-main-K3AC/formal/a22_cap70_cost2x_slip2bps/` |
| `a23_92_4_d09_cost2x_slip2bps` | 复用 LVV7 已完成 A23 高成本运行 | `configs/research/R010-A23/state_tier_hot_budget/base70_blowoff92_m04_d09_cap60_cost2x_slip2bps/` |
| 普通成本 hard5/A22/A23 | 解释成本冲击，不参与通过门槛 | 既有 R010-A11/A22/A23 run_dir |

## 6. 竞争性解释

即使同成本 A22/A23 通过，也可能是：

- 高成本 hard5 被同样成本拖累，并不说明 A22/A23 已能上线。
- A22/A23 2025 优势来自强趋势窗口，未来样本外不一定延续。
- 成本和滑点改变现金、股数与成交价，不能只用 `fee` 差解释。
- A23 与 A22 的差异很小，A23 tier 可能没有足够独立价值。

## 7. 证伪条件

出现以下情况，本假设不通过：

- A22 或 A23 在两个以上分段 final 低于 hard5 同成本。
- A22/A23 虽 final 通过，但 MDD 少于 3/4 分段不差。
- A23 同成本相对 A22 同成本在两个以上分段 final 或 MDD 明显更差。
- 2024 负控段出现不应有的策略逻辑差异，且不能由成本现金路径解释。
- 任一新跑分段缺少 `.run.log`、manifest、`exit_status=0` 或 fresh summary，不得作为 formal 证据。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 待检查 | 本实验只改成本口径，不新增信号字段 |
| 信号生成和成交价格不存在同 bar 泄漏 | 待检查 | 沿用 R010-A11/A22/A23 V2 入口；需确认配置只改成本字段 |
| 股票池或 ETF 池不存在未来成分泄漏 | 沿用上游 | 不新增 ETF 池 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 不使用这些字段 |
| Shadow 或观察信号未被当成默认交易信号 | 通过预注册约束 | 新配置仅在 K3AC 路径下运行，不改默认 hard5/A23 |

负控或错位检查：

- 2024 是负控段；普通成本 hard5/A22/A23 已相同。
- A23 cost2x 复用 LVV7 已完成结果，hard5/A22 cost2x 作为缺口补跑。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | 固定三组同成本对照，不调阈值 |
| 样本内、验证集、样本外划分清楚 | 部分通过 | 沿用四段 formal；forward OOS 仍待后续 |
| 邻近参数敏感性合理 | 上游通过 | LVV7 阈值邻域 24/24，非本实验搜索对象 |
| 成本、滑点或换手扰动已检查 | 通过 | 本实验完成 hard5/A22/A23 同成本 `cost2x_slip2bps` 12/12 strict |
| 已做消融或负控 | 部分通过 | 2024 负控与 hard5/A22/A23 同成本对照 |
| 未只报告最优结果 | 通过 | 固定 hard5/A22/A23 三组，全量汇总 |

证据等级：`L2_formal_strict_pass_a22_preferred`

## 10. 子代理调用记录

适配判断：`适合调用`

调用状态：`called_completed`

子代理豁免：

```text
不适用；本轮已调用只读配置审计和 strict 结果复核子代理。
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-20260607T104500Z-main-CST9 | Kierkegaard | SUBTASK-20260607T104500Z-main-CST9_子查_A23同成本配置审计 | gpt-5.3-codex-spark | 2026-06-07T10:45:00Z | R010-A11 hard5、R010-A22 cap70、R010-A23 cost2x 四段配置和策略成本字段 | 无 | 只读字段审计，未修改文件 | 只做路径和字段核对，不判断策略优劣 | A22 使用 A13 风险预算字段表达 cap70，A23 使用 A22 tier 字段；三组语义不同但同成本字段可统一 | 主控已按其建议生成 hard5/A22 cost2x 派生配置，并复用 A23 cost2x 证据 | 支持 K3AC 固定三组同成本配对，不扩 A23 阈值或换手参数 |
| SUB-20260607T130000Z-main-RSLT | Kierkegaard | SUBTASK-20260607T130000Z-main-RSLT_K3AC同成本strict结果复核 | gpt-5.3-codex-spark | 2026-06-07T13:00:00Z | K3AC summary.json、comparison_pairs.csv、segment_metrics.csv、runner.log、runner.exit | 无 | 只读复核 strict 结果、CSV 和日志状态 | 只做证据完整性和门槛核对，不做策略优劣或 promote/park/kill 判断 | A23 四段为复用历史 run；2025 相对 A22 轻微变差；runner.log 主日志不如各段 run.log 直接 | 主控已复核 `summary.json`、`comparison_pairs.csv`、`segment_metrics.csv`、runner.exit=0 和 8 段 `exit_status=0` | 支持把 K3AC 记为“可采信 formal 同成本证据”，并保留 A23 复用与 2025 轻微落后的边界 |

台账行：已同步 `01_台账/实验台账.csv` 与 `01_台账/子代理调用台账.csv`。

## 11. 执行记录

### 平台配置

```text
configs/research/R010-A23/paired_cost/EX-20260607T103055Z-main-K3AC/formal/
```

### 运行命令

```bash
cd /mnt/e/量化平台_V1.4.0
PYTHONIOENCODING=utf-8 python3 -m py_compile scripts/research/generate_k3ac_a23_paired_cost_configs.py scripts/research/summarize_k3ac_a23_paired_cost.py
bash -n scripts/research/run_k3ac_a23_paired_cost.sh
PYTHONIOENCODING=utf-8 python3 scripts/research/generate_k3ac_a23_paired_cost_configs.py
DRY_RUN=1 bash scripts/research/run_k3ac_a23_paired_cost.sh
PYTHONIOENCODING=utf-8 python3 scripts/research/summarize_k3ac_a23_paired_cost.py
PYTHONUNBUFFERED=1 PYTHONIOENCODING=utf-8 scripts/research/run_k3ac_a23_paired_cost.sh 2>&1 | tee results/v2/research/R010-A23/paired_cost/EX-20260607T103055Z-main-K3AC/logs/formal/runner.log
ALLOW_CONCURRENT_BACKTEST=1 PYTHONUNBUFFERED=1 PYTHONIOENCODING=utf-8 bash scripts/research/run_k3ac_a23_paired_cost.sh > results/v2/research/R010-A23/paired_cost/EX-20260607T103055Z-main-K3AC/logs/formal/runner.log 2>&1; echo $? > results/v2/research/R010-A23/paired_cost/EX-20260607T103055Z-main-K3AC/logs/formal/runner.exit
PYTHONIOENCODING=utf-8 python3 scripts/research/summarize_k3ac_a23_paired_cost.py --strict
```

### 可见进度与日志

- 是否过程可见：是，正式命令使用 `PYTHONUNBUFFERED=1`、每段 `.run.log` 和 runner `tee`。
- 日志路径：`results/v2/research/R010-A23/paired_cost/EX-20260607T103055Z-main-K3AC/logs/formal/`
- 查看进度命令：`Get-Content -Encoding UTF8 E:\量化平台_V1.4.0\results\v2\research\R010-A23\paired_cost\EX-20260607T103055Z-main-K3AC\logs\formal\runner.log -Tail 80`
- 异常判断：每段必须有 `.run.log`、manifest、`exit_status=0` 和 fresh summary。
- 后台回测豁免：实际执行出现偏差；外部进程使用 `ALLOW_CONCURRENT_BACKTEST=1` 与 TC8U 并发运行。该偏差不自动否决结果，但 strict 汇总前必须复核每段日志、manifest、`exit_status=0`、runner.exit 和错误标记。

### 结果路径

```text
results/v2/research/R010-A23/paired_cost/EX-20260607T103055Z-main-K3AC/formal/
results/v2/research/R010-A23/paired_cost/EX-20260607T103055Z-main-K3AC/summary/formal/
```

## 12. 实际观察

- `generate_k3ac_a23_paired_cost_configs.py` 已生成 8 个 hard5/A22 同成本配置：2 个 variant × 4 个 segment。
- 字段复核显示 hard5 仍为 `max_score=5`、`score_hot_filter_mode=hard_cap`；A22 仍为 `max_score=9999`、`score_hot_filter_mode=conditional_hot_state`、`r010a13_score56_risk_budget_enabled=true`、`risk_cap=0.7`。
- 两组新配置均已统一成本字段：`fee_params.commission_rate=0.0002`、`min_commission=5`、`r010b5_research_cost_override_enabled=true`、`r010b5_research_fund_slippage_bps=2.0`、`risk_config.execution.slippage_bps=2.0`。
- `DRY_RUN=1 bash scripts/research/run_k3ac_a23_paired_cost.sh` 显示待运行范围为 hard5/A22 两组共 8 段；A23 cost2x/slip2bps 由汇总脚本从 R010-A23/state_tier_hot_budget 复用。
- 外部已用 `ALLOW_CONCURRENT_BACKTEST=1` 启动正式补跑；runner 日志根为 `results/v2/research/R010-A23/paired_cost/EX-20260607T103055Z-main-K3AC/logs/formal/20260607T110543Z/`。
- hard5 同成本四段已完成：`2020_2021` final `213091.47`、MDD `-21.6947%`、交易 `559`；`2022_2023` final `124873.55`、MDD `-28.2228%`、交易 `450`；`2024` final `163161.20`、MDD `-27.4756%`、交易 `279`；`2025_20260519` final `302895.29`、MDD `-16.9949%`、交易 `464`。
- Strict 汇总已刷新 `summary/formal/summary.json`：`expected_evidence_runs=12`、`completed_evidence_runs=12`、`expected_new_k3ac_runs=8`、`completed_new_k3ac_runs=8`、`strict_missing=[]`、`all_gates_pass=true`。
- A23 cost2x 相对 hard5 cost2x 为 4/4 final 不低、4/4 MDD 不差；四段 final 差为 `+1141.38`、`+7321.61`、`0.00`、`+29163.79`，合计 `+37626.78`；MDD 差为 `+0.0052`、`+0.0348`、`0.0000`、`+0.0193`。
- 2024 负控段 final、MDD、交易和费用完全一致，`negative_control_2024_final_identical=true`。
- A22 cap70 同成本 2020_2021 已完成：final `213910.90`、MDD `-21.3887%`、交易 `581`；相对 hard5 同成本多 `819.43`，MDD 改善 `0.00306`。
- A23 cost2x 相对 A22 cap70 cost2x 在 2020_2021 多 `321.95`，MDD 改善 `0.00215`，交易数相同，说明该段 A23 仍有小幅独立贡献，但 A22 是主要收益来源。
- A22 cap70 同成本 2022_2023 已完成：final `132195.16`、MDD `-24.7470%`、交易 `466`；相对 hard5 同成本多 `7321.61`，MDD 改善 `0.03476`。
- A23 cost2x 与 A22 cap70 cost2x 在 2022_2023 完全一致：final、MDD、交易和费用都相同，说明该段 A23 tier 没有新增贡献。
- A22 cap70 同成本 2024 已完成：final `163161.20`、MDD `-27.4756%`、交易 `279`；与 hard5/A23 同成本完全一致，`negative_control_2024_final_spread=0.0`，负控通过。
- A22 cap70 同成本 2025_20260519 已完成：final `332346.10`、MDD `-15.0398%`、交易 `505`；相对 hard5 同成本多 `29450.81`，MDD 改善 `0.01955`。
- A22 cap70 同成本相对 hard5 同成本四段合计 final 多 `37591.85`，4/4 final 不低、4/4 MDD 不差；交易数合计多 `79`，但 2025 段 fee 反而少 `102.81`，说明优势不是简单用多交易换收益。
- A23 cost2x 相对 A22 cost2x 四段合计仅多 `34.93`：2020_2021 多 `321.95`，2022_2023 与 2024 完全一致，2025_20260519 少 `287.02` 且 MDD 略深 `0.00020`。这通过“不系统性弱于 A22”的门槛，但不足以证明 A23 复杂分层值得优先于 A22。
- 证据审计：`segment_metrics.csv` 共 12 行，其中 `K3AC_new_run=8`、`reused_LVV7_A23_cost2x=4`；`cost_fields_ok/has_summary/log_exists/manifest_exists` 全部为 `True`，`exit_status` 全部为 `0`，`log_has_risk=False`。

## 13. 支持证据

- 配置生成脚本、运行脚本、汇总脚本已通过语法检查。
- 子代理 CST9 只读审计确认三组四段来源配置存在，且 A23 普通模板与 cost2x 版本差异只在成本、slippage、name/output_dir 等预期字段，因此 A23 cost2x 可作为 K3AC 正式证据复用。
- 子代理 RSLT 只读复核给出“可采信”：12/12 证据完整、8/8 新跑完成、A23 复用证据日志和 manifest 存在、全部 strict gates 为 true。
- 平台字段复核显示 hard5/A22 派生配置只改变成本口径、名称和输出目录，不改变 hard5 或 A22 的核心策略语义。

## 14. 反对证据

- A23 虽通过相对 hard5 的门槛，但相对 A22 的独立收益只有 `+34.93`，且 2025_20260519 低于 A22 `287.02`、MDD 略深；复杂度收益比不足。
- K3AC 仍依赖既有 A23 cost2x 结果作为 4 段复用证据；本次审计确认其日志、manifest、summary 和 `exit_status=0` 齐全，但结论仍应标注为“8 段新跑 + 4 段复用”。

## 15. 偏差诊断

- 执行偏差：本实验预注册时要求等待 TC8U 释放资源，但实际外部启动命令包含 `ALLOW_CONCURRENT_BACKTEST=1`，与 TC8U 同时运行。最终审计显示 runner.exit 为 `0`，8 个新跑 run log、manifest、summary、`exit_status=0` 齐全，未发现 `Traceback/ERROR/Exception/exit_status非0` 风险标记；因此该偏差需要记录，但不否决本轮 strict formal 证据。
- 结果偏差风险：A22/A23 的 2025 优势仍可能依赖强趋势窗口；K3AC 证明同成本下 A22/A23 优于 hard5，但不能单独证明生产默认可立即切换。

## 16. 研究判断

建议状态：`completed / formal_strict_pass_a22_preferred_a23_marginal`

理由：本实验只处理 XBWS 明确要求的公平成本对照，不改变默认 hard5，也不引入新换手参数。Strict 结果显示 A22 与 A23 均通过相对 hard5 的收益/回撤门槛，2024 负控完全一致；但 A23 相对 A22 只有极小合计增量且 2025 小幅更弱，因此下一轮应优先推进 A22 cap70 的原生实现、审计和 shadow 边界，而不是继续给 A23 增加复杂换手约束。

## 17. 下一步

1. 新增结果决策 `DEC-20260607T125847Z-main-WQ8R`：A22 cap70 升为 hard5 替代首选挑战者；A23 保留为 broad-blowoff 风险解释和备用挑战者。
2. 不直接切换生产默认；先做 A22 原生字段/日志清理、未来函数和配置差异审计。
3. 若继续做交易层修复，应围绕 A22 开启最小 shadow 或 forward/OOS 边界验证；不为 A23 单独新开换手约束 formal。
