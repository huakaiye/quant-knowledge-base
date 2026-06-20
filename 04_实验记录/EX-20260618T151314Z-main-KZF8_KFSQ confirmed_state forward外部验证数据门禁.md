---
type: 实验记录
ex_id: EX-20260618T151314Z-main-KZF8
rd_id: RD-20260614T115209Z-main-MCYG
status: completed
stage: readonly_completed_insufficient_forward_h10_labels_no_action
owner: main
created_at: 2026-06-18T15:13:14Z
updated_at: 2026-06-18T15:24:00Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 防御模块事前暴露管理层
decision_ids:
  - DEC-20260618T152400Z-main-6JF6
lit_ids: []
idea_ids: []
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths:
  - configs/research/RD-20260614T115209Z-main-MCYG/EX-20260618T151314Z-main-KZF8/kzf8_continuous_forward_hard5_20260520_20260617.json
  - scripts/research/analyze_kzf8_kfsq_forward_validation_readonly.py
result_paths:
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T151314Z-main-KZF8/
summary_paths:
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T151314Z-main-KZF8/summary.json
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T151314Z-main-KZF8/forward_score_summary.csv
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T151314Z-main-KZF8/forward_random_control_summary.csv
quality_gate: external_validation_data_gate_failed_insufficient_h10_labels
subagent_call_ids:
  - SUB-EXEMPT-20260618T151000Z-main-EXTV
subagent_exemption: 当前多代理工具要求用户显式授权子代理/委派/并行 agent；本轮用户未显式授权。
tags:
  - 非R方
  - 低滞后
  - forward
  - 外部验证
  - 数据门禁
  - 只读
---

# KFSQ confirmed_state forward外部验证数据门禁

## 关联链接

- 研究方向：[[02_研究方向/RD-20260614T115209Z-main-MCYG_双池轮动动量崩溃事前暴露管理|RD-20260614T115209Z-main-MCYG 动量崩溃事前暴露管理]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 来源实验：[[04_实验记录/EX-20260618T145033Z-main-KFSQ_confirmed_state单组件episode随机负控只读复核|EX-20260618T145033Z-main-KFSQ confirmed_state单组件episode随机负控只读复核]]
- 产生的决策：[[05_研究决策/DEC-20260618T152400Z-main-6JF6_KFSQ forward外部验证数据不足后继续等待新样本|DEC-20260618T152400Z-main-6JF6 KFSQ forward 外部验证数据不足后继续等待新样本]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：KFSQ 中表现最干净的 `confirmed_state_run_len` 单组件，离开历史 OOS 样本后，在 2026-05-20 到 2026-06-17 的 forward 连续窗口里是否还能提前指向未来 H10 下尾损失。  
我们原本预计：如果它确实是低滞后风险生命周期信号，forward H10 的高分 episode 应该比低分 episode 和随机同规模组合更容易出现下尾损失；如果样本太少，则必须停在数据门禁，不允许解释成通过或失败。  
实际看到：连续 hard5 forward 窗口共有 `21` 个交易日，其中 A0/A1/A2 分别为 `6/7/8` 行；A1 主宇宙集中在 2026-06-05 到 2026-06-15，导致 H10 可标注行数为 `0`、episode 数为 `0`，H5 也只有 `2` 行、`1` 个 episode。  
这说明：现有 forward 样本不足以验证 KFSQ。它不是通过，也不是失败；它只证明现在还没有足够的新样本。  
但还不能说明：不能据此说 `confirmed_state_run_len` 外部验证失败，也不能说它能交易化、shadow、observe 或改实盘。  
下一步要做：保留 KFSQ 为外部验证候选，等真实观察流、dry-run 或更长 forward 样本积累到 H10 `>=20` 行且 `>=5` 个 episode 后再复验。

## 2. 研究背景

本实验属于 [[02_研究方向/RD-20260614T115209Z-main-MCYG_双池轮动动量崩溃事前暴露管理|MCYG 动量崩溃事前暴露管理]]。KFSQ 已经在历史 OOS episode pooled 上显示：单独使用 `confirmed_state_run_len` 的下尾损失分离强于双组件、随机和 shift。但 KFSQ 的候选来自 2XKW 后验诊断，必须转入外部验证。  

现有 forward 资料分成 LWC4（2026-05-20 到 2026-06-05）和 8UP9（2026-06-08 到 2026-06-17）两段，净值曲线各自从 100000 起算，直接拼接会把跨段 H10 标签污染。因此本实验先补一个连续 hard5 基线窗口，用同一条净值曲线生成 H5/H10 标签。

## 3. 实验前假设

固定 `confirmed_state_run_len` 单组件，不调阈值、不调窗口、不调 top 比例；若该信号真的低滞后，forward H10 episode 中高分桶的下尾损失应强于随机同规模和日期错位控制。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：H10 可标注行数不少于 20 且 episode 数不少于 5；在满足数据门禁后，episode 高分桶的 `tail_loss_h10` lift 高于随机 95% 分位，并高于 shift_prev1/shift_next1。
- 交易行为：不产生任何交易动作。本实验只跑 hard5 基线用于生成连续日志和权益曲线，分析脚本只读，不写 shadow、observe 或实盘配置。
- 风险表现：高分 episode 的 H10 下尾损失更重，低分 episode 的坏路径率更低。
- 分段表现：只有一个 forward 连续窗口，不做历史段内再切分；H5 只作为早期诊断，不作为通过依据。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| 历史 KFSQ/2XKW OOS 面板 | 用 2026-05-19 以前的 `confirmed_state_run_len` 经验分布给 forward 打分 | `${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T143708Z-main-2XKW/scored_oos_panel.csv` |
| 连续 hard5 forward 基线 | 生成 2026-05-20 到 2026-06-17 的连续 ACTION 日志和权益曲线 | `${QUANT_PLATFORM_ROOT}/configs/research/RD-20260614T115209Z-main-MCYG/EX-20260618T151314Z-main-KZF8/kzf8_continuous_forward_hard5_20260520_20260617.json` |
| shift_prev1/shift_next1 | 日期错位负控 | 分析脚本内固定生成 |
| random same support | episode 同规模随机负控 | 分析脚本内固定 seed `20260618` |

## 6. 竞争性解释

即使结果符合预期，也可能是：

- 这段 forward 太短，episode 数可能不足，观察值受个别日期主导。
- 2026-05-20 到 2026-06-17 本身是 A22 forward/OOS 检查窗口，市场状态可能单一，无法代表完整崩溃生命周期。
- `confirmed_state_run_len` 可能只是在描述状态持续性，不一定能转化成动作收益。

## 7. 证伪条件

出现以下情况，本假设不通过：

- 在满足 H10 数据门禁后，episode 高分桶 `tail_loss_h10` lift 不能打败随机 95% 分位。
- shift_prev1 或 shift_next1 复制或超过主分数的下尾损失 lift。
- 低分桶不能显示更低的坏路径率或更轻下尾损失。
- 如果 H10 可标注行数少于 20 或 episode 数少于 5，本实验不判定通过或失败，只判定“forward 数据不足”。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 通过 | forward 分数只使用当日 `confirmed_state_run_len`；未来 H10 仅作为标签，且 H10 数据不足时不判定通过 |
| 信号生成和成交价格不存在同 bar 泄漏 | 通过 | 连续 hard5 基线复用既有策略配置；KZF8 不新增交易规则 |
| 股票池或 ETF 池不存在未来成分泄漏 | 预注册沿用 | 沿用 hard5/R010-B 既有 ETF 池和平台数据口径 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 不使用财务、宏观或估值数据 |
| Shadow 或观察信号未被当成默认交易信号 | 通过 | 不写 shadow、observe、live 配置，不改默认逻辑 |

负控或错位检查：

- 对 forward 的 `confirmed_state_only_score` 生成 shift_prev1/shift_next1。
- episode 级 random same support 固定 seed `20260618`。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | 单组件固定、`TOP_FRAC=0.20`、`MIN_H10_ROWS=20`、`MIN_H10_EPISODES=5` |
| 样本内、验证集、样本外划分清楚 | 通过 | 历史 OOS 面板只用于经验 CDF；forward 2026-05-20 以后只用于外部验证 |
| 邻近参数敏感性合理 | 不适用 | 不做参数扫描 |
| 成本、滑点或换手扰动已检查 | 不适用 | 只读风险排序，不评估动作收益 |
| 已做消融或负控 | 数据不足未触发 | H10 主宇宙为空，shift/random 只能生成空样本占位，不参与结论 |
| 未只报告最优结果 | 通过 | H10 为主门槛，H5 只作为诊断；H5 两行未被解释成通过 |

证据等级：预注册为 `L1-外部验证候选门禁`。只有数据门禁和指标门槛同时通过，才可升级为外部验证通过候选。

## 10. 子代理调用记录

适配判断：`适合调用`

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：当前多代理工具要求用户显式授权子代理/委派/并行 agent；本轮用户未显式授权；主控：main；时间：2026-06-18T15:10:00Z
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-EXEMPT-20260618T151000Z-main-EXTV | 无 | SUBTASK-KFSQ-EXTERNAL-VALIDATION-EXEMPT | 无 | 2026-06-18T15:10:00Z | KFSQ/2XKW 输出；LWC4/8UP9 forward 路径；hard5 配置；KZF8 summary/CSV | 本实验记录；平台配置；平台只读脚本；6JF6决策；台账待同步 | `run_v2_backtest.py --config ...kzf8...json`；`analyze_kzf8_kfsq_forward_validation_readonly.py` | 只判断外部验证数据门禁，不判断交易化 | forward A1 出现太晚，H10 主宇宙为空 | 主控已复核 ACTION 分布和 summary | 支持“数据不足，候选保留，不升级” |

台账行：已同步至 `01_台账/子代理调用台账.csv`。

## 11. 执行记录

### 平台配置

```text
${QUANT_PLATFORM_ROOT}/configs/research/RD-20260614T115209Z-main-MCYG/EX-20260618T151314Z-main-KZF8/kzf8_continuous_forward_hard5_20260520_20260617.json
${QUANT_PLATFORM_ROOT}/scripts/research/analyze_kzf8_kfsq_forward_validation_readonly.py
```

### 运行命令

```bash
cd ${QUANT_PLATFORM_ROOT}
PYTHONUNBUFFERED=1 PYTHONPATH=src python3 src/run_v2_backtest.py --config configs/research/RD-20260614T115209Z-main-MCYG/EX-20260618T151314Z-main-KZF8/kzf8_continuous_forward_hard5_20260520_20260617.json 2>&1 | tee results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T151314Z-main-KZF8/run_continuous_forward_hard5.log

PYTHONUNBUFFERED=1 PYTHONPATH=src python3 scripts/research/analyze_kzf8_kfsq_forward_validation_readonly.py 2>&1 | tee results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T151314Z-main-KZF8/run_analysis.log
```

### 可见进度与日志

- 是否过程可见：`是`
- 日志路径：`${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T151314Z-main-KZF8/run_continuous_forward_hard5.log`；`${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T151314Z-main-KZF8/run_analysis.log`
- 查看进度命令：`Get-Content -Tail 80 "${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T151314Z-main-KZF8/run_continuous_forward_hard5.log"`
- 异常判断：无异常退出；连续 hard5 final `104976.11`，交易 `35` 笔；只读分析输出 `status=insufficient_forward_h10_labels`
- 后台回测豁免：不适用，前台可见运行

### 结果路径

```text
${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T151314Z-main-KZF8/
```

## 12. 实际观察

| 指标 | 基准 | 本次 | 变化 | 解释 |
| --- | --- | --- | --- | --- |
| 连续 forward 总行数 | 无 | `21` | 生成成功 | 避免了 LWC4/8UP9 分段净值重置 |
| hard5 final | `100000` 初始资金 | `104976.11` | `+4.98%` | 仅用于生成连续路径标签，不评价策略收益 |
| ACTION 分布 | 无 | A0/A1/A2 = `6/7/8` | A1 只有 7 行 | KFSQ 主宇宙依赖 A1，样本不足 |
| H10 可标注行数 | 门槛 `>=20` | `0` | 未过 | A1 出现在窗口后段，没有足够未来 10 个交易日 |
| H10 episode 数 | 门槛 `>=5` | `0` | 未过 | 不能做 episode pooled 随机/shift 验证 |
| H5 可标注行数 | 诊断项 | `2` | 不作为通过依据 | 2 行均属于同一 episode，样本过小 |
| H5 episode 数 | 诊断项 | `1` | 不作为通过依据 | 单 episode 不能代表外部验证 |
| 外部验证结论 | 必须数据门禁 + 指标门槛同时过 | `external_validation_pass=false`；`status=insufficient_forward_h10_labels` | 数据不足 | 不升级、不判死 |

## 13. 支持证据

- 连续 hard5 forward 回测成功，报告目录为 `${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T151314Z-main-KZF8/continuous_forward_hard5/forward_20260520_20260617/53cc37e7beac433e8d84ad6fc19eca1e/`。
- 只读脚本使用 2XKW 历史 OOS 面板经验 CDF 给 forward `confirmed_state_run_len` 打分，没有重训、调参或交易化。
- H10 数据门禁明确失败：`h10_label_rows=0`，`h10_episode_count=0`，低于预注册门槛 `20/5`。
- H5 只有 `2` 行且 `1` 个 episode，说明即使用短 horizon 也不能形成可靠验证。

## 14. 反对证据

- 本实验没有得到任何可判定的 H10 外部指标，因此不能支持 KFSQ 外部验证通过。
- forward 窗口短，且 A1 只在后段出现，造成标签不可用。
- 当前观察不反证 KFSQ，因为主门槛样本为空；不能把空样本写成失败。

## 15. 偏差诊断

实验前预测允许两种结果：信号通过外部验证，或样本不足停在数据门禁。实际落在第二种。偏差点在于：我们预期连续 21 个交易日至少可能提供部分 H10 A1 样本，但实际 A1 从 2026-06-05 后才集中出现，导致从任一 A1 日期向后数都不足 10 个交易日。

## 16. 研究判断

建议状态：`promote_candidate_retained_data_insufficient`

理由：KZF8 只说明当前 forward 数据不足，不能升级 KFSQ，也不能证伪 KFSQ。KFSQ 的 `confirmed_state_run_len` 单组件仍保留为外部验证候选，但不得动作化、shadow、observe 或改实盘。

## 17. 下一步

下一轮最值得做的不是继续滚动短窗，而是等到真实观察流、dry-run 或 forward 样本中出现至少 `20` 条 H10 可标注 A1 行和 `5` 个 A1 episode 后，再按同一脚本重跑外部验证。若要更快推进，应优先建设自动记录 `confirmed_state_run_len` 的 dry-run 日志，而不是在当前样本上调参数。
