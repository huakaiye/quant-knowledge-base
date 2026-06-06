---
type: 文献卡
lit_id: LIT-20260603T000000Z-mig-2013NOVYMARXC7534
legacy_id: "2013_NovyMarx_毛利率质量因子"
migration_status: migrated_unverified
evidence_level: legacy_raw
source_old_path: 'E:\【笔记库】\量化研究库\📚 文献\2013_NovyMarx_毛利率质量因子.md'
source_old_relative_path: '📚 文献/2013_NovyMarx_毛利率质量因子.md'
owner: mig
created_at: 2026-06-05T12:00:00Z
updated_at: 2026-06-05T12:00:00Z
tags: [旧库迁移, 未复核]
---

# L20260521-006 The Gross Profitability Premium

## 迁移说明

- 迁移状态：机械迁移，尚未人工复核。
- 原旧库 ID：`2013_NovyMarx_毛利率质量因子`
- 来源旧库路径：`E:\【笔记库】\量化研究库\📚 文献\2013_NovyMarx_毛利率质量因子.md`
- 新库 ID：`LIT-20260603T000000Z-mig-2013NOVYMARXC7534`
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
literature_id: L-2013-NovMarx-002
title: The Other Side of Value: The Gross Profitability Premium
authors: [Robert Novy-Marx]
year: 2013
journal: Journal of Financial Economics
url: https://doi.org/10.1016/j.jfineco.2013.01.003
source_tags:
  - "[[质量类策略]]"
  - "[[价值类策略]]"
execution_tags:
  - "[[股票轮动]]"
asset_class: [股票]
applicable_markets: [A股]
extracted_modules:
  - "[[质量盈利过滤]]"
status: 待拆解
tags:
  - 研究/文献
  - 策略/质量
  - 策略/价值
~~~
## 旧库原文

~~~markdown
# L20260521-006 The Gross Profitability Premium

## 基本信息

| 项目 | 内容 |
| --- | --- |
| 论文 | The Other Side of Value: The Gross Profitability Premium |
| 作者 | Robert Novy-Marx |
| 期刊 | Journal of Financial Economics, 2013 |
| DOI | `10.1016/j.jfineco.2013.01.003` |
| 来源 | https://doi.org/10.1016/j.jfineco.2013.01.003 |

## 核心观点

论文强调毛利率相对资产规模的质量指标对股票横截面收益有预测力，并且能与价值策略互补。对当前平台，最直接用途是给小市值策略增加质量过滤。

## 对当前平台的启发

- 小市值日内做 T 不应只按市值和短期走势选股，应过滤盈利质量差的公司。
- 质量过滤可作为“买入前过滤”和“持仓复查”两层使用。
- 如果 CH 中缺少毛利到资产的稳定字段，可先用毛利率、ROE、营收增长做近似版本。

## 可拆模块

| 模块 | 类型 | 说明 |
| --- | --- | --- |
| [[质量盈利过滤]] | 因子模块 | 用盈利能力过滤小市值和动量候选 |

## 风险与限制

- A 股财报披露滞后，必须按可得日处理，避免未来函数。
- 质量信号低频，不能和日内做 T 信号混为同一频率。

~~~