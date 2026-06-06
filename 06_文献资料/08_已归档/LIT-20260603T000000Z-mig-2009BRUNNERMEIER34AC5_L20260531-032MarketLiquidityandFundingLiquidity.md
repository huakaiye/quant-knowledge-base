---
type: 文献卡
lit_id: LIT-20260603T000000Z-mig-2009BRUNNERMEIER34AC5
legacy_id: "2009_Brunnermeier_市场流动性与融资流动性"
migration_status: migrated_unverified
evidence_level: legacy_raw
source_old_path: 'E:\【笔记库】\量化研究库\📚 文献\2009_Brunnermeier_市场流动性与融资流动性.md'
source_old_relative_path: '📚 文献/2009_Brunnermeier_市场流动性与融资流动性.md'
owner: mig
created_at: 2026-06-05T12:00:00Z
updated_at: 2026-06-05T12:00:00Z
tags: [旧库迁移, 未复核]
---

# L20260531-032 Market Liquidity and Funding Liquidity

## 迁移说明

- 迁移状态：机械迁移，尚未人工复核。
- 原旧库 ID：`2009_Brunnermeier_市场流动性与融资流动性`
- 来源旧库路径：`E:\【笔记库】\量化研究库\📚 文献\2009_Brunnermeier_市场流动性与融资流动性.md`
- 新库 ID：`LIT-20260603T000000Z-mig-2009BRUNNERMEIER34AC5`
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
literature_id: L-2009-Brunnermeier-003
title: Market Liquidity and Funding Liquidity
authors:
  - Markus K. Brunnermeier
  - Lasse Heje Pedersen
year: 2009
journal: Review of Financial Studies
peer_reviewed: true
journal_tier: T1
url: https://ideas.repec.org/a/oup/rfinst/v22y2009i6p2201-2238.html
source_tags:
  - "[[低波防御类策略]]"
execution_tags:
  - "[[ETF轮动]]"
  - "[[风控叠加]]"
asset_class:
  - 多资产
applicable_markets:
  - 多资产ETF
extracted_modules:
  - 流动性踩踏预警
status: 收集
tags:
  - 研究/文献
  - 状态/收集
~~~
## 旧库原文

~~~markdown
# L20260531-032 Market Liquidity and Funding Liquidity

## 基本信息

| 项目 | 内容 |
| --- | --- |
| 作者 | Markus K. Brunnermeier、Lasse Heje Pedersen |
| 年份 | 2009 |
| 期刊/来源 | Review of Financial Studies |
| 链接 | https://ideas.repec.org/a/oup/rfinst/v22y2009i6p2201-2238.html |
| 资产类别 | 多资产 |
| 原始市场 | 理论与多市场经验背景 |

## 核心观点

市场流动性和融资流动性会互相强化：当交易者资金约束收紧时，资产流动性可能突然恶化，并且这种恶化具有跨资产共振。对 ETF 轮动而言，价格趋势变弱之外，成交量冲击、成交额萎缩和溢价率异常也可能是防守切换的重要确认变量。

## 收益来源

关联收益来源：[[低波防御类策略]]

该文献不直接提供收益因子，更像风险状态识别模块。它提示我们：深回撤可能不是单纯趋势反转，而是风险资产池交易承载力下降。

## 可拆模块

| 模块 | 类型 | 说明 |
| --- | --- | --- |
| 流动性踩踏预警 | 风控模块 | 观察 ETF 池成交额萎缩、成交量异常放大、溢价率异常和多 ETF 同步下跌 |
| 防守确认层 | 状态模块 | 只作为 D1/D3 防守的确认变量，不单独触发交易 |

## 对当前平台的启发

当前 R010-D 已有高波动低广度信号，但它仍可能误伤正常高波动主线。若叠加流动性恶化，防守信号的解释力可能更强；若流动性正常，则高波动可能只是趋势换挡。

## 数据与实现要求

- 所需数据：ETF 日线成交额、成交量、必要时基金净值与溢价率。
- 频率：日频即可，分钟级可作为后续增强。
- 是否可用当前数据实现：成交量和成交额可实现；溢价率数据需要先确认稳定性。
- 潜在未来函数风险：溢价率使用净值时必须确认净值公布时点，不能使用信号日尚不可见净值。

## 风险与限制

流动性信号容易把“放量突破”和“踩踏卖出”混淆。首轮应只作为风险确认层，并与价格方向、广度和未来防御超额一起审计。

## 下一步

是否拆成模块想法：是
对应模块想法：ETF流动性踩踏预警


~~~