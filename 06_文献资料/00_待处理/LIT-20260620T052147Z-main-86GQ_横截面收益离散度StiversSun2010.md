---
type: 文献卡
lit_id: LIT-20260620T052147Z-main-86GQ
status: todo
owner: main
created_at: 2026-06-20T05:21:47Z
updated_at: 2026-06-20T05:21:47Z
year: 2010
journal: Journal of Financial and Quantitative Analysis
authors: Chris M. Stivers; Licheng Sun
doi:
url: https://www.cambridge.org/core/journals/journal-of-financial-and-quantitative-analysis/article/crosssectional-return-dispersion-and-time-variation-in-value-and-momentum-premiums/77E2E3B09BDA5992C29BBCE2CEDC08FE
related_rd_ids: [RD-20260620T052147Z-main-8AB7]
related_factor_ids: []
related_data_ids: []
tags: [顶刊, 横截面离散度, CS-dispersion, 市场状态, 动量溢价, 组合层开关, 待迁移实验]
---

# 横截面收益离散度 Stivers Sun 2010

## 关联链接

- 相关方向：[[02_研究方向/RD-20260620T052147Z-main-8AB7_双池轮动横截面离散度组合层保守开关|双池轮动横截面离散度组合层保守开关]]
- 祖父方向：[[02_研究方向/RD-20260605T133318Z-main-H6V3_双池轮动score过热拥挤机制模块|双池轮动 score 过热拥挤机制模块]]
- 关联综述（M10 市场状态条件化是趋势状态，不是横截面离散度）：[[06_文献资料/00_待处理/LIT-20260619T104218Z-main-66QH_顶刊K线成交量过热修复因子机制综述|顶刊 K 线成交量过热修复因子机制综述]]
- 因子灵感：`cs_dispersion_20`（过去 20 日全池日收益横截面标准差均值）、`cs_dispersion_change`（离散度相对自身 60 日历史的抬升）
- 数据灵感：日频 ETF 池收盘价（平台已有）
- 机制灵感：组合层保守开关——CS dispersion 低 + score 高 = broad blowoff 保守；CS dispersion 高 + score 高 = 分化健康允许追高
- 模块灵感：hard5 高分事件的 CS dispersion 组合层只读面板

## 文献信息

- 标题：Cross-Sectional Return Dispersion and Time Variation in Value and Momentum Premiums
- 作者：Chris M. Stivers、Licheng Sun
- 年份：2010
- 期刊或来源：Journal of Financial and Quantitative Analysis（JFQA），Vol. 45, Issue 4, pp. 977–1009
- DOI 或 URL：https://www.cambridge.org/core/journals/journal-of-financial-and-quantitative-analysis/article/crosssectional-return-dispersion-and-time-variation-in-value-and-momentum-premiums/77E2E3B09BDA5992C29BBCE2CEDC08FE

## 研究问题

横截面收益离散度（个股收益的横截面标准差）是否能预测动量和价值溢价的时变性？它和已知的"市场状态"（Cooper 2004 的市场趋势状态）是同一个东西吗？

## 数据

美国股票市场，月度数据，样本期 1963–2005。横截面离散度用个股日收益的横截面标准差月度均值度量。

## 方法

构造 `CS dispersion = 个股日收益横截面标准差的月度均值`。按离散度高/低分组，检验后续动量组合和价值组合的收益差异，并控制市场状态（UP/DOWN）、市场波动率、成交量等变量，确认离散度是独立信号。

## 核心结论

用中文概括，不粘贴长篇原文：

1. 横截面收益离散度高时，动量溢价显著更高；离散度低时，动量溢价失效甚至为负。
2. 这个关系在控制市场状态（Cooper 2004 UP/DOWN）、市场波动率、成交量后仍稳健，说明**离散度是独立于市场趋势状态的正交维度**。
3. 机制解释：离散度高 = 个股特异性信息活跃、分化上涨（健康趋势）；离散度低 = 普涨普跌、特异性信息沉寂（易出现 broad blowoff 或普反修复）。
4. 价值溢价的方向相反或较弱，说明离散度对动量的预测力更专门。

## 可转化灵感

| 类型 | 灵感 | 后续卡片 |
| --- | --- | --- |
| 因子 | `cs_dispersion_20`、`cs_dispersion_change`（相对 60 日历史抬升） | 待建 FAC |
| 数据 | 日频 ETF 池收盘价（平台已有） | 待建 DATA |
| 机制 | 组合层保守开关：CS dispersion 低 + score 高 = broad blowoff 保守；CS dispersion 高 + score 高 = 分化健康允许追高 | [[07_因子数据灵感/03_机制/MECH-20260619T025934Z-main-DQUM_hard5过热概率与反弹修复状态框架]] |
| 模块 | hard5 高分事件的 CS dispersion 组合层只读面板 | [[04_实验记录/EX-20260620T052156Z-main-BL8Y_横截面离散度组合层保守开关只读面板预注册]] |

## 局限

哪些地方不能直接迁移到 A 股、ETF、日频或当前平台：

1. 原文是**美股月频个股**横截面，离散度用几千只个股算；本项目 ETF 池只有几十只，横截面标准差的统计噪声更大，信号可能稀薄，需用行业 ETF 间离散度或相对自身历史的离散度变化来降噪。
2. 原文预测的是**动量组合多空溢价**；本项目是 Top1 纯多头轮动，CS dispersion 对多头单边排序的增量需要单独验证。
3. A 股 ETF 有**行业/主题结构性同步**（同行业 ETF 天然同步），绝对离散度被主题结构压低，必须用**相对自身历史的离散度变化**而非绝对水平。
4. 原文离散度和市场波动率高度相关；ETF 层面需确认 CS dispersion 不是市场波动率的重复代理（已被 G4NN 反证的宽基 vol target 同族风险）。
5. 与 66QH 的 M10（市场状态条件化 ret20/breadth）和 M11（同类扩散比例）相关但正交：M10 测趋势方向，M11 测扩散比例，CS dispersion 测横截面分化程度。三者必须做正交性消融，确认 CS dispersion 不是 M10/M11 的重复。

## 下一步

- 与本项目 hard5 对比：A20/A21 用市场状态（MA20 广度 + slope10）条件化高分放行失败，核心反证是 2020-2021 普涨冲顶时市场趋势强但后续差。CS dispersion 正好在普涨冲顶时低（普涨 = 低离散），能补 M10 缺的正交维度——这是它的核心增量。
- 新建只读面板 [[04_实验记录/EX-20260620T052156Z-main-BL8Y_横截面离散度组合层保守开关只读面板预注册]]：在 hard5 高分事件上检验 CS dispersion 高/低桶的 H5/H10 差异、分段稳定性，并补随机同 dispersion 桶、错位一日、M10 市场状态分层（确认正交性）三类负控。
- **不直接写成过滤规则**；先只读，过门槛后才考虑作为 MECH-DQUM 框架 `p_crash` 的组合层字段或独立组合层开关。
