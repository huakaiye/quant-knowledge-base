---
type: 文献卡
lit_id: LIT-20260620T052601Z-main-PYTZ
status: todo
owner: main
created_at: 2026-06-20T05:26:01Z
updated_at: 2026-06-20T05:26:01Z
year: 2015
journal: International Economic Review
authors: Peter C. B. Phillips; Yangru Shi; Jun Yu
doi:
url: http://korora.econ.yale.edu/phillips/pubs/art/p1498.pdf
related_rd_ids: [RD-20260620T052601Z-main-3B2X]
related_factor_ids: []
related_data_ids: []
tags: [顶刊, GSADF, PSY, 爆炸性根, 泡沫检测, 递归单位根, 过热, 待迁移实验]
---

# GSADF 爆炸性泡沫 Phillips Shi Yu 2015

## 关联链接

- 相关方向：[[02_研究方向/RD-20260620T052601Z-main-3B2X_双池轮动GSADF爆炸性泡沫检测|双池轮动 GSADF 爆炸性泡沫检测]]
- 祖父方向：[[02_研究方向/RD-20260605T133318Z-main-H6V3_双池轮动score过热拥挤机制模块|双池轮动 score 过热拥挤机制模块]]
- 关联综述（M4 MAX 是单日跳，不是爆炸性过程）：[[06_文献资料/00_待处理/LIT-20260619T104218Z-main-66QH_顶刊K线成交量过热修复因子机制综述|顶刊 K 线成交量过热修复因子机制综述]]
- 关联框架（`recursive_explosive_score` 列为 p_overheat 候选但未实现）：[[07_因子数据灵感/03_机制/MECH-20260619T025934Z-main-DQUM_hard5过热概率与反弹修复状态框架|hard5 过热概率与反弹修复状态框架]]
- 因子灵感：`recursive_explosive_score`（GSADF/BSADF 统计量）、`bubble_duration`（爆炸性持续期）、`bubble_onset`（爆炸起始）
- 数据灵感：日频 ETF 收盘价（平台已有）；R 包 `exuber` 或 Python 移植
- 机制灵感：价格过程爆炸性检测——区分趋势性上涨（平稳，GSADF 不显著）和泡沫性加速（爆炸，GSADF 显著），作为 `p_overheat` 过程层辅助证据
- 模块灵感：hard5 高分事件的 GSADF 爆炸性只读面板

## 文献信息

- 标题：Testing for Multiple Bubbles: Historical Episodes of Exuberance and Collapse in the S&P 500
- 作者：Peter C. B. Phillips、Yangru Shi、Jun Yu
- 年份：2015
- 期刊或来源：International Economic Review，Vol. 56, Issue 4, pp. 1043–1078
- DOI 或 URL：http://korora.econ.yale.edu/phillips/pubs/art/p1498.pdf

## 研究问题

如何在价格序列中事前检测多个"温和爆炸性"泡沫阶段（exuberance and collapse）？递归单位根检验能否区分"平稳趋势上涨"和"爆炸性泡沫加速"？

## 数据

S&P 500 长期价格序列，以及多国股市、房地产、大宗商品资产价格泡沫案例。日频/月频价格序列。

## 方法

GSADF（Generalized Sup Augmented Dickey-Fuller）检验：对价格序列做递归右尾单位根检验，窗口从宽到窄递归扫描，取所有子窗口 ADF 统计量的上确界（sup）。当 GSADF 统计量超过右尾临界值（用仿真生成），判定该时点价格进入"温和爆炸性"状态。PSY 方法可检测序列中多个泡沫阶段，并通过 BSADF（backward SADF）给出逐时点爆炸性分数，支持滚动/实时检测。

## 核心结论

用中文概括，不粘贴长篇原文：

1. GSADF 能事前识别价格序列中的多个爆炸性泡沫阶段，比传统 ADF 和 CUSUM 更灵敏。
2. 爆炸性状态（GSADF 显著）之后通常伴随 collapse（回归平稳或下跌），符合"exuberance and collapse"模式。
3. BSADF 逐时点分数可用于实时/滚动检测，但递归窗口有滞后。
4. 该方法在多国股市、房地产、大宗商品泡沫上复现稳健。

## 可转化灵感

| 类型 | 灵感 | 后续卡片 |
| --- | --- | --- |
| 因子 | `recursive_explosive_score`（BSADF 统计量）、`bubble_duration`（爆炸持续期）、`bubble_onset`（爆炸起始） | 待建 FAC |
| 数据 | 日频 ETF 收盘价（平台已有）；R 包 `exuber` 或 Python 移植 | 待建 DATA |
| 机制 | 价格过程爆炸性检测——区分趋势性上涨（平稳，GSADF 不显著）和泡沫性加速（爆炸，GSADF 显著），作为 `p_overheat` 过程层辅助证据 | [[07_因子数据灵感/03_机制/MECH-20260619T025934Z-main-DQUM_hard5过热概率与反弹修复状态框架]] |
| 模块 | hard5 高分事件的 GSADF 爆炸性只读面板 | [[04_实验记录/EX-20260620T052616Z-main-UEAC_GSADF爆炸性泡沫只读面板预注册]] |

## 局限

哪些地方不能直接迁移到 A 股、ETF、日频或当前平台：

1. 原文是**单资产长序列**（S&P 500 数十年）；本项目 ETF 上市时间短（多数 `< 10` 年），GSADF 递归窗口的可选范围受限，爆炸性检测的统计功效可能不足。
2. GSADF 递归窗口有**滞后**，BSADF 逐时点分数在实时检测时信号滞后于泡沫起始，适合做事后/辅助证据，不适合做实时硬过滤。
3. 原文检测的是**整个价格序列的爆炸性**；本项目要区分的是"高分时点是否处于爆炸性阶段"，需要把 BSADF 逐时点分数对齐到 hard5 事件日，不是直接套用序列级结论。
4. GSADF 和 MAX（M4 单日极端收益）相关但不同：MAX 看单日跳，GSADF 看多日趋势的统计爆炸性。两者必须做正交性消融，确认 GSADF 不是 MAX 的重复。
5. GSADF 和 52 周高点（nearness，已证伪）不同：nearness 看价格位置，GSADF 看价格过程的生成机制。但两者可能相关（创新高时爆炸性也高），需确认 GSADF 不是 nearness 的重复。
6. 实现成本：需要 R 包 `exuber` 或 Python 移植，比 MAX/CS dispersion 的纯 pandas 实现更重，引入工程风险。

## 下一步

- 与本项目 hard5 对比：52 周高点（nearness）已证伪，但 nearness 只看价格位置；GSADF 看价格过程的统计爆炸性，能区分"趋势性上涨"和"泡沫性加速"，是 nearness 没覆盖的过程层维度。
- 新建只读面板 [[04_实验记录/EX-20260620T052616Z-main-UEAC_GSADF爆炸性泡沫只读面板预注册]]：在 hard5 高分事件上检验 GSADF 显著（爆炸性）vs 不显著（平稳趋势）桶的 H5/H10 差异、分段稳定性，并补随机同 GSADF 桶、错位一日、MAX 分层（正交性）、52 周高点分层（确认不是 nearness 重复）四类负控。
- **不直接写成过滤规则**；先只读，过门槛后才考虑作为 MECH-DQUM 框架 `p_overheat` 的过程层辅助字段。注意 GSADF 滞后性，不适合实时硬过滤，只做辅助证据。
