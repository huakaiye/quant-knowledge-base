---
type: 文献卡
lit_id: LIT-20260603T000000Z-mig-2015FAMAFRENCHEB2D5
legacy_id: "2015_Fama_French_五因子模型"
migration_status: migrated_unverified
evidence_level: legacy_raw
source_old_path: 'E:\【笔记库】\量化研究库\📚 文献\2015_Fama_French_五因子模型.md'
source_old_relative_path: '📚 文献/2015_Fama_French_五因子模型.md'
owner: mig
created_at: 2026-06-05T12:00:00Z
updated_at: 2026-06-05T12:00:00Z
tags: [旧库迁移, 未复核]
---

# L20260521-007 A Five-Factor Asset Pricing Model

## 迁移说明

- 迁移状态：机械迁移，尚未人工复核。
- 原旧库 ID：`2015_Fama_French_五因子模型`
- 来源旧库路径：`E:\【笔记库】\量化研究库\📚 文献\2015_Fama_French_五因子模型.md`
- 新库 ID：`LIT-20260603T000000Z-mig-2015FAMAFRENCHEB2D5`
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
literature_id: L-2015-Fama-002
title: A Five-Factor Asset Pricing Model
authors: [Eugene F. Fama, Kenneth R. French]
year: 2015
journal: Journal of Financial Economics
url: https://doi.org/10.1016/j.jfineco.2014.10.010
source_tags:
  - "[[小市值类策略]]"
  - "[[价值类策略]]"
  - "[[质量类策略]]"
execution_tags:
  - "[[股票轮动]]"
asset_class: [股票]
applicable_markets: [A股]
extracted_modules:
  - "[[质量盈利过滤]]"
  - "[[投资保守性过滤]]"
status: 待拆解
tags:
  - 研究/文献
  - 策略/小市值
  - 策略/质量
~~~
## 旧库原文

~~~markdown
# L20260521-007 A Five-Factor Asset Pricing Model

## 基本信息

| 项目 | 内容 |
| --- | --- |
| 论文 | A Five-Factor Asset Pricing Model |
| 作者 | Eugene F. Fama, Kenneth R. French |
| 期刊 | Journal of Financial Economics, 2015 |
| DOI | `10.1016/j.jfineco.2014.10.010` |
| 来源 | https://doi.org/10.1016/j.jfineco.2014.10.010 |

## 核心观点

五因子模型把规模、价值、盈利能力、投资风格纳入统一框架。对当前平台，它更像是研究框架，而不是直接策略。最实用的是把小市值策略从“只看小”升级为“小市值 + 质量 + 投资保守性”的筛选框架。

## 对当前平台的启发

- 小市值策略需要明确区分规模溢价和垃圾股暴露。
- 质量与投资保守性可作为小市值候选的基本面门槛。
- 因子实验应按收益来源拆分，不要把多个因子一起加入后只看总结果。

## 可拆模块

| 模块 | 类型 | 说明 |
| --- | --- | --- |
| [[质量盈利过滤]] | 因子模块 | 盈利能力过滤 |
| [[投资保守性过滤]] | 因子模块 | 用资产扩张、资本开支或相关代理衡量投资激进程度 |

## 风险与限制

- A 股中小盘壳价值、重组预期和流动性因素可能干扰经典因子解释。
- 财务数据需要严格使用公告可得日。

~~~