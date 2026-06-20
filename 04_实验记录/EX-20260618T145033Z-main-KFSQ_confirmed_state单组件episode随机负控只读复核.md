---
type: 实验记录
ex_id: EX-20260618T145033Z-main-KFSQ
rd_id: RD-20260614T115209Z-main-MCYG
status: completed
stage: readonly_completed_pass_external_validation_candidate_no_action
owner: main
created_at: 2026-06-18T14:50:33Z
updated_at: 2026-06-18T14:54:29Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 防御模块事前暴露管理层
decision_ids:
  - DEC-20260618T145429Z-main-VRMQ
lit_ids: []
idea_ids: []
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths:
  - scripts/research/analyze_kfsq_confirmed_state_episode_readonly.py
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T143708Z-main-2XKW/scored_oos_panel.csv
result_paths:
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T145033Z-main-KFSQ/
summary_paths:
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T145033Z-main-KFSQ/summary.json
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T145033Z-main-KFSQ/score_summary.csv
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T145033Z-main-KFSQ/random_control_summary.csv
quality_gate: readonly_pass_external_validation_candidate
subagent_call_ids:
  - SUB-EXEMPT-20260618T145033Z-main-KFSQ
subagent_exemption: 当前多代理工具要求用户显式授权子代理/委派/并行 agent；本轮用户未显式授权。
tags:
  - 非R方
  - 低滞后
  - episode级
  - 单组件
  - 后验诊断来源
  - 只读
---

# confirmed_state单组件episode随机负控只读复核

## 关联链接

- 研究方向：[[02_研究方向/RD-20260614T115209Z-main-MCYG_双池轮动动量崩溃事前暴露管理|RD-20260614T115209Z-main-MCYG 动量崩溃事前暴露管理]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 来源实验：[[04_实验记录/EX-20260618T143708Z-main-2XKW_生命周期双组件episode级随机负控只读复核|EX-20260618T143708Z-main-2XKW 生命周期双组件episode级随机负控只读复核]]
- 产生的决策：[[05_研究决策/DEC-20260618T145429Z-main-VRMQ_confirmed_state单组件通过后进入外部验证候选|DEC-20260618T145429Z-main-VRMQ confirmed_state单组件通过后进入外部验证候选]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：2XKW 失败后，后验诊断里 `confirmed_state_only` 的下尾损失分离更强。单独用 `confirmed_state_run_len`，能不能打败 episode pooled 随机和 shift。  
我们原本预计：如果真正有效的是“确认状态本身持续时间”，单组件应比双组件少一些自相关噪音，并在下尾损失上打败随机和 shift。  
实际看到：`readonly_pass=true`。全 OOS episode pooled 的 top20 下尾损失 lift 为 `+4.65pct`，高于随机 95% 分位 `+2.55pct`，也高于 shift_next1 的 `+2.58pct`；低风险桶 `bad10` lift 为 `-38.84pct`，低于随机 5% 分位 `-24.55pct`。  
这说明：`confirmed_state_run_len` 单组件比双组件更干净，至少在当前 OOS episode pooled 上打败了随机下尾损失和 shift 下尾损失。  
但还不能说明：它来自 2XKW 后验诊断，不是独立发现；不能交易化、shadow、observe 或改实盘，只能作为外部验证候选。  
下一步要做：寻找外部事件样本、真实观察流或 dry-run 日志验证该单组件；在没有新样本前，不再调本组件。

## 2. 研究背景

2XKW 已经证伪 `unfavorable_run_len + confirmed_state_run_len` 双组件压缩：pooled episode top20 `bad10` lift `+32.59pct` 被随机 p95 和 `shift_next1` 复制。但 2XKW 的组件诊断显示 `confirmed_state_only` 在 pooled episode 下尾损失 lift 更高，为 `+4.65pct`。这是后验线索，不能直接升级；本实验只用于判断它是否值得外部验证。

## 3. 实验前假设

固定 `confirmed_state_run_len` 单组件的 OOS empirical CDF 分数后，若确认状态持续时间是真实风险生命周期信号，它应在全 OOS episode pooled 的下尾损失和坏路径上同时强于随机同规模与 shift 控制。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：全 OOS episode pooled top20 `tail_loss10` lift 必须高于随机 95% 分位，并高于 shift_prev1/shift_next1；top20 `bad10` lift 至少不弱于随机 95% 分位。
- 交易行为：无交易行为。本实验只读，不生成策略配置，不进入 smoke/formal，不产生 shadow、observe 或实盘信号。
- 风险表现：高分 episode 的下尾损失高于基准，低分 episode 的 bad10 和下尾损失低于基准。
- 分段表现：2025 episode-level 不反向；2025 row separated 仍有正向分离。
- 证据等级：因为候选来自 2XKW 后验诊断，通过也只能进入“外部验证候选”，不能视为独立样本通过。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| 2XKW scored OOS panel | 读取已按滚动训练段生成的 `confirmed_state_only_score` | `${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T143708Z-main-2XKW/scored_oos_panel.csv` |
| `state_lifecycle_pair` | 双组件对照 | 2XKW 输出 |
| shift prev/next | `confirmed_state_only_score` 日期错位负控 | 脚本内固定生成 |
| random same support | episode 级同规模随机负控 | 脚本内固定 seed `20260618` |

## 6. 竞争性解释

即使结果符合预期，也可能是：

- 候选来自 2XKW 后验诊断，同样存在选择偏差。
- `confirmed_state_run_len` 可能只是状态自相关，不是可交易风险。
- episode label 仍可能同时包含趋势继续与回撤，不能直接变成降仓动作。

## 7. 证伪条件

出现以下情况，本假设不通过：

- 全 OOS episode pooled top20 下尾损失 lift 不能打败随机 95% 分位。
- shift_prev1 或 shift_next1 复制或超过主分数的下尾损失 lift。
- 2025 episode-level 或 separated row 明显反向。
- 结果只优于双组件但不优于随机/shift。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 通过 | 使用 2XKW 已按训练段 empirical CDF 生成的 `confirmed_state_only_score`，未来 H10 只作标签 |
| 信号生成和成交价格不存在同 bar 泄漏 | 通过 | 本实验不生成成交，不创建策略配置 |
| 股票池或 ETF 池不存在未来成分泄漏 | 预注册沿用 | 沿用 LJQ7/2XKW 面板，不新增成分选择 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 不使用财务、宏观或估值数据 |
| Shadow 或观察信号未被当成默认交易信号 | 通过 | 只读复核，不写 shadow/observe/live 配置 |

负控或错位检查：

- 对 `confirmed_state_only_score` 重新生成 shift_prev1/shift_next1。
- episode-level random same support 固定 seed `20260618`。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | 单组件固定，不扫权重/窗口/top比例/seed |
| 样本内、验证集、样本外划分清楚 | 通过但后验候选 | 复用 2XKW 的 CJC9 同口径 OOS scored panel；候选来自 2XKW 后验诊断 |
| 邻近参数敏感性合理 | 不适用 | 单组件只读复核 |
| 成本、滑点或换手扰动已检查 | 不适用 | 只读风险排序 |
| 已做消融或负控 | 通过 | shift、random、双组件对照均输出 |
| 未只报告最优结果 | 通过 | 主候选固定为 `confirmed_state_only` |

证据等级：`L1-候选`。通过只代表外部验证候选，不代表可交易。

## 10. 子代理调用记录

适配判断：`适合调用`

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：当前多代理工具要求用户显式授权子代理/委派/并行 agent；本轮用户未显式授权；主控：main；时间：2026-06-18T14:50:33Z
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-EXEMPT-20260618T145033Z-main-KFSQ | 无 | SUBTASK-KFSQ-CONFIRMED-STATE-EXEMPT | 无 | 2026-06-18T14:50:33Z | 2XKW scored panel；KFSQ summary/CSV；MCYG方向文档 | 本实验记录；平台只读脚本；VRMQ决策；台账已同步 | `PYTHONUNBUFFERED=1 PYTHONPATH=src python3 scripts/research/analyze_kfsq_confirmed_state_episode_readonly.py` | 只读单组件复核，不判断交易化 | 后验选择偏差、shift复制、episode样本小 | 主控已复核 summary 和随机/shift | 支持外部验证候选，不支持动作化 |

台账行：已同步至 `01_台账/子代理调用台账.csv`。

## 11. 执行记录

### 平台配置

```text
${QUANT_PLATFORM_ROOT}/scripts/research/analyze_kfsq_confirmed_state_episode_readonly.py
${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T143708Z-main-2XKW/scored_oos_panel.csv
```

### 运行命令

```bash
cd ${QUANT_PLATFORM_ROOT}
PYTHONUNBUFFERED=1 PYTHONPATH=src python3 scripts/research/analyze_kfsq_confirmed_state_episode_readonly.py 2>&1 | tee results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T145033Z-main-KFSQ/run.log
```

### 可见进度与日志

- 是否过程可见：`是`
- 日志路径：`${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T145033Z-main-KFSQ/run.log`
- 查看进度命令：`Get-Content -Tail 80 "${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T145033Z-main-KFSQ/run.log"`
- 异常判断：无异常退出；输出 213 行 OOS 日期样本、32 个 OOS episode。
- 后台回测豁免：不适用，前台可见运行。

### 结果路径

```text
${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T145033Z-main-KFSQ/
```

## 12. 实际观察

| 指标 | 基准 | 本次 | 变化 | 解释 |
| --- | --- | --- | --- | --- |
| 总门槛 | 全部通过 | `readonly_pass=true` | 通过 | 仅外部验证候选 |
| pooled episode top20 `bad10` | 基准 53.13% | 85.71% | `+32.59pct` | 与随机 p95 持平，不是主要通过点 |
| pooled episode top20 下尾损失 | 基准 3.61% | 8.25% | `+4.65pct` | 高于随机和 shift |
| random tail loss p95 | 随机 95% | 6.15% | 主分数高出约 `+2.10pct` | 随机下尾过关 |
| shift_next1 下尾损失 lift | 日期错位 | `+2.58pct` | 主分数高出约 `+2.07pct` | shift 下尾过关 |
| low20 `bad10` | 基准 53.13% | 14.29% | `-38.84pct` | 低风险桶明显干净 |
| 2025 row top20 `bad10` | 基准 54.90% | 90.91% | `+36.01pct` | 近端不反向 |
| 2025 episode top20 下尾损失 | 基准 4.05% | 7.23% | `+3.18pct` | 近端 episode 不反向 |

## 13. 支持证据

- 主候选全 OOS episode pooled 下尾损失 lift `+4.65pct`，高于随机 95% 分位 `+2.55pct`。
- 主候选下尾损失 lift 高于 shift_prev1 `+2.19pct` 和 shift_next1 `+2.58pct`。
- 低风险桶 `bad10` lift `-38.84pct`，低于随机 low bad 5% 分位 `-24.55pct`。
- 相比 2XKW 双组件，下尾损失 lift 从 `+2.55pct` 提升到 `+4.65pct`。

## 14. 反对证据

- 候选来自 2XKW 后验诊断，不是独立先验发现。
- top20 `bad10` rate 与随机 p95 持平，主通过点是下尾损失而不是坏路径事件率。
- episode 样本仍只有 32 个，2025 只有 11 个 episode。
- 不能据此进入 shadow、observe 或交易动作。

## 15. 偏差诊断

实验前预测认为单组件应在下尾损失上比双组件更干净；实际符合。但 `bad10` 事件率没有打败随机 p95，只是持平。这说明 `confirmed_state_run_len` 更像“下尾严重度”信号，而不是纯粹的坏路径发生概率信号。

## 16. 研究判断

建议状态：`promote_candidate`

理由：KFSQ 通过只读门槛，但因候选来自 2XKW 后验诊断，只能作为外部验证候选；不得动作化、shadow、observe 或改实盘。

## 17. 下一步

下一步不在当前样本继续调参。应寻找外部事件样本、真实观察流或 dry-run 日志，只记录 `confirmed_state_run_len` 单组件分数并验证：

- episode pooled 下尾损失是否仍打败随机和 shift。
- 2025 以后新样本是否不反向。
- 若没有新样本，不进入动作、shadow 或 observe。
