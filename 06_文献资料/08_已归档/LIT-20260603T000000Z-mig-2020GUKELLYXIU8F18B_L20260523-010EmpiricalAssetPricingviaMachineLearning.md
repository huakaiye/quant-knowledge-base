---
type: 文献卡
lit_id: LIT-20260603T000000Z-mig-2020GUKELLYXIU8F18B
legacy_id: "2020_Gu_Kelly_Xiu_机器学习资产定价"
migration_status: migrated_unverified
evidence_level: legacy_raw
source_old_path: 'E:\【笔记库】\量化研究库\📚 文献\2020_Gu_Kelly_Xiu_机器学习资产定价.md'
source_old_relative_path: '📚 文献/2020_Gu_Kelly_Xiu_机器学习资产定价.md'
owner: mig
created_at: 2026-06-05T12:00:00Z
updated_at: 2026-06-05T12:00:00Z
tags: [旧库迁移, 未复核]
---

# L20260523-010 Empirical Asset Pricing via Machine Learning

## 迁移说明

- 迁移状态：机械迁移，尚未人工复核。
- 原旧库 ID：`2020_Gu_Kelly_Xiu_机器学习资产定价`
- 来源旧库路径：`E:\【笔记库】\量化研究库\📚 文献\2020_Gu_Kelly_Xiu_机器学习资产定价.md`
- 新库 ID：`LIT-20260603T000000Z-mig-2020GUKELLYXIU8F18B`
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
literature_id: L-2020-Gu-003
title: Empirical Asset Pricing via Machine Learning
authors: [Shihao Gu, Bryan Kelly, Dacheng Xiu]
year: 2020
journal: Review of Financial Studies
url: https://academic.oup.com/rfs/article/33/5/2223/5758276
source_tags:
  - "[[多策略融合类策略]]"
execution_tags:
  - "[[TopN分散]]"
  - "[[风控叠加]]"
asset_class: [股票]
applicable_markets: [股票轮动, 多因子]
extracted_modules:
  - "[[机器学习因子评分与非线性组合]]"
status: 待拆解
tags:
  - 研究/文献
  - 策略/机器学习
~~~
## 旧库原文

~~~markdown
# L20260523-010 Empirical Asset Pricing via Machine Learning

## 基本信息

| 项目 | 内容 |
| --- | --- |
| 论文 | Empirical Asset Pricing via Machine Learning |
| 作者 | Shihao Gu, Bryan Kelly, Dacheng Xiu |
| 期刊 | Review of Financial Studies, 2020 |
| 来源 | https://academic.oup.com/rfs/article/33/5/2223/5758276 |

## 核心观点

论文系统比较机器学习方法在资产定价中的表现，强调非线性和交互项的重要性。对当前研究库而言，机器学习应该先作为因子评分研究工具，而不是直接替代策略逻辑。

## 对当前平台的启发

- 可以用机器学习发现“哪些因子组合在什么状态下有效”。
- ETF 轮动可先做轻量模型，例如树模型解释动量、波动率、相关性、市场状态之间的关系。
- 股票多因子可以用模型输出作为候选排序分数，但执行层仍保持透明规则。

## 可拆模块

| 模块 | 类型 | 说明 |
| --- | --- | --- |
| [[机器学习因子评分与非线性组合]] | 研究模块 | 用机器学习探索因子非线性、交互项和状态依赖 |

## 风险与限制

- 机器学习最容易过拟合，必须先建立滚动样本外和特征时点审计。
- 结果解释要优先记录特征贡献和失效状态，不能只看收益排名。

~~~