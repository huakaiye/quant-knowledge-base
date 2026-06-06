---
type: 文献卡
lit_id: LIT-20260603T000000Z-mig-2015HOUXUEZHANGFB8FD
legacy_id: "2015_Hou_Xue_Zhang_消化异常因子"
migration_status: migrated_unverified
evidence_level: legacy_raw
source_old_path: 'E:\【笔记库】\量化研究库\📚 文献\2015_Hou_Xue_Zhang_消化异常因子.md'
source_old_relative_path: '📚 文献/2015_Hou_Xue_Zhang_消化异常因子.md'
owner: mig
created_at: 2026-06-05T12:00:00Z
updated_at: 2026-06-05T12:00:00Z
tags: [旧库迁移, 未复核]
---

# L20260523-005 Digesting Anomalies

## 迁移说明

- 迁移状态：机械迁移，尚未人工复核。
- 原旧库 ID：`2015_Hou_Xue_Zhang_消化异常因子`
- 来源旧库路径：`E:\【笔记库】\量化研究库\📚 文献\2015_Hou_Xue_Zhang_消化异常因子.md`
- 新库 ID：`LIT-20260603T000000Z-mig-2015HOUXUEZHANGFB8FD`
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
literature_id: L-2015-Hou-003
title: Digesting Anomalies
authors: [Kewei Hou, Chen Xue, Lu Zhang]
year: 2015
journal: Review of Financial Studies
url: https://academic.oup.com/rfs/article/28/3/650/1573576
source_tags:
  - "[[多策略融合类策略]]"
execution_tags:
  - "[[风控叠加]]"
asset_class: [股票]
applicable_markets: [股票轮动, 小市值]
extracted_modules:
  - "[[因子稳健性与失效监控]]"
status: 待拆解
tags:
  - 研究/文献
  - 策略/因子治理
~~~
## 旧库原文

~~~markdown
# L20260523-005 Digesting Anomalies

## 基本信息

| 项目 | 内容 |
| --- | --- |
| 论文 | Digesting Anomalies |
| 作者 | Kewei Hou, Chen Xue, Lu Zhang |
| 期刊 | Review of Financial Studies, 2015 |
| 来源 | https://academic.oup.com/rfs/article/28/3/650/1573576 |

## 核心观点

论文从投资和盈利能力视角重新整理大量异常收益现象。对策略研发的启发是：因子不是越多越好，应优先保留有经济解释、可重复、可组合的收益来源。

## 对当前平台的启发

- 小市值策略不能只看市值，应加入盈利质量和投资保守性过滤。
- 文献因子进入研究库前需要标注经济解释和预期失效场景。
- 每个新增因子要和已有因子做增量贡献检查，避免重复暴露。

## 可拆模块

| 模块 | 类型 | 说明 |
| --- | --- | --- |
| [[因子稳健性与失效监控]] | 研究治理模块 | 建立因子筛选、复现和失效跟踪流程 |

## 风险与限制

- 海外股票因子的结论不能直接搬到 A 股。
- 基本面数据存在公告滞后，实验必须使用可见时点数据。

~~~