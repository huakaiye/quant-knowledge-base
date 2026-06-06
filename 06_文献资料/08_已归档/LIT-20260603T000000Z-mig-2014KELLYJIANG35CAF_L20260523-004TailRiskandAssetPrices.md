---
type: 文献卡
lit_id: LIT-20260603T000000Z-mig-2014KELLYJIANG35CAF
legacy_id: "2014_Kelly_Jiang_尾部风险资产定价"
migration_status: migrated_unverified
evidence_level: legacy_raw
source_old_path: 'E:\【笔记库】\量化研究库\📚 文献\2014_Kelly_Jiang_尾部风险资产定价.md'
source_old_relative_path: '📚 文献/2014_Kelly_Jiang_尾部风险资产定价.md'
owner: mig
created_at: 2026-06-05T12:00:00Z
updated_at: 2026-06-05T12:00:00Z
tags: [旧库迁移, 未复核]
---

# L20260523-004 Tail Risk and Asset Prices

## 迁移说明

- 迁移状态：机械迁移，尚未人工复核。
- 原旧库 ID：`2014_Kelly_Jiang_尾部风险资产定价`
- 来源旧库路径：`E:\【笔记库】\量化研究库\📚 文献\2014_Kelly_Jiang_尾部风险资产定价.md`
- 新库 ID：`LIT-20260603T000000Z-mig-2014KELLYJIANG35CAF`
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
literature_id: L-2014-Kelly-003
title: Tail Risk and Asset Prices
authors: [Bryan Kelly, Hao Jiang]
year: 2014
journal: Review of Financial Studies
url: https://academic.oup.com/rfs/article/27/10/2841/1607080
source_tags:
  - "[[低波防御类策略]]"
  - "[[多策略融合类策略]]"
execution_tags:
  - "[[风控叠加]]"
asset_class: [股票]
applicable_markets: [股票轮动, ETF]
extracted_modules:
  - "[[尾部风险与波动风险溢价预警]]"
status: 待拆解
tags:
  - 研究/文献
  - 策略/尾部风险
~~~
## 旧库原文

~~~markdown
# L20260523-004 Tail Risk and Asset Prices

## 基本信息

| 项目 | 内容 |
| --- | --- |
| 论文 | Tail Risk and Asset Prices |
| 作者 | Bryan Kelly, Hao Jiang |
| 期刊 | Review of Financial Studies, 2014 |
| 来源 | https://academic.oup.com/rfs/article/27/10/2841/1607080 |

## 核心观点

论文从横截面极端下跌信息中提取尾部风险。对策略研发而言，尾部风险不是只在指数大跌后才出现，它可能先从个股或行业截面扩散中体现。

## 对当前平台的启发

- 市场状态识别可以加入“极端下跌股票占比”“左尾分位数收益”“行业同步下跌比例”。
- ETF 轮动在尾部风险上升时可以降低进攻 ETF 权重，切到货币、债券或低波资产。
- 小市值策略应特别关注尾部风险，因为流动性和跌停会放大退出成本。

## 可拆模块

| 模块 | 类型 | 说明 |
| --- | --- | --- |
| [[尾部风险与波动风险溢价预警]] | 风控模块 | 从截面极端收益中构建尾部风险代理变量 |

## 风险与限制

- 不能用未来完整月度截面估计当前日尾部风险。
- A 股涨跌停会截断收益分布，尾部指标要同时记录跌停数量和无法成交风险。

~~~