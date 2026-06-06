---
type: 文献卡
lit_id: LIT-20260603T000000Z-mig-2009BOLLERSLEVC7471
legacy_id: "2009_Bollerslev_方差风险溢价"
migration_status: migrated_unverified
evidence_level: legacy_raw
source_old_path: 'E:\【笔记库】\量化研究库\📚 文献\2009_Bollerslev_方差风险溢价.md'
source_old_relative_path: '📚 文献/2009_Bollerslev_方差风险溢价.md'
owner: mig
created_at: 2026-06-05T12:00:00Z
updated_at: 2026-06-05T12:00:00Z
tags: [旧库迁移, 未复核]
---

# L20260523-003 Expected Stock Returns and Variance Risk Premia

## 迁移说明

- 迁移状态：机械迁移，尚未人工复核。
- 原旧库 ID：`2009_Bollerslev_方差风险溢价`
- 来源旧库路径：`E:\【笔记库】\量化研究库\📚 文献\2009_Bollerslev_方差风险溢价.md`
- 新库 ID：`LIT-20260603T000000Z-mig-2009BOLLERSLEVC7471`
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
literature_id: L-2009-Bollerslev-001
title: Expected Stock Returns and Variance Risk Premia
authors: [Tim Bollerslev, George Tauchen, Hao Zhou]
year: 2009
journal: Review of Financial Studies
url: https://academic.oup.com/rfs/article/22/11/4463/1595396
source_tags:
  - "[[低波防御类策略]]"
  - "[[多策略融合类策略]]"
execution_tags:
  - "[[风控叠加]]"
asset_class: [股票指数, 期权]
applicable_markets: [ETF, 指数择时]
extracted_modules:
  - "[[尾部风险与波动风险溢价预警]]"
status: 待拆解
tags:
  - 研究/文献
  - 策略/市场状态
~~~
## 旧库原文

~~~markdown
# L20260523-003 Expected Stock Returns and Variance Risk Premia

## 基本信息

| 项目 | 内容 |
| --- | --- |
| 论文 | Expected Stock Returns and Variance Risk Premia |
| 作者 | Tim Bollerslev, George Tauchen, Hao Zhou |
| 期刊 | Review of Financial Studies, 2009 |
| 来源 | https://academic.oup.com/rfs/article/22/11/4463/1595396 |

## 核心观点

方差风险溢价反映市场对未来波动和尾部风险的补偿要求。对策略研发而言，它可以作为风险状态识别的背景变量。

## 对当前平台的启发

- 如果后续接入期权或波动率指数数据，可以把方差风险溢价作为市场风险温度计。
- 当前无期权数据时，可以先用“隐含波动替代变量缺失”的框架记录，不强行实现。
- 对 ETF 轮动，方差风险溢价更适合作为仓位门控，而不是直接排序因子。

## 可拆模块

| 模块 | 类型 | 说明 |
| --- | --- | --- |
| [[尾部风险与波动风险溢价预警]] | 状态模块 | 用波动风险溢价、尾部风险代理变量辅助判断风险偏好变化 |

## 风险与限制

- A 股期权和波动率数据覆盖有限，历史样本可能短。
- 如果只能用已实现波动率替代方差风险溢价，需要在文档中明确这是弱化版本。

~~~