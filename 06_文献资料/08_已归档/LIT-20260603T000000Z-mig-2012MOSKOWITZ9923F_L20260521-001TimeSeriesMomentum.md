---
type: 文献卡
lit_id: LIT-20260603T000000Z-mig-2012MOSKOWITZ9923F
legacy_id: "2012_Moskowitz_时间序列动量"
migration_status: migrated_unverified
evidence_level: legacy_raw
source_old_path: 'E:\【笔记库】\量化研究库\📚 文献\2012_Moskowitz_时间序列动量.md'
source_old_relative_path: '📚 文献/2012_Moskowitz_时间序列动量.md'
owner: mig
created_at: 2026-06-05T12:00:00Z
updated_at: 2026-06-05T12:00:00Z
tags: [旧库迁移, 未复核]
---

# L20260521-001 Time Series Momentum

## 迁移说明

- 迁移状态：机械迁移，尚未人工复核。
- 原旧库 ID：`2012_Moskowitz_时间序列动量`
- 来源旧库路径：`E:\【笔记库】\量化研究库\📚 文献\2012_Moskowitz_时间序列动量.md`
- 新库 ID：`LIT-20260603T000000Z-mig-2012MOSKOWITZ9923F`
- 证据等级：legacy_raw
- 结论边界：本页保留旧库内容，不代表新库已经采纳旧结论。

## 关联链接

- 迁移总卡：[[11_迁移暂存/MIG-20260605T120000Z-mig-BATCH_旧库批量迁移总卡|旧库批量迁移总卡]]
- 关联方向：待复核
- 关联策略：待复核
- 迁移规范：[[08_方法论/研究库迁移规范|研究库迁移规范]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]

## 复核清单

- [ ] 旧路径真实存在。
- [ ] 平台配置路径真实存在。
- [ ] 平台结果路径真实存在。
- [ ] 实验前假设和证伪条件满足新库标准。
- [ ] 未来函数和过拟合审计满足新库标准。
- [ ] 已同步对应台账和驾驶舱。

## 旧库 Frontmatter

~~~yaml
type: 文献
literature_id: L-2012-Moskowitz-001
title: Time Series Momentum
authors: [Tobias J. Moskowitz, Yao Hua Ooi, Lasse H. Pedersen]
year: 2012
journal: Journal of Financial Economics
url: https://doi.org/10.1016/j.jfineco.2011.11.003
source_tags:
  - "[[趋势跟踪类策略]]"
execution_tags:
  - "[[ETF轮动]]"
  - "[[日频调仓]]"
asset_class: [股指, 债券, 商品, 外汇]
applicable_markets: [ETF, 指数, 期货]
extracted_modules:
  - "[[ETF趋势确认与防守切换]]"
status: 待拆解
tags:
  - 研究/文献
  - 策略/趋势跟踪
~~~
## 旧库原文

~~~markdown
# L20260521-001 Time Series Momentum

## 基本信息

| 项目 | 内容 |
| --- | --- |
| 论文 | Time Series Momentum |
| 作者 | Tobias J. Moskowitz, Yao Hua Ooi, Lasse H. Pedersen |
| 期刊 | Journal of Financial Economics, 2012 |
| DOI | `10.1016/j.jfineco.2011.11.003` |
| 来源 | https://doi.org/10.1016/j.jfineco.2011.11.003 |

## 核心观点

论文研究多类流动期货资产，核心思想是资产自身过去收益对未来收益有预测力。它和横截面动量不同，关注“这个资产自己是否处在趋势中”，适合改造 ETF 轮动和指数轮动。

## 对当前平台的启发

- ETF 双池当前主要做相对强弱排序，可增加时间序列趋势确认。
- R2 ETF 动量轮动可增加“绝对趋势不过关则转防守”的机制。
- 对 A 股 ETF，应重点测试短中期趋势窗口，而不是照搬论文月份级参数。

## 可拆模块

| 模块 | 类型 | 说明 |
| --- | --- | --- |
| [[ETF趋势确认与防守切换]] | 风控模块 | 入选 ETF 需要同时满足相对强和自身趋势为正 |

## 风险与限制

- ETF 样本数量少，容易出现窗口过拟合。
- A 股 ETF 存在行业主题化强、上市时间短的问题。
- 趋势信号和原动量打分高度相关，实验必须做消融，避免重复计分。

~~~