---
type: 实验记录
ex_id: EX-20260618T141233Z-main-M3VC
rd_id: RD-20260614T115209Z-main-MCYG
status: completed
stage: readonly_completed_strict_random_failed_revise_no_action
owner: main
created_at: 2026-06-18T14:12:33Z
updated_at: 2026-06-18T14:21:51Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 防御模块事前暴露管理层
decision_ids:
  - DEC-20260618T142119Z-main-NWY3
lit_ids: []
idea_ids: []
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths:
  - scripts/research/analyze_m3vc_episode_age_stability_readonly.py
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260617T212938Z-main-LJQ7/ljq7_action_panel.csv
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T135410Z-main-CJC9/cjc9_test_predictions.csv
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T135410Z-main-CJC9/cjc9_oos_metrics.csv
result_paths:
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T141233Z-main-M3VC/
summary_paths:
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T141233Z-main-M3VC/summary.json
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T141233Z-main-M3VC/stability_summary.csv
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T141233Z-main-M3VC/random_control_summary.csv
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T141233Z-main-M3VC/bootstrap_summary.csv
quality_gate: strict_random_failed_after_decluster_near_miss
subagent_call_ids:
  - SUB-EXEMPT-20260618T141233Z-main-M3VC
subagent_exemption: 当前多代理工具要求用户显式授权子代理/委派/并行 agent；本轮用户未显式授权。
tags:
  - 非R方
  - 低滞后
  - 事件簇
  - hazard
  - 稳定性审计
  - 错位负控
  - 随机负控
  - 只读
---

# episode_age hazard稳定性与错位簇审计

## 关联链接

- 研究方向：[[02_研究方向/RD-20260614T115209Z-main-MCYG_双池轮动动量崩溃事前暴露管理|RD-20260614T115209Z-main-MCYG 动量崩溃事前暴露管理]]
- 策略档案：
- 来源实验：[[04_实验记录/EX-20260618T135410Z-main-CJC9_组合层事件簇hazard只读面板|EX-20260618T135410Z-main-CJC9 组合层事件簇hazard只读面板]]
- 来源决策：[[05_研究决策/DEC-20260618T140056Z-main-FDSQ_事件簇hazard只读接近但未通过后修订|DEC-20260618T140056Z-main-FDSQ 事件簇hazard只读接近但未通过后修订]]
- 产生的决策：[[05_研究决策/DEC-20260618T142119Z-main-NWY3_episode_age稳定性审计严格随机未过后修订|DEC-20260618T142119Z-main-NWY3 episode_age稳定性审计严格随机未过后修订]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：CJC9 里最接近可用的 `episode_age_hazard`，到底是在识别“风险暴露生命周期变老后容易崩”，还是只是同一段行情连续日期聚在一起造成的假象。  
我们原本预计：如果它是真机制，那么把连续日期去重、按 episode 聚合、做 block/bootstrap、拿前后错位分数和随机分数比较后，2025 的高/低风险分离仍应保留。  
实际看到：`readonly_pass=false`，但不是普通失败。raw 2025 top20 `bad10` 提升 `+36.01pct`、低风险桶降低 `-45.81pct`；去连续日期和 separated bucket 后方向仍在；block bootstrap 5% 分位仍为 `+15.33pct`；组件拆解也不靠单一字段。但去连续日期和 episode 聚合后样本太小，同规模随机分位能复制主分数，严格随机负控失败。  
这说明：`episode_age_hazard` 是目前最接近的非 R 方低滞后线索，但还没有足够证据升级为动作、shadow 或 observe。  
但还不能说明：不能说明它已经超越 R 方/ K3YL，也不能说明可以交易化；它只能说明“状态生命周期”比固定经济损失排序更值得继续审计。  
下一步要做：把方向收敛到事件级/episode级外部验证或扩大样本验证，禁止在本结果上继续扫权重、窗口或 top 比例。

## 2. 研究背景

本实验属于 [[02_研究方向/RD-20260614T115209Z-main-MCYG_双池轮动动量崩溃事前暴露管理|MCYG 动量崩溃事前暴露管理]]。前序 CJC9 没有通过总门槛，但给出一个明确线索：`episode_age_hazard` 在 2025_20260519 的 AUC 达 `0.7896`，top20 `bad10` 提升 `+36.01pct`，低风险桶 `bad10` 降低 `-45.81pct`，且高分桶没有误伤趋势继续。

问题在于，2025 的 shift_prev1/shift_next1 也很强，说明信号可能来自日期簇或状态自相关，而不是可迁移机制。本轮不优化策略，只审计 CJC9 近候选的可信度。

## 3. 实验前假设

固定 CJC9 已生成的 `episode_age_hazard` 分数后，如果它反映的是 A1/overheat/front_any/unfavorable 持续时间所对应的真实风险生命周期，那么在去连续日期、按 episode 聚合、block bootstrap、错位对照和组件贡献拆解后，2025 的高风险/低风险分离仍应明显强于错位与随机对照。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：2025_20260519 主分数原始 top20 `bad10` 提升不低于 `+20pct`，或低风险桶 `bad10` 降低不低于 `-20pct`；去连续日期或 episode 聚合后仍有同方向分离。
- 交易行为：无交易行为。本实验只读，不生成策略配置，不进入 smoke/formal，不产生 shadow、observe 或实盘信号。
- 风险表现：高 `episode_age_hazard` 桶未来 H10 坏路径与下尾损失高于本段基准；低桶坏路径低于本段基准。
- 分段表现：2025 是硬门槛；2022_2023 与 2024 只作为稳定性参考，不允许因为它们表现弱而后验调权。
- 负控表现：shift_prev1、shift_next1、随机同规模、block/bootstrap 的 95% 分位不能复制主分数的 2025 强度。
- 组件贡献：不能完全依赖单一偶然组件；A1/overheat/front_any/unfavorable/confirmed_state 持续时间中至少两个组件或 leave-one-out 版本保留同方向分离。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| LJQ7 action panel | 重建 A1 episode 与事件簇边界 | `${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260617T212938Z-main-LJQ7/ljq7_action_panel.csv` |
| CJC9 predictions | 固定主分数、错位分数和未来标签 | `${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T135410Z-main-CJC9/cjc9_test_predictions.csv` |
| CJC9 OOS metrics | 复核原始分段指标 | `${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T135410Z-main-CJC9/cjc9_oos_metrics.csv` |
| no-adjacent-day sample | 去掉连续日期簇后看信号是否仍成立 | 脚本内固定 `gap_days=5` |
| episode-level aggregate | 按 A1 连续 episode 聚合，避免一天一票放大 | 脚本内从 LJQ7 重建 |
| shift_prev1 / shift_next1 | 日期错位负控 | CJC9 已输出固定分数 |
| random same support | 同规模随机 top 桶负控 | 脚本内固定 seed `20260618` |
| block bootstrap | 连续日期块重抽样稳健性 | 脚本内固定 seed `20260618` |

## 6. 竞争性解释

即使结果符合预期，也可能是：

- 2025 的高坏路径基准率太高，少数连续日期主导 top20 分桶。
- `episode_age_hazard` 只是 overheat 或 front_any 的持久化版本，没有新增机制。
- 去连续日期后样本变少，结果可能受抽样顺序影响。
- episode 聚合标签使用未来 H10 坏路径做评估，不能反推为交易信号可用。
- 组件拆解若只在 2025 有效，可能仍是近端行情特例。

## 7. 证伪条件

出现以下情况，本假设不通过：

- 2025 原始 top20 `bad10` 提升低于 `+20pct` 且低风险桶降低弱于 `-20pct`。
- 去连续日期样本或 episode 聚合后，主分数高/低风险分离方向消失。
- 2025 block bootstrap 的 top20 `bad10` 提升 5% 分位不高于 `+8pct`，且低风险桶降低 95%/5% 稳健性也不达标。
- shift_prev1 或 shift_next1 在去连续日期/episode 聚合后与主分数接近或更强。
- 随机同规模 top 桶 95% 分位能复制主分数。
- 组件贡献被单一组件完全支配；leave-one-out 后分离整体坍塌。
- 任一未来字段、未来标签或 H10 结果进入分数构造。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 通过 | 分数读取 CJC9 已生成的只读 `*_score` 字段；本轮只重建 episode_id 与去重索引，不用未来标签构造分数 |
| 信号生成和成交价格不存在同 bar 泄漏 | 通过 | 本实验不生成成交，不创建策略配置 |
| 股票池或 ETF 池不存在未来成分泄漏 | 预注册沿用 | 沿用既有 LJQ7/CJC9 面板，不新增成分选择 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 不使用财务、宏观或估值数据 |
| Shadow 或观察信号未被当成默认交易信号 | 通过 | 只读审计，不写 shadow/observe/live 配置 |

负控或错位检查：

- 固定使用 CJC9 `episode_hazard_shift_prev1_score` 与 `episode_hazard_shift_next1_score`。
- 固定 seed 的随机同规模 top 桶与 episode/block bootstrap。
- 去连续日期样本与 episode 聚合不改变主分数，只改变统计单位。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | 固定 `episode_age_hazard_score`；`TOP_FRAC=0.20`；`gap_days=5`；不扫权重/窗口/top比例 |
| 样本内、验证集、样本外划分清楚 | 通过 | 使用 CJC9 已输出的 OOS test predictions |
| 邻近参数敏感性合理 | 不适用 | 本轮是稳定性审计，不调邻近参数 |
| 成本、滑点或换手扰动已检查 | 不适用 | 只读风险排序 |
| 已做消融或负控 | 严格负控未通过 | 错位、随机、block bootstrap、去连续日期、episode 聚合、组件/leave-one-out 均输出；去簇和 episode 随机负控可复制 |
| 未只报告最优结果 | 通过 | 输出所有审计口径，不以最佳口径替代总门槛 |

证据等级：`L1-`。raw、separated、bootstrap 与组件证据支持机制线索，但严格随机负控未过，不能升级为正式 L1 通过。

## 10. 子代理调用记录

适配判断：`适合调用`

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：当前多代理工具要求用户显式授权子代理/委派/并行 agent；本轮用户未显式授权；主控：main；时间：2026-06-18T14:12:33Z
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-EXEMPT-20260618T141233Z-main-M3VC | 无 | SUBTASK-M3VC-EPISODE-STABILITY-EXEMPT | 无 | 2026-06-18T14:12:33Z | CJC9 outputs；LJQ7 action panel；MCYG方向文档；M3VC summary/CSV | 本实验记录；平台只读脚本；NWY3决策；台账待回填 | `PYTHONUNBUFFERED=1 PYTHONPATH=src python3 scripts/research/analyze_m3vc_episode_age_stability_readonly.py` | 只读稳定性审计，不判断交易化 | 日期簇、错位复制、小样本 top 桶 | 主控已按严格随机负控重跑并复核 | 支持 revise，不支持动作化 |

台账行：`SUB-EXEMPT-20260618T141233Z-main-M3VC` 已同步至 `01_台账/子代理调用台账.csv`。

## 11. 执行记录

### 平台配置

```text
${QUANT_PLATFORM_ROOT}/scripts/research/analyze_m3vc_episode_age_stability_readonly.py
${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260617T212938Z-main-LJQ7/ljq7_action_panel.csv
${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T135410Z-main-CJC9/cjc9_test_predictions.csv
${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T135410Z-main-CJC9/cjc9_oos_metrics.csv
```

### 运行命令

```bash
cd ${QUANT_PLATFORM_ROOT}
PYTHONUNBUFFERED=1 PYTHONPATH=src python3 scripts/research/analyze_m3vc_episode_age_stability_readonly.py 2>&1 | tee results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T141233Z-main-M3VC/run.log
```

### 可见进度与日志

- 是否过程可见：`是`
- 日志路径：`${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T141233Z-main-M3VC/run.log`
- 查看进度命令：`Get-Content -Tail 80 "${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T141233Z-main-M3VC/run.log"`
- 异常判断：无异常退出；初版 gate 发现过松后已收紧随机负控并重跑。
- 后台回测豁免：不适用，前台可见运行。

### 结果路径

```text
${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T141233Z-main-M3VC/
```

## 12. 实际观察

| 指标 | 基准 | 本次 | 变化 | 解释 |
| --- | --- | --- | --- | --- |
| 总门槛 | 必须全部通过 | `readonly_pass=false` | 未过 | 严格随机负控失败 |
| raw 2025 top20 `bad10` | 本段 54.90% | 90.91% | `+36.01pct` | 原始分离很强 |
| raw 2025 low20 `bad10` | 本段 54.90% | 9.09% | `-45.81pct` | 低风险桶很干净 |
| calendar thin gap5 | 17行，top_n=4 | top lift `+8.82pct`，low lift `-41.18pct` | 方向保留 | 但样本太小，随机可复制 |
| separated bucket gap5 | 51行，top_n=11 | top lift `+26.92pct`，low lift `-18.54pct` | 仍强 | 去连续 top 选择后仍有效 |
| episode level | 11个episode，top_n=3 | top lift `+45.45pct`，low lift `-21.21pct` | 方向强 | 但 episode 数太少，随机可复制 |
| block bootstrap | 1000次，5日块 | top lift 5%分位 `+15.33pct`，low lift 95%分位 `-14.62pct` | 通过 | 连续块重抽样没有推翻 |
| raw random control | random top p95 `+17.83pct` | 主分数 `+36.01pct` | 通过 | raw 口径强于随机 |
| decluster random control | calendar random top p95 `+33.82pct`；episode random top p95 `+45.45pct` | 主分数分别 `+8.82pct`、`+45.45pct` | 未过 | 去簇/episode 样本太小，随机可复制 |
| component support | 至少两个组件支持 | 4个组件支持，leave-one-out 6行支持 | 通过 | 不完全依赖单一组件 |

## 13. 支持证据

- 2025 raw 口径复现 CJC9 强信号：top20 `bad10` 提升 `+36.01pct`，低风险桶降低 `-45.81pct`，top20 下尾损失提升 `+1.65pct`，趋势继续率降低 `-20.32pct`。
- 去连续日期后的 `separated_bucket_gap5` 仍有 top20 `bad10` 提升 `+26.92pct`，低风险桶降低 `-18.54pct`，说明不是完全由连续日期堆叠造成。
- 5日 block bootstrap 的 top20 `bad10` lift 5% 分位仍为 `+15.33pct`，低风险桶 lift 95% 分位为 `-14.62pct`，比简单 raw 随机更稳。
- 组件拆解显示 `unfavorable_run_len`、`confirmed_state_run_len` 等状态持续时间组件贡献明显，leave-one-out 没有整体坍塌。

## 14. 反对证据

- 总门槛 `readonly_pass=false`，失败原因是严格随机负控：`random_gate=false`。
- `calendar_thin_gap5` 只有 17 行、top_n=4；主分数 top lift `+8.82pct`，但 random top p95 是 `+33.82pct`，随机能复制。
- `episode_level` 只有 11 个 episode、top_n=3；主分数 top lift `+45.45pct`，random top p95 同为 `+45.45pct`，无法证明不是抽样偶然。
- episode 聚合下 top20 `trend_good10_lift` 为 `+12.12pct`，说明 episode 级别“坏路径”和“趋势继续”可能在同一 episode 内并存，不能直接做降仓规则。
- shift_prev1 raw 也有 `+26.92pct`，虽弱于主分数，但仍提示状态自相关和日期簇解释没有完全消除。

## 15. 偏差诊断

实验前预测认为去连续日期、episode 聚合和随机负控都应保留主分数优势。实际只满足了一部分：raw、separated bucket、block bootstrap 和组件拆解支持；但 calendar thin 与 episode-level 由于样本太小，随机同规模可以复制。

这意味着当前证据不能写成“已超越 R 方”。更准确的说法是：`episode_age_hazard` 已经接近一个可研究机制，但缺的不是调参，而是更强的事件级样本、外部验证或 live-like dry-run 观察数据。

## 16. 研究判断

建议状态：`revise`

理由：M3VC 没有通过严格门槛，不允许动作化、shadow、observe 或实盘改动；但其 raw、separated、bootstrap 和组件证据显著强于前面的 YCW5 固定经济损失排序，说明“状态生命周期/episode age”仍是 MCYG 当前最接近答案的非 R 方方向。

## 17. 下一步

下一步不能继续在同一小样本里扫权重或 top 比例。更有价值的是：

- 事件级外部验证：扩展到更多组合/更长历史，验证 episode-level 随机负控能否被打败。
- live-like dry-run 数据准备：如果未来有真实观察流，只记录 `episode_age_hazard`，先不交易，用新样本复核。
- 机制压缩：把贡献集中到 `unfavorable_run_len` 与 `confirmed_state_run_len` 等生命周期字段，预注册一个更少组件的只读复核，重点不是更高 raw 指标，而是能否通过 episode-level 随机负控。
