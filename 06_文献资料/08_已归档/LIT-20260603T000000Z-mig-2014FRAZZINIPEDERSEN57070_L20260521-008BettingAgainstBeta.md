---
type: 文献卡
lit_id: LIT-20260603T000000Z-mig-2014FRAZZINIPEDERSEN57070
legacy_id: "2014_Frazzini_Pedersen_低贝塔"
migration_status: migrated_unverified
evidence_level: legacy_raw
source_old_path: 'E:\【笔记库】\量化研究库\📚 文献\2014_Frazzini_Pedersen_低贝塔.md'
source_old_relative_path: '📚 文献/2014_Frazzini_Pedersen_低贝塔.md'
owner: mig
created_at: 2026-06-05T12:00:00Z
updated_at: 2026-06-05T12:00:00Z
tags: [旧库迁移, 未复核]
---

# L20260521-008 Betting Against Beta

## 迁移说明

- 迁移状态：机械迁移，尚未人工复核。
- 原旧库 ID：`2014_Frazzini_Pedersen_低贝塔`
- 来源旧库路径：`E:\【笔记库】\量化研究库\📚 文献\2014_Frazzini_Pedersen_低贝塔.md`
- 新库 ID：`LIT-20260603T000000Z-mig-2014FRAZZINIPEDERSEN57070`
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
literature_id: L-2014-Frazzini-002
title: Betting Against Beta
authors: [Andrea Frazzini, Lasse H. Pedersen]
year: 2014
journal: Journal of Financial Economics
url: https://doi.org/10.1016/j.jfineco.2013.10.005
source_tags:
  - "[[低波防御类策略]]"
execution_tags:
  - "[[风控叠加]]"
asset_class: [股票, 多资产]
applicable_markets: [A股, ETF]
extracted_modules:
  - "[[低波低贝塔风控增强]]"
status: 待拆解
tags:
  - 研究/文献
  - 策略/低波防御
~~~
## 旧库原文

~~~markdown
# L20260521-008 Betting Against Beta

## 基本信息

| 项目 | 内容 |
| --- | --- |
| 论文 | Betting Against Beta |
| 作者 | Andrea Frazzini, Lasse H. Pedersen |
| 期刊 | Journal of Financial Economics, 2014 |
| DOI | `10.1016/j.jfineco.2013.10.005` |
| 来源 | https://doi.org/10.1016/j.jfineco.2013.10.005 |

## 核心观点

论文研究低 beta/高 beta 资产定价差异。对当前平台，最直接的启发是：在股票轮动和 ETF 轮动中，高 beta 或高波动资产不应天然获得更高权重，尤其在风险状态差时应受到约束。

## 对当前平台的启发

- 小市值和动量股票策略可加入低波/低 beta 风险约束。
- ETF 行业轮动可在高波动行业 ETF 上设置仓位折扣。
- 低波模块适合做风险叠加，不宜直接替代收益因子。

## 可拆模块

| 模块 | 类型 | 说明 |
| --- | --- | --- |
| [[低波低贝塔风控增强]] | 风控模块 | 对高 beta、高波动候选做降权或过滤 |

## 风险与限制

- A 股 beta 估计对窗口和停牌敏感。
- 低 beta 可能在强牛市拖累收益，必须分市场状态评估。

~~~