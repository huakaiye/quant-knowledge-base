---
type: 实验记录
ex_id: EX-20260614T115454Z-main-J7EF
rd_id: RD-20260614T115209Z-main-MCYG
status: preregistered
stage: preregistered
owner: main
created_at: 2026-06-14T11:54:54Z
updated_at: 2026-06-14T18:00:00Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 防御模块事前暴露管理
decision_ids: []
lit_ids:
  - LIT-20260614T112631Z-main-VY4K
idea_ids: []
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths:
  - configs/research/RD-20260614T115209Z-main-MCYG/EX-20260614T115454Z-main-J7EF/
result_paths:
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260614T115454Z-main-J7EF/
summary_paths:
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260614T115454Z-main-J7EF/summary/
quality_gate: preregistered
subagent_call_ids: []
subagent_exemption: "当前工具环境子代理调用频繁超时未返回,本轮预注册文档建设主控亲自执行;主控:main;时间:2026-06-14T18:00:00Z"
tags: [双池轮动, 防御模块, 动量崩溃, 事前暴露, 四段formal, 预注册]
---

# DM式事前暴露vs B3事后门控四段formal预注册

## 关联链接

- 研究方向：[[02_研究方向/RD-20260614T115209Z-main-MCYG_双池轮动动量崩溃事前暴露管理|双池轮动动量崩溃事前暴露管理]]
- 父方向：[[02_研究方向/RD-20260605T115651Z-main-DEF0_双池轮动防御模块|双池轮动防御模块]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 来源文献：[[06_文献资料/00_待处理/LIT-20260614T112631Z-main-VY4K_动量崩溃保护Daniel Moskowitz 2016|动量崩溃保护 Daniel Moskowitz 2016]]
- 当前防御基准：[[04_实验记录/EX-20260608T005518Z-main-XK5W_B3Gate与TieredV2旧证据复核|B3Gate 与 TieredV2 旧证据复核]]
- 当前防御决策：[[05_研究决策/DEC-20260608T005556Z-main-U7FN_B3Gate与TieredV2复核后保留为防御骨架决策|B3Gate 与 TieredV2 保留为防御骨架决策]]
- 参照波动率反证：[[04_实验记录/EX-20260606T191019Z-main-G4NN_波动率仓位管理旧证据复核与R010B5边界预注册|G4NN 波动率仓位管理旧证据复核]]
- 产生的决策：待补（实验完成后）
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：把防御模块的"事后回撤门控"（B3/tiered-v2，回撤发生后才动），升级为 Daniel-Moskowitz 的"事前动态暴露管理"——基于动量组合自身已实现方差和市场牛熊状态，在崩溃发生前主动降仓，是否能在 2020_2021 段改善 B3 未能改善的回撤。
我们原本预计：DM 式事前降仓应在 2020_2021 broad blowoff 见顶前主动降仓，使该段 MDD 改善 ≥1pp；同时在 2025_20260519 强趋势段不显著错过收益。
实际看到：待执行（预注册阶段）。
这说明：待执行。
但还不能说明：待执行。
下一步要做：在平台新增 DM 式事前暴露逻辑（动量方差倒数 × 市场状态门控，默认关闭），生成 4 段 config + 随机方差负控，跑四段 formal。

## 2. 研究背景

本实验属于[[02_研究方向/RD-20260614T115209Z-main-MCYG_双池轮动动量崩溃事前暴露管理|双池轮动动量崩溃事前暴露管理]]。当前防御骨架 B3/tiered-v2 本质是"事后门控"——它依赖回撤已发生这一事后信号，在 B3QC 通过成本扰动、B3NC 通过触发滞后一日负控，但 2020_2021 段回撤未改善。

Daniel-Moskowitz（2016, JFE）证明动量崩溃有强事前信号（策略自身已实现方差升高 + 市场大跌后反弹期），可预测可对冲。我们相信事前暴露管理层能补充 B3 的缺口。

**关键边界声明（必须反复强调，区分两个已证伪/已边界方向）**：

1. **不是 G4NN 宽基常开 vol target**：G4NN 实验 formal 反证了"宽基常开/宽基触发目标波动率缩放"。DM 式缩放是**条件化**暴露（方差 + 市场状态双门控），不是宽基常开。Moreira-Muir（2017, JF）独立证实动量是 vol target 例外，这反而**双重印证** G4NN 反证，说明要做的是 DM 式条件化暴露。预注册反复写明：本实验的对照之一是"去掉市场状态条件后是否退化为宽基 vol scale"，若退化则证伪。
2. **不复活 AURT**：AURT（normal_nonrec3 恢复门控二级预算）只进入负控不进实盘。DM 方向是全新的事前暴露理论，不继承 AURT 的参数或触发逻辑。

## 3. 实验前假设

**基于动量组合自身已实现方差 + 市场牛熊状态的事前动态暴露，相对 B3/tiered-v2 事后门控，能在 2020_2021 段改善最大回撤 ≥1pp，且在 2025_20260519 强趋势段不显著错过收益。**

本次只验证"事前暴露是否能补充 B3 在 2020_2021 的缺口"，不验证是否替代 B3。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：DM 式事前暴露相对 B3/tiered-v2，2020_2021 段 MDD 改善 ≥1pp；四段 final 不低段数 ≥3/4。
- 交易行为：事前降仓应在 broad blowoff 见顶前（约 2021 年初）发生，而不是见顶后追认。
- 风险表现：2020_2021 段 MDD 明显改善；2025_20260519 段 MDD 不差（不显著错过强趋势）。
- 分段表现：2020_2021（核心改善段）、2022_2023（折返，中性）、2024（压力，中性）、2025_20260519（强趋势，不伤害）。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| `baseline_b3_tiered_v2` | 当前防御骨架 B3/tiered-v2，主基准 | 参照 B3QC 配置路径 |
| `dm_exposure_var_state` | DM 式事前暴露（动量方差倒数 × 市场状态门控），主候选 | 计划：`${QUANT_PLATFORM_ROOT}/configs/research/RD-20260614T115209Z-main-MCYG/EX-20260614T115454Z-main-J7EF/dm_var_state/` |
| `dm_exposure_var_only` | 只用方差，去掉市场状态条件（用于验证是否退化为宽基 vol scale） | 同上 var_only 子目录 |
| `dm_exposure_shuffled_var` | 随机方差（打乱时间）负控 | 同上 shuffled 子目录 |
| `dm_exposure_cost2x_slip2bps` | 成本扰动子集 | 同上 cost2x_slip2bps 子目录 |

## 6. 竞争性解释

- 事前暴露表现好只是方差窗口选对了，后验调参得到"看起来好"的结果。**对照**：方差窗口预注册锁定（如 20 日），不扩网格。
- 降仓可能只是因为市场指数选了沪深 300，换指数结论消失。**对照**：主候选用沪深 300，不后验选指数。
- 2020_2021 改善可能来自偶然，不是可迁移机制。**对照**：要求其他段不显著退化。
- 事前降仓可能在强趋势段错过收益，净效果可能为负。**对照**：2025_20260519 段 final 不显著低于 baseline。
- DM 式可能等同于宽基 vol target（被 G4NN 反证的方向）。**对照**：var_only 子集若表现与宽基 vol scale 一致，证伪。

## 7. 证伪条件

- DM 式事前暴露相对 B3/tiered-v2，2020_2021 段 MDD 无改善（<1pp），应 `park`。
- 事前降仓导致 2025_20260519 强趋势段 final 显著低于 baseline，应 `revise`（过度防御）。
- 随机方差（shuffled）负控能复制主要回撤改善，应 `kill`。
- DM 式暴露等同于 G4NN 已证伪的"宽基常开 vol target"——验证方式：var_only 子集表现与宽基 vol scale 一致 → 应 `kill`。
- 未来函数审计发现使用了交易时点之后的方差或状态信息，应立即 `kill`。

**不复活 AURT**：本实验不继承 AURT normal_nonrec3 参数。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 待执行 | 方差用过去 N 日（≤t-1）动量组合收益方差；市场状态用 ≤t-1 日市场指数趋势 |
| 信号生成和成交价格不存在同 bar 泄漏 | 待执行 | 沿用现有口径 |
| 股票池或 ETF 池不存在未来成分泄漏 | 待执行 | 同 B3/tiered-v2 池 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 只用价格收益和方差 |
| Shadow 或观察信号未被当成默认交易信号 | 待执行 | DM 式暴露默认关闭，只能经 config 启用；不写 shadow |

负控或错位检查：

- **随机方差负控**：打乱方差序列时间顺序，重算事前暴露信号。若 shuffled 能复制主要回撤改善 → 未来函数或噪声嫌疑。
- **var_only 退化检验**：去掉市场状态条件，看是否退化为宽基 vol scale（被 G4NN 反证）。若退化则证伪本方向"条件化"的核心。
- **错位方差负控**：方差后移 1 日，看时效性。

## 9. 过拟合审计

| 检查项             | 结论  | 证据                                           |
| --------------- | --- | -------------------------------------------- |
| 参数搜索空间已预注册      | 通过  | 方差窗口锁定（如 20 日），不扩窗口网格；状态门控阈值预注册锁定            |
| 样本内、验证集、样本外划分清楚 | 待执行 | 四段同 LM3D，重点样本外为 2022_2023、2024、2025_20260519 |
| 邻近参数敏感性合理       | 待执行 | 若通过，另开方差窗口 15/25 日窄邻域                        |
| 成本、滑点或换手扰动已检查   | 待执行 | cost2x/slip2bps 子集                           |
| 已做消融或负控         | 待执行 | shuffled + var_only 双负控                      |
| 未只报告最优结果        | 通过  | 报告全部候选 + 负控                                  |

证据等级：目标 `L2_formal_candidate`。当前 `L0_preregistered`。

## 10. 子代理调用记录

适配判断：`不适合调用`

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：当前工具环境子代理调用频繁超时未返回，本轮预注册文档建设主控亲自执行；主控：main；时间：2026-06-14T18:00:00Z。
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |

台账行：暂无（豁免）。

## 11. 执行记录

### 平台配置

```text
${QUANT_PLATFORM_ROOT}/configs/research/RD-20260614T115209Z-main-MCYG/EX-20260614T115454Z-main-J7EF/
  - baseline_b3_tiered_v2_*.json (4 段)
  - dm_exposure_var_state_*.json (4 段)
  - dm_exposure_var_only_*.json (4 段)
  - dm_exposure_shuffled_var_*.json (4 段)
  - dm_exposure_cost2x_slip2bps_*.json (4 段)
```

**工程前置**：平台新增 DM 式事前暴露逻辑（动量组合已实现方差 + 市场状态门控，默认关闭）。作为 B3/tiered-v2 的补充层而非替代。市场基准 `510300.XSHG` 已接入。

### 运行命令

```bash
wsl -- bash -lc "cd '$platformWsl' && PYTHONUNBUFFERED=1 PYTHONPATH=src python3 src/run_v2_backtest.py --config configs/research/RD-20260614T115209Z-main-MCYG/EX-20260614T115454Z-main-J7EF/<config>.json 2>&1 | tee results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260614T115454Z-main-J7EF/<run_id>.run.log"
```

### 可见进度与日志

- 是否过程可见：`是`，PYTHONUNBUFFERED=1 + tee。
- 日志路径：`${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260614T115454Z-main-J7EF/<run_id>.run.log`

### 结果路径

```text
${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260614T115454Z-main-J7EF/<run_id>/summary/
```

## 12. 实际观察

待执行。

| 指标 | 基准 | 本次 | 变化 | 解释 |
| --- | --- | --- | --- | --- |

## 13. 支持证据

待执行。

## 14. 反对证据

待执行。

## 15. 偏差诊断

待执行。实验前预测和实际结果有哪些不一致？可能原因是什么？

## 16. 研究判断

建议状态：`preregistered`（待执行）

## 17. 下一步

执行本预注册——实现 DM 式事前暴露逻辑，跑四段 formal + 负控。它能减少的不确定性：**事前暴露管理能否补充 B3/tiered-v2 在 2020_2021 段的回撤缺口。**

若通过：向 promote_candidate 推进，作为 B3/tiered-v2 的补充层（不是替代）。
若失败：明确 park 边界；若 var_only 退化为宽基 vol scale，则写入"动量 vol target 在 ETF 层面亦无效"的强化反证。
