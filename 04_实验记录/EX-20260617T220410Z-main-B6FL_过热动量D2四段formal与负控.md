---
type: 实验记录
ex_id: EX-20260617T220410Z-main-B6FL
rd_id: RD-20260614T115209Z-main-MCYG
status: completed
stage: formal_completed_failed_revise_cost_control_invalid
owner: main
created_at: 2026-06-17T22:04:10Z
updated_at: 2026-06-18T02:50:00Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 防御模块事前暴露管理层
decision_ids: [DEC-20260617T215629Z-main-UARF, DEC-20260618T024516Z-main-UR6S]
lit_ids: [LIT-20260617T220410Z-main-RDHA, LIT-20260614T112631Z-main-VY4K]
idea_ids: []
platform_project: ${LEGACY_QUANT_PLATFORM_ROOT}
config_paths:
  - scripts/research/generate_b6fl_r010d_overheat_formal_configs.py
  - configs/research/RD-20260614T115209Z-main-MCYG/EX-20260617T220410Z-main-B6FL/formal/
result_paths:
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260617T220410Z-main-B6FL/formal/
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260617T220410Z-main-B6FL/formal/summary/summary.json
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260617T220410Z-main-B6FL/formal/summary/segment_summary.csv
summary_paths:
  - scripts/research/summarize_b6fl_r010d_overheat_formal.py
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260617T220410Z-main-B6FL/formal/summary/summary.json
quality_gate: formal_failed
subagent_call_ids: [SUB-EXEMPT-20260617T220400Z-main-B6FL, SUB-EXEMPT-20260618T024500Z-main-UR6S]
subagent_exemption: 当前多代理工具要求用户显式授权子代理/委派/并行 agent；本轮没有该授权，主控执行并记录豁免。
tags: [双池轮动, 防御模块, 动量崩溃, 非R方, 经济目标, 过热动量, R010D, formal, failed, no-live-change]
---

# 过热动量D2四段formal与负控

## 关联链接

- 研究方向：[[02_研究方向/RD-20260614T115209Z-main-MCYG_双池轮动动量崩溃事前暴露管理|MCYG 动量崩溃事前暴露管理]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 来源文献或灵感：[[06_文献资料/00_待处理/LIT-20260617T220410Z-main-RDHA_顶刊拟合目标替代与动量崩溃前置暴露|顶刊拟合目标替代与动量崩溃前置暴露]]；[[06_文献资料/00_待处理/LIT-20260614T112631Z-main-VY4K_动量崩溃保护Daniel Moskowitz 2016|动量崩溃保护 Daniel Moskowitz 2016]]
- 前序实验：[[04_实验记录/EX-20260617T212938Z-main-LJQ7_DM前置风险标签只读面板|LJQ7]]；[[04_实验记录/EX-20260617T213634Z-main-XA5U_过热动量前置暴露D2 smoke|XA5U]]
- 产生的决策：[[05_研究决策/DEC-20260618T024516Z-main-UR6S_过热动量D2四段formal失败后暂停推广|UR6S]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：把“R 方拟合过去趋势”换成“过热动量风险的经济目标”，是否能比当前 B3/tiered-v2 更早减少追高和回撤。

原本预测是：如果滞后来自事后门控和盲目追强，那么 `R010D_D2_OVERHEAT(cap=0.90, keep_current=true)` 应该在四段样本中不显著伤收益，并至少在部分阶段改善最大回撤；延迟触发和随机触发不应复制主候选。

实际看到：formal 不通过。主候选只在 `2022_2023` 和 `2024` 两段跑赢 baseline，在 `2020_2021` 和 `2025_20260519` 明显落后；最大回撤改善只有 `1/4` 段。负控也不干净：`2020_2021` 的延迟一日和随机触发都高于主候选，`2025_20260519` 的随机触发也高于主候选。

成本扰动本轮不能作为有效证据：成本变体四段 final/MDD/交易数与主候选完全相同，汇总脚本标记 `cost_control_valid=false`。初步疑点是成本分支没有像 B3QC/K3AC 那样同步策略内 `r010b5_research_fund_commission_rate` 与 `slippage_bps` 字段；平台生成器已修正，但未回头覆盖已运行配置。

这说明：XA5U 的 2024 smoke 更像局部行情有效，不是可跨段推广的稳健规则。`R010D_D2_OVERHEAT` 不得 promote、observe、shadow 或改实盘默认逻辑。

下一步：MCYG 方向从“过热动量 D2 降 cap”修订为只读概率/分位数面板，先预测崩溃概率或下尾风险，再决定是否值得进入组合动作实验。

## 2. 研究背景

本实验承接 [[05_研究决策/DEC-20260617T215629Z-main-UARF_过热动量D2 smoke通过后进入formal|UARF]]。此前：

- J7EF 的 DM 方差缩放在 2024 smoke 中收益和回撤均差于 baseline，且滞后方差负控不弱，暂不继续。
- LJQ7 证明 broad-any 风险并集仍偏滞后，但 `overheated_momentum` 子标签更集中。
- XA5U 在 2024 真实组合 smoke 中通过：candidate final `181373.71` 高于 baseline `167005.22`，MDD 从 `-26.99%` 改到 `-22.80%`，触发 `36` 次。

本实验的目标不是再找一个 R 方替代分数，而是把顶刊启发的“经济目标”落到组合 formal：收益、回撤、触发次数、延迟负控、随机负控和成本扰动。

## 3. 实验前假设

在当前 B3/tiered-v2 防御骨架不变的情况下，只增加 `R010D_D2_OVERHEAT(cap=0.90, keep_current=true)`，可以在强动量过热的 A1 日减少追高，跨样本改善收益-回撤关系；若延迟一日或随机触发也能复制，则说明它不是事前信号。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：主候选四段 final 不低于 baseline 的 `98%`，且至少 `3/4` 段 final 高于 baseline。
- 交易行为：主候选 `R010D_D2_OVERHEAT` 在至少 `3/4` 段触发次数不低于 `5`，交易数不应异常爆炸。
- 风险表现：主候选至少 `2/4` 段最大回撤改善不低于 `0.5pp`，2024 段应保持 XA5U smoke 中的改善方向。
- 分段表现：2020_2021、2022_2023、2024、2025_20260519 四段不能只靠 2024 单段支撑。
- 负控表现：延迟一日触发和随机触发不能在 `3/4` 段 final 上超过主候选。
- 成本扰动：双倍佣金 + 2bps 固定滑点下，主候选至少 `3/4` 段 final 不低于 baseline 的 `98%`。

固定口径：

```text
baseline = 当前 R010-B4 B3/tiered-v2 防御骨架，R010D 关闭
candidate = R010D_D2_OVERHEAT(cap=0.90, keep_current=true)
lag_control = candidate 逻辑但读取前 1 个已记录交易日的 R010D 标签
random_control = candidate 逻辑但在 A1 日按稳定哈希随机触发，p = 188/591，seed = 20260617
cost_control = candidate + commission_rate 0.0002 + fixed_slippage_spread 0.0002
不扫 cap，不改 top1_ret20/top1_slope10 阈值，不改 keep_current
```

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| `baseline_b3_tiered_v2_current` | 当前 B3/tiered-v2 防御骨架，R010D 关闭。 | `configs/research/RD-20260614T115209Z-main-MCYG/EX-20260617T220410Z-main-B6FL/formal/baseline_b3_tiered_v2_current/` |
| `r010d_d2_overheat_cap90_keep_current` | 主候选。 | `configs/research/RD-20260614T115209Z-main-MCYG/EX-20260617T220410Z-main-B6FL/formal/r010d_d2_overheat_cap90_keep_current/` |
| `r010d_d2_overheat_lag1` | 延迟一交易日触发负控。 | `configs/research/RD-20260614T115209Z-main-MCYG/EX-20260617T220410Z-main-B6FL/formal/r010d_d2_overheat_lag1/` |
| `r010d_d2_overheat_random_p318_seed20260617` | 随机触发负控。 | `configs/research/RD-20260614T115209Z-main-MCYG/EX-20260617T220410Z-main-B6FL/formal/r010d_d2_overheat_random_p318_seed20260617/` |
| `r010d_d2_overheat_cap90_keep_current_cost2x_slip2bps` | 成本扰动。 | `configs/research/RD-20260614T115209Z-main-MCYG/EX-20260617T220410Z-main-B6FL/formal/r010d_d2_overheat_cap90_keep_current_cost2x_slip2bps/` |

## 6. 竞争性解释

即使结果符合预期，也可能是：

- 2024 单段行情偶然适合“少追高”，其他段无法复现。
- 降仓/保留旧仓减少交易，收益改善来自少换手而不是事前风险标签。
- 延迟触发或随机触发也能改善，说明真正有效的是低频减仓或少换仓，不是 overheat 标签。
- 成本扰动后优势消失，说明只是交易成本口径敏感。
- 当前 ETF 池和动态成交额池仍可能有边界，需要后续单独审计。

## 7. 证伪条件

出现以下情况，本假设不通过：

- 主候选任一段 final 低于 baseline 的 `98%`。
- 主候选 final 高于 baseline 的段数少于 `3/4`。
- 主候选最大回撤改善不低于 `0.5pp` 的段数少于 `2/4`。
- 主候选触发次数不低于 `5` 的段数少于 `3/4`。
- 延迟一日或随机触发在 `3/4` 段 final 上超过主候选。
- 成本扰动下 final 不低于 baseline `98%` 的段数少于 `3/4`。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 未发现新增泄漏；不构成 promote | R010D 标签来自 R010-B 状态日志，候选只在研究配置显式启用。 |
| 信号生成和成交价格不存在同 bar 泄漏 | 未发现新增泄漏；仍保留边界 | 回测沿用 R010-B4 13:09/13:10 执行口径；本实验失败，不进入实盘链路。 |
| 股票池或 ETF 池不存在未来成分泄漏 | 继承边界 | 继承 R010-B4 口径；本实验不因失败结果改变股票池/ETF 池判断。 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 本实验不使用财务、宏观或估值字段。 |
| Shadow 或观察信号未被当成默认交易信号 | 通过 | 不改实盘、不 shadow、不 observe。 |

负控结果：

- `r010d_signal_lag_days = 1`：主候选只在 `3/4` 段 final 高于 lag1，且 `2020_2021` lag1 反而更好。
- `r010d_random_overheat_prob = 188/591`：主候选只在 `2/4` 段 final 高于 random，`2020_2021` 与 `2025_20260519` random 更好。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | 固定 cap `0.90`、`keep_current=true`、随机概率 `188/591`，未扫 cap/阈值。 |
| 样本内、验证集、样本外划分清楚 | 通过但失败 | 四段全部报告；2024 通过但 2020_2021 与 2025_20260519 失败。 |
| 邻近参数敏感性合理 | 不做 | 本轮不后验扩参。 |
| 成本、滑点或换手扰动已检查 | 未通过 | 成本变体四段与候选完全相同，`cost_control_valid=false`，不能作为有效成本扰动。 |
| 已做消融或负控 | 通过但不支持候选 | lag1/random 负控均未给出干净优势。 |
| 未只报告最优结果 | 通过 | 汇总脚本固定输出 5 变体 x 4 段。 |

证据等级：`L2_failed`（四段 formal 已完成，结果不通过；成本扰动需另开有效成本补证才可复用）

## 10. 子代理调用记录

适配判断：`适合调用`

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：当前多代理工具要求用户显式授权子代理/委派/并行 agent；本轮没有该授权；主控：main；时间：2026-06-17T22:04:00Z
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `SUB-EXEMPT-20260617T220400Z-main-B6FL` | 无 | `SUBTASK-B6FL-PREREG-EXEMPT` | 无 | 2026-06-17T22:04:00Z | LIT/RD/EX 相关文档与平台配置 | 无子代理修改 | 无 | 豁免 | 无子代理并行复核 | 主控已复核运行结果和 summary | 不支持 promote；只支持流程豁免记录 |
| `SUB-EXEMPT-20260618T024500Z-main-UR6S` | 无 | `SUBTASK-B6FL-DECISION-EXEMPT` | 无 | 2026-06-18T02:45:00Z | B6FL summary、MCYG 方向、UR6S 决策 | 无子代理修改 | 无 | 豁免 | 无子代理并行复核 | 主控复核质量门和成本异常 | 支持 revise 决策记录，不作为策略有效性证据 |

台账行：已同步 `01_台账/子代理调用台账.csv`。

## 11. 执行记录

### 平台配置

```text
已生成并运行 20 个 formal 配置：
configs/research/RD-20260614T115209Z-main-MCYG/EX-20260617T220410Z-main-B6FL/formal/
```

### 运行命令

```bash
cd ${QUANT_PLATFORM_ROOT}
PYTHONUNBUFFERED=1 PYTHONPATH=src python3 src/run_v2_backtest.py --config configs/research/RD-20260614T115209Z-main-MCYG/EX-20260617T220410Z-main-B6FL/formal/<variant>/b6fl_<variant>_<segment>.json
PYTHONPATH=src python3 scripts/research/summarize_b6fl_r010d_overheat_formal.py
```

过程可见性：全部正式运行使用 `PYTHONUNBUFFERED=1` 与 `tee` 写入 `_run_logs`。`baseline_2025_20260519` 与 `random_2020_2021` 曾出现一次 `Floating point exception`，重试成功；失败日志保留为平台运行异常证据，不作为策略结果。

### 汇总结果路径

```text
results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260617T220410Z-main-B6FL/formal/summary/summary.json
results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260617T220410Z-main-B6FL/formal/summary/segment_summary.csv
```

## 12. 实际观察

| 分段 | baseline final | candidate final | lag1 final | random final | 结论 |
| --- | ---: | ---: | ---: | ---: | --- |
| `2020_2021` | `224942.51` | `199901.74` | `233490.97` | `229519.05` | 候选低于 baseline，且 lag/random 更好 |
| `2022_2023` | `131215.13` | `137972.89` | `130014.65` | `120611.80` | 候选跑赢 baseline 与负控 |
| `2024` | `167005.22` | `181373.71` | `157386.86` | `161817.14` | 复现 XA5U smoke 改善 |
| `2025_20260519` | `317973.61` | `274753.16` | `235955.78` | `307271.22` | 候选明显错过强趋势，random 也更好 |

汇总质量门：

- `candidate_final_not_worse_2pct_segments = 2/4`，未达到 `4/4`。
- `candidate_final_beats_baseline_segments = 2/4`，未达到 `3/4`。
- `candidate_mdd_improves_0p5pp_segments = 1/4`，未达到 `2/4`。
- `candidate_trigger_ge_5_segments = 4/4`，触发次数足够。
- `candidate_beats_lag_final_segments = 3/4`，仅勉强达到 lag 门槛。
- `candidate_beats_random_final_segments = 2/4`，未达到 `3/4`。
- `cost_identical_to_candidate_segments = 4/4`，`cost_control_valid=false`。
- `formal_pass=false`。

## 13. 支持证据

- XA5U 2024 smoke 在 B6FL 中复现：2024 candidate final `181373.71` 高于 baseline `167005.22`，MDD 改善约 `4.20pp`。
- 2022_2023 candidate final `137972.89` 高于 baseline `131215.13`，说明 overheat-only 不是单段 2024 完全偶然。
- 触发次数四段均不低于 `5`，不是没有实际触发的空规则。

## 14. 反对证据

- `2020_2021` candidate final `199901.74` 低于 baseline `224942.51`，且 lag1/random 均高于 candidate。
- `2025_20260519` candidate final `274753.16` 明显低于 baseline `317973.61`，强趋势段误伤较大。
- 最大回撤改善只有 `1/4` 段，未支持“前置暴露改善收益-回撤”的核心假设。
- 随机负控只在 `2/4` 段低于 candidate，不能排除少换仓/低频减仓解释。
- 成本扰动四段与 candidate 完全相同，说明本轮成本配置质量门无效；已修正生成脚本，但不回填本轮结果。

## 15. 偏差诊断

本实验暴露出两个问题：

- `R010D_D2_OVERHEAT` 过度依赖 2024 这类“追高容易受伤”的行情，在 2025 强趋势中会提前降风险、错过收益。
- 用单个 overheat 标签直接改组合动作仍然偏粗，无法区分“过热后即将崩”和“强趋势继续延伸”。

成本扰动异常不改变失败结论，因为主候选在非成本主门槛已经失败。若未来要补成本，只能新开或重新预注册有效成本扰动，不得把本轮成本结果写成已通过。

## 16. 研究判断

建议状态：`completed / formal_failed_revise`

结论：`R010D_D2_OVERHEAT(cap=0.90, keep_current=true)` 不推广、不 observe、不 shadow、不改实盘。它可以保留为只读风险标签素材，但不能作为默认交易动作。

对应决策：[[05_研究决策/DEC-20260618T024516Z-main-UR6S_过热动量D2四段formal失败后暂停推广|UR6S]]

## 17. 下一步

不回到 PLS/Ridge/blend 或 `R²` 替代分数调参。下一步只允许新开只读面板，把目标改成更前置的概率或尾部损失：

- 分位数/check loss：预测未来 H5/H10 下尾收益或路径回撤。
- 概率评分：预测未来 10 日是否出现崩溃事件，用 Brier/log loss 而不是单段收益筛选。
- 组合动作必须等只读面板通过前移一日、错位、随机和分段检验后再开新 formal。
