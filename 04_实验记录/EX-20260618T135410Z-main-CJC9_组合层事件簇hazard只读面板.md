---
type: 实验记录
ex_id: EX-20260618T135410Z-main-CJC9
rd_id: RD-20260614T115209Z-main-MCYG
status: completed
stage: readonly_completed_near_miss_revise_no_action
owner: main
created_at: 2026-06-18T13:54:10Z
updated_at: 2026-06-18T14:00:56Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 防御模块事前暴露管理层
decision_ids:
  - DEC-20260618T140056Z-main-FDSQ
lit_ids: []
idea_ids: []
platform_project: ${LEGACY_QUANT_PLATFORM_ROOT}
config_paths:
  - scripts/research/analyze_cjc9_episode_hazard_readonly.py
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260617T212938Z-main-LJQ7/ljq7_action_panel.csv
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T030506Z-main-K3YL/k3yl_test_predictions.csv
result_paths:
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T135410Z-main-CJC9/
summary_paths:
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T135410Z-main-CJC9/summary.json
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T135410Z-main-CJC9/quality_gates.json
quality_gate: near_miss_failed_random_or_competitive_gate
subagent_call_ids:
  - SUB-EXEMPT-20260618T135410Z-main-CJC9
subagent_exemption: 当前多代理工具要求用户显式授权子代理/委派/并行 agent；本轮用户未显式授权。
tags:
  - 非R方
  - 低滞后
  - 事件簇
  - hazard
  - 状态转移
  - 只读
---

# 组合层事件簇hazard只读面板

## 关联链接

- 研究方向：[[02_研究方向/RD-20260614T115209Z-main-MCYG_双池轮动动量崩溃事前暴露管理|RD-20260614T115209Z-main-MCYG 动量崩溃事前暴露管理]]
- 策略档案：
- 来源文献或灵感：
- 产生的决策：[[05_研究决策/DEC-20260618T140056Z-main-FDSQ_事件簇hazard只读接近但未通过后修订|DEC-20260618T140056Z-main-FDSQ 事件簇hazard只读接近但未通过后修订]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：不用 R 方、不继续调 overheat 阈值，也不继续调 YCW5 的经济损失排序，能否用“暴露持续多久、事件是否成簇、状态是否刚切换”提前识别 H10 坏路径。  
我们原本预计：如果真正的问题是状态持续时间和事件簇，而不是某一天横截面分数高低，那么 episode/hazard 分数应在 OOS 中比常数、K3YL、R方、front_any、YCW5固定排序和随机/错位负控更能区分 2025 坏路径。  
实际看到：`readonly_pass=false`，但出现接近线索。`cluster_decay_hazard` 通过 2025 和竞争基准门槛，但随机同规模负控未过；`episode_age_hazard` 通过 2025 和随机负控，且 2025 top20 `bad10` 提升 +36.01pct、低风险桶降低 -45.81pct，但跨段竞争门槛未过。  
这说明：事件簇/持续时间机制比 YCW5 固定经济损失排序更接近目标，尤其能在 2025 强趋势段分出风险，但还没有达到可升级的只读质量门槛。  
但还不能说明：不能说明可以交易、shadow、observe 或改实盘；也不能说明可直接调权重修成策略。  
下一步要做：保留 CJC9 为“修订候选”，新开更窄的只读审计，专门复核 `episode_age_hazard` 的跨段稳定性、错位强度和事件簇解释，不在本实验上后验调参。

## 2. 研究背景

本实验属于 [[02_研究方向/RD-20260614T115209Z-main-MCYG_双池轮动动量崩溃事前暴露管理|MCYG 动量崩溃事前暴露管理]]。K3YL 说明 overheat 标签有只读概率信息但 2025 风险不集中；Z78J 说明同字段趋势继续守门失败；YCW5 又说明固定经济损失排序在 2025 反向。

因此本轮换一个机制：不再把某一天的特征加权成一个风险分数，而是显式统计 A1、overheat、front_any、unfavorable 状态的持续时间、事件簇密度、状态切换和近期退化。研究问题变成“风险暴露走到哪一段生命周期”，而不是“当前截面分数够不够高”。

## 3. 实验前假设

在 A1 且未已回撤 5% 的组合日期中，基于状态持续时间、事件簇密度、状态切换和近期退化构造的非 R 方 episode/hazard 分数，能否比常数、K3YL、R方、front_any、YCW5固定排序和错位/随机负控更早识别 H10 坏路径，并避免 2025 强趋势误伤。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：主候选 `episode_age_hazard`、`cluster_decay_hazard`、`state_switch_hazard` 至少一个在 OOS 3 段中满足：Brier 或 10% check loss 至少 2/3 胜 K3YL 和 R方；top20 `bad10` 或下尾损失提升至少 2/3 为正；随机同规模负控不复制。
- 交易行为：无交易行为。本实验只读，不生成策略配置，不进入 smoke/formal，不产生 shadow 或实盘信号。
- 风险表现：高 hazard 桶未来 H10 `bad10` 和 `tail_loss10` 应高于本段基准；低 hazard 桶应明显低于本段基准。
- 分段表现：2025_20260519 是硬门槛。候选必须在 2025 top20 `bad10` 或低风险桶 `bad10` 上至少改善 8pct，且不能把趋势继续样本集中打入高 hazard 桶。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| LJQ7 action panel | 输入组合状态与未来路径标签 | `${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260617T212938Z-main-LJQ7/ljq7_action_panel.csv` |
| K3YL predictions | 前序概率/分位数基准 | `${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T030506Z-main-K3YL/k3yl_test_predictions.csv` |
| constant base rate | 检查是否只是坏路径基准率 | 脚本内生成 |
| `r2_only` | 明确检验非R方是否有增量 | 脚本内从 `top1_r2` 生成 |
| `front_any_binary` | 前序状态标签基准 | 脚本内生成 |
| `ycw5_stress_proxy` | YCW5固定经济损失排序基准 | 脚本内按 YCW5 公式复现 |
| `shift_prev1/next1` | 日期错位负控 | 脚本内生成 |
| random same support | 同规模随机高 hazard 桶负控 | 脚本内固定 seed 生成 |

## 6. 竞争性解释

即使结果符合预期，也可能是：

- episode/hazard 可能只是复刻 overheat 的连续天数，没有独立增量。
- 事件簇可能与 2025 的整体高坏路径基准率混淆，导致任何分桶都显得有效。
- 近期退化特征可能已经是已发生回撤的同义词，而不是未来风险。
- 样本仍只有 254 条主宇宙记录，2025 分段更小，top20 约 11 条，容易受日期簇影响。

## 7. 证伪条件

出现以下情况，本假设不通过：

- 2025_20260519 不通过 8pct 高/低风险桶硬门槛。
- 高 hazard 桶 `trend_good10_rate` 高于本段基准 5pct 以上，说明误伤强趋势继续。
- 主候选 OOS 少于 2 段胜 K3YL 或 R方。
- shift 或 random same support 复制主候选提升。
- 主候选只在 2024 单段有效，去掉 2024 后结论消失。
- 任一未来字段、未来标签或 H10 结果进入候选分数。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 通过 | 事件持续时间、状态切换和退化特征只从 `trade_date/signal_date` 及之前可见面板字段滚动计算 |
| 信号生成和成交价格不存在同 bar 泄漏 | 通过 | 本实验不生成成交；未来 H10 字段只作标签，不进入候选分数 |
| 股票池或 ETF 池不存在未来成分泄漏 | 预注册沿用 | 沿用既有双池平台面板，不新增成分选择 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 不使用财务、宏观或估值数据 |
| Shadow 或观察信号未被当成默认交易信号 | 通过 | 只读面板，未生成策略配置、shadow、observe 或实盘改动 |

负控或错位检查：

- `shift_prev1`、`shift_next1` 错位 hazard。
- random same support 同分段同规模随机 top 桶。
- `ycw5_stress_proxy` 复现 YCW5 固定横截面排序作为对照，不作为主候选。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 预注册通过 | 固定三类主候选：`episode_age_hazard`、`cluster_decay_hazard`、`state_switch_hazard` |
| 样本内、验证集、样本外划分清楚 | 预注册通过 | 训练段滚动：2020_2021 -> 2022_2023；2020_2023 -> 2024；2020_2024 -> 2025_20260519 |
| 邻近参数敏感性合理 | 不适用 | 不扫窗口/权重/top比例；固定 5 日和 10 日事件簇统计 |
| 成本、滑点或换手扰动已检查 | 不适用 | 只读风险排序 |
| 已做消融或负控 | 通过 | 常数、K3YL、R方、front_any、YCW5 proxy、错位和随机同规模均输出 |
| 未只报告最优结果 | 预注册通过 | 输出全部候选和对照 |

证据等级：预期最高 `L1`。即使通过也只是只读线索，不能交易化。

## 10. 子代理调用记录

适配判断：`适合调用`

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：当前多代理工具要求用户显式授权子代理/委派/并行 agent；本轮用户未显式授权；主控：main；时间：2026-06-18T13:54:10Z
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-EXEMPT-20260618T135410Z-main-CJC9 | 无 | SUBTASK-CJC9-EPISODE-HAZARD-EXEMPT | 无 | 2026-06-18T13:54:10Z | LJQ7 action panel；K3YL outputs；MCYG方向文档；YCW5边界 | 本实验记录；平台只读脚本；台账待回填 | `PYTHONUNBUFFERED=1 PYTHONPATH=src python3 scripts/research/analyze_cjc9_episode_hazard_readonly.py` | 只读 hazard，不判断交易化 | 2025误伤、事件簇过拟合、负控复制 | 主控已复核 summary、metrics、random controls | 支持 FDSQ revise |

台账行：`SUB-EXEMPT-20260618T135410Z-main-CJC9` 已同步至 `01_台账/子代理调用台账.csv`。

## 11. 执行记录

### 平台配置

```text
${LEGACY_QUANT_PLATFORM_ROOT}/scripts/research/analyze_cjc9_episode_hazard_readonly.py
${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260617T212938Z-main-LJQ7/ljq7_action_panel.csv
${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T030506Z-main-K3YL/k3yl_test_predictions.csv
```

### 运行命令

```bash
cd ${QUANT_PLATFORM_ROOT}
PYTHONUNBUFFERED=1 PYTHONPATH=src python3 scripts/research/analyze_cjc9_episode_hazard_readonly.py 2>&1 | tee results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T135410Z-main-CJC9/run.log
```

### 可见进度与日志

- 是否过程可见：`是`
- 日志路径：`${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T135410Z-main-CJC9/run.log`
- 查看进度命令：`Get-Content -Tail 80 "${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T135410Z-main-CJC9/run.log"`
- 异常判断：脚本退出非 0、主宇宙少于 200 行、未来字段进入候选分数、错位/随机复制主候选，均视为异常。
- 后台回测豁免：不适用，前台可见运行。

```text
如后台或静默运行，必须写：
后台回测豁免：<原因>
进程标识：<pid或任务名>
日志路径：<path>
查看进度：<command>
停止方式：<command>
预计耗时：<duration>
```

### 结果路径

```text
${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T135410Z-main-CJC9/
```

## 12. 实际观察

| 指标 | 基准 | 本次 | 变化 | 解释 |
| --- | --- | --- | --- | --- |
| 主宇宙 | LJQ7 A1 且未已回撤5% | 254行，bad10 95个 | 与 K3YL/YCW5 同口径 | 可直接比较 |
| 最佳门控候选 | `cluster_decay_hazard` | `readonly_pass=false` | 2025=true，competitive=true，random=false | 接近但未通过随机同规模负控 |
| `cluster_decay_hazard` Brier | 对常数/K3YL/R方/YCW5 | 3/3、2/3、3/3、2/3 胜 | 竞争基准通过 | 比 YCW5 更稳，但随机不稳 |
| `cluster_decay_hazard` 2025 top20 | 本段 bad10 54.90% | top20 bad10 提升 +8.73pct，下尾损失提升 +1.39pct | 通过 2025 硬门槛 | 但随机 p95 未被打败 |
| `episode_age_hazard` 2025 | 本段 bad10 54.90% | top20 bad10 提升 +36.01pct，低风险桶 -45.81pct，AUC 0.790 | 2025 信号最强 | 跨段 Brier/K3YL/YCW5 竞争门槛不足 |
| `episode_age_hazard` 随机负控 | 同规模随机 top 桶 | bad p95 胜 2/3，loss p95 胜 1/3 | 部分干净 | 但 2022-2023 不够强 |
| 错位控制 | shift prev/next | 2025 shift_prev1 bad10 提升 +26.92pct，shift_next1 +17.83pct | 风险 | 强度有日期簇成分，需二次审计 |

## 13. 支持证据

- `episode_age_hazard` 是目前最强 2025 线索：2025_20260519 AUC `0.7896`，top20 `bad10` 提升 `+36.01pct`，低风险桶 `bad10` 降低 `-45.81pct`，top20 趋势继续率低于基准 `-20.32pct`。
- `cluster_decay_hazard` 跨段竞争更强：Brier 对常数 `3/3` 胜、对 K3YL `2/3` 胜、对 R方 `3/3` 胜、对 YCW5 proxy `2/3` 胜，且 top20 下尾损失提升 `3/3` 为正。
- 两个主线索都不同于 YCW5 固定横截面经济损失排序，至少说明“持续时间/事件簇”值得作为下一轮只读审计对象。

## 14. 反对证据

- 总门槛未通过：`readonly_pass=false`。
- `cluster_decay_hazard` 虽通过 2025 和竞争门槛，但随机同规模负控没有通过，bad p95 `0/3` 胜、loss p95 `1/3` 胜。
- `episode_age_hazard` 虽通过 2025 和随机门槛，但竞争门槛不足：Brier 对 K3YL `1/3` 胜、对 YCW5 `1/3` 胜，10% check loss 对 K3YL `1/3` 胜。
- 2025 的 shift_prev1/shift_next1 也有明显正提升，说明日期簇或持续状态自相关可能解释部分效果。
- `state_switch_hazard` 方向明显错误，2025 top20 `bad10` 提升 `-54.90pct`，高分桶反而是趋势继续样本。

## 15. 偏差诊断

实验前预测要求同一个候选同时通过 2025、竞争基准和随机负控；实际结果被拆成两半：`cluster_decay_hazard` 竞争指标好但随机不干净，`episode_age_hazard` 2025 与随机好但跨段竞争不足。可能原因是：

- 2025 强趋势段中，持续时间确实能区分“成熟趋势风险”和“早期趋势继续”，但这个机制在 2022-2023 不如 overheat/K3YL。
- 事件簇统计在小样本 top 桶下容易被日期连续性放大，随机同规模和错位负控会吞掉一部分解释力。
- 状态切换不是风险源，反而高分对应强趋势继续，说明不能简单把“切换次数多”视为危险。

## 16. 研究判断

建议状态：`revise`

理由：CJC9 未通过 L1 只读质量门，不能动作化、shadow、observe 或改实盘；但 `episode_age_hazard` 首次在 2025 强趋势段给出清晰区分，值得新开更窄的只读审计。下一轮必须预注册，不能直接调本实验权重。

## 17. 下一步

下一轮最值得做的是“episode_age_hazard 稳定性与错位簇审计”：

- 固定 `episode_age_hazard`，不调权重。
- 单独解释 A1/overheat/front_any/unfavorable 持续时间谁贡献最大。
- 加强错位负控：prev1、next1、同段 block bootstrap、去连续日期抽样。
- 目标是判断 2025 强信号是真正生命周期机制，还是连续日期簇造成的样本假象。
