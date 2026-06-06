---
type: 文献卡
lit_id: LIT-20260603T000000Z-mig-2016BAKEREF23C
legacy_id: "2016_Baker_经济政策不确定性"
migration_status: migrated_unverified
evidence_level: legacy_raw
source_old_path: 'E:\【笔记库】\量化研究库\📚 文献\2016_Baker_经济政策不确定性.md'
source_old_relative_path: '📚 文献/2016_Baker_经济政策不确定性.md'
owner: mig
created_at: 2026-06-05T12:00:00Z
updated_at: 2026-06-05T12:00:00Z
tags: [旧库迁移, 未复核]
---

# L20260522-010 Measuring Economic Policy Uncertainty

## 迁移说明

- 迁移状态：机械迁移，尚未人工复核。
- 原旧库 ID：`2016_Baker_经济政策不确定性`
- 来源旧库路径：`E:\【笔记库】\量化研究库\📚 文献\2016_Baker_经济政策不确定性.md`
- 新库 ID：`LIT-20260603T000000Z-mig-2016BAKEREF23C`
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
literature_id: L-2016-Baker-001
title: Measuring Economic Policy Uncertainty
authors: [Scott R. Baker, Nicholas Bloom, Steven J. Davis]
year: 2016
journal: Quarterly Journal of Economics
url: https://doi.org/10.1093/qje/qjw024
source_tags:
  - "[[市场状态识别]]"
execution_tags:
  - "[[外部数据]]"
  - "[[风控叠加]]"
asset_class: [股票, 宏观]
applicable_markets: [ETF, 股票轮动, 多资产配置]
extracted_modules:
  - "[[市场状态识别与切换门控]]"
status: 收集
tags:
  - 研究/文献
  - 策略/状态识别
~~~
## 旧库原文

~~~markdown
# L20260522-010 Measuring Economic Policy Uncertainty

## 基本信息

| 项目 | 内容 |
| --- | --- |
| 论文 | Measuring Economic Policy Uncertainty |
| 作者 | Scott R. Baker, Nicholas Bloom, Steven J. Davis |
| 期刊 | Quarterly Journal of Economics, 2016 |
| DOI | `10.1093/qje/qjw024` |
| 来源 | https://doi.org/10.1093/qje/qjw024 |

## 核心观点

论文提出经济政策不确定性指数。对当前项目的启发是：部分市场状态转变不是价格内部结构能完全解释的，政策不确定性可能改变风险偏好、波动率和动量延续性。

## 对当前平台的启发

- 第一阶段不接入该类外部数据，避免数据时滞和口径复杂化。
- 后续如研究宏观状态门控，可将 EPU 作为外部风险背景变量。
- 对 A 股而言，需要特别确认中国 EPU 数据发布时间和可获取时点，避免未来函数。

## 可拆模块

| 模块 | 类型 | 说明 |
| --- | --- | --- |
| [[市场状态识别与切换门控]] | 外部状态变量 | 作为第二阶段宏观风险背景，不进入首版 R010 |

## 风险与限制

- 外部数据存在发布时间、修订、地区口径问题。
- 高频 ETF 轮动未必需要宏观慢变量。
- 只有在价格内部状态信号不足时才考虑引入。

~~~