---
type: 文献卡
lit_id: LIT-20260603T000000Z-mig-2009DEMIGUEL1N74F1B
legacy_id: "2009_DeMiguel_1N组合基准"
migration_status: migrated_unverified
evidence_level: legacy_raw
source_old_path: 'E:\【笔记库】\量化研究库\📚 文献\2009_DeMiguel_1N组合基准.md'
source_old_relative_path: '📚 文献/2009_DeMiguel_1N组合基准.md'
owner: mig
created_at: 2026-06-05T12:00:00Z
updated_at: 2026-06-05T12:00:00Z
tags: [旧库迁移, 未复核]
---

# L20260521-009 Optimal Versus Naive Diversification

## 迁移说明

- 迁移状态：机械迁移，尚未人工复核。
- 原旧库 ID：`2009_DeMiguel_1N组合基准`
- 来源旧库路径：`E:\【笔记库】\量化研究库\📚 文献\2009_DeMiguel_1N组合基准.md`
- 新库 ID：`LIT-20260603T000000Z-mig-2009DEMIGUEL1N74F1B`
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
literature_id: L-2009-DeMiguel-004
title: "Optimal Versus Naive Diversification: How Inefficient is the 1/N Portfolio Strategy?"
authors: [Victor DeMiguel, Lorenzo Garlappi, Raman Uppal]
year: 2009
journal: Review of Financial Studies
url: https://doi.org/10.1093/rfs/hhm075
source_tags:
  - "[[多策略融合类策略]]"
execution_tags:
  - "[[TopN分散]]"
asset_class: [股票, 多资产]
applicable_markets: [ETF, 股票轮动]
extracted_modules:
  - "[[1N与TopN权重基准]]"
status: 待拆解
tags:
  - 研究/文献
  - 执行/TopN分散
~~~
## 旧库原文

~~~markdown
# L20260521-009 Optimal Versus Naive Diversification

## 基本信息

| 项目 | 内容 |
| --- | --- |
| 论文 | Optimal Versus Naive Diversification |
| 作者 | Victor DeMiguel, Lorenzo Garlappi, Raman Uppal |
| 期刊 | Review of Financial Studies, 2009 |
| DOI | `10.1093/rfs/hhm075` |
| 来源 | https://doi.org/10.1093/rfs/hhm075 |

## 核心观点

论文比较复杂优化组合和简单 1/N 分散，提示在估计误差很大时，简单分散可能是强基准。对当前平台而言，它给 TopN 策略提供了一个纪律：任何复杂权重方案都必须先战胜等权基准。

## 对当前平台的启发

- ETF 双池 TopN 版本应把 1/N 等权作为默认基准。
- 如果引入波动率缩放、风险平价或得分加权，必须和等权版本对照。
- 多策略融合不要直接上复杂优化，先建立简单、稳健、可解释的组合权重基准。

## 可拆模块

| 模块 | 类型 | 说明 |
| --- | --- | --- |
| [[1N与TopN权重基准]] | 组合模块 | 用等权 TopN 作为所有复杂权重方案的对照组 |

## 风险与限制

- 等权不是收益最大化方法，只是强基准。
- 在标的波动差异极大时，等权可能隐含不均衡风险暴露。

~~~