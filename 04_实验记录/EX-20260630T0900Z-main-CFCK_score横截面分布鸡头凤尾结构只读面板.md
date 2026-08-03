---
type: 实验记录
ex_id: EX-20260630T0900Z-main-CFCK
rd_id: RD-20260605T133318Z-main-H6V3
status: completed
stage: completed
owner: main
created_at: 2026-06-30T09:00:00Z
updated_at: 2026-06-30T10:30:00+08:00
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 核心轮动 score 过热拥挤机制
decision_ids: []
lit_ids: []
idea_ids: []
platform_project: ${LEGACY_QUANT_PLATFORM_ROOT}
config_paths:
  - 未执行回测配置（只读分布面板）
result_paths:
  - results/v2/research/RD-20260605T133318Z-main-H6V3/score_distribution_explore/
summary_paths:
  - results/v2/research/RD-20260605T133318Z-main-H6V3/score_distribution_explore/summary.json
  - results/v2/research/RD-20260605T133318Z-main-H6V3/score_distribution_explore/overview.json
quality_gate: completed_readonly_distribution_panel_preregistered
subagent_call_ids: [SUB-20260630T1000Z-main-SCOREDIST]
subagent_exemption: 本轮主控亲自执行写脚本与跑数据（子代理执行超时后接管）；侦察阶段调用 3 个 Explore 子代理（SUBTASK-A2-SKELETON/SCORING/RISK-EXEC）和 1 个 general-purpose 执行子代理（SUBTASK-SCORE-DISTRIBUTION-PANEL，超时未交付）。本面板的 score 计算口径、未来函数判断、研究结论由主控亲自复核。
tags: [双池轮动, score分布, 鸡头凤尾, 双峰, hard5, 聚类阈值, H6V3, 只读面板]
---

# score 横截面分布鸡头凤尾结构只读面板

## 关联链接

- 研究方向：[[02_研究方向/RD-20260605T133318Z-main-H6V3_双池轮动score过热拥挤机制模块|双池轮动 score 过热拥挤机制模块]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 相关方向：[[02_研究方向/RD-20260619T083919Z-main-WEMY_双池轮动A股撤离追高状态机|WEMY 撤离追高状态机]]（A28 四 veto 的上游）
- 相关机制：[[07_因子数据灵感/03_机制/MECH-20260619T025934Z-main-DQUM_hard5过热概率与反弹修复状态框架|MECH-DQUM hard5 过热概率框架]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：有人提出一个思路——ETF 的动量 score 在数轴上会"聚成两段"（强者恒强 vs 弱者愈弱），可以用聚类找到两段之间的谷点作为动态拦截阈值，替代 hard5 的静态 score=5。

我们原本预计：2022_2023（分化期）和 2025_20260519（抱团期）应该出现明显的双峰结构；2020_2021（普涨期）趋于单峰。

实际看到：**20 个代表性日期全部是单峰，没有任何一个出现双峰**。ETF 的 score 横截面是单调衰减的单峰分布——一个大峰在低分端（主体 0-3 分），高分端逐渐稀疏但没有第二个峰。

这说明：ETF 作为分散工具，把个股层面的剧烈分化熨平了，"科技抱团 vs 旧资产"的双峰分化**在 ETF 的 score 数轴上根本不出现**。"用聚类找动态分界点替代 hard5"这个具体思路在 ETF 层面**从根上不成立**。

但还不能说明：这个思路完全没价值。因为数据同时证实了一个真实现象——**极少数标的的 score 远超主体（"鸡头"长尾）**，在抱团期 top5 均值能到 70-105，而主体只有 2-3 分。这说明"强者很强"是真的，只是它的形态不是"两段聚集"，而是"主体群 + 离群点"。正确的处理方式应是离群点检测（这正是 hard5 和 A28 过热 veto 在做的事），不是聚类分界。

下一步要做：不是继续找动态分界点。既然"鸡头长尾"真实存在，下一步应回到"这些极端高分标的是真趋势还是过热"——这正是 WEMY/A28/MECH-DQUM 路线。如果继续研究 score 分布，应聚焦"离群点的时序持续性"而非"横截面分界"。

## 2. 研究背景

用户（接手 A2 策略改进）提出别人提供的思路：把 hard5 的静态阈值（score=5）换成"横截面 score 分布的自适应聚类分界点"。假设 150 个标的的 score 会聚集成段（中间密集带 + 两端离散的"鸡头"高分和"凤尾"低分），抱团/分化期形成双峰，可用聚类找两峰之间的谷点作动态阈值。用户要求先用 Python 画图验证这个结构是否真实存在。

## 3. 实验前假设

ETF score 横截面分布在分化/抱团期存在"聚集带 + 离散双尾"或双峰结构。

## 4. 实验前预测

- 分化期（2022_2023）和抱团期（2025_20260519）双峰更明显
- 普涨期（2020_2021）趋于单峰
- top5 / bottom5 与主体有明显距离（鸡头凤尾）

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| hard5 阈值（score=5） | 作为参照线画在分布图上 | 策略默认 `max_score=5` |
| k-means k=2 分界点 | 检验聚类能否找到稳定分界 | 本面板 1D 精确解 |
| max-gap 分界点 | 检验最大间隔法 | 本面板排序后相邻差最大处 |
| annualized / R² 分量 | 判断双峰是否来自 R² 压制 | 拆开 score 两个分量分别画分布 |

## 6. 竞争性解释

1. score = 年化收益 × R²，R²∈[0,1] 可能人为制造低分聚集带，造成双峰假象。
2. 样本量差异（2020 年有效 ETF 少至 54 只，2026 年 133 只）可能影响分布形状。
3. 本面板只用 STATIC_ETF_POOL（133 只）未叠 MA 过滤和动态池，与策略实际筛选池略有差异。

## 7. 证伪条件

- 所有时期均为单峰连续衰减分布 → 思路缺乏数据支撑（部分成立）
- 双峰完全由 R² 压制造成 → 非市场分化（已排除，annualized 单独也是单峰）
- 分界点剧烈漂移 → 无法稳定使用（成立，std 是均值的 2.3 倍）

## 8. 未来函数审计

| 项目 | 检查 | 结论 |
| --- | --- | --- |
| 数据时间戳 | 用 D 日 close 算 D 日横截面分布 | 只读统计，不复现交易 |
| 信号滞后 | 面板不产生交易信号 | 无未来函数风险 |
| 交易价格 | 无交易 | 不适用 |
| 口径一致性 | score 公式 1:1 复用 `_score_log_matrix`（momentum.py:144-180） | 通过 |
| 负控 | 本面板是描述性统计，无收益对照 | 不适用（下一步 formal 时补） |

未来函数风险：无。本面板只读查询 ClickHouse 日线收盘价，用 D 日 close 计算 D 日的横截面 score 分布，不产生任何交易决策、不下单、不回测。

## 9. 过拟合审计

| 项目 | 检查 | 结论 |
| --- | --- | --- |
| 实验预注册 | 假设、预测、证伪条件在跑数据前已写 | 通过 |
| 参数范围 | 未调任何策略参数 | 不适用 |
| 多重比较 | 报告了全部 20 个日期，未只挑好的 | 通过 |
| 证据等级 | L1_readonly_distribution_panel | 只能 observe，不改策略 |

证据等级：**L1_readonly_distribution_panel_preregistered**。只能作为观察材料，不能作为路线升级依据。

## 10. 子代理调用记录

### 适配判断

本轮主控亲自执行写脚本与跑数据。原因：general-purpose 执行子代理（SUBTASK-SCORE-DISTRIBUTION-PANEL）在 600 秒内超时未交付任何产物，主控接管后分步完成（写脚本→装 matplotlib→去 sklearn/scipy 依赖改纯 numpy→跑通）。score 计算口径、未来函数判断、研究结论均由主控亲自复核。

### 调用表

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-20260630T0730Z-main-A2SKELETON | — | SUBTASK-A2-SKELETON | Explore | 2026-06-30T07:30Z | A2 配置、initialize、STATIC_ETF_POOL | 无 | 无 | A2 调度时序与配置覆盖 | 行号偏移已校正 | 通过 | 摸清 A2 骨架 |
| SUB-20260630T0730Z-main-A2SCORING | — | SUBTASK-A2-SCORING | Explore | 2026-06-30T07:30Z | filter_etfs、_score_etfs_batch、score_hot_filter | 无 | 无 | 选股与评分链路 | slope004 三种解读已主控核实 | 通过 | 摸清评分逻辑 |
| SUB-20260630T0730Z-main-A2RISKEXEC | — | SUBTASK-A2-RISK-EXEC | Explore | 2026-06-30T07:30Z | sell/buy/sync、B3gate、tiered-v2 | 无 | 无 | 风控与执行链路 | AURT 代号在代码中不存在 | 通过 | 摸清执行链路 |
| SUB-20260630T1000Z-main-SCOREDIST | — | SUBTASK-SCORE-DISTRIBUTION-PANEL | general-purpose | 2026-06-30T10:00Z | A28 脚本、momentum.py | 无（超时未交付） | 超时未执行 | 无（超时） | 任务过重超时 | 主控接管 | 改由主控亲自执行 |

### 台账行

已同步至 `01_台账/子代理调用台账.csv`（见台账同步步骤）。

## 11. 执行记录

### 平台配置

- 脚本：`${LEGACY_QUANT_PLATFORM_ROOT}/scripts/research/analyze_score_distribution_panel.py`
- 数据：ClickHouse `quant.jq_bar_daily`，端口 9001
- 候选池：STATIC_ETF_POOL 133 只（未叠 MA 过滤和动态池）
- score 公式：1:1 复用 `src/quant_v2/utils/momentum.py:144` `_score_log_matrix`（weights=linspace(1,2,n)，fit_weights=weights²，annualized=exp(slope*250)-1，r2=1-ss_res/ss_tot，score=annualized*r2）

### 运行命令

```bash
wsl -- bash -c "cd /mnt/e/量化平台_V1.4.0 && PYTHONPATH=src PYTHONUNBUFFERED=1 python3 scripts/research/analyze_score_distribution_panel.py 2>&1 | tee results/v2/research/RD-20260605T133318Z-main-H6V3/score_distribution_explore/run.log"
```

### 可见进度与日志

- 查询 ClickHouse：154227 行，133 只标的，交易日 2019-10-08 ~ 2026-05-19 共 1603 日
- 选定 20 个代表性日期（4 段 × 5 日）
- 算分完成 2071 行明细
- 分布分析 20 个日期全部完成
- 运行日志：`results/v2/research/RD-20260605T133318Z-main-H6V3/score_distribution_explore/run.log`

### 结果路径

- 明细：`daily_scores.csv`（2071 行）
- 汇总：`summary.json`、`overview.json`
- 图：`panel_<segment>_<date>.png` × 20 + `threshold_drift_timeline.png`

## 12. 实际观察

### 12.1 双峰性（核心证伪项）

| 指标 | 值 |
| --- | --- |
| 双峰日期数 | **0 / 20** |
| KDE 单峰日期 | 19 / 20（1 个报 2 峰但谷不深，未达双峰标准） |
| annualized 单独双峰 | 0 / 20 |

**结论：ETF score 横截面是单调衰减的单峰分布，不存在双峰。**

### 12.2 鸡头凤尾（top5 vs 主体）

| 日期段 | top5 均值 | 主体均值 | top5 距主体 | score≥5 数 |
| --- | --- | --- | --- | --- |
| 2020_2021（普涨） | 0.22 ~ 5.83 | -0.12 ~ 1.30 | 0.33 ~ 4.53 | 0 ~ 5 |
| 2022_2023（分化） | 1.53 ~ 6.32 | -0.16 ~ 1.27 | 1.69 ~ 5.05 | 0 ~ 9 |
| 2024（震荡） | 1.27 ~ 9.42 | -0.25 ~ 1.13 | 1.24 ~ 8.29 | 0 ~ 11 |
| **2025_20260519（抱团）** | **1.34 ~ 105.23** | -0.07 ~ 3.28 | **1.22 ~ 103.00** | 0 ~ 26 |

**结论："鸡头"长尾真实存在。** 抱团期（2025-09、2026-01、2026-05）top5 均值飙到 60-105，而主体 130 只 ETF 一直在 0-3 分。这是"主体群 + 极少数离群点"的长尾结构，不是"两段聚集"。

### 12.3 分界点稳定性

| 指标 | 值 |
| --- | --- |
| kmeans 分界均值 | 10.25 |
| kmeans 分界标准差 | **23.19**（是均值的 2.3 倍） |
| 分界范围 | -0.16 ~ 96.84 |

**结论：分界点剧烈漂移。** 少数极端高分（抱团顶的 100+）把 k-means 两簇中点拉飞。若用动态阈值替代 hard5，每天换股、换手爆炸，与 A2 低换手抗抖初衷冲突。

### 12.4 hard5 关系

| 指标 | 值 |
| --- | --- |
| kmeans 分界均值 vs hard5(5) | +5.25（分界均值高于 5） |
| score≥5 的 ETF 数 | 多数日期 0-1，抱团期飙到 11-26 |

## 13. 支持证据

- 20/20 日期单峰，无任何双峰 → 直接证伪"两段聚集"假设
- 分界点 std 是均值的 2.3 倍 → 聚类分界无法稳定使用
- annualized 单独也 0 双峰 → 双峰不是 R² 压制造成的（因为本来就没双峰）

## 14. 反对证据（不能只报支持项）

- "鸡头"长尾真实且显著：top5 距主体在抱团期达 74-103，说明"少数标的远超主体"是真的，只是形态是长尾非双峰
- 这意味着思路的**直觉**（强者很强、需特殊处理极端高分）有真东西，只是**机制理解错了**（不是聚类分界，是离群点处理）

## 15. 偏差诊断

预测"分化/抱团期双峰更明显"与现实"全单峰"的偏差原因：ETF 是分散工具，个股层面的剧烈分化在 ETF 层被熨平。用户/别人提供的思路很可能来自**个股层面**的经验（个股确实会出现明显的板块分化双峰），但 ETF 层面不成立。

## 16. 研究判断

**建议状态：observe（证伪"双峰分界"，确认"鸡头长尾"）**

- "用聚类找动态分界点替代 hard5"在 ETF 层面**证伪**：无双峰、分界点剧烈漂移。不进入 formal，不在本结果上后验调聚类方法/峰数/带宽。
- "鸡头长尾"现象**确认**：极少数标的 score 远超主体，抱团期极端化。这是 hard5 和 A28 过热 veto 存在的合理依据。
- 这条线索与研究库现有路线合流：处理极端高分应走"离群点识别"（A28 过热 veto / A22 软预算 / MECH-DQUM p_overheat），而非"横截面聚类分界"。

## 17. 下一步

1. **不继续**：不扩聚类方法（GMM/DBSCAN/Jenks）、不调峰数判定、不调 KDE 带宽——无双峰是结构性的，换方法不会改变结论。
2. **若继续 score 分布研究**：转向"离群点的时序持续性"——那些 score 飙到 50+ 的标的，后续是继续涨（真趋势）还是崩（过热）？这与 A28 的 raw-vs-actual H10 分析同源。
3. **与现有路线合流**：本面板确认了 hard5 过滤"鸡头"的合理性，下一步应回到 WEMY/A28/MECH-DQUM——区分"真过热"和"假过热"的极端高分，而不是找动态分界点。
4. **若该思路要救活**：必须换数据层（个股/微盘），但那不属于 ETF 双池轮动策略，需另开方向。
