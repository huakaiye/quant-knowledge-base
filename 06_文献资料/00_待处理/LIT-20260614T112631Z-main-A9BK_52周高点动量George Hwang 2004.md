---
type: 文献卡
lit_id: LIT-20260614T112631Z-main-A9BK
status: todo
owner: main
created_at: 2026-06-14T11:26:31Z
updated_at: 2026-06-14T17:40:00Z
year: 2004
journal: The Journal of Finance
authors: Thomas J. George, Chuan-Yang Hwang
doi:
url: https://www.bauer.uh.edu/tgeorge/papers/gh4-paper.pdf
related_rd_ids: []
related_factor_ids: []
related_data_ids: []
tags: [52周高点, 锚定效应, momentum, 顶刊, 待迁移实验]
---

# 52周高点动量George Hwang 2004

## 关联链接

- 相关方向：待关联（52 周高点锚定信号研究方向 RD 建设中）
- 因子灵感：52 周高点距离 nearness ratio（当前价 / 过去 52 周最高价）
- 数据灵感：ETF 日线收盘价、52 周滚动最高价
- 机制灵感：投资者以近端高点为心理锚，接近高点时的行为偏差可预测未来收益
- 模块灵感：核心轮动第二信号维度，与动量正交组合

## 文献信息

- 标题：The 52-Week High and Momentum Investing
- 作者：Thomas J. George, Chuan-Yang Hwang
- 年份：2004
- 期刊或来源：The Journal of Finance, Vol. LIX, No. 5
- DOI 或 URL：https://www.bauer.uh.edu/tgeorge/papers/gh4-paper.pdf

## 研究问题

传统动量（Jegadeesh-Titman，过去 6-12 个月收益排序）是否真的捕捉了"趋势外推"？还是说投资者真正在意的是"距离近端高点多近"这个心理锚？如果用 nearness ratio 替代传统动量，预测力如何？

## 数据

美国股票市场（CRSP），1929-1996 长样本，月频。后续在 20 个国际市场检验（Journal of International Money and Finance, 2011），其中 18 个市场有效；台湾市场（Physica A, 2015）也确认。

## 方法

定义 nearness ratio：

```text
nearness_i,t = 当前价_i,t / 过去52周最高价_i
```

按 nearness 排序构造多空组合，与按传统 6-12 月收益排序的动量组合对比收益、持续性、风险调整后表现。

## 核心结论

用中文概括，不粘贴长篇原文：

1. nearness ratio 能 **subsume（吸收）** 传统 6-12 月动量的预测力——即加入 nearness 后传统动量的 alpha 消失，反过来不成立。
2. 基于 nearness 的多空组合在持有期长达 **3 年**仍显著有效，远长于传统动量的 1 年衰减。
3. 机制解释：投资者以近端高点为锚，接近高点时"不愿卖出/愿意追入"的行为偏差是持续性的、可预测的。
4. 行业层面延伸（Liu et al.《Industry information and the 52-week high effect》）确认行业信息能增强该效应。

## 可转化灵感

| 类型 | 灵感 | 后续卡片 |
| --- | --- | --- |
| 因子 | nearness ratio 作为与动量正交的第二信号 | 待建 FAC |
| 数据 | 需要 252 日滚动最高价（A 股 ETF 约 1 年交易日） | 待建 DATA |
| 机制 | 锚定效应是行为偏差，与趋势外推是不同维度 | 待建 MECH |
| 模块 | 动量选 Top 候选 + nearness 过滤/加权的组合评分 | 待建 IDEA |

## 局限

哪些地方不能直接迁移到 A 股、ETF、ETF 日频或当前平台：

1. 原文是个股横截面；ETF 是组合，单个 ETF 的"52 周高点"语义是行业/主题层面的锚，行为偏差强度可能弱于个股。
2. A 股 ETF 有涨跌停、主题轮动快，52 周高点可能长期停留在某些周期品/科技 ETF 上，nearness 长期偏低，信号区分度需验证。
3. 原文是多空组合；本项目是 Top1 纯多头，nearness 在多头单边选 Top 时的增量需 formal 验证。
4. **与本项目已证伪边界的关键区分**：5KZW（多周期确认直接替代）和 9QRG（5 日主排序替代）证伪的是"换周期"。nearness 不是换周期，是换信号维度（锚定 vs 趋势外推）。预注册时必须写明这一区别，避免被误归入已证伪网格。推荐做"组合"而非"替代"。

## 下一步

- 新建研究方向 RD（52 周高点锚定信号），parent 指向核心轮动模块 RD-20260605T115651Z-main-CORE。
- 新建预注册实验，baseline = 25 日动量 Top1 hard5，候选 = 组合评分（动量 + nearness 等权或加权）、动量 Top3 ∩ nearness Top3，四段 formal + 随机 nearness 负控（复用 WXMD 随机标签负控方法论）。
