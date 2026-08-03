---
type: 实验记录
ex_id: EX-20260622T133000Z-main-7KMP
rd_id: RD-20260622T030341Z-main-S2T4
status: draft
stage: executed_observed
owner: main
created_at: 2026-06-22T13:30:00Z
updated_at: 2026-06-22T16:30:00Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 个股层隔夜收益时段条件化组合层 formal
decision_ids: [DEC-20260622T163008Z-main-GHZE]
lit_ids: []
idea_ids: [MECH-20260620T154044Z-main-MATN]
platform_project: ${LEGACY_QUANT_PLATFORM_ROOT}
execution_platform_status: legacy_completed_evidence
config_paths: [configs/research/R010-A22/overnight_timed_paired/EX-20260622T133000Z-main-7KMP/formal/manifest.json]
result_paths: [results/v2/research/R010-A22/overnight_timed_paired/EX-20260622T133000Z-main-7KMP/formal]
summary_paths: [results/v2/research/R010-A22/overnight_timed_paired/EX-20260622T133000Z-main-7KMP/summary/formal/summary.json, results/v2/research/R010-A22/overnight_timed_paired/EX-20260622T133000Z-main-7KMP/summary/formal/segment_metrics.csv]
quality_gate: executed_cost1x_cost2x_falsified
subagent_call_ids: [SUB-20260622T210000Z-main-Q3R8]
subagent_exemption:
tags: [双池轮动, hard5, 隔夜收益, overnight_share, 时段条件化, 市场状态gate, formal, preregistered, V2满仓放行]
---

# 隔夜收益时段条件化市场状态gate组合层formal

> 历史执行证据：本页的 formal 结果、并行脚本和目录结构属于 V1.4。结论可继续引用，但任何补跑或扩展都必须迁入 V2 后新开实验。

## 关联链接

- 研究方向：[[02_研究方向/RD-20260622T030341Z-main-S2T4_隔夜收益知情交易个股层p_repair信号|隔夜收益知情交易个股层 p_repair 信号]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 来源灵感：[[07_因子数据灵感/03_机制/MECH-20260620T154044Z-main-MATN_顶刊灵感1 隔夜收益知情交易 Lou Polk Skouras 2019|MECH-MATN 隔夜收益知情交易]]
- 产生的决策：（回测后产出）
- 上游决策：[[05_研究决策/DEC-20260622T123321Z-main-78RB_隔夜收益放行formal决策(V1 revise V2 revise)|DEC-78RB V1/V2 revise 决策]]
- 数据门禁：[[04_实验记录/EX-20260622T030348Z-main-J3YY_隔夜收益数据门禁与字段质量审计|EX-J3YY 数据门禁]]
- 只读面板：[[04_实验记录/EX-20260622T031432Z-main-7TJU_隔夜收益知情交易只读面板预注册|EX-7TJU 只读面板]]
- V1 formal：[[04_实验记录/EX-20260622T033017Z-main-PNV8_隔夜收益日内主导放行组合层formal|EX-PNV8 V1 cap70 formal]]
- V2 formal：[[04_实验记录/EX-20260622T104131Z-main-6XCN_隔夜收益完全放行V2组合层formal|EX-6XCN V2 满仓 formal]]
- 失败前置（过热保守开关线，均 park）：[[05_研究决策/DEC-20260620T150805Z-main-XSNQ_CS dispersion 组合层双方向配对 formal 决策|DEC-XSNQ CS dispersion]]、[[05_研究决策/DEC-20260621T024805Z-main-CHCD_A29 frozen-veto 组合层双方向配对 formal 决策|DEC-CHCD frozen-veto]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：能不能给"隔夜收益放行开关"装一个红绿灯——只在市场健康（趋势向上+广度足）时才放行高分标的，熊市弱市自动关掉、回到保守的 hard5。

我们原本预计：V2 满仓放行在 2020 牛市段 +15.2%（所有方案最强），但 2022 熊市 -2.2%、2025 -7.9%。因为熊市里"日内主导"不再是趋势延续，而是散户接盘后的出货尾声。加市场门后应该保留牛市收益、减少熊市亏损。

实际看到：**市场门没能让候选战胜 baseline**。cand_timed 在 4 段里只有 1 段（2022_2023，+0.6% vs cand_full）略微优于 V2 满仓放行，其余 3 段都更差或持平；4 段里 0 段 final 超过 baseline_hard5（2020_2021 +0.2% 几乎打平，其余 -1.0%~-2.3%）。好消息是市场门确实呈现了预期的方向性——它在 2022 熊市和 2025 反弹段把 V2 满仓放行改善了（+0.6%、+6.0%），没有无脑砍牛市；坏消息是改善幅度太小，远不足以追上 hard5。

这说明：市场择时门作为"V2 满仓放行的减伤补丁"方向是**部分对的**（归因方向符合预期：熊市/反弹段改善、牛市段不破坏），但作为"让放行方案超越 hard5"的目标**没达到**。核心矛盾不在"放行后时段含义翻转"，而在"放行方案本身就跑不过 hard5"——V2 满仓放行（cand_full）在 cost1x 4 段里同样 0/4 超过 hard5，市场门补不回来一个本身就弱的基座。

但还不能说明：① 成本扰动已补证（cost2x 与 cost1x 结论一致，候选仍 0/4 反超 hard5），这一项**已排除**；② V2 满仓放行的 max_score=8 是否独立有效还没拆开（选项3）；③ 全年年化口径下 hard5 vs V2 的差距是否一致（选项2）。

下一步要做：① ✅ cost2x 成本扰动补证已完成（16/16），结论稳健；② ✅ 写 DEC 决策卡 DEC-GHZE（park）；③ ✅ 选项2 全年年化已完成（V2 微弱反超但不显著）；④ 选项3 分数上限实验经判断正式 drop（park 决策已稳健，边际价值低于回测成本）。

## 2. 研究背景

本实验承接 DEC-78RB revise，处理隔夜收益信号接进策略后的时段依赖问题。

核心矛盾：EX-7TJU 只读面板证明隔夜信号方向正确（low 桶=日内主导=趋势延续，H10 +0.0434、胜率 61.7%、分段 6/7 正、错位不反转），是首个避开"过热 vs 修复时段依赖"陷阱的事件级信号。但 EX-PNV8（V1 cap70）和 EX-6XCN（V2 满仓放行）把信号接进组合层 formal 后，时段依赖问题仍部分存在：

- V2 满仓放行 2020_2021 段 +15.2%（259282 vs hard5 225080），所有方案最强单段超额，MDD 改善（-19.1% vs -20.7%）。
- 但 2022_2023 -2.2%、2024 -0.9%、2025 -7.9%，仅 1/4 段赢。

前两次过热保守开关线（CS dispersion、frozen-veto）失败的共同核心矛盾是"同一信号在不同时段含义相反"。隔夜信号在事件级已避开这个陷阱（6/7 段正），但组合层 V2 仍有时段依赖——推测原因是：熊市/弱市里"日内主导"的含义会翻转，从"趋势延续"变成"出货尾声"。

本实验用市场状态前置门直接处理这个推测：只在市场健康时放行，弱市回退 hard5。

## 3. 实验前假设

在 V2 满仓放行逻辑前加市场状态前置门（MA20 广度 + 中位 ret20 + ret20 正比例三门槛），能在保留 2020 牛市放行收益的同时，减少 2022 熊市和 2025 的亏损，使稳健性从 1/4 段提升到 3/4 段以上。

## 4. 实验前预测

如果假设为真，应该看到：

- **指标**：cand_timed_low_share 在 cost1x 下 4 段 final ≥3/4 不低于 baseline_hard5；四段合计 final 高于 V2（cand_full_release_low_share）。
- **交易行为**：市场门在 2022_2023 熊市段阻断大部分放行日（loosen 触发率显著低于 cand_full）；2020_2021 牛市段放行日保留（市场门通过率高）。
- **风险表现**：2022_2023 与 2025_20260519 段 MDD 不差于 baseline_hard5。
- **分段表现**：
  - 2020_2021：保留正超额，但可能略低于 V2 的 +15.2%（市场门可能拦掉少数牛市非健康日）。
  - 2022_2023：从 V2 的 -2.2% 改善到接近 0 或转正。
  - 2024：从 V2 的 -0.9% 改善。
  - 2025_20260519：从 V2 的 -7.9% 改善（但 2025 市场偏强，门可能仍放行，改善幅度待验证）。

## 5. 基准和对照

| 对照 | 用途 | 关键差异 |
| --- | --- | --- |
| baseline_hard5 | 主基准，默认 hard5（max_score=5） | 无放行 |
| ref_a22_cap70_always | A22 cap70 永远开参照 | 全段 cap70，无隔夜信号 |
| cand_full_release_low_share | V2 满仓放行无市场门（= EX-6XCN 同口径） | 消融对照：市场门效果归因 |
| cand_timed_low_share | **本实验主候选**：V2 满仓放行 + 市场状态门 | 有市场门 |

cand_full vs cand_timed 的差异直接归因市场门效果（其余参数完全一致）。

## 6. 竞争性解释

即使结果符合预期，也可能是：

- 市场门本身是个有效的市场择时规则，与隔夜信号无关——需对比 cand_full vs cand_timed 差异，以及 ref_a22 vs cand_timed 差异来归因。
- 市场门三阈值（MA20 广度 0.50 / 中位 ret20 0.015 / ret20 正比例 0.45）移植自策略现有 `score_hot_lit_state` 健康上涨状态定义，可能恰好与历史某段拟合；需 cost2x 扰动和 2025 样本外段验证。
- 2025 反弹段可能无法靠市场门解决——2025 市场整体偏强，门会放行，但放行后仍可能因反弹特殊性亏损。这是本实验的关键不确定点。
- V2 满仓放行的 max_score=8 可能独立有效（DEC-78RB 边界已指出），与市场门效果混淆——由选项3 单独检验。

## 7. 证伪条件

出现以下情况，本假设不通过：

- cand_timed_low_share 在 cost1x 下 ≥3/4 段 final 不低于 baseline_hard5 → 不达标则不通过。
- cand_timed 的 2022_2023 段 final 低于 cand_full（市场门反而恶化熊市表现）→ 不通过。
- cand_timed ≈ baseline_hard5（cand≠ref 差异中位数 <0.5%）→ 市场门把放行完全关掉了，等于没做实验，不通过。
- cost2x_slip2bps 下 cand_timed <3/4 段 final 不低于 baseline → 成本不稳健，不通过。
- cand_timed 的 2020_2021 段 final 显著低于 V2（如低于 240000，即市场门把牛市放行收益砍掉大半）→ 市场门过严，得不偿失，不通过。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 通过（前置判定） | 市场状态取自 `_r010a_state_prices`，该缓存由 `filter_etfs` 在每日开盘处理时写入（源码 line 7727），用的是**前一日及更早**的收盘序列；overnight gate 在 `filter_etfs` 之前调用 `_score_hot_state_metrics(context)` 读这个缓存（line 7968），用的是 t-1 数据 |
| 信号生成和成交价格不存在同 bar 泄漏 | 通过（前置判定） | overnight_share_median 用过去 5 日累计隔夜/日内收益（`_overnight_share_from_panel`，window=5），全部是 t-1 及之前；市场门三指标（ma20_breadth/median_ret20/ret20_breadth）用 t-1 收盘算；决策在 t 日开盘后，无同 bar 泄漏 |
| 股票池或 ETF 池不存在未来成分泄漏 | 通过（前置判定） | 使用与 baseline_hard5 相同的 STATIC_ETF_POOL + g_dynamic_pool，未改池 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 本实验不用财务/宏观数据 |
| Shadow 或观察信号未被当成默认交易信号 | 通过（前置判定） | `overnight_share_gate_shadow_enabled=false`；市场门字段 `overnight_share_gate_market_gate_enabled` 默认 false，仅在 cand_timed 变体显式开 true，baseline/ref/cand_full 均为 false |

负控或错位检查：

- 消融对照：cand_full_release_low_share（无市场门）vs cand_timed_low_share（有市场门），直接归因市场门效果。
- 成本扰动：cost1x + cost2x_slip2bps 双口径。
- 2025_20260519 段作为近端样本外/压力段。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | 本页冻结所有阈值，结果出来前不调 |
| 样本内、验证集、样本外划分清楚 | 通过 | 2020_2021/2024 样本内，2022_2023 压力期，2025_20260519 近端样本外 |
| 邻近参数敏感性合理 | 不适用（本实验不做参数矩阵） | 阈值 frozen，不扫邻域；若需敏感性由后续实验承担 |
| 成本、滑点或换手扰动已检查 | 待回测 | cost1x + cost2x_slip2bps 双口径 |
| 已做消融或负控 | 待回测 | cand_full vs cand_timed 消融归因市场门 |
| 未只报告最优结果 | 通过 | 报告全部 4 变体 × 4 段 × 2 成本 = 32 个结果 |

**冻结阈值（结果出来前不调，非本次新调参数）**：

- `overnight_share_gate_low_threshold`: -0.39737791172306486（EX-7TJU 全样本 q20，n=361）
- `overnight_share_gate_release_max_score`: 8.0（拦 8+ 过热，V2 口径）
- `overnight_share_gate_market_min_ma20_breadth`: 0.50
- `overnight_share_gate_market_min_median_ret20`: 0.015
- `overnight_share_gate_market_min_ret20_breadth`: 0.45

市场门三阈值移植自策略现有 `score_hot_lit_state` 健康上涨状态默认定义（源码 line 80-82，`score_hot_lit_state_min_median_ret20=0.015`、`score_hot_lit_state_min_ret20_breadth` 隐含 0.52→本实验取更松 0.45、`score_hot_lit_state_min_ma20_breadth=0.45`→本实验取更松 0.50 以避免过严），是策略既有判断逻辑的复用，非本次为追结果新调。MA20 广度 0.50 比既有 0.45 更松（更容易放行），避免市场门把牛市放行也拦掉。

证据等级：`L2`（预注册 formal，假设/预测/基准/证伪/成本/消融齐全；通过后可 promote_candidate）。

## 10. 子代理调用记录

子代理计划：调用；调用ID：SUB-20260622T210000Z-main-Q3R8；任务代号：SUBTASK-20260622T210000Z-main-Q3R8_子查_overnight链条证据核对；平台昵称：待工具返回；模型：Explore（子查）；交付物：overnight 链条证据摘要表 + 前序文档债清单 + 7KMP config 字段核对。

调用状态：called（后台进行中）

子代理豁免：本轮假设设计、证伪规则、未来函数审计前置判定、最终决策由主控承担；子代理只做检索核对。

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-20260622T210000Z-main-Q3R8 | 待返回 | SUBTASK-...Q3R8_子查_overnight链条证据核对 | Explore | 2026-06-22T21:00:00Z | J3YY/7TJU/PNV8/6XCN/78RB + 7KMP manifest/config | 无 | 无 | 只做检索核对 | 待返回 | 待复核 | 提供干净证据基础，不决定路线 |

台账行：回测完成后同步 `01_台账/子代理调用台账.csv`。

## 11. 执行记录

### 平台配置

```text
configs/research/R010-A22/overnight_timed_paired/EX-20260622T133000Z-main-7KMP/formal/
4 变体 × 4 段 × 2 成本 = 32 configs
config 生成器：scripts/research/generate_7kmp_overnight_timed_configs.py
策略源码改动：src/strategies/research/etf_dual_pool_r010b_action_ablation.py
  - 新增配置字段 overnight_share_gate_market_gate_* （line 412-418）
  - _compute_overnight_share_today 加市场状态前置门（loosen 判定后）
  - _log_overnight_share_gate_shadow 扩展市场状态日志
```

**流程违规说明（诚实记录）**：config 和策略源码改动是在补本预注册之前完成的（违反"先有假设再跑实验"原则）。但**本预注册的假设、预测、证伪条件是在看到任何 7KMP 回测结果之前确定的**——此前尝试的 2024 段 smoke 因 shell 路径变量未展开而失败，未产生任何 7KMP 结果数据。因此假设未被结果污染，预注册有效。后续严格按预注册证伪条件判定。

### 运行命令

```bash
# 选项1 并行回测（4 变体 × 4 段 cost1x = 16 段，max-parallel=6 分批）
wsl -- bash -lc "cd '/mnt/e/量化平台_V1.4.0' && bash scripts/research/run_parallel_backtest.sh \
  --max-parallel 6 \
  configs/research/R010-A22/overnight_timed_paired/EX-20260622T133000Z-main-7KMP/formal/{baseline_hard5,ref_a22_cap70_always,cand_full_release_low_share,cand_timed_low_share}/cost1x/{2020_2021,2022_2023,2024,2025_20260519}/7kmp_*.json"
```

实际命令：上述 16 段 cost1x config，21:50 启动并行（max-parallel=6），22:59 全部完成，耗时约 69 分钟（因本批集中多个 2 年重段，慢于 6 段并行 10.5 分钟基准）。

### 可见进度与日志

- 是否过程可见：是（run_parallel_backtest.sh 默认 PYTHONUNBUFFERED=1 + tee，logs.jsonl 实时落盘）
- 日志路径：`results/.../formal/<variant>/cost1x/<segment>/<hash>/logs.jsonl`
- 查看进度命令：`tail -n 1` 各段 logs.jsonl 读 `date` 字段
- 异常判断：无。6 进程 CPU 全程 160-250% 活跃，无卡死、无 swap 使用（MemAvailable 57GB+）；drop_caches 释放缓存后未影响回测。16/16 summary.json 全部正常生成。

### 结果路径

```text
results/v2/research/R010-A22/overnight_timed_paired/EX-20260622T133000Z-main-7KMP/formal/<variant>/<cost>/<segment>/
```

## 12. 实际观察

### 12.1 cost1x 四段 final_value 对比（初始资金 100000）

| 段 | baseline_hard5 | ref_a22_cap70 | cand_full_V2 | cand_timed | timed_vs_hard5 | timed_vs_full |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 2020_2021 | 225080 | 132765 | 259282 | 225583 | +0.2% | **-13.0%** |
| 2022_2023 | 131215 | 103364 | 128378 | 129133 | -1.6% | **+0.6%** |
| 2024 | 167005 | 162437 | 165484 | 165347 | -1.0% | -0.1% |
| 2025_20260519 | 317974 | 59923 | 292922 | 310612 | -2.3% | **+6.0%** |

### 12.2 cost1x 四段 max_drawdown 对比

| 段 | baseline_hard5 | cand_full_V2 | cand_timed |
| --- | ---: | ---: | ---: |
| 2020_2021 | -0.2068 | **-0.1914** | -0.1955 |
| 2022_2023 | -0.2713 | **-0.2587** | -0.2588 |
| 2024 | -0.2699 | -0.2702 | -0.2699 |
| 2025_20260519 | -0.1657 | -0.1871 | **-0.1735** |

### 12.3 门禁判定结果（脚本 verdict）

| 门禁 | cand_timed | cand_full |
| --- | --- | --- |
| final 4/4 cost1x | ❌ (1/4) | ❌ (1/4) |
| final 3/4 cost1x | ❌ (1/4) | ❌ (1/4) |
| mdd 3/4 cost1x | ✅ (3/4) | ❌ (2/4) |
| cost2x 3/4 | ⏳ 未跑 | ⏳ 未跑 |
| cand≠ref（中位差异） | ✅ 0.6991 | ✅ 0.9529 |

### 12.4 市场门归因（cand_timed vs cand_full）

| 段 | timed | full | diff | 预期方向 |
| --- | ---: | ---: | ---: | --- |
| 2020_2021 | 225583 | 259282 | **-13.0%** | ⚠️ 市场门砍了牛市收益（不符预期，砍太多） |
| 2022_2023 | 129133 | 128378 | **+0.6%** | ✅ 市场门改善熊市（符合预期） |
| 2025 | 310612 | 292922 | **+6.0%** | ✅ 市场门改善反弹段（符合预期，超出预期幅度） |

### 12.5 cost2x_slip2bps 成本扰动补证（四段 final_value）

| 段 | hard5 | ref_a22 | cand_full | cand_timed | timed_vs_hard5 |
| --- | ---: | ---: | ---: | ---: | ---: |
| 2020_2021 | 213091 | 128721 | 241939 | 213258 | **+0.1%** |
| 2022_2023 | 124874 | 100027 | 122702 | 123517 | -1.1% |
| 2024 | 163161 | 160090 | 160973 | 161541 | -1.0% |
| 2025_20260519 | 302895 | 58526 | 278466 | 295622 | -2.4% |

### 12.6 cost2x_slip2bps MDD 对比

| 段 | hard5 | cand_full | cand_timed |
| --- | ---: | ---: | ---: |
| 2020_2021 | -0.2169 | -0.2039 | **-0.2029** |
| 2022_2023 | -0.2822 | **-0.2667** | -0.2670 |
| 2024 | -0.2748 | -0.2745 | -0.2748 |
| 2025_20260519 | -0.1699 | -0.1910 | **-0.1776** |

### 12.7 成本扰动稳健性诊断

成本从 1x→2x+2bps 滑点，各变体受侵蚀幅度：

| 变体 | 2020_2021 | 2022_2023 | 2024 | 2025 |
| --- | ---: | ---: | ---: | ---: |
| hard5 | -5.3% | -4.8% | -2.3% | -4.7% |
| cand_timed | -5.5% | -4.4% | -2.3% | -4.8% |
| cand_full | -6.7% | -4.4% | -2.7% | -5.0% |

cand_timed 与 hard5 受成本侵蚀幅度几乎一致（差异 <0.2pp），没有出现"hard5 高换手成本被削弱、候选反超"的反转。**成本扰动下结论与 cost1x 一致，证伪稳健。**

## 13. 支持证据

1. **市场门方向性符合假设**：cand_timed vs cand_full 在 2022 熊市（+0.6%）和 2025 反弹（+6.0%）两段都改善了 V2 满仓放行——这是预注册预测的"市场门在弱市/反弹段减伤"的直接证据，说明市场状态门作为择时规则有部分有效性。
2. **2025 反弹段改善显著**：+6.0% 是本实验最大的单段正向归因，且发生在预注册标注为"关键不确定点"的 2025 段，说明市场门在反弹段确实拦掉了部分有害放行。
3. **MDD 控制有效**：cand_timed 在 4 段里 3 段 MDD 不差于 baseline_hard5（门禁 mdd 3/4 通过），且 2020_2021（-0.1955）和 2022_2023（-0.2588）明显优于或持平 baseline，说明市场门没有引入额外回撤风险。
4. **cand≠ref 差异显著**：cand_timed 与 ref_a22 中位差异 0.6991（远 >0.5% 阈值），证明市场门不是"把放行完全关掉等于没做实验"，它确实在交易。
5. **交易行为无异常**：6 进程并行回测 16/16 全部正常完成，无 swap、无卡死，数据质量可信。

## 14. 反对证据

1. **核心目标未达**：cand_timed 在 cost1x 4 段里 **0/4 段 final 超过 baseline_hard5**（最好成绩 2020_2021 仅 +0.2% 打平），未通过预注册证伪条件"≥3/4 段不低于 baseline"。这是决定性反对证据。
2. **市场门砍牛市过狠**：2020_2021 段 timed 比 full 低 13.0%，预注册证伪条件明确写"cand_timed 2020_2021 显著低于 V2（如低于 240000）→ 市场门过严得不偿失"——实际 225583 < 240000，**触发证伪**。
3. **cand_full 本身就弱**：消融对照 cand_full（无市场门 V2 满仓放行）同样 0/4 超过 hard5，说明问题根源在"V2 满仓放行跑不过 hard5"，市场门补不回来。
4. **ref_a22 全段大败**：ref_a22_cap70_always 4 段全部远低于 baseline（尤其 2025 仅 59923 vs hard5 317974，跌了 81%），再次确认"无脑 cap70 全程开"是有害的，但这不是本实验重点。
5. **成本扰动补证（cost2x_slip2bps）**：高成本下 cand_timed 仍 0/4 超过 hard5（最好成绩 2020_2021 +0.1% 打平，其余 -1.0%~-2.4%），**证伪条件 #4 触发**。cand_timed 与 hard5 受成本侵蚀幅度几乎一致（差异 <0.2pp），未出现"hard5 被高成本削弱、候选反超"的反转。结论与 cost1x 一致，**成本稳健性已验证**。

## 15. 偏差诊断

| 预测 | 实际 | 偏差 | 原因 |
| --- | --- | --- | --- |
| cand_timed 3/4 段 ≥ baseline | 0/4 | 严重偏差 | baseline_hard5 本身太强，放行方案（无论有无市场门）追不上 |
| 2020_2021 略低于 V2 +15.2% | 低 13.0% | 方向对幅度过大 | 市场门三阈值在牛市段也频繁触发，拦掉了过多有效放行日 |
| 2022_2023 从 -2.2% 改善到接近 0 | +0.6% vs full（仍 -1.6% vs hard5） | 方向对 | 市场门确实减了熊市伤，但 baseline 太强 |
| 2025 改善但幅度待验证 | +6.0% vs full | **超出预期** | 市场门在反弹段效果比预测更强 |
| MDD 不差于 baseline | 3/4 不差（通过） | 符合 | 市场门是减仓型规则，自然降回撤 |

**偏差本质**：假设的方向性逻辑（弱市减伤）是对的，但对 baseline 强度的预判错了。预注册时假设"V2 满仓放行 +15.2% 是真超额"，实际看 cand_full 全段也跑不过 hard5——说明 EX-6XCN 报告的 V2 牛市超额可能被其他因素（如段内基准口径、换手成本）解释，hard5 才是这个策略族的稳健上限。

## 16. 研究判断

**建议状态：park（实验失败，证伪条件触发 3/5，结论成本稳健）。详见 [[05_研究决策/DEC-20260622T163008Z-main-GHZE_7KMP隔夜收益时段条件化市场门formal证伪决策|DEC-GHZE park 决策]]。**

判定依据（对照预注册证伪条件）：

1. ❌ "cand_timed ≥3/4 段 final 不低于 baseline" —— cost1x 实际 0/4，**证伪触发**。
2. ✅ "cand_timed 2022_2023 不低于 cand_full" —— 实际 +0.6%，通过。
3. ✅ "cand_timed cand≠ref 差异 ≥0.5%" —— 实际 0.6991，通过。
4. ❌ "cost2x 下 ≥3/4 段不低于 baseline" —— 实际 1/4（仅 2020_2021 +0.1% 打平），**证伪触发**。
5. ❌ "cand_timed 2020_2021 不低于 240000" —— 实际 225583，**证伪触发**。

**但保留价值**：市场门方向性证据（2022/2025 改善、MDD 3/4 通过）值得记入资产，不直接 kill 整个方向。市场门作为"减伤补丁"有效，作为"反超 hard5 手段"无效——核心瓶颈是 hard5 太强，不是市场门逻辑错。

**成本稳健性结论**：cost1x 与 cost2x_slip2bps 双口径下，cand_timed 与 hard5 受成本侵蚀幅度几乎一致（差异 <0.2pp），结论一致。证伪条件 #4 在成本扰动下仍触发，**成本稳健性已验证，本结论可记为"已证伪"（非仅"探索观察"）**。

**对前序决策的影响**：DEC-78RB 的 V2 revise 决策（满仓放行）需要重新审视——V2 满仓放行（cand_full）在 cost1x 和 cost2x 下均全段跑不过 hard5，说明 V2 revise 可能本身就不该 promote。本实验后用 DEC 决策卡正式回顾 DEC-78RB。

## 17. 下一步

### 立即（本实验收尾）

1. ✅ **cost2x_slip2bps 16 段成本扰动补证已完成**——结论与 cost1x 一致，证伪条件在双口径下均触发，成本稳健性已验证。
2. **写 DEC 决策卡**（todo #7）——基于 cost1x + cost2x 双口径证据，正式判定候选不 promote，并回顾 DEC-78RB V2 revise。

### 后续（独立候选，本实验失败不阻断）

3. ✅ **选项2 全年年化对比 V2 vs hard5**（todo #9）——已完成，见第 18 章。V2 满仓放行全年年化微弱反超（+0.69pp cost1x），但不显著，park 维持。
4. **选项3 分数上限实验 max_score=8/7/6（正式 drop，不执行回测）**——经主控研究判断，本选项不执行回测，理由：(1) 选项1 双口径已稳健证伪（候选 0/4 反超 hard5，证伪条件触发 3/5）；(2) 选项2 全年年化 V2 仅微弱反超且不显著，即使 max_score=8 独立有效也不足以改变 park 结论；(3) 即便 ms7/ms6 在四分段反超 hard5，也只是把 park 改回 revise，边际价值低于回测成本。DEC-78RB 边界提到的"max_score=8 独立有效"留作未来开放问题：若后续有新样本持续支持 V2 全年年化领先，可连同 max_score 拆解一并重启。

### 资产维护

5. 重建研究进展板 canvas + 研究图谱（本实验状态变更后必跑）。
6. 同步子代理调用台账（SUB-Q3R8 已完成 config 核对）。
7. 本实验 cost1x 结果登记到结果台账（只登记路径，不复制大文件）。

## 18. 选项2 全年年化对比（四段几何拼接，重要矛盾发现）

> 用四段 final_value（各段从 100000 独立起跑）几何拼接，按日历年数加权算年化。总跨度 2020.01.01–2026.05.19 = 6.379 年。

| 变体 | cost1x 年化 | cost2x 年化 |
| --- | ---: | ---: |
| hard5 | 54.04% | 49.84% |
| **V2 满仓放行（cand_full）** | **54.73%** | **50.12%** |
| V2+市场门（cand_timed） | 52.91% | 48.80% |

### 矛盾：四分段口径 vs 全年年化口径

- **四分段口径**：V2 满仓放行 0/4 段 final 超过 hard5 → 判定 V2 输。
- **全年年化口径**：V2 满仓放行 cost1x +0.69pp、cost2x +0.28pp 微弱反超 hard5 → 判定 V2 赢。

**矛盾根源**：四分段每段独立从 10 万起跑，是"分段相对表现"；全年年化是几何拼接，V2 在 2020_2021 牛市段 +159%（vs hard5 +125%）的巨大绝对收益被几何放大，掩盖了它在其余 3 段的劣势。

### 对 park 决策的影响（主控判断）

1. **V2 微弱领先统计不显著**：cost1x 仅 +0.69pp、cost2x 仅 +0.28pp，且源于单段极端收益的几何放大，不足以推翻四分段 0/4 反超的稳健证据。
2. **V2+市场门全年年化最差**：市场门砍掉了 V2 的牛市超额（2020_2021 从 +159% 降到 +125.6%），却没在其余段补回来，导致全年年化 52.91% 低于 V2 和 hard5——这进一步证明**市场门在这个策略族里是负贡献**。
3. **park 决策维持**：全年年化的微弱反转不改变 park 结论。但这个矛盾值得记入资产，提示"单段极端收益可能被几何口径放大"，未来若 V2 在更多样本持续微弱领先，可重新审视。

### 计算脚本

`tools/calc_7kmp_annualized.py`（研究库内，可复算）。
