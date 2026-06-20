---
type: 研究方向
rd_id: RD-20260620T022601Z-main-GHZL
parent_rd_id: RD-20260619T083919Z-main-WEMY
scope: 模块
module_type: 撤离追高状态机 m04 单因子深化
status: active
priority: P1
owner: main
created_at: 2026-06-20T02:26:01Z
updated_at: 2026-06-20T07:30:00Z
strategy_id: STRAT-20260605T115651Z-main-DP00
current_decision_id: DEC-20260620T062621Z-main-Z8MP
current_best_ex_id: EX-20260620T022611Z-main-FZM4
tags: [双池轮动, hard5, MAX, 彩票式过热, 横截面异象, 顶刊, WEMY子方向, m04深化]
---

# 双池轮动 MAX 彩票式过热信号

## 关联链接

- 父方向：[[02_研究方向/RD-20260619T083919Z-main-WEMY_双池轮动A股撤离追高状态机|双池轮动 A 股撤离追高状态机]]（WEMY 当前 revise，A28 已把 MAX 列为 m04 strong hint）
- 祖父方向：[[02_研究方向/RD-20260605T133318Z-main-H6V3_双池轮动score过热拥挤机制模块|双池轮动 score 过热拥挤机制模块]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 来源文献：[[06_文献资料/00_待处理/LIT-20260620T022539Z-main-36A6_MAX彩票式过热BaliCakiciWhitelaw2011|MAX 彩票式过热 Bali Cakici Whitelaw 2011]]
- 关联综述（MAX 列为 M4）：[[06_文献资料/00_待处理/LIT-20260619T104218Z-main-66QH_顶刊K线成交量过热修复因子机制综述|顶刊 K 线成交量过热修复因子机制综述]]
- 关联框架（`max_daily_return_20` 列为 p_overheat 字段）：[[07_因子数据灵感/03_机制/MECH-20260619T025934Z-main-DQUM_hard5过热概率与反弹修复状态框架|hard5 过热概率与反弹修复状态框架]]
- 上游 A28 数据门禁（m04 strong hint，24 事件 H10 +4.19pp 胜率 66.67%）：[[04_实验记录/EX-20260619T113348Z-main-UN96_A28非QMT量价结构状态机数据门禁|A28 非 QMT 量价结构状态机数据门禁]]
- 上游 A28 决策：[[05_研究决策/DEC-20260619T114146Z-main-5E5G_A28量价结构门禁通过后转过热veto正式实验|A28 量价结构门禁通过后转过热 veto 正式实验]]
- 当前最佳实验：[[04_实验记录/EX-20260620T022611Z-main-FZM4_MAX彩票式过热只读面板预注册|MAX 彩票式过热只读面板预注册]]
- 研究驾驶舱：[[00_入口/研究驾驶舱|研究驾驶舱]]

## 一句话说明

作为 WEMY 量价结构状态机的子方向，用 Bali-Cakici-Whitelaw 2011 的严格横截面十分位方法深化 A28 已识别的 m04（极端单日收益）strong hint，并补 A 股涨停制度交互，与 A29 组合 veto formal 互补——不重复 A29 的组合验证，只做 MAX 单因子深化。

## 研究对象

- 所属策略：双池轮动策略（`RD-20260605T115651Z-main-DP00`）。
- 所属模块：A 股撤离追高状态机（`RD-20260619T083919Z-main-WEMY`）下的 m04 单因子深化子方向；祖父方向是 score 过热拥挤机制模块（`RD-20260605T133318Z-main-H6V3`）。
- 平台策略代码：`${QUANT_PLATFORM_ROOT}/src/strategies/research/etf_dual_pool_r010b_action_ablation.py`（沿用 H6V3 既有 R010 动作消融框架）。
- 平台只读脚本：首轮需新建只读面板脚本，参照 `analyze_a28_volume_price_structure_gate.py` 和 `analyze_r010a16_hot_state_panel.py` 的风格。
- 平台结果路径：`${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260620T022601Z-main-GHZL/EX-20260620T022611Z-main-FZM4/`（待执行）。

## 当前研究信念

WEMY 的 A28 已经把 66QH 的 M1-M16 落到 178 个 hard5 高分事件上做数据门禁和只读强线索排序，发现 4 个 strong hint 均为过热 veto，其中 `m04_lottery_extreme_return_veto`（极端单日收益，即 MAX）24 事件、4 段、H10 effect `+4.19pp`、胜率 `66.67%`，方向与 Bali-Cakici-Whitelaw 2011（JFE）的 MAX 异象预测一致（高 MAX 后续 underperform）。

本子方向的核心信念是：A28 只做了 m04 的 veto 二元（命中/不命中），没有做 Bali 式的横截面十分位排序，也没有处理 A 股涨停制度对 MAX 的截断。Bali 2011 证明低/高 MAX 十分位月度收益差超过 1%，控制动量、反转、流动性后仍稳健。本方向用 Bali 的严格十分位方法深化 m04，并补"涨停封顶的 MAX vs 自然跳涨的 MAX"分层（Cogent 2023 中国 MAX 研究强调这是中国市场关键），与 A29 的 4 veto 组合 formal 互补——A29 验证组合 veto 的组合层收益，本方向验证 MAX 单因子的横截面预测力和负控。

## 可观察预测

如果这个方向是对的，应能看到：

- 在 hard5 高分事件中，按 Bali 十分位排序后，高 MAX 桶的 H5/H10 均值低于低 MAX 桶，且呈单调递减。
- 高 MAX 桶下尾 p10 更负，未来 10 日最大回撤更深。
- 这个差异在随机同 MAX 桶、`shift_prev1/shift_next1` 错位、同主题随机同规模负控下仍成立。
- 至少 `3/4` 历史分段方向一致。
- 涨停封顶的 MAX 与自然跳涨的 MAX 表现不同（A 股制度交互增量）。

## 竞争性解释

即使高 MAX 表现差，也可能来自：

- A 股涨停制度把单日涨幅机械封顶（10%/20%），MAX 被截断，反映的不是彩票偏好而是涨停板特性。
- 少数商品 LOF 或跨境 ETF 暴涨主导均值。
- 高 MAX 只在 2020 普涨冲顶年份有效，跨期不稳。
- ETF 已分散特质风险，MAX 异象弱于个股横截面。
- 与 A28 m04 veto 重叠，本方向的增量只是十分位细节，不是新机制。

## 证伪条件

出现以下情况，本方向应 `revise`、`park` 或 `kill`：

- Bali 十分位分层后 H5/H10 差异消失，或被随机同 MAX 桶、错位一日、同主题随机负控复制（说明 A28 m04 veto 已捕获全部信号，本方向无增量）。
- MAX 在 A 股涨停制度下信号失效，涨停板数才是真信号而非 MAX 本身。
- 只在单一年份有效，`<3/4` 分段方向一致。
- 事件数不足 50，无法形成统计结论。
- 看完结果后才后验调 MAX 窗口、分桶阈值或组合权重（违反 5E5G "不在 A28 结果上调阈值"的边界）。

## 已完成实验

| ex_id | 结论 | 记录 |
| --- | --- | --- |
| EX-20260620T022611Z-main-FZM4 | 待执行（preregistered） | [[04_实验记录/EX-20260620T022611Z-main-FZM4_MAX彩票式过热只读面板预注册]] |

## 关键决策

| dec_id | 决策 | 记录 |
| --- | --- | --- |

## 当前下一步

先执行 `EX-20260620T022611Z-main-FZM4` MAX 彩票式过热只读面板：在 hard5 高分事件上用 Bali 十分位方法检验 MAX 分布、高/低 MAX 桶的 H5/H10 差异、下尾和分段稳定性，并补随机同 MAX 桶、错位一日、同主题随机、涨停板分层四类负控。

只有过只读门槛后（事件数 `>=50`、H5/H10 差异显著且中位不显著为负、胜率 `>=52%`、`>=3/4` 分段一致、四类负控不可复制），才考虑把 MAX 作为 MECH-DQUM 框架 `p_overheat` 的独立字段，或作为 A29 strong-veto 的单因子依据进入 formal。本方向**不直接写成 hard5 过滤规则**，也**不复活**残差动量、52 周高点、FIP、分钟路径、强势阶段转移、盘中热点或反弹修复任一已 park 路线。与 A29 组合 veto formal 是互补关系：A29 验证组合收益，本方向验证单因子机制。

## 给新手的方向解释

- 为什么有这个方向：A28 已经发现"极端单日收益"（MAX）是 hard5 高分事件里 4 个过热 veto strong hint 之一，但只做了二元 veto。Bali 2011 顶刊证明 MAX 是稳健的横截面异象，值得用十分位方法单独深化，并处理 A 股涨停制度对 MAX 的截断。
- 它和主策略的关系：是 WEMY 撤离追高状态机的子方向，目标是回答"高分里的单日跳涨（高 MAX，应保守）和连续温和上涨（低 MAX，可能可追）如何区分"。
- 当前最重要的证据：A28 m04 strong hint（24 事件 H10 +4.19pp 胜率 66.67%）方向与 Bali 2011 一致。
- 现在还不知道什么：A 股涨停制度会不会把 MAX 截断到失效；十分位排序后信号剩多少；与 A29 组合 veto 是否互补还是重复。
