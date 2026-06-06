---
type: 文献卡
lit_id: LIT-20260605T133518Z-main-ZU9R
status: todo
owner: main
created_at: 2026-06-05T13:35:18Z
updated_at: 2026-06-05T13:36:00Z
year: 2007
journal: Journal of Financial Economics
authors: Harrison Hong; Walter Torous; Rossen Valkanov
doi: 10.1016/j.jfineco.2005.09.010
url: https://www.columbia.edu/~hh2679/industry-12-05-05.pdf
related_rd_ids: [RD-20260605T131301Z-main-KC7N]
related_factor_ids: []
related_data_ids: []
tags: [行业领先, 信息扩散, 顶刊启发, 双池轮动]
---

# Do Industries Lead Stock Markets

## 关联链接

- 相关方向：[[02_研究方向/RD-20260605T131301Z-main-KC7N_双池轮动主题簇主线确认模块|双池轮动主题簇主线确认模块]]
- 因子灵感：
- 数据灵感：
- 机制灵感：
- 模块灵感：

## 文献信息

- 标题：Do Industries Lead Stock Markets?
- 作者：Harrison Hong; Walter Torous; Rossen Valkanov
- 年份：2007
- 期刊或来源：Journal of Financial Economics
- DOI 或 URL：`10.1016/j.jfineco.2005.09.010`；https://www.columbia.edu/~hh2679/industry-12-05-05.pdf

## 研究问题

行业组合收益是否能领先并预测整体市场，以及这种预测是否来自信息在不同资产和投资者之间逐步扩散。

## 数据

论文使用美国行业组合和市场变量，并扩展到多个主要海外股票市场。样本、市场和频率与本库 ETF 双池不同，本卡只保留“行业信息扩散”的机制启发。

## 方法

作者检验行业组合滞后收益对市场收益和经济活动指标的预测力，并用跨国家和跨行业结果检查稳健性。

## 核心结论

部分行业收益能提前反映与基本面相关的信息，整体市场可能滞后吸收行业层面的信息。对双池轮动的启发是：ETF 主题簇共同走强可能不仅是“拥挤”，也可能是市场正在逐步识别一条主线。

## 可转化灵感

| 类型 | 灵感 | 后续卡片 |
| --- | --- | --- |
| 机制 | 主题簇共同走强应先作为“信息扩散/主线确认”标签观察，而不是直接用单只 ETF 高分追涨 | 主题簇主线确认Formal V2 Shadow预注册 |
| 模块 | 把 Top10 同主题数量、主题集中度和坏桶主题写入 R010-B action 日志，便于后续事件复盘 | 双池轮动主题簇主线确认模块 |

## 局限

论文讨论的是行业组合与市场指数的领先关系，不是 ETF 轮动交易规则。A 股行业 ETF 有命名噪音、成分变化、涨跌停、T+1 和容量约束，必须通过本平台 formal V2 路径验证。

## 下一步

- 先做 shadow 日志和错位主题负控；如果负控仍有效，优先怀疑市场阶段或分类噪音。
