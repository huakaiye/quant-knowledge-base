---
type: 文献卡
lit_id: LIT-20260603T000000Z-mig-2012NOVYMARX6465D
legacy_id: "2012_NovyMarx_中期动量"
migration_status: migrated_unverified
evidence_level: legacy_raw
source_old_path: 'E:\【笔记库】\量化研究库\📚 文献\2012_NovyMarx_中期动量.md'
source_old_relative_path: '📚 文献/2012_NovyMarx_中期动量.md'
owner: mig
created_at: 2026-06-05T12:00:00Z
updated_at: 2026-06-05T12:00:00Z
tags: [旧库迁移, 未复核]
---

# L20260531-002 Is Momentum Really Momentum?

## 迁移说明

- 迁移状态：机械迁移，尚未人工复核。
- 原旧库 ID：`2012_NovyMarx_中期动量`
- 来源旧库路径：`E:\【笔记库】\量化研究库\📚 文献\2012_NovyMarx_中期动量.md`
- 新库 ID：`LIT-20260603T000000Z-mig-2012NOVYMARX6465D`
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
literature_id: L-2012-NovMarx-002
title: Is Momentum Really Momentum?
authors: [Robert Novy-Marx]
year: 2012
journal: Journal of Financial Economics
doi: 10.1016/j.jfineco.2011.05.003
url: https://www.sciencedirect.com/science/article/abs/pii/S0304405X11001152
source_tags:
  - "[[横截面动量]]"
  - "[[中期动量]]"
execution_tags:
  - "[[ETF轮动]]"
  - "[[动量质量准入]]"
asset_class: [股票]
applicable_markets: [ETF轮动映射, 股票轮动]
extracted_modules:
  - "[[动量质量因子准入]]"
  - "[[慢快动量转折门控]]"
status: 已拆解
tags:
  - 研究/文献
  - 状态/已拆解
~~~
## 旧库原文

~~~markdown
# L20260531-002 Is Momentum Really Momentum?

## 基本信息

| 项目 | 内容 |
| --- | --- |
| 作者 | Robert Novy-Marx |
| 年份 | 2012 |
| 期刊 | Journal of Financial Economics, 103(3), 429-453 |
| DOI | `10.1016/j.jfineco.2011.05.003` |
| 链接 | [ScienceDirect](https://www.sciencedirect.com/science/article/abs/pii/S0304405X11001152) |

## 核心观点

论文质疑传统动量对“近端收益”的依赖，指出动量收益很大程度来自更中期的历史表现，而不是越近越好。对当前 ETF 双池而言，启发是：不能只看最近 5 日或 10 日是否还强，就断定旧仓值得保留或新候选值得追入。

## 收益来源

关联收益来源：[[横截面动量]]、[[中期动量]]

收益来源可以理解为中期趋势延续，而近端过强或过弱可能包含短期反转、事件冲击和噪声。

## 可拆模块

| 模块 | 类型 | 说明 |
| --- | --- | --- |
| [[动量质量因子准入]] | 因子模块 | 把中期动量与近端冲击分离，避免被短期跳涨或短期回撤误导 |
| [[慢快动量转折门控]] | 状态模块 | 用中期趋势作为慢速状态，用近端动量作为快速状态，识别转折点 |

## 对当前平台的启发

R010-B1 中 A2-current-momentum 使用旧仓 `ret5/slope10/ret20` 不转负来决定是否抗抖，结果只在 2024 显著有效，跨周期不稳。该文献提示我们：

- `ret5` 过近，可能只是噪声或短期反转。
- `ret20` 可以作为中期趋势雏形，但还需要趋势质量和横截面环境确认。
- 判断旧仓是否应保留，不能只问“旧仓还涨不涨”，还要问“旧仓的中期趋势是否仍是池内有效主线”。

## 数据与实现要求

- 所需数据：ETF 日线收益、候选排名、当前持仓未来标签。
- 频率：日频。
- 是否可用当前数据实现：是。
- 潜在未来函数风险：中期窗口必须固定在信号日前；不要用全样本最优窗口。

## 风险与限制

- 原文基于个股月度动量，ETF 日频轮动不能直接套用 12 到 7 个月窗口。
- ETF 池较小且跨资产，近端收益和中期收益的含义会随资产类别变化。
- 该文献适合作为“窗口分解原则”，不适合作为单独交易规则。

## 下一步

对应模块想法：[[动量质量因子准入]]、[[慢快动量转折门控]]

下一步实验：在 R010-C 中拆分旧仓保留信号的近端动量、中期动量和趋势质量贡献。

~~~