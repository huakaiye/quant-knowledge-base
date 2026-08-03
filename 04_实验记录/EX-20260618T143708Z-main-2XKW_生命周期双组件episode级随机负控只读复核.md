---
type: 实验记录
ex_id: EX-20260618T143708Z-main-2XKW
rd_id: RD-20260614T115209Z-main-MCYG
status: completed
stage: readonly_completed_failed_no_action
owner: main
created_at: 2026-06-18T14:37:08Z
updated_at: 2026-06-18T14:42:37Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 防御模块事前暴露管理层
decision_ids:
  - DEC-20260618T144237Z-main-GNSM
lit_ids: []
idea_ids: []
platform_project: ${LEGACY_QUANT_PLATFORM_ROOT}
config_paths:
  - scripts/research/analyze_2xkw_lifecycle_pair_episode_readonly.py
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260617T212938Z-main-LJQ7/ljq7_action_panel.csv
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T141233Z-main-M3VC/summary.json
result_paths:
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T143708Z-main-2XKW/
summary_paths:
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T143708Z-main-2XKW/summary.json
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T143708Z-main-2XKW/score_summary.csv
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T143708Z-main-2XKW/random_control_summary.csv
quality_gate: failed_episode_random_and_shift
subagent_call_ids:
  - SUB-EXEMPT-20260618T143708Z-main-2XKW
subagent_exemption: 当前多代理工具要求用户显式授权子代理/委派/并行 agent；本轮用户未显式授权。
tags:
  - 非R方
  - 低滞后
  - episode级
  - 生命周期
  - 随机负控
  - 只读
---

# 生命周期双组件episode级随机负控只读复核

## 关联链接

- 研究方向：[[02_研究方向/RD-20260614T115209Z-main-MCYG_双池轮动动量崩溃事前暴露管理|RD-20260614T115209Z-main-MCYG 动量崩溃事前暴露管理]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 来源实验：[[04_实验记录/EX-20260618T141233Z-main-M3VC_episode_age hazard稳定性与错位簇审计|EX-20260618T141233Z-main-M3VC episode age 稳定性审计]]
- 产生的决策：[[05_研究决策/DEC-20260618T144237Z-main-GNSM_生命周期双组件episode负控未过后暂停|DEC-20260618T144237Z-main-GNSM 生命周期双组件episode负控未过后暂停]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：M3VC 里最有贡献的是状态生命周期组件，而不是完整的五组件 `episode_age_hazard`。如果只保留 `unfavorable_run_len` 与 `confirmed_state_run_len`，能不能在 episode 级别打败随机负控。  
我们原本预计：如果真正机制是“状态持续太久后风险上升”，更少组件应该在全 OOS episode pooled 口径上比随机更干净，同时 2025 不反向。  
实际看到：`readonly_pass=false`。双组件在全 OOS episode pooled 上 top20 `bad10` lift 为 `+32.59pct`，top20 下尾损失 lift 为 `+2.55pct`，但随机同规模 95% 分位分别达到 `+32.59pct` 和 `+2.66pct`，`shift_next1` 也几乎复制主结果。  
这说明：双组件压缩没有解决 M3VC 的核心问题，事件级随机和状态自相关仍然能解释主要表现。  
但还不能说明：不能说明整个生命周期方向都无效；`confirmed_state_only` 的诊断下尾损失更强，但这是本实验后验观察，不能在本实验里升级。  
下一步要做：暂停双组件方案；若继续，只能新开单组件 `confirmed_state_run_len` 的预注册只读复核，并且明确它来自 2XKW 诊断，不得直接动作化。

## 2. 研究背景

本实验属于 [[02_研究方向/RD-20260614T115209Z-main-MCYG_双池轮动动量崩溃事前暴露管理|MCYG 动量崩溃事前暴露管理]]。M3VC 说明：`episode_age_hazard` 的 raw、separated bucket、block bootstrap 和组件拆解都有支持，但 calendar-thin 与 episode-level 随机同规模可复制，严格随机负控未过。

M3VC 的组件拆解显示，`unfavorable_run_len` 与 `confirmed_state_run_len` 是 2025 中最强的两个生命周期组件；`a1_run_len` 反而没有贡献。因此本轮不是继续调 CJC9 权重，而是把机制压缩到两个最直观的状态持续时间组件，检验更少组件是否能降低过拟合。

## 3. 实验前假设

固定使用 `unfavorable_run_len` 与 `confirmed_state_run_len` 两个当时可见的状态生命周期字段，按 CJC9 的滚动训练段 empirical CDF 做 OOS 分数后，能在全 OOS episode pooled 口径上比同规模随机更稳定地识别 H10 坏路径。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：主候选 `state_lifecycle_pair` 在全 OOS episode pooled 上，top20 `bad10` lift 或 top20 `tail_loss10` lift 超过随机同规模 95% 分位；low20 `bad10` lift 低于随机 5% 分位更好但不是唯一通过条件。
- 交易行为：无交易行为。本实验只读，不生成策略配置，不进入 smoke/formal，不产生 shadow、observe 或实盘信号。
- 风险表现：全 OOS episode 高分桶坏路径和下尾损失高于基准；低分桶坏路径低于基准。
- 分段表现：2025_20260519 不要求单独打败 episode-level 随机，因为 M3VC 已证明该段只有 11 个 episode；但要求 2025 episode-level 不反向，且 row-level/separated 仍保留正向分离。
- 对照表现：`shift_prev1/next1` 和 random same support 不能同时复制 pooled episode 主候选。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| LJQ7 action panel | 重建状态持续时间、A1 episode、未来路径标签 | `${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260617T212938Z-main-LJQ7/ljq7_action_panel.csv` |
| M3VC summary | 继承上一轮失败边界和门槛 | `${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T141233Z-main-M3VC/summary.json` |
| `state_lifecycle_pair` | 主候选，两个状态持续时间组件等权 | 脚本内固定生成 |
| `unfavorable_only` / `confirmed_state_only` | 组件归因，不作为后验择优候选 | 脚本内固定生成 |
| `episode_age_proxy` | 五组件压缩对照 | 脚本内固定生成 |
| shift prev/next | 日期错位负控 | 脚本内固定生成 |
| random same support | episode 级同规模随机负控 | 脚本内固定 seed `20260618` |

## 6. 竞争性解释

即使结果符合预期，也可能是：

- `unfavorable_run_len` 与 `confirmed_state_run_len` 彼此高度重合，本质仍是单组件信号。
- 全 OOS pooled 合并了 2022-2025，不代表 2025 单段一定可用。
- episode label 使用 episode 内任意 H10 坏路径作为评估，可能同时包含趋势继续与回撤，不能直接变成降仓动作。
- empirical CDF 只解决训练段标尺问题，不能解决样本少或状态自相关问题。

## 7. 证伪条件

出现以下情况，本假设不通过：

- 全 OOS episode pooled 的主候选 top20 `bad10` lift 和 `tail_loss10` lift 均不能打败随机同规模 95% 分位。
- 全 OOS episode pooled 的主候选不优于 shift_prev1/shift_next1。
- 2025 episode-level 出现明显反向：高分桶 bad10 低于基准且低分桶 bad10 高于基准。
- row-level/separated 2025 分离消失，说明只靠 pooled 混合样本。
- 组件归因显示只有单一组件有效，双组件没有增量。
- 任一未来字段、未来标签或 H10 结果进入分数构造。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 通过 | 候选分数只使用 `unfavorable_run_len` 与 `confirmed_state_run_len`，由 `trade_date` 及之前状态滚动计算；未来 H10 只作标签 |
| 信号生成和成交价格不存在同 bar 泄漏 | 通过 | 本实验不生成成交，不创建策略配置 |
| 股票池或 ETF 池不存在未来成分泄漏 | 预注册沿用 | 沿用既有 LJQ7 面板，不新增成分选择 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 不使用财务、宏观或估值数据 |
| Shadow 或观察信号未被当成默认交易信号 | 通过 | 只读复核，不写 shadow/observe/live 配置 |

负控或错位检查：

- `shift_prev1`、`shift_next1` 在 segment 内按日期错位。
- episode-level random same support 使用固定 seed、同 top_n 数量抽样。
- 主门槛使用全 OOS episode pooled，2025 单段只做不反向约束。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | 固定两个组件等权；`TOP_FRAC=0.20`；不扫权重/窗口/top比例 |
| 样本内、验证集、样本外划分清楚 | 通过 | 采用 CJC9 同样滚动 OOS 切分：2020_2021 -> 2022_2023；2020_2023 -> 2024；2020_2024 -> 2025_20260519 |
| 邻近参数敏感性合理 | 不适用 | 本轮是机制压缩复核，不调邻近参数 |
| 成本、滑点或换手扰动已检查 | 不适用 | 只读风险排序 |
| 已做消融或负控 | 通过但未过 | 组件-only、五组件 proxy、shift、random、episode pooled 均输出；主候选随机和 shift gate 失败 |
| 未只报告最优结果 | 通过 | 输出所有候选和对照，未以后验最佳替代主候选 |

证据等级：`L0/L1-失败`。本实验是有效证伪，不支持交易化。

## 10. 子代理调用记录

适配判断：`适合调用`

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：当前多代理工具要求用户显式授权子代理/委派/并行 agent；本轮用户未显式授权；主控：main；时间：2026-06-18T14:37:08Z
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-EXEMPT-20260618T143708Z-main-2XKW | 无 | SUBTASK-2XKW-LIFECYCLE-PAIR-EXEMPT | 无 | 2026-06-18T14:37:08Z | M3VC summary；LJQ7 action panel；2XKW summary/CSV；MCYG方向文档 | 本实验记录；平台只读脚本；GNSM决策；台账待回填 | `PYTHONUNBUFFERED=1 PYTHONPATH=src python3 scripts/research/analyze_2xkw_lifecycle_pair_episode_readonly.py` | 只读机制压缩复核，不判断交易化 | episode样本少、随机复制、双组件重合 | 主控已复核 summary 和随机负控 | 支持 park/revise，不支持动作化 |

台账行：`SUB-EXEMPT-20260618T143708Z-main-2XKW` 已同步至 `01_台账/子代理调用台账.csv`。

## 11. 执行记录

### 平台配置

```text
${LEGACY_QUANT_PLATFORM_ROOT}/scripts/research/analyze_2xkw_lifecycle_pair_episode_readonly.py
${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260617T212938Z-main-LJQ7/ljq7_action_panel.csv
```

### 运行命令

```bash
cd ${QUANT_PLATFORM_ROOT}
PYTHONUNBUFFERED=1 PYTHONPATH=src python3 scripts/research/analyze_2xkw_lifecycle_pair_episode_readonly.py 2>&1 | tee results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T143708Z-main-2XKW/run.log
```

### 可见进度与日志

- 是否过程可见：`是`
- 日志路径：`${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T143708Z-main-2XKW/run.log`
- 查看进度命令：`Get-Content -Tail 80 "${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T143708Z-main-2XKW/run.log"`
- 异常判断：无异常退出；输出 213 行 OOS 日期样本、32 个 OOS episode。
- 后台回测豁免：不适用，前台可见运行。

### 结果路径

```text
${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T143708Z-main-2XKW/
```

## 12. 实际观察

| 指标 | 基准 | 本次 | 变化 | 解释 |
| --- | --- | --- | --- | --- |
| 总门槛 | 全部通过 | `readonly_pass=false` | 未过 | 随机和 shift gate 失败 |
| pooled episode top20 `bad10` | 基准 53.13% | 85.71% | `+32.59pct` | 表面很强 |
| pooled episode top20 下尾损失 | 基准 3.61% | 6.15% | `+2.55pct` | 表面很强 |
| pooled random top `bad10` p95 | 随机 95% | 85.71% | 与主分数相同 | 随机可复制 |
| pooled random tail loss p95 | 随机 95% | 6.26% | 高于主分数 6.15% | 下尾损失也未过随机 |
| shift_next1 | 日期错位 | top20 `bad10` lift `+32.59pct`、下尾损失 `+2.58pct` | 复制主结果 | 状态自相关解释很强 |
| 2025 episode | 基准 54.55% | top20 `bad10` 66.67%，low20 33.33% | 不反向 | 但不是决定性通过 |
| 2025 separated row | 基准 54.90% | top20 `+17.83pct`、low20 `-27.63pct` | 通过不反向 | 日期级仍有分离 |
| confirmed_state_only | 主候选诊断 | pooled tail lift `+4.65pct` | 强于双组件 | 只能作为后验线索，不能本实验升级 |

## 13. 支持证据

- 双组件在全 OOS episode pooled 上有强表面分离：top20 `bad10` lift `+32.59pct`，top20 下尾损失 lift `+2.55pct`，top20 趋势继续率低于基准 `-40.18pct`。
- 2025 单段未反向：episode top20 `bad10` lift `+12.12pct`，separated row top20 `bad10` lift `+17.83pct`、low20 `-27.63pct`。
- 诊断显示 `confirmed_state_only` 下尾损失分离更强，说明状态持续时间仍有研究价值。

## 14. 反对证据

- 随机门槛失败：pooled episode random top `bad10` p95 与主分数同为 `85.71%`，random tail loss p95 `6.26%` 还高于主分数 `6.15%`。
- shift gate 失败：`shift_next1` top20 `bad10` lift 同为 `+32.59pct`，下尾损失 lift `+2.58pct` 略高于主分数。
- 双组件没有相对单组件形成清晰增量；`confirmed_state_only` 在下尾损失上更强。
- 这说明双组件压缩仍可能只是状态自相关和少数 episode 的结果。

## 15. 偏差诊断

实验前预测认为“更少组件”会降低过拟合并打败 pooled episode 随机；实际相反：指标看起来强，但随机和错位都能复制。这说明 M3VC 的问题不只是组件太多，而是 episode 样本和状态自相关本身仍然过强。

## 16. 研究判断

建议状态：`park`

理由：`state_lifecycle_pair` 双组件方案没有通过 episode 级随机负控和错位负控，不能继续作为候选动作、shadow 或 observe。生命周期方向不 kill，因为 `confirmed_state_only` 给出新的单组件诊断线索；但它必须新开预注册，且只能作为只读复核。

## 17. 下一步

如果继续 MCYG，下一轮只能做一个更窄的单组件 `confirmed_state_run_len` 只读复核：

- 预注册为“后验诊断来源”，证据等级先降一档。
- 主门槛必须打败 pooled episode random 和 shift。
- 不能动作化、shadow、observe。
