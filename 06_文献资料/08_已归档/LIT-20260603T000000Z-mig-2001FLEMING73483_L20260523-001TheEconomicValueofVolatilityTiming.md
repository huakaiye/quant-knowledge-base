---
type: 文献卡
lit_id: LIT-20260603T000000Z-mig-2001FLEMING73483
legacy_id: "2001_Fleming_波动率择时经济价值"
migration_status: migrated_unverified
evidence_level: legacy_raw
source_old_path: 'E:\【笔记库】\量化研究库\📚 文献\2001_Fleming_波动率择时经济价值.md'
source_old_relative_path: '📚 文献/2001_Fleming_波动率择时经济价值.md'
owner: mig
created_at: 2026-06-05T12:00:00Z
updated_at: 2026-06-05T12:00:00Z
tags: [旧库迁移, 未复核]
---

# L20260523-001 The Economic Value of Volatility Timing

## 迁移说明

- 迁移状态：机械迁移，尚未人工复核。
- 原旧库 ID：`2001_Fleming_波动率择时经济价值`
- 来源旧库路径：`E:\【笔记库】\量化研究库\📚 文献\2001_Fleming_波动率择时经济价值.md`
- 新库 ID：`LIT-20260603T000000Z-mig-2001FLEMING73483`
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
literature_id: L-2001-Fleming-001
title: The Economic Value of Volatility Timing
authors: [Jeff Fleming, Chris Kirby, Barbara Ostdiek]
year: 2001
journal: Journal of Finance
url: https://doi.org/10.1111/0022-1082.00327
source_tags:
  - "[[低波防御类策略]]"
  - "[[多策略融合类策略]]"
execution_tags:
  - "[[风控叠加]]"
asset_class: [股票, 债券, 黄金]
applicable_markets: [ETF, 多策略组合]
extracted_modules:
  - "[[波动率择时与动态风险预算]]"
status: 待拆解
tags:
  - 研究/文献
  - 策略/风险预算
~~~
## 旧库原文

~~~markdown
# L20260523-001 The Economic Value of Volatility Timing

## 基本信息

| 项目 | 内容 |
| --- | --- |
| 论文 | The Economic Value of Volatility Timing |
| 作者 | Jeff Fleming, Chris Kirby, Barbara Ostdiek |
| 期刊 | Journal of Finance, 2001 |
| 来源 | https://doi.org/10.1111/0022-1082.00327 |

## 核心观点

论文强调波动率预测本身可以带来组合价值。对策略研发的启发是：即使不预测方向，也可以根据条件波动率调整风险暴露。

## 对当前平台的启发

- 多策略组合层可以先做“风险预算调节”，不急于做复杂择时。
- ETF 轮动策略在高波动阶段可降低目标仓位，在波动回落后恢复。
- 防守状态不一定等于全空仓，可以是目标波动率下降后的低暴露状态。

## 可拆模块

| 模块 | 类型 | 说明 |
| --- | --- | --- |
| [[波动率择时与动态风险预算]] | 风控模块 | 根据已实现波动率或预测波动率动态调整组合风险预算 |

## 风险与限制

- 波动率估计窗口过短会带来频繁换仓。
- A 股和 ETF 的涨跌停、停牌、流动性会让实际风险暴露调整滞后。
- 必须避免使用当日收盘后才知道的完整日内波动来做当日交易判断。

~~~