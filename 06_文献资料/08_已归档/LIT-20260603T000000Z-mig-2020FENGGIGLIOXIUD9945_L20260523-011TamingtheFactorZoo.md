---
type: 文献卡
lit_id: LIT-20260603T000000Z-mig-2020FENGGIGLIOXIUD9945
legacy_id: "2020_Feng_Giglio_Xiu_驯服因子动物园"
migration_status: migrated_unverified
evidence_level: legacy_raw
source_old_path: 'E:\【笔记库】\量化研究库\📚 文献\2020_Feng_Giglio_Xiu_驯服因子动物园.md'
source_old_relative_path: '📚 文献/2020_Feng_Giglio_Xiu_驯服因子动物园.md'
owner: mig
created_at: 2026-06-05T12:00:00Z
updated_at: 2026-06-05T12:00:00Z
tags: [旧库迁移, 未复核]
---

# L20260523-011 Taming the Factor Zoo

## 迁移说明

- 迁移状态：机械迁移，尚未人工复核。
- 原旧库 ID：`2020_Feng_Giglio_Xiu_驯服因子动物园`
- 来源旧库路径：`E:\【笔记库】\量化研究库\📚 文献\2020_Feng_Giglio_Xiu_驯服因子动物园.md`
- 新库 ID：`LIT-20260603T000000Z-mig-2020FENGGIGLIOXIUD9945`
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
literature_id: L-2020-Feng-001
title: Taming the Factor Zoo
authors: [Guanhao Feng, Stefano Giglio, Dacheng Xiu]
year: 2020
journal: Journal of Finance
url: https://doi.org/10.1111/jofi.12883
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
# L20260523-011 Taming the Factor Zoo

## 基本信息

| 项目 | 内容 |
| --- | --- |
| 论文 | Taming the Factor Zoo |
| 作者 | Guanhao Feng, Stefano Giglio, Dacheng Xiu |
| 期刊 | Journal of Finance, 2020 |
| 来源 | https://doi.org/10.1111/jofi.12883 |

## 核心观点

论文关注大量候选因子中哪些真正提供增量信息。对研究库的启发是：每个新因子都要问“它相对已有因子增加了什么”，而不是只看单独回测表现。

## 对当前平台的启发

- 建立因子入库流程：文献来源、经济解释、实现口径、样本外表现、与已有因子的相关性。
- 对已有动量质量、平滑上涨、波动率等模块做重叠度检查。
- 若新因子只复制已有动量暴露，应降级为辅助解释，不进入实盘候选。

## 可拆模块

| 模块 | 类型 | 说明 |
| --- | --- | --- |
| [[因子稳健性与失效监控]] | 研究治理模块 | 检查新因子相对已有因子的增量贡献 |

## 风险与限制

- 统计检验不能替代交易成本、流动性和执行约束。
- 因子筛选阈值需要预先定义，不能事后按结果修改。

~~~