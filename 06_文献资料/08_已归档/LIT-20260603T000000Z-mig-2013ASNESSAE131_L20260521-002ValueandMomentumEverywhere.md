---
type: 文献卡
lit_id: LIT-20260603T000000Z-mig-2013ASNESSAE131
legacy_id: "2013_Asness_价值与动量跨资产"
migration_status: migrated_unverified
evidence_level: legacy_raw
source_old_path: 'E:\【笔记库】\量化研究库\📚 文献\2013_Asness_价值与动量跨资产.md'
source_old_relative_path: '📚 文献/2013_Asness_价值与动量跨资产.md'
owner: mig
created_at: 2026-06-05T12:00:00Z
updated_at: 2026-06-05T12:00:00Z
tags: [旧库迁移, 未复核]
---

# L20260521-002 Value and Momentum Everywhere

## 迁移说明

- 迁移状态：机械迁移，尚未人工复核。
- 原旧库 ID：`2013_Asness_价值与动量跨资产`
- 来源旧库路径：`E:\【笔记库】\量化研究库\📚 文献\2013_Asness_价值与动量跨资产.md`
- 新库 ID：`LIT-20260603T000000Z-mig-2013ASNESSAE131`
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
literature_id: L-2013-Asness-001
title: Value and Momentum Everywhere
authors: [Clifford S. Asness, Tobias J. Moskowitz, Lasse H. Pedersen]
year: 2013
journal: Journal of Finance
url: https://doi.org/10.1111/jofi.12021
source_tags:
  - "[[横截面动量类策略]]"
  - "[[价值类策略]]"
execution_tags:
  - "[[ETF轮动]]"
  - "[[TopN分散]]"
asset_class: [股票, 股指, 债券, 货币, 商品]
applicable_markets: [ETF, 股票轮动]
extracted_modules:
  - "[[价值动量互补组合]]"
status: 待拆解
tags:
  - 研究/文献
  - 策略/横截面动量
  - 策略/价值
~~~
## 旧库原文

~~~markdown
# L20260521-002 Value and Momentum Everywhere

## 基本信息

| 项目 | 内容 |
| --- | --- |
| 论文 | Value and Momentum Everywhere |
| 作者 | Clifford S. Asness, Tobias J. Moskowitz, Lasse H. Pedersen |
| 期刊 | Journal of Finance, 2013 |
| DOI | `10.1111/jofi.12021` |
| 来源 | https://doi.org/10.1111/jofi.12021 |

## 核心观点

论文从多资产角度研究价值和动量，强调两类收益来源在不同资产和市场中广泛存在，并且二者可以互补。对当前平台而言，关键不是复制跨资产模型，而是把“单一动量信号”改造成“动量主导、估值或防御信号辅助”的组合逻辑。

## 对当前平台的启发

- ETF 双池可以研究“动量 + 估值/防御 ETF 代理”的组合规则。
- 股票动量策略可加入低估值或质量约束，减少高估值动量末端接力。
- 多策略融合应避免简单叠加，应先判断不同收益来源之间是否互补。

## 可拆模块

| 模块 | 类型 | 说明 |
| --- | --- | --- |
| [[价值动量互补组合]] | 组合模块 | 动量打分为主，价值/质量/防御信号作为约束或二级排序 |

## 风险与限制

- ETF 估值代理不如股票直接，可能需要行业估值、指数估值或防御资产替代。
- 价值信号慢，和日频动量轮动的调仓节奏不一致。

~~~