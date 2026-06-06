---
type: 文献卡
lit_id: LIT-20260603T000000Z-mig-2016MCLEANPONTIFFABAC9
legacy_id: "2016_McLean_Pontiff_因子发表后衰减"
migration_status: migrated_unverified
evidence_level: legacy_raw
source_old_path: 'E:\【笔记库】\量化研究库\📚 文献\2016_McLean_Pontiff_因子发表后衰减.md'
source_old_relative_path: '📚 文献/2016_McLean_Pontiff_因子发表后衰减.md'
owner: mig
created_at: 2026-06-05T12:00:00Z
updated_at: 2026-06-05T12:00:00Z
tags: [旧库迁移, 未复核]
---

# L20260523-006 Does Academic Research Destroy Stock Return Predictability?

## 迁移说明

- 迁移状态：机械迁移，尚未人工复核。
- 原旧库 ID：`2016_McLean_Pontiff_因子发表后衰减`
- 来源旧库路径：`E:\【笔记库】\量化研究库\📚 文献\2016_McLean_Pontiff_因子发表后衰减.md`
- 新库 ID：`LIT-20260603T000000Z-mig-2016MCLEANPONTIFFABAC9`
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
literature_id: L-2016-McLean-003
title: Does Academic Research Destroy Stock Return Predictability?
authors: [R. David McLean, Jeffrey Pontiff]
year: 2016
journal: Journal of Finance
url: https://doi.org/10.1111/jofi.12365
source_tags:
  - "[[多策略融合类策略]]"
execution_tags:
  - "[[风控叠加]]"
asset_class: [股票]
applicable_markets: [全部策略]
extracted_modules:
  - "[[因子稳健性与失效监控]]"
status: 待拆解
tags:
  - 研究/文献
  - 策略/因子治理
~~~
## 旧库原文

~~~markdown
# L20260523-006 Does Academic Research Destroy Stock Return Predictability?

## 基本信息

| 项目 | 内容 |
| --- | --- |
| 论文 | Does Academic Research Destroy Stock Return Predictability? |
| 作者 | R. David McLean, Jeffrey Pontiff |
| 期刊 | Journal of Finance, 2016 |
| 来源 | https://doi.org/10.1111/jofi.12365 |

## 核心观点

论文讨论学术研究发表后，异常收益可预测性可能衰减。对研究库的意义是：论文因子不能只看原论文样本内收益，必须关注发表后、样本外、换市场后的稳定性。

## 对当前平台的启发

- 文献因子进入实验前，应记录原文样本期和发表后检验期。
- 新因子上线需要“发现期、验证期、上线观察期”三段管理。
- 如果因子只在少数年份有效，应转入状态依赖模块，而不是直接作为常驻因子。

## 可拆模块

| 模块 | 类型 | 说明 |
| --- | --- | --- |
| [[因子稳健性与失效监控]] | 研究治理模块 | 建立因子发表后衰减、样本外稳定性和上线后监控规则 |

## 风险与限制

- A 股制度变化频繁，衰减可能来自交易制度、数据质量或拥挤度变化。
- 不能因为短期样本外失败就直接否定因子，需要区分市场状态和因子失效。

~~~