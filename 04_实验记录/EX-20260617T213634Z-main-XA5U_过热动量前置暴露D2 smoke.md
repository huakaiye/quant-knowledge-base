---
type: 实验记录
ex_id: EX-20260617T213634Z-main-XA5U
rd_id: RD-20260614T115209Z-main-MCYG
status: completed
stage: smoke_completed_pass_formal_candidate
owner: main
created_at: 2026-06-17T21:36:34Z
updated_at: 2026-06-17T21:58:00Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 防御模块事前暴露管理层
decision_ids: [DEC-20260617T215629Z-main-UARF]
lit_ids: [LIT-20260614T112631Z-main-VY4K]
idea_ids: []
platform_project: ${LEGACY_QUANT_PLATFORM_ROOT}
config_paths:
  - scripts/research/generate_xa5u_r010d_overheat_smoke_configs.py
  - configs/research/RD-20260614T115209Z-main-MCYG/EX-20260617T213634Z-main-XA5U/smoke/
result_paths:
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260617T213634Z-main-XA5U/smoke/
summary_paths:
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260617T213634Z-main-XA5U/smoke/summary/summary.json
quality_gate: economic_smoke_pass
subagent_call_ids: []
subagent_exemption: 当前可用子代理工具需用户显式要求委派/并行 agent，本轮没有显式授权；主控：main；时间：2026-06-17T21:41:00Z
tags: [双池轮动, 防御模块, 动量崩溃, 过热动量, R010D, smoke, DM修订]
---

# 过热动量前置暴露D2 smoke

## 关联链接

- 研究方向：[[02_研究方向/RD-20260614T115209Z-main-MCYG_双池轮动动量崩溃事前暴露管理|双池轮动动量崩溃事前暴露管理]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 来源文献或灵感：[[06_文献资料/00_待处理/LIT-20260614T112631Z-main-VY4K_动量崩溃保护Daniel Moskowitz 2016|动量崩溃保护 Daniel Moskowitz 2016]]；[[04_实验记录/EX-20260617T212938Z-main-LJQ7_DM前置风险标签只读面板|LJQ7 DM 前置风险标签只读面板]]
- 产生的决策：[[05_研究决策/DEC-20260617T215629Z-main-UARF_过热动量D2 smoke通过后进入formal|过热动量 D2 smoke 通过后进入 formal]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：  
LJQ7 的 broad-any 风险标签没有通过，但“过热动量”子标签看起来更像前置信号。XA5U 只验证平台已有 `R010D_D2_OVERHEAT` 动作在 2024 段真实组合里是否有经济意义。  
我们原本预计：  
如果过热动量是可用的前置风险，D2-overheat 应该在不明显伤 final 的情况下改善 2024 最大回撤，并且实际触发不少于 5 次。  
实际看到：  
2024 当前代码口径 baseline final `167005.22`、MDD `-26.99%`、交易 `281`；D2-overheat final `181373.71`、MDD `-22.80%`、交易 `255`，触发 `36` 次。  
这说明：  
过热动量不只是只读统计线索，迁移到真实组合后在 2024 smoke 中同时改善收益、回撤和交易数。  
但还不能说明：  
2024 smoke 通过也不能 promote，只能支持四段 formal + 成本/延迟/随机负控。  
下一步要做：  
先跑当前代码口径 baseline 和 `r010d_d2_overheat_cap90_keep_current` 两个 2024 smoke 配置。

## 2. 研究背景

本实验属于 [[02_研究方向/RD-20260614T115209Z-main-MCYG_双池轮动动量崩溃事前暴露管理|MCYG]]。

LJQ7 主标签 `front_existing_any` 失败，原因是 broad-any 覆盖太宽且滞后：主标签 53.3% 触发时已经处于 20 日回撤 5% 之后，H10 路径风险只比未标记 A1 多差 0.73pp，未达到预注册 1pp。但预注册子标签 `front_existing_overheated_momentum` 表现更集中：总支持度 188，H10 路径风险比未标记 A1 多差 1.35pp，`preemptive_bad10_lift` 约 20.1pp，且 delay5/future5/random 负控均弱于主标签。

平台代码中已有 `R010D_D2_OVERHEAT` 研究动作：A1 且强动量过热时，优先保留旧仓并限制新追高，风险仓 cap 为 90%。本实验不改阈值、不扫 cap，只检验已有动作的 2024 经济烟测。

## 3. 实验前假设

只验证已有 `R010D_D2_OVERHEAT(cap=0.90, keep_current=true)` 在 2024 段是否相对当前 B3/tiered-v2 baseline 改善最大回撤，且 final 不显著受损。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：candidate final 不低于 baseline 的 98%；candidate 最大回撤较 baseline 改善至少 0.5pp。
- 交易行为：`R010D_D2_OVERHEAT` 实际触发不少于 5 次；若触发很少则视为无效 smoke。
- 风险表现：候选不应复制 J7EF 的问题，即 final 和 MDD 同时差于 baseline。
- 分段表现：本轮只跑 2024 smoke；通过后才允许新开四段 formal，不在本实验中补跑其他分段。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| baseline_b3_tiered_v2_current | 当前代码口径 baseline，避免用旧代码结果比较新候选 | `${LEGACY_QUANT_PLATFORM_ROOT}/configs/research/RD-20260614T115209Z-main-MCYG/EX-20260617T213634Z-main-XA5U/smoke/baseline_b3_tiered_v2_current/xa5u_baseline_b3_tiered_v2_current_2024.json` |
| r010d_d2_overheat_cap90_keep_current | 只启用已有 R010D D2-overheat 动作 | `${LEGACY_QUANT_PLATFORM_ROOT}/configs/research/RD-20260614T115209Z-main-MCYG/EX-20260617T213634Z-main-XA5U/smoke/r010d_d2_overheat_cap90_keep_current/xa5u_r010d_d2_overheat_cap90_keep_current_2024.json` |

## 6. 竞争性解释

即使结果符合预期，也可能是：

- 2024 恰好适合过热动量，其他分段会错过趋势。
- cap=90% 太轻，回撤改善可能来自保留旧仓而不是仓位降低。
- 当前 baseline 和候选都受平台未提交代码影响，因此只能作为同口径 smoke，不是最终历史证据。
- 触发次数若过少，单次路径事件可能主导结果。

## 7. 证伪条件

出现以下情况，本假设不通过：

- candidate final < baseline final 的 98%。
- candidate 最大回撤改善 < 0.5pp。
- `R010D_D2_OVERHEAT` 触发少于 5 次。
- final 和最大回撤同时差于 baseline。
- 运行日志显示 R010D 未启用、未进入 `enabled_actions`，或 action 字段不符合预注册配置。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | smoke 通过 | 只启用平台已有 `r010d_a1_overheated_momentum_risk`，由交易日前已有 ACTION 字段派生 |
| 信号生成和成交价格不存在同 bar 泄漏 | smoke 通过 | 沿用 R010-B4 13:09/13:10 执行框架，本轮不新增盘中字段 |
| 股票池或 ETF 池不存在未来成分泄漏 | 沿用 baseline 风险 | 不新建池、不改池 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 本轮不使用此类数据 |
| Shadow 或观察信号未被当成默认交易信号 | 预注册通过 | smoke 结果只允许决定是否进入 formal，不改实盘 |

负控或错位检查：

- 本轮是 economic smoke，只设置 current-code baseline 对照；若 smoke 通过，下一实验必须补四段 formal、延迟一日触发、随机 overheat 日期和成本扰动。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | 只测一个已有动作：`d2_overheat cap=0.90 keep_current=true` |
| 样本内、验证集、样本外划分清楚 | 通过 | 仅 2024 smoke；不把结果当 formal |
| 邻近参数敏感性合理 | 不适用 | 不扫 cap、不扫阈值 |
| 成本、滑点或换手扰动已检查 | 待后续 | smoke 通过后才做成本扰动 |
| 已做消融或负控 | 部分 | 当前代码口径 baseline；延迟/随机负控留给 formal |
| 未只报告最优结果 | 通过 | 两个固定配置都汇总 |

证据等级：`L2 经济烟测`。通过也不能 promote。

## 10. 子代理调用记录

适配判断：`不适合调用`

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：当前可用子代理工具需用户显式要求委派/并行 agent，本轮没有显式授权；主控：main；时间：2026-06-17T21:41:00Z
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |

台账行：

无；本轮没有实际子代理调用。

## 11. 执行记录

### 平台配置

```text
平台项目：${QUANT_PLATFORM_ROOT}
生成脚本：scripts/research/generate_xa5u_r010d_overheat_smoke_configs.py
汇总脚本：scripts/research/summarize_xa5u_r010d_overheat_smoke.py
配置目录：configs/research/RD-20260614T115209Z-main-MCYG/EX-20260617T213634Z-main-XA5U/smoke/
```

### 运行命令

```bash
cd ${QUANT_PLATFORM_ROOT}
PYTHONUNBUFFERED=1 PYTHONPATH=src python3 scripts/research/generate_xa5u_r010d_overheat_smoke_configs.py
PYTHONUNBUFFERED=1 PYTHONPATH=src python3 src/run_v2_backtest.py --config configs/research/RD-20260614T115209Z-main-MCYG/EX-20260617T213634Z-main-XA5U/smoke/baseline_b3_tiered_v2_current/xa5u_baseline_b3_tiered_v2_current_2024.json
PYTHONUNBUFFERED=1 PYTHONPATH=src python3 src/run_v2_backtest.py --config configs/research/RD-20260614T115209Z-main-MCYG/EX-20260617T213634Z-main-XA5U/smoke/r010d_d2_overheat_cap90_keep_current/xa5u_r010d_d2_overheat_cap90_keep_current_2024.json
PYTHONUNBUFFERED=1 PYTHONPATH=src python3 scripts/research/summarize_xa5u_r010d_overheat_smoke.py
```

### 可见进度与日志

- 是否过程可见：`是`
- 日志路径：`${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260617T213634Z-main-XA5U/smoke/`
- 查看进度命令：前台 WSL 命令直接输出；结果汇总见 `summary/summary.json`。
- 异常判断：任一回测非 0 退出、summary 缺失、R010D 触发少于 5、经济门槛失败。
- 后台回测豁免：不适用。

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
results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260617T213634Z-main-XA5U/smoke/
```

## 12. 实际观察

| 指标 | 基准 | 本次 | 变化 | 解释 |
| --- | --- | --- | --- | --- |
| final_value | `167005.22` | `181373.71` | `+14368.49` | 通过“不低于 baseline 98%”门槛 |
| max_drawdown | `-26.99%` | `-22.80%` | 改善 `4.20pp` | 通过“改善至少 0.5pp”门槛 |
| total_return | `67.01%` | `81.37%` | `+14.37pp` | 2024 smoke 有经济增量 |
| annual_return | `67.24%` | `81.67%` | `+14.43pp` | 同口径比较 |
| trades | `281` | `255` | `-26` | 没有通过加交易换收益 |
| R010D 触发 | `0` | `36` | `+36` | 通过触发不少于 5 次门槛 |
| quality gate | - | `economic_smoke_pass=true` | 通过 | 只允许进入四段 formal，不允许 promote |

## 13. 支持证据

- D2-overheat 同时改善 final、MDD 和交易数，未复制 J7EF “收益和回撤同时变差”的问题。
- 当前代码口径 baseline 复现历史 R010-B4 2024 结果，说明比较口径干净。
- 触发 36 次，说明不是无触发或单次事件偶然。

## 14. 反对证据

- 只有 2024 smoke，不能证明 2020_2021、2022_2023 和 2025_20260519 稳定有效。
- `keep_current=true` 可能把收益改善主要来自“少追高/少换仓”，而不是仓位 cap；formal 需要拆动作归因。
- 尚未做延迟一日触发、随机 overheat 日期、成本扰动和四段样本外。

## 15. 偏差诊断

结果强于预期：不仅 MDD 改善，final 也提高，交易数下降。可能原因是 D2-overheat 在强动量拥挤状态下优先保留旧仓，减少了 2024 多次追高换仓带来的路径损耗；这和 J7EF 方差缩放不同，不是简单压仓。

## 16. 研究判断

建议状态：`promote_candidate`

理由：2024 smoke 经济门槛通过，但证据等级仍只是 L2 smoke。可以进入四段 formal + 成本/延迟/随机负控，不能改实盘、不能 shadow、不能 observe。

## 17. 下一步

下一轮必须新开 XA5U formal：四段 baseline vs D2-overheat，并补延迟一日触发、随机 overheat 日期、成本扰动和动作归因。它要回答：2024 的改善是否跨分段稳定，是否只是少换仓或单段行情偶然。
