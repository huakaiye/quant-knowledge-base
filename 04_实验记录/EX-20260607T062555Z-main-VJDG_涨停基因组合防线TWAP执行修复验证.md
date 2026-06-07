---
type: 实验记录
ex_id: EX-20260607T062555Z-main-VJDG
rd_id: RD-20260603T000000Z-mig-HD5EEBAA8D5EEB
status: completed
stage: formal_completed_twap_execution_passed
owner: main
created_at: 2026-06-07T06:25:55Z
updated_at: 2026-06-07T06:43:30Z
strategy_id:
  - STRAT-20260603T000000Z-mig-TF8F01
  - STRAT-20260603T000000Z-mig-H486C4036486C4
module_type: twap_execution_repair
decision_ids:
  - DEC-20260607T035846Z-main-2NYF
  - DEC-20260607T064247Z-main-GRKL
lit_ids: []
idea_ids:
  - IDEA-20260529T000000Z-mig-I2026052900174B28
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths:
  - configs/research/RD-20260603T000000Z-mig-HD5EEBAA8D5EEB/EX-20260607T062555Z-main-VJDG/twap_execution_repair.json
result_paths:
  - results/v2/research/RD-20260603T000000Z-mig-HD5EEBAA8D5EEB/EX-20260607T062555Z-main-VJDG/
summary_paths:
  - results/v2/research/RD-20260603T000000Z-mig-HD5EEBAA8D5EEB/EX-20260607T062555Z-main-VJDG/summary/
quality_gate: twap_execution_repair_passed_observe_candidate
subagent_call_ids:
  - SUB-20260607T041000Z-main-TWAP-REPO
  - SUB-20260607T041001Z-main-TWAP-PLATFORM
subagent_exemption:
tags:
  - 小市值
  - 涨停基因
  - TWAP
  - 分钟流动性
  - 执行修复
---

# 涨停基因组合防线TWAP执行修复验证

## 关联链接

- 研究方向：[[02_研究方向/RD-20260603T000000Z-mig-HD5EEBAA8D5EEB_小市值T0——研究总结|小市值T0——研究总结]]；[[02_研究方向/RD-20260603T000000Z-mig-H35F08B9535F08_涨停事件价量结构|涨停事件价量结构]]
- 策略档案：[[03_策略档案/STRAT-20260603T000000Z-mig-TF8F01_小市值日内做T|小市值日内做T]]；[[03_策略档案/STRAT-20260603T000000Z-mig-H486C4036486C4_涨停事件价量结构策略|涨停事件价量结构策略]]
- 来源文献或灵感：[[07_因子数据灵感/04_模块/IDEA-20260529T000000Z-mig-I2026052900174B28_I20260529-001涨停事件价量结构因子|涨停事件价量结构因子]]
- 上游实验：[[04_实验记录/EX-20260607T033527Z-main-UKVS_涨停基因小市值修复防线验证|涨停基因小市值修复防线验证]]；[[04_实验记录/EX-20260607T035232Z-main-8QKX_涨停基因组合防线分钟级执行复核|涨停基因组合防线分钟级执行复核]]
- 上游决策：[[05_研究决策/DEC-20260607T035846Z-main-2NYF_涨停基因小市值修复后执行防线决策|涨停基因小市值修复后执行防线决策]]
- 产生的决策：[[05_研究决策/DEC-20260607T064247Z-main-GRKL_涨停基因TWAP执行修复后观察决策|涨停基因TWAP执行修复后观察决策]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：  
单点分钟执行已经被 8QKX 否决。本实验只问一个问题：把固定日频候选改成 TWAP 分钟执行，并在部分变体中加入信号日前历史分钟流动性过滤，能不能把成交完成率拉回可实盘观察区间，同时保留 UKVS 的收益回撤优势。  
我们原本预计：TWAP 会显著降低单分钟容量失败；历史分钟流动性过滤会进一步减少部分成交，但可能牺牲收益和持仓数量。  
实际看到：四个 TWAP 变体都通过预注册门槛。`twap_p05` 全样本收益 `+71.99%`、最大回撤 `-25.56%`、买入金额完成率 `98.18%`、卖出股数完成率 `98.90%`；`twap_p03` 收益 `+71.35%`、最大回撤 `-26.09%`、买入完成率 `98.18%`、卖出完成率 `98.57%`。
这说明：8QKX 的单点分钟容量阻断可以被 TWAP 执行显著缓解，且完整权益路径仍保留 UKVS 的收益回撤特征。
但还不能说明：本实验仍是分钟 K 线级仿真，没有盘口队列、封单和真实冲击成本；不能直接打开实盘，只能进入默认关闭 observe 候选。
下一步要做：设计 shadow/observe 日志和小资金纸面执行记录；若真实未成交、滑点或容量不达标，再回退。

## 2. 研究背景

本实验属于小市值 T0 方向，是 2NYF 决策后的执行修复实验。上游已经确认：

- UKVS：日频组合防线 `count_p10_n6_guard_env_hold4` 在严格日频口径下收益 `+76.04%`、最大回撤 `-26.78%`，成本扰动后仍为 `+71.68%`。
- 8QKX：单点分钟执行失败，`first_minute` 买卖通过率均约 `47.40%`，`10:30/14:55` 买入通过率约 `25.08%`，主要失败原因是单分钟容量超限。

因此本轮不再继续优化日频信号，而是验证执行层是否能修复。

## 3. 实验前假设

若该策略距离实盘主要差在单点成交方式，而不是信号本身，那么 TWAP 分钟执行应能显著提高成交完成率，并在完整权益路径上保持正收益和可接受回撤。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：至少一个 TWAP 变体全样本收益 `> +50%`、最大回撤 `>= -30%`、夏普不低于 `0.50`。
- 交易行为：买入和卖出目标金额完成率均不低于 `95%`；`partial_fill`、`limit_up/down`、`zero_volume` 不能成为主要交易结果。
- 风险表现：不能重新出现 `stale_liquidation`；2025-2026 压力分段不得低于 `-5%`。
- 分段表现：四段中不能有 2 段以上显著弱于 UKVS 日频组合防线。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| UKVS `count_p10_n6_guard_env_hold4` | 日频信号候选基准 | `${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260603T000000Z-mig-HD5EEBAA8D5EEB/EX-20260607T033527Z-main-UKVS/summary/repair_variant_all_metrics.csv` |
| 8QKX 单点分钟审计 | 执行失败基准 | `${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260603T000000Z-mig-HD5EEBAA8D5EEB/EX-20260607T035232Z-main-8QKX/summary/minute_execution_summary.csv` |
| `twap_p05` | 10:00-10:30 买入、14:30-14:55 卖出，每分钟最多参与 5% 成交额 | 本实验输出 |
| `twap_p03` | 同上，每分钟最多参与 3% 成交额 | 本实验输出 |
| `twap_p05_histliq_p03` | 5% TWAP，加信号日前 20 日同窗口 3% 历史容量过滤 | 本实验输出 |
| `twap_p03_histliq_p03` | 3% TWAP，加同一历史容量过滤 | 本实验输出 |

## 6. 竞争性解释

即使结果符合预期，也可能是：

- 分钟 K 线容量仍低估盘口队列、涨停封单、撤单和冲击成本。
- `jq_bar_minute_v2` 是前复权价格口径，适合权益路径一致性，但仍不能完全代表真实委托成交价。
- TWAP 改变了成交时点，收益改善可能来自盘中价格路径偶然性。
- 历史流动性过滤若有效，可能只是降低持仓数和风险暴露，而不是执行能力真正改善。

## 7. 证伪条件

出现以下情况，本假设不通过：

- 所有 TWAP 变体全样本收益低于 `+50%` 或最大回撤深于 `-30%`。
- 买入或卖出金额完成率低于 `95%`。
- 2025-2026 分段收益低于 `-5%`。
- `limit_up/down`、`zero_volume`、`partial_fill` 或缺分钟数据成为主要失败原因。
- 历史分钟流动性过滤使用了执行日或未来分钟数据。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 通过 | 历史分钟流动性过滤只用 `signal_date` 之前 20 个交易日同窗口成交额；本轮全部通过过滤，未影响结果。 |
| 信号生成和成交价格不存在同 bar 泄漏 | 通过 | 日频信号沿用 UKVS；执行日分钟线只用于模拟成交，不反向筛选信号。 |
| 股票池或 ETF 池不存在未来成分泄漏 | 通过 | 股票池和候选沿用 UKVS 的 `signal_date` 小市值池。 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 本实验不新增财务、宏观字段。 |
| Shadow 或观察信号未被当成默认交易信号 | 通过 | 结论限定为默认关闭 observe 候选，未修改实盘默认开关。 |

负控或错位检查：

- 本实验不新增选股负控；执行负控基准是 8QKX 单点分钟失败结果。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 预注册 | 仅四个固定执行变体，不看结果后扩展窗口或参与率。 |
| 样本内、验证集、样本外划分清楚 | 预注册 | 覆盖 UKVS 同一全样本和四段分段；不训练参数。 |
| 邻近参数敏感性合理 | 通过 | 3% 与 5% 参与率结果接近，收益约 `+71%`，回撤约 `-26%`。 |
| 成本、滑点或换手扰动已检查 | 通过但有限制 | 使用 UKVS 成本模型和分钟 TWAP 成交价；未包含盘口冲击成本。 |
| 已做消融或负控 | 通过 | 历史流动性过滤版本与不过滤版本一致，说明 10 万机制资金在历史窗口容量下不是瓶颈。 |
| 未只报告最优结果 | 预注册 | 四个变体全部输出。 |

证据等级：`L0 / L1 / L2 / L3 / L4 / L5`

## 10. 子代理调用记录

适配判断：适合调用。任务涉及新实验记录、平台分钟执行实现和未来函数风险。

调用状态：called

子代理豁免：不适用。

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-20260607T041000Z-main-TWAP-REPO | Rawls | SUBTASK-20260607-TWAP-REPO | inherited | 2026-06-07T04:10:00Z | 研究规范、UKVS、8QKX、2NYF、台账 | 无 | 只读 `Get-Content` / `rg`，未运行回测 | 只核对流程和反链，不判断策略有效性 | 必须补 VJDG 台账、2NYF 后续实验链接、术语 TWAP/分钟流动性过滤 | 已采纳 | 影响记录完整性 |
| SUB-20260607T041001Z-main-TWAP-PLATFORM | Galileo | SUBTASK-20260607-TWAP-PLATFORM | inherited | 2026-06-07T04:10:01Z | 平台脚本、配置、8QKX summary、VJDG 配置 | 无 | 只读检查，未运行正式回测 | 提醒当时只有配置、未见实现；不能把 8QKX 当 TWAP 证据 | 需要独立 TWAP 脚本、统一价格口径、排除执行日未来流动性、逐分钟明细 | 已采纳：新增独立 TWAP 脚本、前复权分钟口径、逐分钟 fill 明细 | 影响实现质量和未来函数边界 |

台账行：已同步 `01_台账/子代理调用台账.csv`。

## 11. 执行记录

### 平台配置

```text
${QUANT_PLATFORM_ROOT}/configs/research/RD-20260603T000000Z-mig-HD5EEBAA8D5EEB/EX-20260607T062555Z-main-VJDG/twap_execution_repair.json
```

### 运行命令

```bash
$platformWsl = powershell -ExecutionPolicy Bypass -File tools/Get-QuantPlatformRoot.ps1 -Target Platform -Format WSL
wsl -- bash -lc "cd '$platformWsl' && PYTHONUNBUFFERED=1 PYTHONPATH=src python3 scripts/research/backtest_lion_limit_gene_twap_execution.py --config configs/research/RD-20260603T000000Z-mig-HD5EEBAA8D5EEB/EX-20260607T062555Z-main-VJDG/twap_execution_repair.json | tee results/v2/research/RD-20260603T000000Z-mig-HD5EEBAA8D5EEB/EX-20260607T062555Z-main-VJDG/twap_execution_repair.log"
```

### 可见进度与日志

- 是否过程可见：是，使用 `PYTHONUNBUFFERED=1` 和 `tee`。
- 日志路径：`${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260603T000000Z-mig-HD5EEBAA8D5EEB/EX-20260607T062555Z-main-VJDG/twap_execution_repair.log`
- 查看进度命令：`Get-Content <log> -Tail 80`
- 异常判断：若任一 TWAP 变体无权益曲线、分钟数据缺失严重或成交统计无法输出，则实验不得完成。
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
${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260603T000000Z-mig-HD5EEBAA8D5EEB/EX-20260607T062555Z-main-VJDG/
```

## 12. 实际观察

| 指标 | 基准 | 本次 | 变化 | 解释 |
| --- | --- | --- | --- | --- |
| 全样本收益 | UKVS 日频组合 `+76.04%` | `twap_p05` `+71.99%`；`twap_p03` `+71.35%` | 略降 | TWAP 真实化执行后保留主要收益。 |
| 最大回撤 | UKVS 日频组合 `-26.78%` | `twap_p05` `-25.56%`；`twap_p03` `-26.09%` | 略改善 | TWAP 没有放大回撤。 |
| 夏普 | UKVS 日频组合 `0.622` | `twap_p05` `0.585`；`twap_p03` `0.581` | 略降 | 执行口径更严格后风险收益仍可接受。 |
| 买入完成率 | 8QKX 单点买入最低 `25.08%` | `98.18%` | 大幅改善 | TWAP 解决了主要单分钟容量问题。 |
| 卖出完成率 | 8QKX 单点卖出约 `47.40%-50.15%` | `98.90%` / `98.57%` | 大幅改善 | 卖出容量也基本可控。 |
| 2025-2026 分段 | 预期不低于 `-5%` | `twap_p05` `-3.45%`；`twap_p03` `-3.75%` | 通过 | 压力窗口仍小亏，但低于否决阈值。 |
| 历史流动性过滤 | 预期可能剔除弱容量候选 | 5,682 条检查全部通过 | 无影响 | 10 万资金下，信号日前 20 日窗口容量不是瓶颈。 |
| 逐分钟参与率 | 预期不超过配置上限 | 5% 版本最大 `0.05`；3% 版本最大 `0.03` | 通过 | `twap_minute_fills.csv` 记录 10,416 条分钟 fill。 |

## 13. 支持证据

- `twap_scorecard.csv`：四个预注册 TWAP 变体均 `twap_pass=True`。
- `twap_trade_stats.csv`：`twap_p05` 买入完成率 `98.18%`、卖出完成率 `98.90%`；`twap_p03` 买入完成率 `98.18%`、卖出完成率 `98.57%`。
- `twap_minute_fills.csv`：逐分钟 fill 记录 10,416 行，最大使用参与率不超过预注册上限。
- `twap_variant_segment_metrics.csv`：2020-2021、2022-2023 为正，2024 和 2025-2026 小幅为负但未触发否决。

## 14. 反对证据

- 仍有 16 条交易失败记录，原因是窗口内无 TWAP 买入/卖出容量；虽不影响总体通过，但 shadow 必须记录。
- 平均持仓数约 `1.85`，低于名义 6 只，策略更像“环境触发 + 低频持仓”而非满仓小市值轮动。
- 历史分钟流动性过滤没有产生剔除，不能证明该模块有独立贡献。
- 本实验仍没有盘口队列、封单、撤单重试和真实冲击成本；不能直接 `promote` 到实盘默认。

## 15. 偏差诊断

预测中“历史分钟流动性过滤会进一步减少部分成交”没有发生，因为 10 万验证资金下，信号日前 20 日同窗口 3% 历史容量的最低值约 `8.22万`，显著高于平均目标金额约 `2.44万`。真正解决执行阻断的是 TWAP 分散到 10:00-10:30 与 14:30-14:55 窗口，而不是历史流动性过滤。

另一个偏差是 3% 和 5% 参与率结果非常接近，说明当前资金规模下 3% 已足够，5% 不是必要条件。

## 16. 研究判断

建议状态：`observe` / `promote_candidate_for_shadow`，不是 `promote`。

理由：TWAP 完整路径通过收益、回撤、成交完成率和 2025-2026 压力窗口门槛，解除 8QKX 的单点执行阻断；但盘口和真实冲击成本未验证，必须默认关闭观察。

## 17. 下一步

下一步不是继续调参数，而是进入 shadow/observe 设计：

- 生成每日候选、TWAP 计划、预计成交额参与率和未成交原因日志。
- 用真实行情回放或模拟下单记录纸面成交，至少覆盖 20-60 个交易日。
- 观察项包括：实际可成交价、真实滑点、未成交比例、盘口封单、撤单重试、容量占用和小资金可承载上限。
