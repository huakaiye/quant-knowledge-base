---
type: 文献卡
lit_id: LIT-20260603T000000Z-mig-2019ASNESSA3D2A
legacy_id: "2019_Asness_质量减垃圾"
migration_status: migrated_unverified
evidence_level: legacy_raw
source_old_path: 'E:\【笔记库】\量化研究库\📚 文献\2019_Asness_质量减垃圾.md'
source_old_relative_path: '📚 文献/2019_Asness_质量减垃圾.md'
owner: mig
created_at: 2026-06-05T12:00:00Z
updated_at: 2026-06-05T12:00:00Z
tags: [旧库迁移, 未复核]
---

# L20260523-008 Quality Minus Junk

## 迁移说明

- 迁移状态：机械迁移，尚未人工复核。
- 原旧库 ID：`2019_Asness_质量减垃圾`
- 来源旧库路径：`E:\【笔记库】\量化研究库\📚 文献\2019_Asness_质量减垃圾.md`
- 新库 ID：`LIT-20260603T000000Z-mig-2019ASNESSA3D2A`
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
literature_id: L-2019-Asness-001
title: Quality Minus Junk
authors: [Clifford S. Asness, Andrea Frazzini, Lasse H. Pedersen]
year: 2019
journal: Review of Accounting Studies
url: https://doi.org/10.1007/s11142-018-9470-2
source_tags:
  - "[[质量类策略]]"
  - "[[低波防御类策略]]"
execution_tags:
  - "[[风控叠加]]"
asset_class: [股票]
applicable_markets: [小市值, 股票轮动]
extracted_modules:
  - "[[质量防御与价值质量组合]]"
status: 待拆解
tags:
  - 研究/文献
  - 策略/质量
~~~
## 旧库原文

~~~markdown
# L20260523-008 Quality Minus Junk

## 基本信息

| 项目 | 内容 |
| --- | --- |
| 论文 | Quality Minus Junk |
| 作者 | Clifford S. Asness, Andrea Frazzini, Lasse H. Pedersen |
| 期刊 | Review of Accounting Studies, 2019 |
| 来源 | https://doi.org/10.1007/s11142-018-9470-2 |

## 核心观点

质量可以从盈利能力、成长、稳健性和派息等维度定义。对策略研发而言，质量因子适合作为高风险策略的防守过滤和权重倾斜。

## 对当前平台的启发

- 小市值策略应增加质量门槛，避免买入低质量壳股或财务恶化票。
- 动量策略可以在市场转弱时提高质量因子的权重。
- 多策略组合中，质量防御可作为风险状态升高后的替代暴露。

## 可拆模块

| 模块 | 类型 | 说明 |
| --- | --- | --- |
| [[质量防御与价值质量组合]] | 因子模块 | 将盈利质量、稳健性和估值结合成防守型股票评分 |

## 风险与限制

- 质量因子依赖基本面公告时点，必须做未来函数审计。
- A 股财务指标可能受行业差异影响，建议行业内标准化。

~~~