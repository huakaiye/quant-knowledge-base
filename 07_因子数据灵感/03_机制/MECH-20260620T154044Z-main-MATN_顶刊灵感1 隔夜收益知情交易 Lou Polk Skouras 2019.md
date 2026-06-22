---
type: 因子数据灵感
idea_id: MECH-20260620T154044Z-main-MATN
status: draft
owner: main
created_at: 2026-06-20T15:40:44Z
updated_at: 2026-06-20T16:00:00Z
source_lit_ids: []
related_rd_ids: [RD-20260605T133318Z-main-H6V3]
category: 机制
tags: [顶刊灵感, 隔夜收益, 知情交易, 个股层, p_repair, ETF, 待数据门禁]
subagent_call_ids: [SUB-20260620T153000Z-main-E7F8]
---

# 顶刊灵感1 隔夜收益知情交易 Lou Polk Skouras 2019

## 关联链接

- 来源文献：Lou Dong, Polk Christopher, Skouras Spyros (2019), "A Flow-Based Explanation of Return Predictability," *Review of Financial Studies* 32(3):1300-1340（待建文献卡 LIT）
- 相关方向：[[02_研究方向/RD-20260605T133318Z-main-H6V3_双池轮动score过热拥挤机制模块|双池轮动 score 过热拥挤机制模块]]
- 升级实验：（待 formal 后决定）
- 相关术语：（待补）
- 关联框架：[[07_因子数据灵感/03_机制/MECH-20260619T025934Z-main-DQUM_hard5过热概率与反弹修复状态框架|hard5 过热概率与反弹修复状态框架]]（候选 `p_repair` 个股层字段）
- 数据门禁参考：[[07_因子数据灵感/03_机制/MECH-20260620T060722Z-main-APH5_FZM4MAX彩票式过热只读面板脚本设计|APH5 脚本设计卡]]

## 一句话说明

把 ETF 日收益拆成"隔夜（open/pre_close）"和"日内（close/open）"两段，用隔夜收益占比判断高分标的的上涨是"知情/修复延续型"（隔夜主导、日内不回落，可放宽 hard5）还是"噪声追高型"（日内尾盘冲高回落，保守）。这是与 MAX/CS dispersion/GSADF 三维完全正交的**日内结构维度**。

## 来源

顶刊机制灵感储备子代理 SUB-E7F8（2026-06-20）从金融顶刊检索，专为 CS dispersion formal 失败后的下一步储备。本方向在研究库 66QH 综述"持仓续持优先于新买"表里已列为候选状态，但标注"当前分钟/隔夜链路需继续审计"——即平台未系统验证过隔夜字段质量，存在数据门禁缺口。

## 可实现定义

字段（个股层，每个 ETF 标的，纯日频量价可算）：

```text
overnight_ret_t   = open_t / close_{t-1} - 1     # 隔夜收益（含开盘跳空）
intraday_ret_t    = close_t / open_t - 1         # 日内收益
overnight_share_5 = 过去 5 日累计 overnight_ret / (累计 overnight_ret + 累计 intraday_ret)
intraday_reversal_5 = 过去 5 日 intraday_ret 与当日 ret 的反向相关强度
```

判定：`overnight_share_5` 高（隔夜主导）+ 日内不大幅回落 = 知情延续 → 放宽 hard5；`intraday_reversal_5` 高（日内冲高回落）= 噪声追高 → 保守。

数据源：ClickHouse `quant.jq_bar_daily`，字段 `open_price / close_price / pre_close`（APH5 卡已确认端口 9001 可读）。

## 预期作用

改善 hard5 高分标的的**误杀/误放**判断精度，直接喂 MECH-DQUM 的 `p_repair`（修复延续 vs 噪声追高的个股层判别），解决用户核心痛点（p_repair 当前因真实 held_repair 仅 2 事件而阻塞）。预期改善收益质量（减少误放噪声追高）而非单纯提收益。

## 风险

- 数据是否可得：字段（open/close/pre_close）已在 `jq_bar_daily`，但 A 股 ETF 开盘集合竞价受做市商/申赎扰动，隔夜信号噪声可能大于美股个股；跨境 ETF 隔夜跳空受外盘影响，需按资产属性（A18 标签）分层。**前置：必须先做数据门禁**（复用 UN96/A28 风格），确认隔夜字段质量。
- 是否可能未来函数：overnight/intraday 用当日 open/close，signal_date 当天可得，无前视；overnight_share_5 的滚动窗口只用过去 5 日，需确保不含未来。
- 是否可能过拟合：窗口（5 日）需做 3/10 邻域敏感性；判定阈值需固定预注册值，不看结果后调。
- 是否影响交易成本：不改变交易频率，只改变高分标的放行/拦截决策，对换手影响中性。

## 与三维正交性

**高正交**。MAX（单日跳涨）/ CS dispersion（横截面离散度）/ GSADF（爆炸性过程）都是 close-to-close；隔夜/日内分解是**完全不同的日内结构维度**，三者都不覆盖。无需消融（正交性结构性成立）。

## 升级为实验的条件

- [ ] 数据门禁通过：`jq_bar_daily` 的 open_price/pre_close 在 A 股 ETF + 跨境 ETF 上的覆盖率、异常值（开盘停牌、涨跌停）清洗验证。
- [ ] CS dispersion formal 决策完成（DEC-XSNQ）：若 CS dispersion park，本方向升为新 RD 优先项；若 promote，本方向作为 p_repair 字段补充。
- [ ] 只读面板预注册（仿 BL8Y 风格）：先算全样本隔夜占比分布 + 高分事件分层 H10 effect，不直接接交易。

## 子代理依据来源

本灵感由 SUB-20260620T153000Z-main-E7F8（顶刊机制灵感储备）检索并结构化，主控已采纳 Top 1 排序建议。论文卷期页待主控正式立项前复核（RFS 32(3):1300-1340 为标准顶刊卷期）。
