---
type: 文献卡
lit_id: LIT-20260603T000000Z-mig-2004COOPERAF5D5
legacy_id: "2004_Cooper_市场状态与动量"
migration_status: migrated_unverified
evidence_level: legacy_raw
source_old_path: 'E:\【笔记库】\量化研究库\📚 文献\2004_Cooper_市场状态与动量.md'
source_old_relative_path: '📚 文献/2004_Cooper_市场状态与动量.md'
owner: mig
created_at: 2026-06-05T12:00:00Z
updated_at: 2026-06-05T12:00:00Z
tags: [旧库迁移, 未复核]
---

# L20260522-001 Market States and Momentum

## 迁移说明

- 迁移状态：机械迁移，尚未人工复核。
- 原旧库 ID：`2004_Cooper_市场状态与动量`
- 来源旧库路径：`E:\【笔记库】\量化研究库\📚 文献\2004_Cooper_市场状态与动量.md`
- 新库 ID：`LIT-20260603T000000Z-mig-2004COOPERAF5D5`
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
literature_id: L-2004-Cooper-001
title: Market States and Momentum
authors: [Michael J. Cooper, Roberto C. Gutierrez Jr., Allaudeen Hameed]
year: 2004
journal: Journal of Finance
doi: 10.1111/j.1540-6261.2004.00665.x
url: https://www.rogutierrez.net/files/States_and_Momentum.pdf
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
  - 策略/横截面动量
~~~
## 旧库原文

~~~markdown
# L20260522-001 Market States and Momentum

## 基本信息

| 项目 | 内容 |
| --- | --- |
| 论文 | Market States and Momentum |
| 作者 | Michael J. Cooper, Roberto C. Gutierrez Jr., Allaudeen Hameed |
| 期刊 | Journal of Finance, 2004 |
| DOI | `10.1111/j.1540-6261.2004.00665.x` |
| 来源 | https://www.rogutierrez.net/files/States_and_Momentum.pdf |

## 核心观点

论文把市场状态定义为过去市场收益状态，而不是事后牛熊标签。其核心发现是，动量收益对滞后的市场状态敏感：过去市场上涨之后，动量收益更强；过去市场下跌之后，动量收益弱甚至为负。

## 对当前项目的启发

ETF 双池动量不能只看当日 Top1 强弱，还要看“当前动量信号处在什么滞后市场状态里”。这对 R010 很关键：

- 市场状态只能用过去收益、过去广度、过去波动率定义。
- 不能用事后回看某个月是牛市还是熊市。
- 状态变量要作为门控，而不是替代动量排序本身。

## 可落地信号

| 信号 | 计算口径 | 可用时点 | 用途 |
| --- | --- | --- | --- |
| 市场过去20日收益 | 沪深300ETF或ETF池等权组合过去20日收益 | T日开盘前只能用T-1收盘；盘中可用实时价更新 | 判断上行/下行市场状态 |
| 市场过去60日收益 | 同上，60日窗口 | 同上 | 避免短期噪音误判 |
| ETF池中位20日收益 | 静态池或动态池中位20日收益 | T-1或实时 | 判断是否为广泛上行 |

## 风险与限制

- A股 ETF 轮动周期比论文月度股票动量更短，不能直接照搬形成期长度。
- 过去市场收益只能作为状态条件，不能单独决定买卖。
- 用全样本分位数定义状态会产生未来函数，必须改成滚动分位数或训练期固定阈值。

## 关联模块

- [[市场状态识别与切换门控]]
- [[ETF趋势确认与防守切换]]
- [[动量质量因子准入]]

~~~