---
type: 文献卡
lit_id: LIT-20260620T022539Z-main-36A6
status: todo
owner: main
created_at: 2026-06-20T02:25:39Z
updated_at: 2026-06-20T02:25:39Z
year: 2011
journal: Journal of Financial Economics
authors: Turan G. Bali; Nusret Cakici; Robert F. Whitelaw
doi:
url: https://www.sciencedirect.com/science/article/abs/pii/S0304405X1000190X
related_rd_ids: [RD-20260620T022601Z-main-GHZL]
related_factor_ids: []
related_data_ids: []
tags: [顶刊, MAX效应, 彩票偏好, 横截面异象, 过热, 单日极端收益, 待迁移实验]
---

# MAX 彩票式过热 Bali Cakici Whitelaw 2011

## 关联链接

- 相关方向：[[02_研究方向/RD-20260620T022601Z-main-GHZL_双池轮动MAX彩票式过热信号|双池轮动 MAX 彩票式过热信号]]
- 关联综述（已把 MAX 列为 M4 极端单日收益彩票）：[[06_文献资料/00_待处理/LIT-20260619T104218Z-main-66QH_顶刊K线成交量过热修复因子机制综述|顶刊 K 线成交量过热修复因子机制综述]]
- 因子灵感：`max_daily_return_20`（过去 20 日最大单日涨幅）、`jump_ratio_20`（累计涨幅中最大几日贡献比例）
- 数据灵感：日频 OHLCV（平台已有）
- 机制灵感：彩票型过热（单日跳涨）vs 连续信息型上涨，对应 hard5 框架 `p_overheat` 的正交维度
- 模块灵感：hard5 高分标的的 MAX 分层只读面板，作为过热正交改善维度

## 文献信息

- 标题：Stocks as Lotteries: The MAX Effect and the Cross-Section of Expected Returns
- 作者：Turan G. Bali、Nusret Cakici、Robert F. Whitelaw
- 年份：2011
- 期刊或来源：Journal of Financial Economics，Vol. 99, Issue 2, pp. 427–446
- DOI 或 URL：https://www.sciencedirect.com/science/article/abs/pii/S0304405X1000190X
- 全文 PDF（NYU Stern）：https://pages.stern.nyu.edu/~rwhitela/papers/max%20jfe11.pdf

## 研究问题

为什么“近期单日最大涨幅极高”的股票（彩票型 payoff）后续系统性 underperform？这是投资者偏好彩票型收益导致的定价异象吗？它是否独立于动量、反转、流动性等已知因子？

## 数据

美国股票市场，月度横截面，样本期跨越数十年。后续在中国（Cogent 2023）、斯里兰卡（Emerald）、多资产 ETF（QuantPedia）等市场复现。

## 方法

构造 `MAX(月) = 过去一个月内最大的每日收益`（通常取最大 1 日或最大 5 日平均）。按 MAX 十分位分组，检验后续月度收益，并控制市场、规模、价值、动量、短期反转、流动性等因子。核心是把“彩票型跳涨”从收益中分离出来。

## 核心结论

用中文概括，不粘贴长篇原文：

1. 最低 vs 最高 MAX 十分位，月度收益差超过 1%（raw 和 risk-adjusted 都成立）。
2. 高 MAX 标的后续 underperform，符合投资者彩票偏好导致系统性高估的解释。
3. 控制动量、反转、流动性、短期反转后仍稳健。
4. 后续争议：Gorman et al. 2021 提出可能是过度反应而非彩票偏好；但异象本身在多市场稳健。

## 可转化灵感

| 类型 | 灵感 | 后续卡片 |
| --- | --- | --- |
| 因子 | `max_daily_return_20`、`jump_ratio_20`（最大几日贡献占比）、涨停板数 | 待建 FAC |
| 数据 | 日频 OHLCV（平台已有）；涨停状态作为 A 股制度交互特征 | 待建 DATA |
| 机制 | 彩票型过热（单日跳涨）vs 连续信息型上涨的区分，是 hard5 框架 `p_overheat` 的正交维度 | [[07_因子数据灵感/03_机制/MECH-20260619T025934Z-main-DQUM_hard5过热概率与反弹修复状态框架]] |
| 模块 | hard5 高分标的的 MAX 分层只读面板 | [[04_实验记录/EX-20260620T022611Z-main-FZM4_MAX彩票式过热只读面板预注册]] |

## 局限

哪些地方不能直接迁移到 A 股、ETF、日频或当前平台：

1. 原文是**美股月频个股**横截面；本项目是**日频 ETF**动量轮动，窗口和累计规则需要重新适配，不能直接套用月度参数。
2. **A 股有涨停制度**（主板 10%、科创板/跨境 ETF 20%），单日最大涨幅被机械封顶，会扭曲 MAX。必须区分“涨停封顶的 MAX”和“自然跳涨的 MAX”，并把涨停板数作为独立特征（Cogent 2023 中国 MAX 研究特别强调这一点）。
3. 原文是**横截面多空**；本项目是 Top1 纯多头持有，MAX 在多头单边排序上的增量需要单独验证，不能假设多空结论直接成立。
4. **ETF 已分散特质风险**，MAX 异象可能弱于个股横截面；但跨境、商品、主题 ETF 仍保留单日跳涨特性，需用实验回答信号剩多少。
5. ETF 成交量/换手率对 MAX 的交互作用在 ETF 层面尚未验证（`turnover_ratio` 对 ETF 当前覆盖为 0）。

## 下一步

- 与本项目 hard5 对比：score `>5` 是混合代理，MAX 是正交的“彩票型过热”维度，是真正的**新信号维度**，不是换参数。
- 新建只读面板 [[04_实验记录/EX-20260620T022611Z-main-FZM4_MAX彩票式过热只读面板预注册]]：在 212 个 hard5 高分事件上检验 MAX 分布、高/低 MAX 桶的 H5/H10 差异、下尾和分段稳定性，并补随机同 MAX 桶、错位一日、同主题随机、涨停板分层四类负控。
- **不直接写成过滤规则**；先只读，过门槛后才考虑作为 MECH-DQUM 框架 `p_overheat` 的独立字段进入 formal。
