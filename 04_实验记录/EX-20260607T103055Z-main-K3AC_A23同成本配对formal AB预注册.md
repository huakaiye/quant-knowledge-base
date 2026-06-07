---
type: 实验记录
ex_id: EX-20260607T103055Z-main-K3AC
rd_id: RD-20260605T133318Z-main-H6V3
status: active
stage: formal_running_partial_hard5_complete_a23_vs_hard5_pass
owner: main
created_at: 2026-06-07T10:30:55Z
updated_at: 2026-06-07T19:58:40+08:00
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: score_hot_soft_budget_cost_pair
decision_ids:
  - DEC-20260607T102206Z-main-XBWS
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
quality_gate: L2_partial_a23_vs_hard5_pass_a22_missing
subagent_call_ids:
  - SUB-20260607T104500Z-main-CST9
subagent_exemption:
tags: [双池轮动, score过热, A23, 同成本配对, cost2x, formal]
---

# A23同成本配对formal AB预注册

## 关联链接

- 研究方向：[[02_研究方向/RD-20260605T133318Z-main-H6V3_双池轮动score过热拥挤机制模块|双池轮动 score 过热拥挤机制模块]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 上游实验：[[04_实验记录/EX-20260607T101347Z-main-VX4J_A23事件归因与成本换手约束只读预注册|VX4J A23 事件归因与成本换手约束]]
- 上游决策：[[05_研究决策/DEC-20260607T102206Z-main-XBWS_A23事件归因后先做同成本配对决策|XBWS A23 先做同成本配对决策]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：A23 高成本失败是不是只是因为它被拿去和普通成本 A22 比，还是在同样高成本下也比 hard5 或 A22 差。  
我们原本预计：如果 A22/A23 的高分软预算真有结构价值，那么在同一个 `cost2x_slip2bps` 成本口径下，它们仍应比 hard5 更好；如果连同成本 hard5 都打不过，说明高分软预算对成本太脆弱。  
实际看到：平台已生成 hard5/A22 两组 8 个 `cost2x_slip2bps` 配置，A23 4 段高成本证据可复用 LVV7；外部已用 `ALLOW_CONCURRENT_BACKTEST=1` 启动 K3AC，当前 hard5 同成本四段已全部完成，A22 同成本正在运行 2020_2021 段。非 strict 汇总显示 `completed_evidence_runs=8/12`、`completed_new_k3ac_runs=4/8`。  
这说明：A23 同成本已经通过相对 hard5 同成本的第一道门：4/4 分段 final 不低、4/4 分段 MDD 不差，四段 final 合计多 `37626.78`。但仍缺全部 A22 同成本补跑，所以不能判断 A23 是否只是 A22 cap70 的同义表达，也不能宣布 K3AC 通过。  
但还不能说明：即使同成本通过，也还不能直接上线；仍需未来函数审计、样本外、负控和可能的换手约束验证。  
下一步要做：等待当前 K3AC runner 补齐 hard5/A22 八段后，运行 strict 汇总；由于本次实际执行与预注册的“等待 TC8U 释放资源”不同，最终必须把并发启动作为执行偏差审计。

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
| 成本、滑点或换手扰动已检查 | 待完成 | 本实验就是同成本扰动正式检查 |
| 已做消融或负控 | 部分通过 | 2024 负控与 hard5/A22/A23 同成本对照 |
| 未只报告最优结果 | 通过 | 固定 hard5/A22/A23 三组，全量汇总 |

证据等级：`L0_configs_validated`

## 10. 子代理调用记录

适配判断：`适合调用`

调用状态：`called_completed`

子代理豁免：

```text
不适用；本轮已调用只读配置审计子代理。
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-20260607T104500Z-main-CST9 | Kierkegaard | SUBTASK-20260607T104500Z-main-CST9_子查_A23同成本配置审计 | gpt-5.3-codex-spark | 2026-06-07T10:45:00Z | R010-A11 hard5、R010-A22 cap70、R010-A23 cost2x 四段配置和策略成本字段 | 无 | 只读字段审计，未修改文件 | 只做路径和字段核对，不判断策略优劣 | A22 使用 A13 风险预算字段表达 cap70，A23 使用 A22 tier 字段；三组语义不同但同成本字段可统一 | 主控已按其建议生成 hard5/A22 cost2x 派生配置，并复用 A23 cost2x 证据 | 支持 K3AC 固定三组同成本配对，不扩 A23 阈值或换手参数 |

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
- 非 strict 汇总已刷新 `summary/formal/summary.json`：`expected_evidence_runs=12`、`completed_evidence_runs=8`、`expected_new_k3ac_runs=8`、`completed_new_k3ac_runs=4`。
- A23 cost2x 相对 hard5 cost2x 为 4/4 final 不低、4/4 MDD 不差；四段 final 差为 `+1141.38`、`+7321.61`、`0.00`、`+29163.79`，合计 `+37626.78`；MDD 差为 `+0.0052`、`+0.0348`、`0.0000`、`+0.0193`。
- 2024 负控段 final、MDD、交易和费用完全一致，`negative_control_2024_final_identical=true`。
- 当前 runner 正在运行 A22 cap70 同成本 2020_2021 段；最近观察进度为 2020-03-04、`8%`、权益 `102315.70`。

## 13. 支持证据

- 配置生成脚本、运行脚本、汇总脚本已通过语法检查。
- 子代理 CST9 只读审计确认三组四段来源配置存在，且 A23 普通模板与 cost2x 版本差异只在成本、slippage、name/output_dir 等预期字段，因此 A23 cost2x 可作为 K3AC 正式证据复用。
- 平台字段复核显示 hard5/A22 派生配置只改变成本口径、名称和输出目录，不改变 hard5 或 A22 的核心策略语义。

## 14. 反对证据

- 当前 hard5/A22 的 8 段同成本正式回测完成 4 段，A22 四段仍缺失，不能判断 A22/A23 是否通过。
- K3AC 仍依赖既有 A23 cost2x 结果的日志和 manifest；strict 汇总前必须确认 A23 4 段也具备 `exit_status=0`、manifest 和 summary。

## 15. 偏差诊断

- 执行偏差：本实验预注册时要求等待 TC8U 释放资源，但实际外部启动命令包含 `ALLOW_CONCURRENT_BACKTEST=1`，与 TC8U 同时运行。该偏差需要在最终 strict 后单独审计；若出现日志缺失、runner 非 0、错误标记或资源争用迹象，不得把本轮结果直接作为 clean formal。
- 结果偏差风险：当前只完成 hard5 两段，A23 相对 hard5 的 partial 优势不能代表四段稳定性，也不能替代 A22 同成本对照。

## 16. 研究判断

建议状态：`active / formal_running_partial_hard5_complete_a23_vs_hard5_pass`

理由：本实验只处理 XBWS 明确要求的公平成本对照，不改变默认 hard5，也不引入新换手参数。当前 A23 已通过相对 hard5 同成本的收益/回撤门槛，但 formal 证据仍缺 A22 四段；并发执行偏差需要最终审计。

## 17. 下一步

1. 继续监控当前 K3AC runner，直到 hard5/A22 8 段全部完成。
2. 运行 `PYTHONIOENCODING=utf-8 python3 scripts/research/summarize_k3ac_a23_paired_cost.py --strict`。
3. 复核每段 `.run.log`、manifest、summary、`exit_status=0` 和 runner.exit；记录并发执行偏差是否影响 formal 可信度。
4. 根据 strict 结果决定 A22/A23 是否还能进入下一轮换手约束研究。
