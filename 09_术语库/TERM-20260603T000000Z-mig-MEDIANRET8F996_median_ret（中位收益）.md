---
type: 术语
term_id: TERM-20260603T000000Z-mig-MEDIANRET8F996
legacy_id: "median_ret（中位收益）"
migration_status: migrated_unverified
evidence_level: legacy_raw
source_old_path: 'E:\【笔记库】\量化研究库\📖 概念\median_ret（中位收益）.md'
source_old_relative_path: '📖 概念/median_ret（中位收益）.md'
owner: mig
created_at: 2026-06-05T12:00:00Z
updated_at: 2026-06-05T12:00:00Z
tags: [旧库迁移, 未复核]
---

# median_ret（中位收益）

## 迁移说明

- 迁移状态：机械迁移，尚未人工复核。
- 原旧库 ID：`median_ret（中位收益）`
- 来源旧库路径：`E:\【笔记库】\量化研究库\📖 概念\median_ret（中位收益）.md`
- 新库 ID：`TERM-20260603T000000Z-mig-MEDIANRET8F996`
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
type: 概念
aliases: [median_ret, 中位收益, 池中位收益]
status: 生效
tags:
  - 概念/指标
  - 市场状态
~~~
## 旧库原文

~~~markdown
# median_ret（中位收益）

## 定义

median_ret 是候选 ETF 池中所有 ETF 近期收益的**中位数**。反映"市场整体是向上还是向下"。

## 公式

```text
median_ret = median(池内每只 ETF 的近期收益率)
```

具体使用的收益窗口取决于上下文——B3 gate 中使用的是与全弱信号同周期的收益口径。

## 在策略中的用途

| 模块 | 如何使用 | 阈值 |
|------|---------|------|
| [[B3 gate]] gate 确认 | `median_ret ≤ 0` → 整体走弱，gate 通过 | ≤ 0 |
| [[tiered-v2（分层强度防守）]] strong 条件 | `median_ret ≤ 0` → 不转正，持续走弱 | ≤ 0 |
| [[tiered-v2（分层强度防守）]] extreme 条件 | `median_ret ≤ -0.015` → 深度恶化 | ≤ -0.015 |
| 低 median_ret 线索（非线性仓位） | `median_ret ≤ -0.01` 且 B3 active 时降仓有局部正信号 | ≤ -0.01 |

## 为什么用中位数而非均值？

均值会被少数几只极端涨跌 ETF 拉偏。中位数是"大多数 ETF 的表现"——更能代表市场整体的方向。

## 正值 vs 负值的含义

```
median_ret > 0    → 大部分 ETF 在涨，选股有价值
median_ret = 0    → 涨跌各半，选股难度大
median_ret < 0    → 大部分在跌，市场环境差
median_ret < -0.01 → 全面走弱，极少数 ETF 能独善其身
```

## 相关概念

- [[ma20_breadth（广度）]] — 另一个 gate 确认指标，两者 OR 逻辑互补
- [[dispersion20]] — 与 median_ret 配对使用：如果 median_ret 低且 dispersion20 高，说明仍有选股空间
- [[B3 gate]]
- [[tiered-v2（分层强度防守）]]

~~~