---
type: 文献卡
lit_id: LIT-20260603T000000Z-mig-2017MOREIRAMUIR01619
legacy_id: "2017_Moreira_Muir_波动率管理"
migration_status: migrated_unverified
evidence_level: legacy_raw
source_old_path: 'E:\【笔记库】\量化研究库\📚 文献\2017_Moreira_Muir_波动率管理.md'
source_old_relative_path: '📚 文献/2017_Moreira_Muir_波动率管理.md'
owner: mig
created_at: 2026-06-05T12:00:00Z
updated_at: 2026-06-05T12:00:00Z
tags: [旧库迁移, 未复核]
---

# L20260521-005 Volatility-Managed Portfolios

## 迁移说明

- 迁移状态：机械迁移，尚未人工复核。
- 原旧库 ID：`2017_Moreira_Muir_波动率管理`
- 来源旧库路径：`E:\【笔记库】\量化研究库\📚 文献\2017_Moreira_Muir_波动率管理.md`
- 新库 ID：`LIT-20260603T000000Z-mig-2017MOREIRAMUIR01619`
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
literature_id: L-2017-Moreira-001
title: Volatility-Managed Portfolios
authors: [Alan Moreira, Tyler Muir]
year: 2017
journal: Journal of Finance
url: https://doi.org/10.1111/jofi.12513
source_tags:
  - "[[低波防御类策略]]"
execution_tags:
  - "[[风控叠加]]"
asset_class: [股票因子, 外汇, 多资产]
applicable_markets: [ETF, 股票轮动]
extracted_modules:
  - "[[波动率缩放仓位]]"
status: 待拆解
tags:
  - 研究/文献
  - 策略/低波防御
~~~
## 旧库原文

~~~markdown
# L20260521-005 Volatility-Managed Portfolios

## 基本信息

| 项目 | 内容 |
| --- | --- |
| 论文 | Volatility-Managed Portfolios |
| 作者 | Alan Moreira, Tyler Muir |
| 期刊 | Journal of Finance, 2017 |
| DOI | `10.1111/jofi.12513` |
| 来源 | https://doi.org/10.1111/jofi.12513 |

## 核心观点

论文研究根据已实现波动率调整组合风险暴露。对策略研发而言，它提供了一个简单而可实现的思想：不是在高波动时预测涨跌，而是在高波动时减少风险预算。

## 对当前平台的启发

- ETF 双池可以在市场或组合波动率升高时降低总仓位。
- 小市值策略可用个股或组合波动率过滤极端高风险样本。
- 实验时必须和未管理波动率版本直接比较，避免只看回归 alpha。

## 可拆模块

| 模块 | 类型 | 说明 |
| --- | --- | --- |
| [[波动率缩放仓位]] | 组合模块 | 根据已实现波动率调整总仓位或单标的权重 |

## 风险与限制

- 后续研究对实盘可实施版本的效果有争议，因此必须做样本外和滚动验证。
- A 股涨跌停和流动性会影响波动率估计。

~~~