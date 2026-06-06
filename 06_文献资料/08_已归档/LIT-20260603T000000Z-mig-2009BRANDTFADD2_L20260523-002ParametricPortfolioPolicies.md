---
type: 文献卡
lit_id: LIT-20260603T000000Z-mig-2009BRANDTFADD2
legacy_id: "2009_Brandt_参数化组合政策"
migration_status: migrated_unverified
evidence_level: legacy_raw
source_old_path: 'E:\【笔记库】\量化研究库\📚 文献\2009_Brandt_参数化组合政策.md'
source_old_relative_path: '📚 文献/2009_Brandt_参数化组合政策.md'
owner: mig
created_at: 2026-06-05T12:00:00Z
updated_at: 2026-06-05T12:00:00Z
tags: [旧库迁移, 未复核]
---

# L20260523-002 Parametric Portfolio Policies

## 迁移说明

- 迁移状态：机械迁移，尚未人工复核。
- 原旧库 ID：`2009_Brandt_参数化组合政策`
- 来源旧库路径：`E:\【笔记库】\量化研究库\📚 文献\2009_Brandt_参数化组合政策.md`
- 新库 ID：`LIT-20260603T000000Z-mig-2009BRANDTFADD2`
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
literature_id: L-2009-Brandt-002
title: Parametric Portfolio Policies
authors: [Michael W. Brandt, Pedro Santa-Clara, Rossen Valkanov]
year: 2009
journal: Review of Financial Studies
url: https://academic.oup.com/rfs/article/22/9/3411/1599782
source_tags:
  - "[[多策略融合类策略]]"
execution_tags:
  - "[[TopN分散]]"
  - "[[风控叠加]]"
asset_class: [股票, ETF]
applicable_markets: [ETF, 股票轮动]
extracted_modules:
  - "[[参数化组合权重策略]]"
status: 待拆解
tags:
  - 研究/文献
  - 策略/组合权重
~~~
## 旧库原文

~~~markdown
# L20260523-002 Parametric Portfolio Policies

## 基本信息

| 项目 | 内容 |
| --- | --- |
| 论文 | Parametric Portfolio Policies |
| 作者 | Michael W. Brandt, Pedro Santa-Clara, Rossen Valkanov |
| 期刊 | Review of Financial Studies, 2009 |
| 来源 | https://academic.oup.com/rfs/article/22/9/3411/1599782 |

## 核心观点

论文不是先估计每个资产的收益率再做均值方差优化，而是把资产特征直接映射为组合权重。这个思想适合把动量、波动率、质量、估值等信号合成连续权重。

## 对当前平台的启发

- ETF 双池可以从 Top1 或 TopN 离散选择，升级为“分数越强权重越高”的连续权重。
- 小市值策略可以把质量、流动性、波动率作为权重倾斜，而不是只做过滤。
- 多策略组合可以让每个子策略的权重由状态信号决定。

## 可拆模块

| 模块 | 类型 | 说明 |
| --- | --- | --- |
| [[参数化组合权重策略]] | 组合模块 | 用少量参数把特征分数映射为仓位权重 |

## 风险与限制

- 参数过多会迅速变成过拟合。
- 权重函数必须设置上限、下限和换手约束。
- 初期应优先做线性或分段线性版本，不直接上复杂模型。

~~~