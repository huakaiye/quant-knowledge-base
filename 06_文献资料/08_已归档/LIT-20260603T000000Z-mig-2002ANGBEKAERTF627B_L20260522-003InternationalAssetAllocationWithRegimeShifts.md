---
type: 文献卡
lit_id: LIT-20260603T000000Z-mig-2002ANGBEKAERTF627B
legacy_id: "2002_Ang_Bekaert_状态转换资产配置"
migration_status: migrated_unverified
evidence_level: legacy_raw
source_old_path: 'E:\【笔记库】\量化研究库\📚 文献\2002_Ang_Bekaert_状态转换资产配置.md'
source_old_relative_path: '📚 文献/2002_Ang_Bekaert_状态转换资产配置.md'
owner: mig
created_at: 2026-06-05T12:00:00Z
updated_at: 2026-06-05T12:00:00Z
tags: [旧库迁移, 未复核]
---

# L20260522-003 International Asset Allocation With Regime Shifts

## 迁移说明

- 迁移状态：机械迁移，尚未人工复核。
- 原旧库 ID：`2002_Ang_Bekaert_状态转换资产配置`
- 来源旧库路径：`E:\【笔记库】\量化研究库\📚 文献\2002_Ang_Bekaert_状态转换资产配置.md`
- 新库 ID：`LIT-20260603T000000Z-mig-2002ANGBEKAERTF627B`
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
literature_id: L-2002-Ang-001
title: International Asset Allocation With Regime Shifts
authors: [Andrew Ang, Geert Bekaert]
year: 2002
journal: Review of Financial Studies
doi: 10.1093/rfs/15.4.1137
url: https://academic.oup.com/rfs/article/15/4/1137/1568247
source_tags:
  - "[[市场状态识别]]"
  - "[[状态切换]]"
execution_tags:
  - "[[市场环境过滤]]"
  - "[[仓位管理]]"
asset_class: [股票, 多资产]
applicable_markets: [ETF, 多资产组合]
extracted_modules:
  - "[[市场状态识别与切换门控]]"
status: 已拆解
tags:
  - 研究/文献
  - 策略/市场状态
~~~
## 旧库原文

~~~markdown
# L20260522-003 International Asset Allocation With Regime Shifts

## 基本信息

| 项目 | 内容 |
| --- | --- |
| 论文 | International Asset Allocation With Regime Shifts |
| 作者 | Andrew Ang, Geert Bekaert |
| 期刊 | Review of Financial Studies, 2002 |
| DOI | `10.1093/rfs/15.4.1137` |
| 来源 | https://academic.oup.com/rfs/article/15/4/1137/1568247 |

## 核心观点

论文讨论带状态转换的资产配置问题。对当前项目最有价值的不是直接上复杂模型，而是把“状态有持续性、状态切换有概率、坏状态下相关性和波动率上升”这些原则引入策略门控。

## 对当前项目的启发

市场状态识别不应每天完全独立判断。状态需要有持续性和切换成本：

- 进入状态需要确认。
- 退出状态也需要确认。
- 进入和退出阈值应不同，避免状态来回跳。
- 如果使用概率模型，只能用在线过滤概率，不能用事后平滑概率。

## 可落地信号

| 信号 | 计算口径 | 可用时点 | 用途 |
| --- | --- | --- | --- |
| 状态持续天数 | 当前状态连续保持天数 | 实时状态机内部变量 | 限制过快切换 |
| 进入确认 | 连续2日满足条件，或强信号单日触发 | 信号日当时 | 降低假突破 |
| 退出确认 | 退出阈值弱于进入阈值，例如广度从高降到中才退出 | 信号日当时 | 降低抖动 |
| 状态置信度 | 多个信号投票得分 | 信号日当时 | 决定是否只降权而非切换 |

## R010 候选规则

```text
state_today = f(过去数据)
if 新状态置信度 >= 0.70 and 连续确认 >= 2:
    切换状态
elif 新状态置信度 >= 0.90:
    允许单日强制切换
else:
    保持旧状态
```

## 风险与限制

- HMM 或 Markov switching 很容易无意中使用事后状态，必须区分 filtered probability 和 smoothed probability。
- 对当前阶段，优先使用规则状态机；复杂概率模型放到第二阶段。

## 关联模块

- [[市场状态识别与切换门控]]
- [[波动率缩放仓位]]
- [[ETF趋势确认与防守切换]]

~~~