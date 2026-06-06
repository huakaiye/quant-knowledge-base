---
type: 文献卡
lit_id: LIT-20260603T000000Z-mig-2015BARROSO7DA3F
legacy_id: "2015_Barroso_风险管理动量"
migration_status: migrated_unverified
evidence_level: legacy_raw
source_old_path: 'E:\【笔记库】\量化研究库\📚 文献\2015_Barroso_风险管理动量.md'
source_old_relative_path: '📚 文献/2015_Barroso_风险管理动量.md'
owner: mig
created_at: 2026-06-05T12:00:00Z
updated_at: 2026-06-05T12:00:00Z
tags: [旧库迁移, 未复核]
---

# L20260521-003 Momentum Has Its Moments

## 迁移说明

- 迁移状态：机械迁移，尚未人工复核。
- 原旧库 ID：`2015_Barroso_风险管理动量`
- 来源旧库路径：`E:\【笔记库】\量化研究库\📚 文献\2015_Barroso_风险管理动量.md`
- 新库 ID：`LIT-20260603T000000Z-mig-2015BARROSO7DA3F`
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
literature_id: L-2015-Barroso-001
title: Momentum Has Its Moments
authors: [Pedro Barroso, Pedro Santa-Clara]
year: 2015
journal: Journal of Financial Economics
url: https://doi.org/10.1016/j.jfineco.2014.11.010
source_tags:
  - "[[横截面动量类策略]]"
  - "[[低波防御类策略]]"
execution_tags:
  - "[[风控叠加]]"
asset_class: [股票]
applicable_markets: [ETF, 股票轮动]
extracted_modules:
  - "[[波动率缩放仓位]]"
  - "[[动量崩盘预警]]"
status: 待拆解
tags:
  - 研究/文献
  - 策略/横截面动量
  - 策略/低波防御
~~~
## 旧库原文

~~~markdown
# L20260521-003 Momentum Has Its Moments

## 基本信息

| 项目 | 内容 |
| --- | --- |
| 论文 | Momentum Has Its Moments |
| 作者 | Pedro Barroso, Pedro Santa-Clara |
| 期刊 | Journal of Financial Economics, 2015 |
| DOI | `10.1016/j.jfineco.2014.11.010` |
| 来源 | https://doi.org/10.1016/j.jfineco.2014.11.010 |

## 核心观点

论文关注动量策略的风险不是常数，动量崩盘往往和风险状态变化有关。对当前平台，最有价值的不是预测收益，而是用波动率和风险状态动态调整动量暴露。

## 对当前平台的启发

- ETF 双池 TopN 可以按组合波动率缩放仓位。
- 动量趋势日内做 T 可以在市场高波动或急速反转时降低做多暴露。
- 研究重点应放在“减少大回撤后急反弹造成的动量反杀”。

## 可拆模块

| 模块 | 类型 | 说明 |
| --- | --- | --- |
| [[波动率缩放仓位]] | 风控模块 | 高波动降低仓位，低波动恢复仓位 |
| [[动量崩盘预警]] | 风控模块 | 针对动量策略的崩盘风险状态识别 |

## 风险与限制

- 波动率缩放可能降低牛市收益。
- 如果波动率窗口太短，会把普通震荡误判成风险状态。

~~~