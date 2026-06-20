---
type: 实验记录
ex_id: EX-20260618T032837Z-main-5LLS
rd_id: RD-20260614T115209Z-main-MCYG
status: completed
stage: smoke_partial_hard_gate_failed_no_promote
owner: main
created_at: 2026-06-18T03:28:37Z
updated_at: 2026-06-18T05:18:44Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 防御模块事前暴露管理层
decision_ids: []
lit_ids: [LIT-20260617T220410Z-main-RDHA, LIT-20260614T112631Z-main-VY4K]
idea_ids: []
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths:
  - scripts/research/generate_5lls_r010d_d3_strict_smoke_configs.py
  - scripts/research/summarize_5lls_r010d_d3_strict_smoke.py
  - configs/research/RD-20260614T115209Z-main-MCYG/EX-20260618T032837Z-main-5LLS/smoke/
result_paths:
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T032837Z-main-5LLS/smoke/
summary_paths:
  - results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T032837Z-main-5LLS/smoke/summary/summary.json
quality_gate: preregistered_hard_2025_misinjury_gate_failed
subagent_call_ids: [SUB-EXEMPT-20260618T033100Z-main-5LLS]
subagent_exemption: 当前可用子代理工具要求用户显式授权子代理/委派/并行 agent；本轮用户未显式授权，主控继续执行；主控：main；时间：2026-06-18T03:31:00Z
tags: [双池轮动, 防御模块, 动量崩溃, 过热动量, 高波低广度, 误伤门控, smoke]
---

# 过热高波低广度严格动作 smoke

## 关联链接

- 研究方向：[[02_研究方向/RD-20260614T115209Z-main-MCYG_双池轮动动量崩溃事前暴露管理|双池轮动动量崩溃事前暴露管理]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 来源文献或灵感：[[06_文献资料/00_待处理/LIT-20260617T220410Z-main-RDHA_顶刊拟合目标替代与动量崩溃前置暴露|顶刊拟合目标替代与动量崩溃前置暴露]]；[[06_文献资料/00_待处理/LIT-20260614T112631Z-main-VY4K_动量崩溃保护Daniel Moskowitz 2016|动量崩溃保护 Daniel Moskowitz 2016]]
- 前序实验：[[04_实验记录/EX-20260618T030506Z-main-K3YL_崩溃概率与下尾分位数只读面板|K3YL 崩溃概率与下尾分位数只读面板]]；[[04_实验记录/EX-20260617T220410Z-main-B6FL_过热动量D2四段formal与负控|B6FL 过热动量 D2 四段 formal 与负控]]
- 产生的决策：暂无；本轮只证伪 D3 strict 动作候选，不改变 MCYG 总路线
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：  
K3YL 说明 `r010d_overheat_binary` 能提前提示一部分下尾风险，但 B6FL 也说明“只要过热就降仓”的 D2 动作会在 2025 强趋势里误伤。我们这次只测试一个更窄的动作：必须同时满足“强动量过热”和“高波动低广度”，也就是平台已有的 `R010D_D3_STRICT`。

我们原本预计：  
如果 2025 的误伤来自 D2 太宽，那么 D3 严格门控应减少触发次数，并且 2025_20260519 final 不应显著低于 baseline；同时 2024 的保护收益不能完全消失。

实际看到：  
阶段性关键段已足够证伪。2024 段 D3 strict 小幅跑赢 baseline，但最大回撤更差；2025_20260519 段 final `309930.55`，低于 baseline `317973.61`，约为 baseline 的 `97.47%`，未达到预注册 `98%` 误伤硬门槛。

这说明：  
D3 strict 比 D2 更窄，但仍没有解决“强趋势段误伤”这个核心问题。它不能从 K3YL 的只读风险标签升级为交易动作。

但还不能说明：  
即使 smoke 通过，也不能说明可以改实盘。D3 仍是基于历史 action log 的研究动作，需要成本、负控、样本外和默认关闭边界继续验证。

下一步要做：  
停止 D3 strict 动作升级，不继续扫 cap、阈值、seed 或 keep-current。MCYG 当前最佳仍是 K3YL 的只读概率/下尾风险观察层；若继续降低滞后，必须回到更前置的只读状态转移/概率校准，而不是把当前标签直接交易化。

## 2. 研究背景

本实验属于 [[02_研究方向/RD-20260614T115209Z-main-MCYG_双池轮动动量崩溃事前暴露管理|MCYG 双池轮动动量崩溃事前暴露管理]]。

用户提出“当前策略方式滞后性太大”，前序研究把“R 方之外”的方向从单纯路径拟合转向概率评分、分位数损失和事前状态暴露。K3YL 的结果显示，`r010d_overheat_binary` 在 A1 且未已回撤 5% 的样本里有只读预测信息；但 2025 段整体 bad10 事件率高，单纯 overheat 标签无法区分“趋势继续”和“马上崩”。

本轮不再扩 `top1_ret20/top1_slope10` 阈值，也不调整 D2 的 cap 或 keep-current。平台源码中已经存在 `d3_strict` 模式：只有 `r010d_a1_high_vol_low_breadth` 与 `r010d_a1_overheated_momentum_risk` 同时为真时才触发。这是一个已有更窄动作，不是看结果后新增策略规则。

运行前只读检查显示，在 K3YL 主宇宙中，`overheat_hv` 的未来 H10 路径风险更集中：2024 bad10 率为 `90%`，2025 H10 均值转为负，不像原 D2 overheat 在 2025 中还切到继续上涨样本。因此值得做最小真实组合 smoke。

## 3. 实验前假设

在当前 B3/tiered-v2 baseline 上，只把 `R010D_D3_STRICT` 打开，能够比 B6FL 的 D2-overheat 更少误伤 2025 强趋势，同时保留 2024 局部保护能力。

固定主候选：

- `r010d_d3_strict_cap80`：`r010d_enabled=true`，`r010d_mode=d3_strict`，`r010d_d3_strict_risk_cap=0.80`，不延迟，不随机。

固定负控：

- `r010d_d3_strict_lag1`：信号延迟一交易日。
- `r010d_d3_strict_random_p377_seed20260618`：只随机替代 overheat，概率为 `115/305`，让 D3 在 high-vol-low-breadth 条件后的期望触发数对齐。
- `r010d_d3_strict_cap80_cost2x_slip2bps`：双倍佣金 + 2bps 固定滑点。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：`2025_20260519` 主候选 final 不低于 baseline 的 `98%`，且 MDD 不比 baseline 恶化超过 `0.5pp`；这是本轮硬门槛。
- 指标：四段里至少 `3/4` 段 final 不低于 baseline 的 `98%`。
- 指标：四段里至少 `2/4` 段 final 高于 baseline，且至少 `2/4` 段 MDD 改善 `>=0.5pp`。
- 交易行为：主候选至少 `3/4` 段触发次数 `>=5`，否则只能说明动作太少，不能作为机制证据。
- 负控：主候选 final 至少 `3/4` 段高于 lag1，且至少 `3/4` 段高于 random；否则说明及时性或标签信息量不干净。
- 成本：成本扰动至少 `3/4` 段 final 不低于 baseline 的 `98%`，且成本变体不能与主候选完全相同；若完全相同，成本控制视为无效。
- 分段表现：如果只在 2024 好、但 2025 仍明显低于 baseline，则本轮失败，不能进入下一层验证。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| B6FL baseline | 同口径当前 B3/tiered-v2 baseline，R010D 关闭 | `${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260617T220410Z-main-B6FL/formal/summary/segment_summary.csv` |
| `r010d_d3_strict_cap80` | 主候选，既有 D3 严格动作 | `${QUANT_PLATFORM_ROOT}/configs/research/RD-20260614T115209Z-main-MCYG/EX-20260618T032837Z-main-5LLS/smoke/` |
| `r010d_d3_strict_lag1` | 延迟一日负控 | 同上 |
| `r010d_d3_strict_random_p377_seed20260618` | 同支持度随机负控 | 同上 |
| `r010d_d3_strict_cap80_cost2x_slip2bps` | 成本扰动 | 同上 |

## 6. 竞争性解释

即使结果符合预期，也可能是：

- D3 触发次数较少，收益改善来自偶然避开少数坏日，不一定可迁移。
- D3 的 `high_vol_low_breadth` 可能仍是已回撤后的状态，实际动作未必足够前置。
- 若成本变体和主候选相同，说明动作没有产生可交易成本差异，不能把成本门槛写成通过。
- 2025 不误伤可能只是触发太少，而不是识别了“趋势继续”。
- 复用 B6FL baseline 需要确认源配置完全同口径；如果源配置变化，本轮对照失效。

## 7. 证伪条件

出现以下情况，本假设不通过：

- `2025_20260519` 主候选 final 低于 baseline 的 `98%`。
- `2025_20260519` 主候选 MDD 比 baseline 恶化超过 `0.5pp`。
- 主候选 final 不低于 baseline `98%` 的分段数少于 `3/4`。
- 主候选 final 高于 baseline 的分段数少于 `2/4`。
- 主候选 MDD 改善 `>=0.5pp` 的分段数少于 `2/4`。
- lag1 或 random 负控在至少 `2` 个以上关键段复制或超过主候选。
- 成本扰动输出与主候选完全相同，或成本扰动后不满足基本收益门槛。
- 发现 D3 使用的字段不是交易日前可见，或不是既有平台分支。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 预注册待复核 | D3 使用 action record 中交易日前已记录的 `r010d_a1_high_vol_low_breadth` 与 `r010d_a1_overheated_momentum_risk` |
| 信号生成和成交价格不存在同 bar 泄漏 | 预注册待复核 | 使用既有 `run_v2_backtest.py` 与 R010-B4 源配置；执行后检查日志和 summary |
| 股票池或 ETF 池不存在未来成分泄漏 | 沿用 baseline 风险 | 本轮不新增池，不改数据源 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 本轮不用财务、宏观或估值字段 |
| Shadow 或观察信号未被当成默认交易信号 | 通过预注册约束 | 只在 research config 中打开 R010D，不改默认配置，不接实盘或 shadow |

负控或错位检查：

- `r010d_d3_strict_lag1`：延迟一交易日触发。
- `r010d_d3_strict_random_p377_seed20260618`：同支持度随机替代 overheat。
- `r010d_d3_strict_cap80_cost2x_slip2bps`：成本扰动。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | 只测既有 D3 strict cap80、lag1、random、cost；不扫 cap、阈值或 seed |
| 样本内、验证集、样本外划分清楚 | 通过 | 四段沿用 B6FL：2020_2021、2022_2023、2024、2025_20260519 |
| 邻近参数敏感性合理 | 本轮不做 | 因为本轮是 smoke，明确不扩 cap 或阈值邻域 |
| 成本、滑点或换手扰动已检查 | 关键段已执行但无效 | 2024 与 2025 成本变体均与主候选完全相同，不能作为成本通过证据 |
| 已做消融或负控 | 关键段已执行 | 2024/2025 已完成 lag1、random、cost；2025 lag1 高于主候选，主候选未通过误伤硬门槛 |
| 未只报告最优结果 | 通过 | 汇总脚本输出所有变体和分段 |

证据等级：执行前 `L0 preregistered`；执行后最高只能为 `L2 smoke`，不得直接 promote。

## 10. 子代理调用记录

适配判断：`适合调用但工具规则禁止未授权启动`

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：当前可用子代理工具要求用户显式授权子代理/委派/并行 agent；本轮用户未显式授权，主控继续执行；主控：main；时间：2026-06-18T03:31:00Z
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `SUB-EXEMPT-20260618T033100Z-main-5LLS` | 无 | `SUBTASK-5LLS-D3-STRICT-EXEMPT` | 无 | 2026-06-18T03:31:00Z | K3YL/B6FL 实验记录、LJQ7 action panel、平台 R010D 分支 | 无子代理修改 | 无 | 豁免，不作为研究证据 | 缺少独立路径复核 | 主控已核对 D3 为既有平台分支且生成固定配置 | 只支持本轮继续 smoke，不支持路线升级 |

台账行：

待同步 `01_台账/子代理调用台账.csv`。

## 11. 执行记录

### 平台配置

```text
平台项目：${QUANT_PLATFORM_ROOT}
生成脚本：scripts/research/generate_5lls_r010d_d3_strict_smoke_configs.py
汇总脚本：scripts/research/summarize_5lls_r010d_d3_strict_smoke.py
配置目录：configs/research/RD-20260614T115209Z-main-MCYG/EX-20260618T032837Z-main-5LLS/smoke/
结果目录：results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T032837Z-main-5LLS/smoke/
```

### 运行命令

```bash
cd ${QUANT_PLATFORM_ROOT}
PYTHONUNBUFFERED=1 PYTHONPATH=src python3 scripts/research/generate_5lls_r010d_d3_strict_smoke_configs.py
PYTHONUNBUFFERED=1 PYTHONPATH=src python3 src/run_v2_backtest.py --config <generated-config>
PYTHONUNBUFFERED=1 PYTHONPATH=src python3 scripts/research/summarize_5lls_r010d_d3_strict_smoke.py
```

### 可见进度与日志

- 是否过程可见：`是`
- 日志路径：`${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T032837Z-main-5LLS/smoke/<variant>/<segment>/<run>.run.log`
- 查看进度命令：前台命令直接输出；每个配置用 `tee` 保存 run log。
- 异常判断：配置生成失败、run_v2_backtest 非 0、结果目录缺 summary.json、D3 触发数低于 5、汇总脚本找不到 B6FL baseline。
- 后台回测豁免：不适用；本轮前台可见执行。

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
results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T032837Z-main-5LLS/smoke/
```

## 12. 实际观察

配置已生成 `16` 个固定变体/分段组合。实际完成了关键近端段 `2024`、`2025_20260519` 的 candidate、lag1、random、cost 变体，以及成本变体 `2020_2021`；因 `2025_20260519` 预注册误伤硬门槛已经失败，剩余历史段不再影响“不得升级”的判断。

汇总脚本输出 `partial=true`，但关键段完整：`complete_segments=["2024","2025_20260519"]`，`key_2024_2025_complete=true`，`hard_2025_no_misinjury=false`，`partial_key_gate_pass=false`，`smoke_pass=false`。

| 分段 | baseline final / MDD | D3 strict final / MDD | 触发次数 | 观察 |
| --- | --- | --- | --- | --- |
| `2024` | `167005.22` / `-26.99%` | `168034.48` / `-29.05%` | `21` | final 多 `1029.26`，但 MDD 恶化约 `2.06pp` |
| `2025_20260519` | `317973.61` / `-16.57%` | `309930.55` / `-16.57%` | `26` | final 少 `8043.06`，约为 baseline 的 `97.47%`，低于 `98%` 硬门槛 |

负控方面，2024 主候选高于 lag1 与 random；2025 主候选高于 random 但低于 lag1。成本扰动在已完成的 2024 与 2025 与主候选完全相同，不能作为有效成本敏感性证据。

## 13. 支持证据

- `2024` 段 D3 strict final 高于 baseline，说明“过热 + 高波低广度”确实能在局部样本避开一部分风险。
- `2024` 段主候选 final 高于 lag1 与 random，说明该段的及时性和标签信息量没有被负控完全复制。
- `2025_20260519` 段 MDD 没有比 baseline 恶化，说明 D3 strict 的风险压缩没有制造额外深回撤；问题主要是机会成本。

## 14. 反对证据

- `2025_20260519` 段 final 低于 baseline `8043.06`，违反预注册硬门槛：`candidate final >= baseline * 0.98`。
- `2024` 段虽然 final 变高，但 MDD 从 `-26.99%` 恶化到 `-29.05%`，没有满足回撤改善目标。
- `2025_20260519` 段 lag1 final `312412.08` 高于主候选 `309930.55`，不支持“更及时一定更好”。
- 成本变体在关键段与主候选完全一致，说明当前平台成本扰动没有形成有效可交易成本检验。
- 本轮仍使用既有 R010D action 标签，不能证明标签足够前置；只能证明该动作规则在组合层不应升级。

## 15. 偏差诊断

本轮提前停止补跑剩余历史段，不是因为结果有利，而是因为近端强趋势误伤硬门槛已经失败。按预注册，`2025_20260519` 失败足以否决 smoke 通过；继续补跑 `2020_2021`、`2022_2023` 只能补全统计表，不能改变“不得升级”的结论。

偏差来源主要有三点：

- D3 strict 的条件更窄，但仍没有识别“过热后趋势继续”的样本。
- 过热标签在 K3YL 中是概率/下尾只读信号，直接转成 `cap80` 动作会把概率排序硬切成仓位决策，信息损失较大。
- 成本扰动没有改变结果，说明当前成本门控链路对该动作不敏感，后续不能把成本通过写成证据。

## 16. 研究判断

建议状态：`completed / smoke_partial_hard_gate_failed_no_promote`

证据等级：`L1 fail-action-smoke`。D3 strict 动作候选被证伪，不进入 formal，不进入 observe/shadow，不改实盘默认。

是否需要研究决策卡：暂不需要。理由是本轮没有改变 MCYG 总路线，只是把 K3YL 后允许尝试的一个极小动作候选证伪；MCYG 的当前最佳仍是 K3YL 的只读概率/下尾风险观察层。

## 17. 下一步

停止 D3 strict 动作升级，不补扫 cap、阈值、随机 seed、keep-current 或更宽/更窄组合条件。

如果继续回应“滞后性太大”的问题，下一轮应回到顶刊方法启发的只读层：状态转移概率、概率校准、分位数/check loss 或经济损失排序，而不是把当前 `r010d_overheat_binary` 或 `R010D_D3_STRICT` 直接写成交易动作。
