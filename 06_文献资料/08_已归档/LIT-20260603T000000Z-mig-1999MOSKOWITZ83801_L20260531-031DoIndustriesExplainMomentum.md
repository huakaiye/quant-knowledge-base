---
type: 文献卡
lit_id: LIT-20260603T000000Z-mig-1999MOSKOWITZ83801
legacy_id: "1999_Moskowitz_行业动量"
migration_status: migrated_unverified
evidence_level: legacy_raw
source_old_path: 'E:\【笔记库】\量化研究库\📚 文献\1999_Moskowitz_行业动量.md'
source_old_relative_path: '📚 文献/1999_Moskowitz_行业动量.md'
owner: mig
created_at: 2026-06-05T12:00:00Z
updated_at: 2026-06-05T12:00:00Z
tags: [旧库迁移, 未复核]
---

# L20260531-031 Do Industries Explain Momentum?

## 迁移说明

- 迁移状态：机械迁移，尚未人工复核。
- 原旧库 ID：`1999_Moskowitz_行业动量`
- 来源旧库路径：`E:\【笔记库】\量化研究库\📚 文献\1999_Moskowitz_行业动量.md`
- 新库 ID：`LIT-20260603T000000Z-mig-1999MOSKOWITZ83801`
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
literature_id: L-1999-Moskowitz-001
title: Do Industries Explain Momentum?
authors:
  - Tobias J. Moskowitz
  - Mark Grinblatt
year: 1999
journal: Journal of Finance
peer_reviewed: true
journal_tier: T1
url: https://www.aqr.com/Insights/Research/Journal-Article/Do-Industries-Explain-Momentum
source_tags:
  - "[[横截面动量类策略]]"
execution_tags:
  - "[[ETF轮动]]"
asset_class:
  - 股票
  - 行业组合
applicable_markets:
  - 美股
  - ETF主题池
extracted_modules:
  - ETF簇动量
status: 收集
tags:
  - 研究/文献
  - 状态/收集
~~~
## 旧库原文

~~~markdown
# L20260531-031 Do Industries Explain Momentum?

## 基本信息

| 项目 | 内容 |
| --- | --- |
| 作者 | Tobias J. Moskowitz、Mark Grinblatt |
| 年份 | 1999 |
| 期刊/来源 | Journal of Finance |
| 链接 | https://www.aqr.com/Insights/Research/Journal-Article/Do-Industries-Explain-Momentum |
| 资产类别 | 股票行业组合 |
| 原始市场 | 美股 |

## 核心观点

论文认为行业层面的动量能解释相当一部分个股动量收益。对当前 ETF 双池来说，直接启发不是买行业股票，而是不要只盯单只 Top1 ETF，应当观察资产类别或主题簇是否整体存在动量延续。

## 收益来源

关联收益来源：[[横截面动量类策略]]

ETF 双池的候选池横跨商品、海外、港股、A股宽基、风格和债券。若某一簇内部同时走强，Top1 的信号更可能代表主线；若 Top1 只是孤立跳涨，则更可能是噪音或过热。

## 可拆模块

| 模块 | 类型 | 说明 |
| --- | --- | --- |
| ETF簇动量 | 因子模块 | 按资产类别或主题对 ETF 池分组，计算簇收益、簇广度、簇内离散度 |
| 主线确认 | 风控模块 | Top1 所在簇没有广度支持时，降低追涨或换仓强度 |

## 对当前平台的启发

适合补充 R010-D 的 `high_vol_low_breadth` 和 `overheated_momentum`：当 Top1 很强但其所在簇缺少跟随，可能更接近过热；当同簇多个 ETF 同时强，才更像可延续主线。

## 数据与实现要求

- 所需数据：ETF 日线收盘价、成交额、ETF 分类表。
- 频率：日频。
- 是否可用当前数据实现：价格可实现，分类表需要在配置中维护。
- 潜在未来函数风险：ETF 分类必须使用固定配置或上市时可见分类，不能按未来表现重新聚类。

## 风险与限制

行业动量来自股票行业组合，ETF 双池中的资产类别更杂，不能直接套用原论文周期。首轮只作为日志字段和分桶审计，不直接改变交易。

## 下一步

是否拆成模块想法：是
对应模块想法：ETF簇动量与主线确认


~~~