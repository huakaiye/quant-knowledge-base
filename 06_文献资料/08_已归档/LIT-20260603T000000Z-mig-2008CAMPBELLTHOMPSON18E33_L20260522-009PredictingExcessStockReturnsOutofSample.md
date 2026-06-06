---
type: 文献卡
lit_id: LIT-20260603T000000Z-mig-2008CAMPBELLTHOMPSON18E33
legacy_id: "2008_Campbell_Thompson_样本外预测约束"
migration_status: migrated_unverified
evidence_level: legacy_raw
source_old_path: 'E:\【笔记库】\量化研究库\📚 文献\2008_Campbell_Thompson_样本外预测约束.md'
source_old_relative_path: '📚 文献/2008_Campbell_Thompson_样本外预测约束.md'
owner: mig
created_at: 2026-06-05T12:00:00Z
updated_at: 2026-06-05T12:00:00Z
tags: [旧库迁移, 未复核]
---

# L20260522-009 Predicting Excess Stock Returns Out of Sample

## 迁移说明

- 迁移状态：机械迁移，尚未人工复核。
- 原旧库 ID：`2008_Campbell_Thompson_样本外预测约束`
- 来源旧库路径：`E:\【笔记库】\量化研究库\📚 文献\2008_Campbell_Thompson_样本外预测约束.md`
- 新库 ID：`LIT-20260603T000000Z-mig-2008CAMPBELLTHOMPSON18E33`
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
literature_id: L-2008-Campbell-001
title: Predicting Excess Stock Returns Out of Sample
authors: [John Y. Campbell, Samuel B. Thompson]
year: 2008
journal: Review of Financial Studies
url: https://academic.oup.com/rfs/article-abstract/21/4/1509/1567518
source_tags:
  - "[[市场状态识别]]"
execution_tags:
  - "[[实验治理]]"
  - "[[状态切换]]"
asset_class: [股票, 指数]
applicable_markets: [ETF, 股票轮动, 多资产配置]
extracted_modules:
  - "[[市场状态识别与切换门控]]"
status: 待拆解
tags:
  - 研究/文献
  - 策略/状态识别
~~~
## 旧库原文

~~~markdown
# L20260522-009 Predicting Excess Stock Returns Out of Sample

## 基本信息

| 项目 | 内容 |
| --- | --- |
| 论文 | Predicting Excess Stock Returns Out of Sample: Can Anything Beat the Historical Average? |
| 作者 | John Y. Campbell, Samuel B. Thompson |
| 期刊 | Review of Financial Studies, 2008 |
| DOI | `10.1093/rfs/hhm055` |
| 来源 | https://academic.oup.com/rfs/article-abstract/21/4/1509/1567518 |

## 核心观点

论文强调样本外预测和经济约束的重要性。对市场状态识别而言，这比“找到复杂模型”更重要：状态信号必须接受符号约束、非负约束、置信度裁剪和样本外验证，不能让模型输出脱离经济含义的极端交易指令。

## 对当前平台的启发

- 状态门控阈值不能只按样本内收益最优选择。
- 若后续使用概率模型，概率输出必须经过上下限裁剪和状态确认。
- 首版状态识别应保守：优先减少明显错误交易，而不是追求每次切换都正确。

## 可拆模块

| 模块 | 类型 | 说明 |
| --- | --- | --- |
| [[市场状态识别与切换门控]] | 实验治理/风控模块 | 给状态信号加入经济约束和样本外验证要求 |

## 风险与限制

- 该文不是直接给出 ETF 轮动因子，而是提供预测治理原则。
- 需要在研究记录中明确样本内、样本外和阈值选择过程。

~~~