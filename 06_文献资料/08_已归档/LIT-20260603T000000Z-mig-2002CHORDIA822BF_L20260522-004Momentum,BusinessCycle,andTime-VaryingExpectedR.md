---
type: 文献卡
lit_id: LIT-20260603T000000Z-mig-2002CHORDIA822BF
legacy_id: "2002_Chordia_商业周期与动量"
migration_status: migrated_unverified
evidence_level: legacy_raw
source_old_path: 'E:\【笔记库】\量化研究库\📚 文献\2002_Chordia_商业周期与动量.md'
source_old_relative_path: '📚 文献/2002_Chordia_商业周期与动量.md'
owner: mig
created_at: 2026-06-05T12:00:00Z
updated_at: 2026-06-05T12:00:00Z
tags: [旧库迁移, 未复核]
---

# L20260522-004 Momentum, Business Cycle, and Time-Varying Expected Returns

## 迁移说明

- 迁移状态：机械迁移，尚未人工复核。
- 原旧库 ID：`2002_Chordia_商业周期与动量`
- 来源旧库路径：`E:\【笔记库】\量化研究库\📚 文献\2002_Chordia_商业周期与动量.md`
- 新库 ID：`LIT-20260603T000000Z-mig-2002CHORDIA822BF`
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
literature_id: L-2002-Chordia-002
title: Momentum, Business Cycle, and Time-Varying Expected Returns
authors: [Tarun Chordia, Lakshmanan Shivakumar]
year: 2002
journal: Journal of Finance
doi: 10.1111/1540-6261.00449
url: https://ideas.repec.org/a/bla/jfinan/v57y2002i2p985-1019.html
source_tags:
  - "[[横截面动量]]"
  - "[[市场状态识别]]"
execution_tags:
  - "[[市场环境过滤]]"
asset_class: [股票]
applicable_markets: [股票轮动, ETF轮动]
extracted_modules:
  - "[[市场状态识别与切换门控]]"
status: 已拆解
tags:
  - 研究/文献
  - 策略/横截面动量
~~~
## 旧库原文

~~~markdown
# L20260522-004 Momentum, Business Cycle, and Time-Varying Expected Returns

## 基本信息

| 项目 | 内容 |
| --- | --- |
| 论文 | Momentum, Business Cycle, and Time-Varying Expected Returns |
| 作者 | Tarun Chordia, Lakshmanan Shivakumar |
| 期刊 | Journal of Finance, 2002 |
| DOI | `10.1111/1540-6261.00449` |
| 来源 | https://ideas.repec.org/a/bla/jfinan/v57y2002i2p985-1019.html |

## 核心观点

论文从商业周期和时变预期收益角度解释动量收益。对我们而言，关键不是引入宏观预测模型，而是承认动量收益随经济/市场状态变化，不能把单一动量参数视为永久稳定。

## 对当前项目的启发

A股 ETF 双池是高频率的主题轮动，不适合直接引入月度宏观变量，但可以借鉴“状态依赖的动量收益”框架：

- 动量策略在上行/扩张状态更有效。
- 弱势、修复、流动性紧张状态下动量规则要降权。
- 交易规则应在状态层决定参数，而不是每个状态重写策略。

## 可落地信号

| 信号 | 数据 | 用途 |
| --- | --- | --- |
| 宽基趋势 | 沪深300ETF、中证500ETF、创业板ETF过去20/60日收益 | 替代宏观扩张/收缩状态 |
| ETF池广度 | ETF池趋势通过率 | 判断动量收益是否处在顺周期环境 |
| 市场波动率 | 宽基或ETF池等权组合20日实现波动率 | 高波动时降低动量暴露 |
| 修复状态 | 过去20/60日下跌后3/5日急反弹 | 判断动量崩盘风险 |

## 风险与限制

- 宏观变量频率低，滞后明显，暂不适合作为 ETF 日频轮动主信号。
- 可以把宏观思想映射为市场价格状态，但必须避免事后定义周期。

## 关联模块

- [[市场状态识别与切换门控]]
- [[动量崩盘预警]]
- [[ETF趋势确认与防守切换]]

~~~