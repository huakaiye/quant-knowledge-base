---
type: 研究方向
rd_id: RD-20260622T030341Z-main-S2T4
parent_rd_id: RD-20260605T133318Z-main-H6V3
scope: 模块
module_type: 核心轮动风控诊断模块（个股层 p_repair）
status: active
priority: P1
owner: main
created_at: 2026-06-22T03:03:41Z
updated_at: 2026-06-22T13:00:00Z
strategy_id: STRAT-20260605T115651Z-main-DP00
current_decision_id: DEC-20260622T123321Z-main-78RB
current_best_ex_id: EX-20260622T104131Z-main-6XCN
tags: [双池轮动, hard5, 隔夜收益, 知情交易, 个股层, p_repair, 顶刊, LouPolkSkouras2019, 过热vs修复, revise, 完全放行]
---

# 隔夜收益知情交易个股层 p_repair 信号

## 关联链接

- 父方向：[[02_研究方向/RD-20260605T133318Z-main-H6V3_双池轮动score过热拥挤机制模块|双池轮动 score 过热拥挤机制模块]]（H6V3）
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 灵感来源：[[07_因子数据灵感/03_机制/MECH-20260620T154044Z-main-MATN_顶刊灵感1 隔夜收益知情交易 Lou Polk Skouras 2019|MECH-MATN 隔夜收益知情交易]]
- 当前最佳实验：[[04_实验记录/EX-20260622T030348Z-main-J3YY_隔夜收益数据门禁与字段质量审计|EX-J3YY 数据门禁]]
- 当前决策：（待数据门禁后产出）
- 关联框架：[[07_因子数据灵感/03_机制/MECH-20260619T025934Z-main-DQUM_hard5过热概率与反弹修复状态框架|MECH-DQUM hard5 过热概率与反弹修复状态框架]]（p_repair 个股层字段）
- 失败前置（过热保守开关，均 park）：[[05_研究决策/DEC-20260620T150805Z-main-XSNQ_CS dispersion 组合层双方向配对 formal 决策|DEC-XSNQ CS dispersion park]]、[[05_研究决策/DEC-20260621T024805Z-main-CHCD_A29 frozen-veto 组合层双方向配对 formal 决策|DEC-CHCD frozen-veto park]]
- 文献：Lou Polk Skouras 2019（RFS 32(3):1300-1340，待建 LIT）
- 研究驾驶舱：[[00_入口/研究驾驶舱|研究驾驶舱]]

## 一句话说明

把 ETF 日收益拆成"隔夜"（open/pre_close）和"日内"（close/open）两段，用隔夜收益占比判断 hard5 高分标的的上涨是"知情/修复延续"（隔夜主导+日内不回落，应放行）还是"噪声追高"（日内冲高回落，应保守）。这是与 MAX/CS dispersion/GSADF/frozen-veto 完全正交的日内结构维度，直接解决两条过热保守开关线共同失败的核心矛盾——"同一信号在不同时段含义相反"。

## 研究对象

- 所属策略：双池轮动 DP00（默认 hard5）
- 所属模块：核心轮动风控诊断模块（个股层 p_repair）
- 平台策略代码：`${QUANT_PLATFORM_ROOT}/src/strategies/research/etf_dual_pool_r010b_action_ablation.py`
- 平台配置路径：待门禁后定
- 平台结果路径：待门禁后定

核心信号：
- `overnight_ret = open/pre_close - 1`（隔夜收益，含开盘跳空）
- `intraday_ret = close/open - 1`（日内收益）
- `overnight_share_5 = 过去5日累计隔夜收益 / (累计隔夜+累计日内)`

判定：`overnight_share_5` 高（隔夜主导）+ 日内不大幅回落 = 知情延续（放行）；日内冲高回落（`intraday_ret` 为负或反转）= 噪声追高（保守）。

## 当前研究信念

CS dispersion（组合层标量）和 frozen-veto（个股层结构）两条过热保守开关线均 park，共同核心矛盾是"同一信号在不同时段含义相反"（过热 vs 修复）。隔夜收益是日内结构维度，它看的不是"涨多少"而是"谁在买"——隔夜是机构调仓（知情），日内尾盘是散户追涨（噪声）。理论上能区分 veto/CS dispersion 都分不清的"过热 vs 修复"，是 MECH-DQUM 框架 p_repair 的最佳个股层候选。

## 可观察预测

如果这个方向是对的，应该看到：
- 隔夜主导的 hard5 高分标的 H10 effect 正向（知情延续，放行正确）。
- 日内冲高回落的 hard5 高分标的 H10 effect 负向（噪声追高，保守正确）。
- 隔夜占比对 high/low 桶的 H10 effect 有显著区分（类似 CS dispersion 的 low vs high 差）。
- 与 frozen-veto 的 4 个警报灯正交（不重叠）。

## 竞争性解释

- 隔夜跳空可能由指数期货/折溢价主导，而非个股知情（跨境 ETF 尤甚）。
- A 股 ETF 开盘集合竞价受做市商/申赎扰动，隔夜信号噪声可能大于美股个股。
- 隔夜占比可能与涨跌停制度交互（涨停日 overnight 接近 10%）。

## 证伪条件

- 数据门禁不通过（open/pre_close 覆盖率 <95%）→ 方向阻塞，等数据。
- 隔夜 high/low 桶 H10 effect 无显著区分 → p_repair 信号无效，park。
- 隔夜占比与 frozen-veto 的 4 警报灯高度相关（>0.7）→ 不正交，降级。
- 错位一日负控反转 → 同 FZM4 同款问题，park。

## 已完成实验

| ex_id | 结论 | 记录 |
| --- | --- | --- |
| EX-20260622T030348Z-main-J3YY | 数据门禁 PASSED（覆盖率 100%） | [[04_实验记录/EX-20260622T030348Z-main-J3YY_隔夜收益数据门禁与字段质量审计]] |
| EX-20260622T031432Z-main-7TJU | 只读面板 promote_candidate（low 桶全门禁通过：H10+0.0434/胜率61.7%/分段6/7/错位不反转） | [[04_实验记录/EX-20260622T031432Z-main-7TJU_隔夜收益知情交易只读面板预注册]] |
| EX-20260622T033017Z-main-PNV8 | V1 cap70 formal revise（修复 bug 后 2/4 段赢，参数矩阵 -0.50 达 3/4） | [[04_实验记录/EX-20260622T033017Z-main-PNV8_隔夜收益日内主导放行组合层formal]] |
| EX-20260622T104131Z-main-6XCN | V2 完全放行 formal revise（满仓 2020_2021 +15.2% 最强单段，但 1/4 段赢） | [[04_实验记录/EX-20260622T104131Z-main-6XCN_隔夜收益完全放行V2组合层formal]] |

## 关键决策

| dec_id | 决策 | 记录 |
| --- | --- | --- |
| DEC-20260622T123321Z-main-78RB | revise（V1/V2 均不足 4/4，但 2020 段 +15.2% 最强，需时段条件化） | [[05_研究决策/DEC-20260622T123321Z-main-78RB_隔夜收益放行formal决策(V1 revise V2 revise)]] |

## 当前下一步

**方向 revise（DEC-78RB）**。隔夜收益信号在事件级全门禁通过（H10+0.0434/胜率61.7%/分段6/7），V2 完全放行在 2020_2021 段达 +15.2%（所有方案最强单段超额），但组合层四段稳健性不够（V2 1/4）。

核心进展：
- 从 cap70 → 完全放行满仓：2020 段从 +5.6% 提升到 +15.2%（满仓效果显著）
- 退出机制诊断：5-7 分 + 10 天 + 日内主导 + 满仓最优（均值+5.33%/胜率71.4%）
- 信号方向正确（A股日内=趋势延续），但 2022/2025 仍有时段依赖问题

下一步选项（一切以实验结果说话）：
1. **时段条件化**：只在市场趋势向上+广度足时启用放行（可能解决 2022 熊市不该放行的问题）
2. **全年年化对比**：如果 V2 全年年化 > hard5，即使某些段输也值得
3. **分数上限实验**：max_score=8 vs 7 vs 6 的对比（max_score=8 可能独立有效）

## 给新手的方向解释

hard5 像一道"一刀切的保险丝"，看到高分就拦。但有时候高分是健康上涨（拦了错过机会），有时候是真过热（拦对了）。之前试过用"横截面离散度"和"量价警报灯"判断该不该拦，都失败了——因为它们在不同市场环境下含义相反。这次换思路：不看"涨多少"，看"谁在买"——隔夜涨的是机构（知情，该放行），盘中追的是散户（噪声，该拦）。
