---
type: 实验记录
ex_id: EX-20260618T130636Z-main-28Z4
rd_id: RD-20260605T115651Z-main-DEF0
status: completed
stage: readonly_completed_failed_no_action
owner: main
created_at: 2026-06-18T13:06:36Z
updated_at: 2026-06-18T13:15:47Z
strategy_id: R010-B4
module_type: defense_attribution
decision_ids:
  - DEC-20260618T131519Z-main-UR2G
lit_ids: []
idea_ids: []
platform_project: ${LEGACY_QUANT_PLATFORM_ROOT}
config_paths:
  - scripts/research/analyze_b3_state_only_extreme_gap.py
  - results/v2/research/R010-B4/EX-20260611T060247Z-main-592F/summary/formal/segment_compare.csv
result_paths:
  - results/v2/research/R010-B4/EX-20260618T130636Z-main-28Z4/state_only_extreme_gap/
summary_paths:
  - results/v2/research/R010-B4/EX-20260618T130636Z-main-28Z4/state_only_extreme_gap/summary.json
  - results/v2/research/R010-B4/EX-20260618T130636Z-main-28Z4/state_only_extreme_gap/event_summary.csv
  - results/v2/research/R010-B4/EX-20260618T130636Z-main-28Z4/state_only_extreme_gap/segment_summary.csv
  - results/v2/research/R010-B4/EX-20260618T130636Z-main-28Z4/state_only_extreme_gap/random_control_summary.csv
quality_gate: readonly_gate_failed
subagent_call_ids:
  - SUB-EXEMPT-20260618T130701Z-main-28Z4
subagent_exemption: "当前多代理工具要求用户显式授权子代理/委派/并行 agent；本轮用户未显式授权；主控：main；时间：2026-06-18T13:07:01Z"
tags:
  - B3
  - tiered-v2
  - state-only-extreme
  - low-lag
  - readonly-attribution
---

# B3 state-only extreme触发缺口归因

## 关联链接

- 研究方向：[[02_研究方向/RD-20260605T115651Z-main-DEF0_双池轮动防御模块|RD-20260605T115651Z-main-DEF0 双池轮动防御模块]]
- 上游实验：[[04_实验记录/EX-20260611T060247Z-main-592F_B3弱势持久确认缩短负控formal|EX-20260611T060247Z-main-592F B3弱势持久确认缩短负控formal]]
- 上游决策：[[05_研究决策/DEC-20260618T124615Z-main-7JGR_B3弱势持久确认缩短formal失败后不推广|DEC-20260618T124615Z-main-7JGR B3弱势持久确认缩短formal失败后不推广]]
- 产生的决策：[[05_研究决策/DEC-20260618T131519Z-main-UR2G_B3 state-only extreme缺口归因失败后不动作化|DEC-20260618T131519Z-main-UR2G B3 state-only extreme缺口归因失败后不动作化]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：原 tiered-v2 为了少误判，要求弱势持续确认；但这种确认会带来滞后。我们不再调确认天数，而是只读检查“已经出现极端弱势状态、但门控还没激活”的日期，看看这些日期之后是否真的更容易发生损失或回撤。

我们原本预计：如果低滞后缺口真实存在，state-only extreme 日期之后的未来 5/10/20 日收益和路径回撤应明显差于普通非极端日期，并且不能被前后一日错位或随机抽样复制。

实际看到：事件覆盖足够，919 个 state-only extreme 日期覆盖 4 个 formal 分段；但未来 10 日 DD5 率为 22.85%，低于 quiet control 的 24.91%，未来 10 日路径最差收益均值也没有更差。分段只有 2/4 更差，前移一日错位负控反而更强。

这说明：state-only extreme 本身不是一个稳定的低滞后防御缺口。原 B3 持久确认带来的滞后，至少在这个口径下更像必要过滤，而不是简单可以绕过的缺陷。

但还不能说明：不能否定所有低滞后研究，也不能否定 B3/tiered-v2 本身；它只否定“直接用 state-only extreme 绕过持久确认”的动作化方向。

下一步要做：不进入动作 smoke，不 shadow，不 observe，不改实盘；若继续低滞后防御研究，需要换独立机制，不能在本事件口径上继续扫阈值、cap 或确认天数。

## 2. 研究背景

本实验属于 [[02_研究方向/RD-20260605T115651Z-main-DEF0_双池轮动防御模块|RD-20260605T115651Z-main-DEF0]]。[[04_实验记录/EX-20260611T060247Z-main-592F_B3弱势持久确认缩短负控formal|592F]] 已证明简单把 B3 弱势持久确认从 5 天缩短到 3 天不能超过原 tiered-v2，且 [[05_研究决策/DEC-20260618T124615Z-main-7JGR_B3弱势持久确认缩短formal失败后不推广|7JGR]] 已暂停该路线。

本轮改为检查另一类更早信号：`state-only extreme`。它指的是极端弱势状态已被当日可见字段识别，但原 persistence/tiered 动作尚未 active 的日期。

## 3. 实验前假设

在 B3/tiered-v2 原始四段 formal 路径中，`state-only extreme` 日期相对普通非极端日期具有更高的未来路径回撤风险；这种风险如果稳定存在，才有资格进入后续低滞后动作 smoke。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：`state_only_extreme` 的未来 10 日路径回撤达到 5% 的比例显著高于 quiet control，未来 10/20 日路径最差收益均值更低。
- 交易行为：这些事件应主要出现在原 gate active 之前或 gate 未触发的缺口区间，而不是完全重合于已有防御动作。
- 风险表现：至少 3/4 分段中，`state_only_extreme` 相对 quiet control 有更高 `future_dd5_10d_rate` 或更差 `future_min_ret_10d_mean`。
- 分段表现：2025_20260519 不能靠牺牲强趋势解释为通过；若 2025 state-only extreme 之后仍多为趋势延续，则不能进入动作 smoke。
- 负控表现：`shift_prev1`、`shift_next1` 和同分段随机同数量抽样不能复制或强于主事件表现。

预注册只读通过门槛：

- 事件覆盖：`state_only_extreme_days >= 20`，且至少覆盖 3 个 formal 分段。
- 风险提升：全样本 `state_only_extreme.future_dd5_10d_rate - quiet.future_dd5_10d_rate >= 0.08`，或 `future_min_ret_10d_mean` 至少差 1.0 个百分点。
- 分段稳定：至少 3/4 分段满足 state-only extreme 比 quiet control 更差。
- 负控约束：前后一日错位和随机同数量抽样不能同时达到或超过主事件风险提升。
- 实盘边界：本实验不允许产生 `promote`、`shadow`、`observe` 或默认交易开关。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| 原 B3QC tiered-v2 四段 formal | 当前防御基准，只读取日志和 equity，不新增交易 | `${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/R010-B4/EX-20260611T060247Z-main-592F/summary/formal/segment_compare.csv` |
| quiet control | 非极端、非 active、非 raw 弱势日期，用于衡量普通环境风险 | `state_only_extreme_daily_panel.csv` |
| gate active/pass 日期 | 检查 state-only 是否只是已知防御动作的重复 | `event_summary.csv` |
| shift_prev1 / shift_next1 | 错位负控，检查事件日期是否只是滞后标签或趋势簇 | `event_summary.csv` |
| random same-count | 随机同数量负控，检查是否只是坏年份抽样偏差 | `random_control_summary.csv` |

## 6. 竞争性解释

即使结果符合预期，也可能是：

- 未来标签污染：极端状态定义如果依赖了未来路径，就会把结果提前泄漏到信号中。
- 趋势簇偏差：state-only extreme 可能只是集中出现在 2024/2025 某些波动簇，随机同数量抽样也可能同样差。
- 强趋势误伤：2025 强趋势中极端状态可能只是短暂换手噪音，提前降仓会损害收益。
- 已有门控重复：若 state-only 日期几乎都紧邻 gate active，新增规则可能只是重复原动作。
- 日志字段缺失：若历史 `logs.jsonl` 无法完整还原当日字段，结论只能降级为探索观察。

## 7. 证伪条件

出现以下情况，本假设不通过：

- `state_only_extreme_days < 20` 或覆盖少于 3 个 formal 分段。
- 全样本风险提升小于预注册门槛，且 3/4 分段稳定性不成立。
- `shift_prev1`、`shift_next1` 或随机同数量抽样表现等于或强于主事件。
- 2025_20260519 中 state-only extreme 之后主要是趋势延续，或提前动作会明显误伤强趋势。
- 事件字段无法从原始日志稳定解析，导致 `state_only_extreme` 定义不可复现。

本次触发证伪：风险提升、分段稳定、错位负控和随机负控均未通过。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 通过 | state-only extreme 只使用 `logs.jsonl` 当日 ACTION payload 中的 `median_ret`、`ma20_breadth`、`r010b3_top5_filter_exhausted_count` 和 persistence/tiered 状态；未来收益只作标签 |
| 信号生成和成交价格不存在同 bar 泄漏 | 通过 | 本实验不生成成交，只读归因；后续动作化被本实验否决 |
| 股票池或 ETF 池不存在未来成分泄漏 | 沿用原 formal 路径 | 读取原 B3QC formal run_dir，不新增池构造 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | B3/tiered-v2 主要使用 ETF 动量、广度、斜率和组合日志字段 |
| Shadow 或观察信号未被当成默认交易信号 | 通过 | summary 中 `promote_allowed=false`、`shadow_allowed=false`、`observe_allowed=false`、`default_trade_change_allowed=false` |

负控或错位检查：

- `shift_prev1_future_dd5_h10_rate=24.65%`，高于主事件 22.85%，且 `shift_prev1_stronger=true`。
- 随机同数量 500 次抽样的 DD5 均值为 24.42%，也高于主事件 22.85%；主事件 DD5 只处在随机分布 4.2% 分位。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | 本轮没有参数搜索，只做事件归因；通过门槛已在执行前写入 |
| 样本内、验证集、样本外划分清楚 | 通过 | 输出四段 formal 分段 summary |
| 邻近参数敏感性合理 | 不适用 | 本轮不扫阈值、cap、confirm 天数 |
| 成本、滑点或换手扰动已检查 | 不适用 | 本轮不生成交易 |
| 已做消融或负控 | 通过 | 输出 shift 和 random 控制 |
| 未只报告最优结果 | 通过 | 输出全样本、分段、负控和 top events；未筛选候选 |

证据等级：`L1 只读归因失败`

## 10. 子代理调用记录

适配判断：`适合调用`

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：当前多代理工具要求用户显式授权子代理/委派/并行 agent；本轮用户未显式授权；主控：main；时间：2026-06-18T13:07:01Z
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-EXEMPT-20260618T130701Z-main-28Z4 | 无 | SUBTASK-28Z4-STATE-ONLY-EXTREME-EXEMPT | 无 | 2026-06-18T13:07:01Z | README、入口页、方法论、592F/7JGR链路、平台日志路径 | 本实验预注册、脚本、结果回填 | WSL 只读分析脚本 | 豁免只说明工具边界，不提供策略有效性证据 | 缺少独立复核 | 主控复核 summary/event/segment/random 输出 | 支持 UR2G：不动作化、不 shadow、不 observe |

台账行：已同步 `01_台账/子代理调用台账.csv`。

## 11. 执行记录

### 平台配置

```text
${LEGACY_QUANT_PLATFORM_ROOT}/scripts/research/analyze_b3_state_only_extreme_gap.py
输入：${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/R010-B4/EX-20260611T060247Z-main-592F/summary/formal/segment_compare.csv
```

### 运行命令

```bash
cd /mnt/e/量化平台_V1.4.0
mkdir -p results/v2/research/R010-B4/EX-20260618T130636Z-main-28Z4/state_only_extreme_gap
PYTHONUNBUFFERED=1 PYTHONPATH=src python3 scripts/research/analyze_b3_state_only_extreme_gap.py \
  --segment-compare results/v2/research/R010-B4/EX-20260611T060247Z-main-592F/summary/formal/segment_compare.csv \
  --output-dir results/v2/research/R010-B4/EX-20260618T130636Z-main-28Z4/state_only_extreme_gap \
  2>&1 | tee results/v2/research/R010-B4/EX-20260618T130636Z-main-28Z4/state_only_extreme_gap/run.log
```

### 可见进度与日志

- 是否过程可见：是，脚本打印 4 个分段 run_dir、action_rows、main_metrics、quality_gates 和 summary 路径。
- 日志路径：`${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/R010-B4/EX-20260618T130636Z-main-28Z4/state_only_extreme_gap/run.log`
- 查看进度命令：`tail -f results/v2/research/R010-B4/EX-20260618T130636Z-main-28Z4/state_only_extreme_gap/run.log`
- 异常判断：无异常；重跑后无 pandas warning。
- 后台回测豁免：不适用；本轮为只读分析脚本，不是回测，不后台运行。

### 结果路径

```text
${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/R010-B4/EX-20260618T130636Z-main-28Z4/state_only_extreme_gap/summary.json
${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/R010-B4/EX-20260618T130636Z-main-28Z4/state_only_extreme_gap/event_summary.csv
${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/R010-B4/EX-20260618T130636Z-main-28Z4/state_only_extreme_gap/segment_summary.csv
${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/R010-B4/EX-20260618T130636Z-main-28Z4/state_only_extreme_gap/random_control_summary.csv
${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/R010-B4/EX-20260618T130636Z-main-28Z4/state_only_extreme_gap/top_state_only_extreme_events.csv
```

## 12. 实际观察

| 指标 | 基准 | 本次 | 变化 | 解释 |
| --- | --- | --- | --- | --- |
| state_only_extreme_days | 预注册门槛 >=20 | 919，覆盖 4 段 | 覆盖通过 | 事件不是太少导致失败 |
| future_dd5_10d_rate | quiet control 24.91% | state-only 22.85% | -2.06pp | 主事件没有更高未来回撤风险 |
| future_min_ret_10d_mean | quiet control -3.224% | state-only -3.115% | +0.110pp | 主事件路径最差收益反而略好 |
| segments_worse_than_quiet | 需要 >=3/4 | 2/4 | 未通过 | 2020_2021、2022_2023 更好；2024、2025 较弱 |
| shift_prev1 | 主事件 22.85% | 24.65% | 负控更强 | 事件日期没有独立时点优势 |
| random same-count | 主事件 22.85% | 随机均值 24.42%，p95 25.57% | 未通过 | 主事件弱于随机同数量抽样 |

分段结果：

| 分段 | state-only n | quiet n | DD5 lift | future_min_ret_10d_delta | 判断 |
| --- | ---: | ---: | ---: | ---: | --- |
| 2020_2021 | 271 | 202 | -2.86pp | +0.443pp | 不支持 |
| 2022_2023 | 317 | 138 | -9.30pp | +0.247pp | 不支持 |
| 2024 | 143 | 77 | +4.70pp | -0.784pp | 支持但单段 |
| 2025_20260519 | 188 | 133 | +2.70pp | +0.046pp | 弱支持，不足以动作化 |

## 13. 支持证据

- `parse_pass=true`，四段日志共 1542 行 ACTION payload 可解析，run_dir 全部来自原 B3QC tiered-v2 formal。
- `coverage_pass=true`，state-only extreme 覆盖 919 天和 4 个分段。
- top events 能找到 2024-01-22/23/24 等真实坏路径，说明事件口径确实能抓到个别风险日。

## 14. 反对证据

- `risk_lift_pass=false`：全样本 DD5 lift 为 -2.06pp，未来路径最差收益均值也没有更差。
- `segment_pass=false`：只有 2/4 分段更差，低于预注册 3/4。
- `shift_control_pass=false`：前移一日错位负控比主事件更强。
- `random_control_pass=false`：随机同数量抽样的 DD5 均值高于主事件，主事件只处于随机分布 4.2% 分位。

## 15. 偏差诊断

失败不是因为事件数不足，而是因为极端状态太宽泛。它可以覆盖 2024 年 1 月这类真实坏路径，但在 2020_2021 和 2022_2023 中并不比普通日更危险。2025_20260519 也只是 DD5 率略高，路径最差收益均值并没有更差，不足以支持提前降仓。前移一日负控更强，说明事件时点还存在趋势簇/日期对齐问题。

## 16. 研究判断

建议状态：`park`

理由：state-only extreme 缺口归因未通过预注册门槛，不进入动作 smoke；不得据此绕过 B3 持久确认，不 shadow、不 observe、不改实盘。该字段最多作为诊断标签保留。

## 17. 下一步

不要继续在 `state-only extreme` 上扫阈值、cap 或确认天数。若继续寻找低滞后防御，应换独立机制，例如真实组合层损失暴露、事件簇 hazard 或新数据源；进入前仍需新开预注册实验并设置错位/随机负控。
