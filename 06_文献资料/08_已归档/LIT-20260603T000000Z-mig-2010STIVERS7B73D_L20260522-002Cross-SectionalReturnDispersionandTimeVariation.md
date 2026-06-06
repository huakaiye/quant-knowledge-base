---
type: 文献卡
lit_id: LIT-20260603T000000Z-mig-2010STIVERS7B73D
legacy_id: "2010_Stivers_截面离散度与动量溢价"
migration_status: migrated_unverified
evidence_level: legacy_raw
source_old_path: 'E:\【笔记库】\量化研究库\📚 文献\2010_Stivers_截面离散度与动量溢价.md'
source_old_relative_path: '📚 文献/2010_Stivers_截面离散度与动量溢价.md'
owner: mig
created_at: 2026-06-05T12:00:00Z
updated_at: 2026-06-05T12:00:00Z
tags: [旧库迁移, 未复核]
---

# L20260522-002 Cross-Sectional Return Dispersion and Time Variation in Value and Momentum Premiums

## 迁移说明

- 迁移状态：机械迁移，尚未人工复核。
- 原旧库 ID：`2010_Stivers_截面离散度与动量溢价`
- 来源旧库路径：`E:\【笔记库】\量化研究库\📚 文献\2010_Stivers_截面离散度与动量溢价.md`
- 新库 ID：`LIT-20260603T000000Z-mig-2010STIVERS7B73D`
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
literature_id: L-2010-Stivers-001
title: Cross-Sectional Return Dispersion and Time Variation in Value and Momentum Premiums
authors: [Chris Stivers, Licheng Sun]
year: 2010
journal: Journal of Financial and Quantitative Analysis
doi: 10.1017/S0022109010000384
url: https://www.cambridge.org/core/journals/journal-of-financial-and-quantitative-analysis/article/abs/crosssectional-return-dispersion-and-time-variation-in-value-and-momentum-premiums/77E2E3B09BDA5992C29BBCE2CEDC08FE
source_tags:
  - "[[横截面动量]]"
  - "[[市场状态识别]]"
execution_tags:
  - "[[ETF轮动]]"
  - "[[市场环境过滤]]"
asset_class: [股票]
applicable_markets: [股票轮动, ETF轮动]
extracted_modules:
  - "[[市场状态识别与切换门控]]"
status: 已拆解
tags:
  - 研究/文献
  - 策略/市场状态
~~~
## 旧库原文

~~~markdown
# L20260522-002 Cross-Sectional Return Dispersion and Time Variation in Value and Momentum Premiums

## 基本信息

| 项目 | 内容 |
| --- | --- |
| 论文 | Cross-Sectional Return Dispersion and Time Variation in Value and Momentum Premiums |
| 作者 | Chris Stivers, Licheng Sun |
| 期刊 | Journal of Financial and Quantitative Analysis, 2010 |
| DOI | `10.1017/S0022109010000384` |
| 来源 | https://www.cambridge.org/core/journals/journal-of-financial-and-quantitative-analysis/article/abs/crosssectional-return-dispersion-and-time-variation-in-value-and-momentum-premiums/77E2E3B09BDA5992C29BBCE2CEDC08FE |

## 核心观点

论文研究横截面收益离散度与价值、动量溢价的时变关系。其关键启发是：横截面离散度本身可以作为状态变量，而不是只作为风险统计量。

## 对当前项目的启发

ETF 双池轮动只有在 ETF 之间存在足够可交易差异时才有意义。低离散环境下，即使 Top1 排名每天变化，也可能只是噪音；极高离散环境下，可能是冲击行情或动量崩盘风险上升。

## 可落地信号

| 信号 | 计算口径 | 可用时点 | 用途 |
| --- | --- | --- | --- |
| ETF池20日收益离散度 | ETF池每只ETF过去20日收益的截面标准差 | T-1收盘或盘中实时重算 | 判断轮动是否有选标价值 |
| Top1-Top5动量分差 | Top1得分减Top5得分，或Top1/Top5中位数 | 信号生成时 | 判断是否值得换仓 |
| ETF池中位收益 | ETF池20日收益中位数 | T-1或实时 | 区分全面上涨与少数主线 |

## R010 候选规则

```text
if dispersion_low:
    提高换仓门槛，优先保留持仓
elif dispersion_mid and breadth_mid:
    启用平滑上涨软排序
elif dispersion_high and top_score_extreme:
    信任原始动量，但加风控确认
```

## 风险与限制

- 文献中的高离散度对动量溢价未必总是正向；我们不能简单认为离散度越高越好。
- ETF 池较小且主题集中，离散度阈值必须用滚动历史或训练期确定。
- 离散度不能使用未来全样本分位数。

## 关联模块

- [[市场状态识别与切换门控]]
- [[动量质量因子准入]]
- [[ETF趋势确认与防守切换]]

~~~