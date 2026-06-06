---
type: 文献卡
lit_id: LIT-20260603T000000Z-mig-2003PASTORSTAMBAUGHE1022
legacy_id: "2003_Pastor_Stambaugh_流动性风险"
migration_status: migrated_unverified
evidence_level: legacy_raw
source_old_path: 'E:\【笔记库】\量化研究库\📚 文献\2003_Pastor_Stambaugh_流动性风险.md'
source_old_relative_path: '📚 文献/2003_Pastor_Stambaugh_流动性风险.md'
owner: mig
created_at: 2026-06-05T12:00:00Z
updated_at: 2026-06-05T12:00:00Z
tags: [旧库迁移, 未复核]
---

# L20260522-008 Liquidity Risk and Expected Stock Returns

## 迁移说明

- 迁移状态：机械迁移，尚未人工复核。
- 原旧库 ID：`2003_Pastor_Stambaugh_流动性风险`
- 来源旧库路径：`E:\【笔记库】\量化研究库\📚 文献\2003_Pastor_Stambaugh_流动性风险.md`
- 新库 ID：`LIT-20260603T000000Z-mig-2003PASTORSTAMBAUGHE1022`
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
literature_id: L-2003-Pastor-001
title: Liquidity Risk and Expected Stock Returns
authors: [Lubos Pastor, Robert F. Stambaugh]
year: 2003
journal: Journal of Political Economy
url: https://www.nber.org/system/files/working_papers/w8462/w8462.pdf
source_tags:
  - "[[市场状态识别]]"
  - "[[低波防御类策略]]"
execution_tags:
  - "[[风控叠加]]"
  - "[[状态切换]]"
asset_class: [股票]
applicable_markets: [股票轮动, ETF]
extracted_modules:
  - "[[市场状态识别与切换门控]]"
status: 待拆解
tags:
  - 研究/文献
  - 策略/状态识别
~~~
## 旧库原文

~~~markdown
# L20260522-008 Liquidity Risk and Expected Stock Returns

## 基本信息

| 项目 | 内容 |
| --- | --- |
| 论文 | Liquidity Risk and Expected Stock Returns |
| 作者 | Lubos Pastor, Robert F. Stambaugh |
| 期刊 | Journal of Political Economy, 2003 |
| DOI | `10.1086/374184` |
| 来源 | https://www.nber.org/system/files/working_papers/w8462/w8462.pdf |

## 核心观点

论文将市场范围的流动性视作重要状态变量。对当前项目的启发是：市场状态不应只由价格趋势决定，成交额、流动性和冲击成本也可能决定动量策略能否顺利延续。

## 对当前平台的启发

- ETF 双池可先用 ETF 成交额广度、Top1 成交额变化作为简化流动性代理。
- 小市值策略更需要流动性状态，避免弱市中买入无法退出的标的。
- 流动性信号适合作为风险状态确认，而不是单独决定买卖。

## 可拆模块

| 模块 | 类型 | 说明 |
| --- | --- | --- |
| [[市场状态识别与切换门控]] | 风控模块 | 在趋势和离散度之外加入流动性恶化确认 |

## 风险与限制

- 原论文的流动性指标不容易直接复刻到 A 股 ETF。
- ETF 成交额受新发基金、规模变化影响，必须做上市时间和异常值处理。
- 第一阶段只作为观察信号，不直接交易。

~~~