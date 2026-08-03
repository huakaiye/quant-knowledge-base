---
type: 实验记录
ex_id: EX-20260617T210334Z-main-9VWX
rd_id: RD-20260617T204310Z-main-Q88K
status: completed
stage: engineering_smoke_economic_gate_failed
owner: main
created_at: 2026-06-17T21:03:34Z
updated_at: 2026-06-17T21:24:00Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 核心轮动模块
decision_ids: [DEC-20260617T205354Z-main-W29B, DEC-20260617T212155Z-main-9PRQ]
lit_ids: [LIT-20260617T204327Z-main-6JY4]
idea_ids: []
platform_project: ${LEGACY_QUANT_PLATFORM_ROOT}
config_paths:
  - configs/research/RD-20260617T204310Z-main-Q88K/EX-20260617T210334Z-main-9VWX/
  - scripts/research/generate_q88k_fixed_non_r2_blend_configs.py
  - scripts/research/run_q88k_fixed_non_r2_blend_formal.sh
  - scripts/research/summarize_q88k_fixed_non_r2_blend.py
result_paths:
  - results/v2/research/RD-20260617T204310Z-main-Q88K/EX-20260617T210334Z-main-9VWX/
summary_paths:
  - results/v2/research/RD-20260617T204310Z-main-Q88K/EX-20260617T210334Z-main-9VWX/q88k_fixed_non_r2_blend_summary.json
quality_gate: q88k_fixed_blend_2024_smoke_failed_final_and_mdd
subagent_call_ids: []
subagent_exemption: 当前可用 spawn_agent 工具要求只有用户显式要求子代理/委派/并行 agent 工作时才可调用；本轮用户未显式授权，主控直接执行并记录豁免。
tags: [双池轮动, 核心轮动, 非R方, fixed-blend, 组合级formal, smoke, failed, park, no-live-change]
---

# 固定非R方blend组合级formal

## 关联链接

- 研究方向：[[02_研究方向/RD-20260617T204310Z-main-Q88K_双池轮动顶刊非R方横截面排序|Q88K 双池轮动顶刊非R方横截面排序]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 来源文献或灵感：[[06_文献资料/00_待处理/LIT-20260617T204327Z-main-6JY4_顶刊横截面机器学习与特征压缩综述|顶刊横截面机器学习与特征压缩综述]]
- 前序实验：[[04_实验记录/EX-20260617T204318Z-main-MTEX_非R方日频横截面排序只读面板|MTEX 非R方日频横截面排序只读面板]]
- 前序决策：[[05_研究决策/DEC-20260617T205354Z-main-W29B_非R方日频PLS失败后修订|W29B 非R方日频PLS失败后修订]]
- 产生的决策：[[05_研究决策/DEC-20260617T212155Z-main-9PRQ_固定非R方blend 2024 smoke失败后暂停|9PRQ 固定非R方blend 2024 smoke失败后暂停]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：MTEX 中唯一留下来的线索 `fixed_non_r2_blend`，从只读 close-to-close 对照升级到真实组合回测后，是否还能比当前 hard5 更好。

我们原本预计：如果滞后问题主要来自 `R²` 偏向“已经走平滑的趋势”，那么固定非 R² blend 应该在四段组合回测中至少 `3/4` 段 final 不低于 hard5，并且不能只是随机权重碰巧有效。

实际看到：平台编译通过，16 个研究配置生成成功，2024 工程 smoke 运行完成且 `Q88K诊断 fixed_non_r2_blend启用` 出现在 `logs.jsonl`。但 2024 段最终权益只有 `107562.26`，明显低于 hard5 2024 的 `167005.22`；MDD `-33.78%`，也差于 hard5 的 `-26.99%`。

这说明：MTEX 里 fixed blend 的 close-to-close 均值线索不能迁移到真实组合路径。它不是工程未生效，而是排序后真实持仓路径被 2024 压力段强烈反证。

但还不能说明：所有非 R² 方法都无效；它只说明这组固定权重、60 日特征和 hard5 候选门槛组合不值得继续跑全量 formal。

下一步要做：按 [[05_研究决策/DEC-20260617T212155Z-main-9PRQ_固定非R方blend 2024 smoke失败后暂停|9PRQ]] 暂停 Q88K fixed blend 路线；不扩权重、lookback、随机种子或成本参数。

## 2. 研究背景

本实验属于 [[02_研究方向/RD-20260617T204310Z-main-Q88K_双池轮动顶刊非R方横截面排序|Q88K]]。MTEX 已经证伪 PLS/Ridge 训练压缩：主模型 H5 均值低于 hard5，错位标签还略高于主模型。但 `fixed_non_r2_blend` 在只读面板里四段 H5 超额均值为正，因此 W29B 允许另开实验验证它是否有组合级价值。

这不是后验替换主模型：本实验重新预注册 fixed blend 为主候选，并增加组合回测、成本扰动和随机权重负控。

## 3. 实验前假设

固定非 R² 特征 blend 在不使用 `R²` 作为排序特征的情况下，可以比当前 hard5 更少滞后，并在真实组合回测中保留跨分段收益增量。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：`fixed_non_r2_blend` 四段至少 `3/4` 段 final 不低于 hard5，四段合计 final 高于 hard5。
- 交易行为：换手不能显著高于 hard5；若交易数大幅增加但收益只小幅增加，视为弱证据。
- 风险表现：至少 `3/4` 段 MDD 不差于 hard5；2024 段不能明显恶化。
- 分段表现：2020_2021、2022_2023、2024、2025_20260519 中至少 `3/4` 段通过 final 门槛。
- 负控表现：`fixed_non_r2_blend` 的 final 不低段数和合计 final 必须高于 `random_non_r2_blend`。
- 成本扰动：`fixed_non_r2_blend_cost2x_slip2bps` 至少 `3/4` 段 final 不低于 hard5，或若低于 hard5，不能把主候选写成稳健。

固定口径：

```text
strategy_file = src/strategies/research/etf_dual_pool_r010b_action_ablation.py
main_variant = fixed_non_r2_blend
negative_control = random_non_r2_blend
cost_control = fixed_non_r2_blend_cost2x_slip2bps
hard5_gate = 原 hard5 score 仍要求 0 < score < 5
ranking_score = fixed_non_r2_blend 的横截面 z-score 加权和
lookback = 60 日
stock_sum = 1
defense/execution = 沿用 LM3D/RNEU/MCWS 同口径 R010B A2 + B3/tiered-v2 配置
```

固定特征权重沿用 MTEX：

```text
ret5 0.08, ret10 0.08, ret20 0.16, ret60 0.08,
ret5_minus_ret20_q 0.14, ret20_minus_ret60_q 0.08,
slope25_ann 0.18, trend_eff20 0.14, up_share20 0.10,
vol20 -0.10, downside_vol20 -0.08,
dd20 0.12, dd60 0.08, near_high60 0.04,
ma_gap20 0.05, ma_gap60 0.03,
volume_ratio -0.04, money20_log 0.04
```

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| hard5_baseline | 当前核心排序基准；可复跑，也可用既有 hard5 四段数作为主比较。 | configs/research/RD-20260617T204310Z-main-Q88K/EX-20260617T210334Z-main-9VWX/hard5_baseline/ |
| fixed_non_r2_blend | 主候选，固定非 R² 特征 blend。 | configs/research/RD-20260617T204310Z-main-Q88K/EX-20260617T210334Z-main-9VWX/fixed_non_r2_blend/ |
| random_non_r2_blend | 固定随机权重非 R² blend，检验是不是任意多特征组合都能赢。 | configs/research/RD-20260617T204310Z-main-Q88K/EX-20260617T210334Z-main-9VWX/random_non_r2_blend/ |
| fixed_non_r2_blend_cost2x_slip2bps | 主候选成本扰动，佣金 2x + 固定滑点 2bps。 | configs/research/RD-20260617T204310Z-main-Q88K/EX-20260617T210334Z-main-9VWX/fixed_non_r2_blend_cost2x_slip2bps/ |

## 6. 竞争性解释

即使结果符合预期，也可能是：

- fixed blend 把 hard5 过滤后的候选重新排序，收益来自少数主题行情，而不是普适降低滞后。
- 组合级 formal 中的成交价格、换手和防御模块交互与 MTEX close-to-close 标签不同，可能放大或抹平线索。
- fixed blend 权重来自同一轮 MTEX 对照，虽然本轮重新预注册，但仍有后验选择风险。
- 随机权重负控若也表现良好，说明不是特定经济权重有效，而是候选池或市场状态本身驱动。
- money20_log 在策略侧使用历史成交额均值，不使用当前日完整成交额；这比 MTEX 更保守，但会造成口径差异。

## 7. 证伪条件

出现以下情况，本假设不通过：

- 主候选 `fixed_non_r2_blend` 完成四段后，final 不低于 hard5 的分段少于 `3/4`。
- 主候选四段合计 final 不高于 hard5。
- 主候选 MDD 不差分段少于 `3/4`，或 2024 段 MDD 明显恶化。
- 主候选换手显著高于 hard5，且收益增量不足以覆盖换手和成本。
- `random_non_r2_blend` 的 final 不低段数或合计 final 不弱于主候选。
- `fixed_non_r2_blend_cost2x_slip2bps` 不满足 `3/4` final 不低，且主候选增量主要来自低成本假设。
- 2024 smoke 出现脚本错误、特征不可用、候选数异常为 0、日志无 `Q88K诊断` 或交易产物缺失，则先修工程，不进入 formal 结论。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 预检查通过 | 策略评分器只用 `_history_wide` 历史日线、当前价格和当日成交量投影；不读取未来收益。 |
| 信号生成和成交价格不存在同 bar 泄漏 | 有边界 | 与既有 hard5 回测同口径，当前价参与排序，执行由平台引擎撮合；不是 13:10 独立事件策略。 |
| 股票池或 ETF 池不存在未来成分泄漏 | 有边界 | 沿用双池轮动静态池 + 动态池配置；本轮只比较同一框架下排序器，不声明完整成分无偏。 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 不使用财务、宏观或估值字段。 |
| Shadow 或观察信号未被当成默认交易信号 | 通过 | `scorer_type` 默认关闭，只在研究配置中显式启用；不改实盘配置。 |

负控或错位检查：

- `random_non_r2_blend` formal 负控。
- MTEX 中已有 `shuffled_label_pls1`、`random_same_day`、`shift_prev1_same_code` 只读负控，作为解释边界继续引用。
- 成本扰动 `fixed_non_r2_blend_cost2x_slip2bps`。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | 固定主候选、随机负控、成本扰动、四段和失败门槛；不看结果后改权重或窗口。 |
| 样本内、验证集、样本外划分清楚 | 有边界 | fixed blend 无训练集；权重来自 MTEX 对照线索，因此本轮是确认实验。 |
| 邻近参数敏感性合理 | 未做 | 本轮禁止 alpha、权重、lookback 网格；通过后再另开邻域。 |
| 成本、滑点或换手扰动已检查 | 预注册 | 生成 cost2x/slip2bps 变体并统计交易数。 |
| 已做消融或负控 | 预注册 | random_non_r2_blend formal + MTEX 只读负控。 |
| 未只报告最优结果 | 通过 | 主候选固定为 `fixed_non_r2_blend`；随机和成本对照必须同步披露。 |

证据等级：`L1_engineering_smoke_economic_fail`。只完成 2024 smoke，不声明四段 formal 结论，但 2024 作为预注册风险关键段已经足以阻断本候选继续全量。

## 10. 子代理调用记录

适配判断：`适合调用，但系统工具边界禁止本轮调用`

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：当前可用 spawn_agent 工具要求只有用户显式要求子代理/委派/并行 agent 工作时才可调用；本轮用户未显式授权；主控：main；时间：2026-06-17T21:03:00Z
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 无 | 无 | 无 | 无 | 无 | 无 | 无 | 无 | 系统工具授权边界，不代表任务不适合子代理 | 主控需自行复核平台代码、配置、日志和 summary | 已复核编译、配置、`summary.json`、`logs.jsonl` 和汇总脚本输出 | 支持 9PRQ 暂停本候选 |

台账行：不新增子代理调用台账；正文记录系统工具授权豁免。

## 11. 执行记录

### 平台配置

```text
scripts/research/generate_q88k_fixed_non_r2_blend_configs.py
scripts/research/run_q88k_fixed_non_r2_blend_formal.sh
scripts/research/summarize_q88k_fixed_non_r2_blend.py
configs/research/RD-20260617T204310Z-main-Q88K/EX-20260617T210334Z-main-9VWX/
```

### 运行命令

已执行编译：

```bash
cd ${QUANT_PLATFORM_ROOT}
PYTHONPATH=src python3 -m py_compile src/strategies/research/etf_dual_pool_r010b_action_ablation.py scripts/research/generate_q88k_fixed_non_r2_blend_configs.py scripts/research/summarize_q88k_fixed_non_r2_blend.py scripts/research/analyze_core_non_r2_cross_section_ranker.py
bash -n scripts/research/run_q88k_fixed_non_r2_blend_formal.sh
```

生成配置：

```bash
cd ${QUANT_PLATFORM_ROOT}
PYTHONPATH=src python3 scripts/research/generate_q88k_fixed_non_r2_blend_configs.py
```

2024 工程 smoke：

```bash
cd ${QUANT_PLATFORM_ROOT}
PYTHONUNBUFFERED=1 bash scripts/research/run_rneu_segment.sh configs/research/RD-20260617T204310Z-main-Q88K/EX-20260617T210334Z-main-9VWX/fixed_non_r2_blend/q88k_fixed_non_r2_blend_2024.json q88k_fixed_non_r2_blend_2024_smoke
```

四段 formal：

```bash
cd ${QUANT_PLATFORM_ROOT}
PYTHONUNBUFFERED=1 bash scripts/research/run_q88k_fixed_non_r2_blend_formal.sh fixed_non_r2_blend
PYTHONUNBUFFERED=1 bash scripts/research/run_q88k_fixed_non_r2_blend_formal.sh random_non_r2_blend
PYTHONUNBUFFERED=1 bash scripts/research/run_q88k_fixed_non_r2_blend_formal.sh fixed_non_r2_blend_cost2x_slip2bps
PYTHONPATH=src python3 scripts/research/summarize_q88k_fixed_non_r2_blend.py
```

本轮未继续执行四段 formal。原因：2024 smoke 是完整 2024 段回测，已经严重违反预注册“2024 段不能明显恶化”的风险门槛；继续跑其余分段只会增加资源消耗，不能改变本候选不进入 promote 的判断。

### 可见进度与日志

- 是否过程可见：`是`
- 日志路径：`results/v2/research/RD-20260617T204310Z-main-Q88K/EX-20260617T210334Z-main-9VWX/fixed_non_r2_blend/q88k_fixed_non_r2_blend_2024_smoke.run.log`
- 查看进度命令：前台直接看终端；运行后查看各 `*.run.log`
- 异常判断：任一段 exit code 非 0、缺 `summary.json`、缺交易产物或日志无 `Q88K诊断`，均视为工程失败
- 后台回测豁免：无；本轮默认前台可见运行

```text
无后台或静默运行。
```

### 结果路径

```text
results/v2/research/RD-20260617T204310Z-main-Q88K/EX-20260617T210334Z-main-9VWX/
```

关键产物：

```text
results/v2/research/RD-20260617T204310Z-main-Q88K/EX-20260617T210334Z-main-9VWX/fixed_non_r2_blend/2024/c32842bec0384d729477c688d013aa77/summary.json
results/v2/research/RD-20260617T204310Z-main-Q88K/EX-20260617T210334Z-main-9VWX/fixed_non_r2_blend/2024/c32842bec0384d729477c688d013aa77/logs.jsonl
results/v2/research/RD-20260617T204310Z-main-Q88K/EX-20260617T210334Z-main-9VWX/q88k_fixed_non_r2_blend_summary.json
```

## 12. 实际观察

| 指标 | hard5 2024 | fixed_non_r2_blend 2024 smoke | 变化 | 解释 |
| --- | ---: | ---: | ---: | --- |
| final | `167005.22` | `107562.26` | `-59442.96` | 明显低于基准，且差距足以阻断后续 formal。 |
| MDD | `-26.99%` | `-33.78%` | 约 `-6.79pp` | 回撤明显恶化，违反 2024 风险门槛。 |
| 交易数 | `281` | `278` | `-3` | 不是因为换手大幅增加导致费用拖累，而是选标路径本身更差。 |
| 运行状态 | 既有基准 | exit code `0` | 工程通过 | `logs.jsonl` 有 `Q88K诊断 fixed_non_r2_blend启用`，特征 ETF 数约 `20-40`。 |

汇总脚本输出：

```text
fixed_non_r2_blend 2024 final=107562.26 diff=-59442.96 mdd=-33.78% trades=278
fixed_non_r2_blend final不低: 0/1
fixed_non_r2_blend MDD不差: 0/1
```

## 13. 支持证据

- 平台研究评分器编译通过。
- `generate_q88k_fixed_non_r2_blend_configs.py` 生成 `16` 个配置，主候选、随机负控、成本扰动和 hard5 baseline 字段检查正确。
- 2024 smoke exit code `0`，生成 `summary.json`、`equity_curve.csv`、`trades.csv`、`orders.json`、`logs.jsonl` 等完整产物。
- `logs.jsonl` 显示 fixed blend 分支确实启用，不是回退到 hard5。

## 14. 反对证据

- 2024 final `107562.26`，低于 hard5 `167005.22`，差额 `-59442.96`。
- 2024 MDD `-33.78%`，差于 hard5 `-26.99%`。
- 交易数 `278` 接近 hard5 `281`，说明失败不是“换手太高但信号对”的简单成本问题。
- MTEX 中 fixed blend 的 H5 均值线索，在真实组合路径中没有保住。

## 15. 偏差诊断

实验前预测和实际结果最不一致的地方是：MTEX close-to-close H5 均值在 2024 为正超额，但组合级 2024 真实路径大幅落后。可能原因：

- H5 事件均值没有反映连续持仓、换仓顺序和防御模块交互。
- fixed blend 可能挑中了短期看似有弹性、但在 2024 趋势延续或回撤阶段更容易反复切换的 ETF。
- 只读面板的同日候选 Top1 与组合回测中的持仓延续、现金、防御仓位和执行价格不是同一个目标函数。
- `money20_log` 在策略侧用历史成交额而非完整当日成交额，口径更保守，但差距过大，不足以解释全部失败。

## 16. 研究判断

建议状态：`park`

理由：2024 是预注册中的关键压力段，主候选不仅没有改善收益，反而 final 大幅少 `59442.96`、MDD 恶化约 `6.79pp`。工程已经证明 fixed blend 生效，因此这是经济假设失败，不是运行失败。继续跑四段、成本扰动和随机负控不能把本候选提升为可用路线。

## 17. 下一步

- 新增 [[05_研究决策/DEC-20260617T212155Z-main-9PRQ_固定非R方blend 2024 smoke失败后暂停|9PRQ]]，暂停 Q88K fixed blend 路线。
- 不继续运行 `fixed_non_r2_blend` 四段 formal。
- 不扩 fixed blend 权重、lookback、随机 seed、成本参数或候选池过滤。
- 后续若继续“降低滞后”，应转向不同机制，而不是继续在日频非 R² blend 上调参。
