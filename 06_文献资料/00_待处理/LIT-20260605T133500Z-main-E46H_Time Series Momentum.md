---
type: 文献卡
lit_id: LIT-20260605T133500Z-main-E46H
status: todo
owner: main
created_at: 2026-06-05T13:35:00Z
updated_at: 2026-06-05T13:36:00Z
year: 2012
journal: Journal of Financial Economics
authors: Tobias J. Moskowitz; Yao Hua Ooi; Lasse Heje Pedersen
doi: 10.1016/j.jfineco.2011.11.003
url: https://pages.stern.nyu.edu/~lpederse/papers/TimeSeriesMomentum.pdf
related_rd_ids: [RD-20260605T131301Z-main-KC7N]
related_factor_ids: []
related_data_ids: []
tags: [时间序列动量, 趋势跟随, 顶刊启发, 双池轮动]
---

# Time Series Momentum

## 关联链接

- 相关方向：[[02_研究方向/RD-20260605T131301Z-main-KC7N_双池轮动主题簇主线确认模块|双池轮动主题簇主线确认模块]]
- 因子灵感：
- 数据灵感：
- 机制灵感：
- 模块灵感：

## 文献信息

- 标题：Time Series Momentum
- 作者：Tobias J. Moskowitz; Yao Hua Ooi; Lasse Heje Pedersen
- 年份：2012
- 期刊或来源：Journal of Financial Economics
- DOI 或 URL：`10.1016/j.jfineco.2011.11.003`；https://pages.stern.nyu.edu/~lpederse/papers/TimeSeriesMomentum.pdf

## 研究问题

资产自身过去收益是否能预测未来收益？这种时间序列动量是否跨资产类别存在，以及它和传统横截面动量有什么关系？

## 数据

论文研究 58 个流动期货或远期合约，覆盖股票指数、货币、商品和债券等资产类别，样本长度超过 25 年。本文献卡只提取机制灵感，不直接迁移参数。

## 方法

核心做法是用资产自身过去收益构建趋势信号，并比较不同资产、不同样本和不同持有期下的可预测性；还分析了投机者和套保者仓位与趋势收益的关系。

## 核心结论

时间序列动量在多资产中普遍存在，趋势延续通常集中在中短期窗口，长期可能发生反转。对双池轮动的启发是：主线确认不应只看横截面排名，还要检查候选主题自身是否处在持续趋势中；但论文对象是国际期货，不等于 A 股 ETF。

## 可转化灵感

| 类型 | 灵感 | 后续卡片 |
| --- | --- | --- |
| 因子 | 对 Top1 所属主题增加“自身趋势是否延续”的 shadow 标签，而不是只看单日横截面得分 | 主题簇主线确认Formal V2 Shadow预注册 |
| 机制 | 趋势延续和长期反转可以同时存在，因此强主题簇不能自动等于加仓；需要金融坏桶、右尾集中和成本扰动检查 | 双池轮动主题簇主线确认模块 |
| 模块 | 先做 `observe_only` shadow 日志，再决定是否进入正式交易化消融 | 主题簇主线确认Formal V2 Shadow预注册 |

## 局限

不能直接把期货多资产趋势参数迁移到 A 股 ETF。双池平台有 ETF 成分、交易成本、T+1、午后信号和 hard cap 等约束；本卡只能支持“趋势需要事前确认”的研究假设。

## 下一步

- 在平台策略中增加默认关闭的主题簇 shadow 日志，记录 `6p_same` 强主线和金融坏桶，不改变目标和订单。
