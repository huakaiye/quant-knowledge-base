---
type: 文献卡
lit_id: LIT-20260603T000000Z-mig-2014DAFROGINTHEPANB412A
legacy_id: "2014_Da_FrogInThePan_平滑上涨动量"
migration_status: migrated_unverified
evidence_level: legacy_raw
source_old_path: 'E:\【笔记库】\量化研究库\📚 文献\2014_Da_FrogInThePan_平滑上涨动量.md'
source_old_relative_path: '📚 文献/2014_Da_FrogInThePan_平滑上涨动量.md'
owner: mig
created_at: 2026-06-05T12:00:00Z
updated_at: 2026-06-05T12:00:00Z
tags: [旧库迁移, 未复核]
---

# L20260521-011 Frog in the Pan: Continuous Information and Momentum

## 迁移说明

- 迁移状态：机械迁移，尚未人工复核。
- 原旧库 ID：`2014_Da_FrogInThePan_平滑上涨动量`
- 来源旧库路径：`E:\【笔记库】\量化研究库\📚 文献\2014_Da_FrogInThePan_平滑上涨动量.md`
- 新库 ID：`LIT-20260603T000000Z-mig-2014DAFROGINTHEPANB412A`
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
literature_id: L-2014-Da-001
title: Frog in the Pan: Continuous Information and Momentum
authors: [Zhi Da, Umit G. Gurun, Mitch Warachka]
year: 2014
journal: The Review of Financial Studies
url: https://academic.oup.com/rfs/article/27/7/2171/1578455
doi: 10.1093/rfs/hhu003
source_tags:
  - "[[时间序列动量]]"
  - "[[平滑上涨]]"
execution_tags:
  - "[[动量质量准入]]"
asset_class: [股票]
applicable_markets: [美股, ETF轮动映射]
extracted_modules:
  - "[[动量质量因子准入]]"
status: 已转模块
tags:
  - 研究/文献
  - 状态/已转模块
~~~
## 旧库原文

~~~markdown
# L20260521-011 Frog in the Pan: Continuous Information and Momentum

## 基本信息

| 项目 | 内容 |
| --- | --- |
| 作者 | Zhi Da、Umit G. Gurun、Mitch Warachka |
| 年份 | 2014 |
| 期刊 | The Review of Financial Studies, 27(7), 2171-2218 |
| DOI | `10.1093/rfs/hhu003` |
| 链接 | [Oxford Academic](https://academic.oup.com/rfs/article/27/7/2171/1578455) |

## 核心观点

论文提出 Frog-in-the-pan 假说：投资者更容易忽视连续、小幅到来的信息，而更容易注意到离散、剧烈的信息冲击。因此，在形成期总收益相近的情况下，连续小幅上涨带来的动量更可能延续，离散跳涨带来的动量更容易衰减。

## 收益来源

关联收益来源：[[时间序列动量]]、[[平滑上涨]]

行为解释是有限注意力：市场对持续小幅信息反应不足，导致价格延续；而大幅跳涨更容易吸引注意力，短期定价更充分。

## 可拆模块

| 模块 | 类型 | 说明 |
| --- | --- | --- |
| [[动量质量因子准入]] | 因子模块 | 用上涨天数占比和跳涨集中度区分平滑趋势与事件跳涨 |

## 对当前平台的启发

ETF 双池原策略只回答“谁最强”，但没有区分强势来源。如果强势来自少数跳涨日，继续追入可能面临回吐；如果强势来自连续小幅上涨，趋势延续概率可能更好。

R006/R007 已验证：

- 样本内硬准入显著提高收益和夏普。
- 样本外硬准入未超过基准，但 `w80/q045` 降低了最大回撤。
- 下一步应改为软排序加分，而不是硬防守过滤。

## 数据与实现要求

- 所需数据：ETF 日线收盘价。
- 频率：日频。
- 当前数据可实现：是。
- 潜在未来函数风险：需要确保只使用当日当前价和历史收盘，不能使用未来完整日线。

## 风险与限制

- 原论文研究对象是股票，ETF 是组合资产，信息扩散机制可能弱化。
- A 股 ETF 跨境品种、行业品种、商品品种的跳涨原因差异较大，统一阈值可能不稳。
- 样本内收益提升不等于可采纳，必须看样本外和参数稳定性。

## 下一步

对应模块想法：[[动量质量因子准入]]

下一步实验：将平滑上涨改为软排序因子。

~~~