---
type: 文献卡
lit_id: LIT-20260603T000000Z-mig-2023GOULDING07A86
legacy_id: "2023_Goulding_动量转折点"
migration_status: migrated_unverified
evidence_level: legacy_raw
source_old_path: 'E:\【笔记库】\量化研究库\📚 文献\2023_Goulding_动量转折点.md'
source_old_relative_path: '📚 文献/2023_Goulding_动量转折点.md'
owner: mig
created_at: 2026-06-05T12:00:00Z
updated_at: 2026-06-05T12:00:00Z
tags: [旧库迁移, 未复核]
---

# L20260531-001 Momentum Turning Points

## 迁移说明

- 迁移状态：机械迁移，尚未人工复核。
- 原旧库 ID：`2023_Goulding_动量转折点`
- 来源旧库路径：`E:\【笔记库】\量化研究库\📚 文献\2023_Goulding_动量转折点.md`
- 新库 ID：`LIT-20260603T000000Z-mig-2023GOULDING07A86`
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
literature_id: L-2023-Goulding-001
title: Momentum Turning Points
authors: [Christian L. Goulding, Campbell R. Harvey, Michele G. Mazzoleni]
year: 2023
journal: Journal of Financial Economics
doi: 10.1016/j.jfineco.2023.05.007
url: https://www.sciencedirect.com/science/article/abs/pii/S0304405X23001034
source_tags:
  - "[[时间序列动量]]"
  - "[[市场状态识别]]"
execution_tags:
  - "[[ETF轮动]]"
  - "[[状态日志]]"
asset_class: [股票, 指数]
applicable_markets: [ETF轮动, 指数轮动, 趋势跟踪]
extracted_modules:
  - "[[慢快动量转折门控]]"
status: 已拆解
tags:
  - 研究/文献
  - 状态/已拆解
~~~
## 旧库原文

~~~markdown
# L20260531-001 Momentum Turning Points

## 基本信息

| 项目 | 内容 |
| --- | --- |
| 作者 | Christian L. Goulding、Campbell R. Harvey、Michele G. Mazzoleni |
| 年份 | 2023 |
| 期刊 | Journal of Financial Economics, 149(3), 378-406 |
| DOI | `10.1016/j.jfineco.2023.05.007` |
| 链接 | [ScienceDirect](https://www.sciencedirect.com/science/article/abs/pii/S0304405X23001034) |

## 核心观点

论文用慢速和快速时间序列动量组合识别市场周期。慢速动量更稳但反应慢，快速动量更敏感但容易误报；两者一致时说明趋势状态更明确，两者背离时说明市场可能处于转折点。

## 收益来源

关联收益来源：[[时间序列动量]]、[[市场状态识别]]

它对当前研究最重要的启发不是“预测下一天涨跌”，而是把单一动量强弱拆成四类状态：趋势延续、趋势回调、熊市弱势、弱势反弹。这样可以避免把所有回撤都当成防守信号，也避免在急反弹中继续追旧赢家。

## 可拆模块

| 模块 | 类型 | 说明 |
| --- | --- | --- |
| [[慢快动量转折门控]] | 状态模块 | 用慢速趋势和快速趋势的同向/背离关系，决定原始动量、抗抖、降仓或观察恢复 |

## 对当前平台的启发

ETF 双池当前的动作 A1/A2/A3/A4 问题不只在动作力度，更在启动信号。该文献适合转化为 R010-C 的启动信号诊断框架：

- 慢速趋势为正、快速趋势为正：允许原始动量或强主线抗抖。
- 慢速趋势为正、快速趋势为负：可能是趋势内回调，不应立刻全防守，但要降低追高。
- 慢速趋势为负、快速趋势为负：弱势无主线，优先验证降仓或防守。
- 慢速趋势为负、快速趋势为正：弱势反弹，重点防止旧赢家失效和动量崩盘。

## 数据与实现要求

- 所需数据：ETF 日线收盘价、候选池日线收益、宽基或 ETF 池等权收益。
- 频率：日频优先，盘中版本必须单独标记为盘中快照。
- 是否可用当前数据实现：是。
- 潜在未来函数风险：慢速/快速状态只能用信号日前可见数据；离线标签可以使用未来收益，但不能反写到交易信号。

## 风险与限制

- 原文主要研究股票市场周期，ETF 双池包含跨境、商品、债券和行业 ETF，状态解释要按资产类别复核。
- 快速动量窗口过短会引入噪声，不能直接用单日涨跌判断状态。
- 若只用 2024 年校准阈值，容易再次把强趋势行情拟合成通用规则。

## 下一步

对应模块想法：[[慢快动量转折门控]]

下一步实验：并入 [[R20260531-022_R010C动作启动信号诊断与重构]]，先做离线标签审计，不直接交易化。

~~~