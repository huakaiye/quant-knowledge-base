---
type: 术语
term_id: TERM-20260603T000000Z-mig-MA20BREADTH3E9C6
legacy_id: "ma20_breadth（广度）"
migration_status: migrated_unverified
evidence_level: legacy_raw
source_old_path: 'E:\【笔记库】\量化研究库\📖 概念\ma20_breadth（广度）.md'
source_old_relative_path: '📖 概念/ma20_breadth（广度）.md'
owner: mig
created_at: 2026-06-05T12:00:00Z
updated_at: 2026-06-05T12:00:00Z
tags: [旧库迁移, 未复核]
---

# ma20_breadth（池内广度）

## 迁移说明

- 迁移状态：机械迁移，尚未人工复核。
- 原旧库 ID：`ma20_breadth（广度）`
- 来源旧库路径：`E:\【笔记库】\量化研究库\📖 概念\ma20_breadth（广度）.md`
- 新库 ID：`TERM-20260603T000000Z-mig-MA20BREADTH3E9C6`
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
aliases: [ma20_breadth, 广度, 均线广度, 池内广度]
status: 生效
tags:
  - 概念/指标
  - 市场状态
~~~
## 旧库原文

~~~markdown
# ma20_breadth（池内广度）

## 定义

ma20_breadth 是候选 ETF 池中**收盘价在 20 日均线上方的 ETF 占比**。表达"上升趋势的覆盖面有多广"。

## 如何看这个指标

| 数值 | 含义 | 策略含义 |
|------|------|---------|
| > 70% | 普遍上升 | 大部分 ETF 趋势健康 |
| 40% – 70% | 分化状态 | 选股变得重要 |
| 25% – 40% | 广度萎缩 | B3 gate extreme 条件之一——池内不到 1/4 在均线上方 |
| < 25% | 极度萎缩 | 极少数 ETF 还有趋势，触发 tiered-v2 extreme cap60 |

## 在策略中的用途

| 模块 | 如何使用 | 阈值 |
|------|---------|------|
| [[B3 gate]] gate 确认 | `ma20_breadth ≤ 0.40` → gate 通过 | ≤ 0.40 |
| [[tiered-v2（分层强度防守）]] extreme 条件 | `ma20_breadth ≤ 0.25` → extreme | ≤ 0.25 |

## 为什么和 median_ret 是 OR 关系

两种不同类型的恶化场景需要不同指标来识别：

```
场景A：广度崩了但中位收益还好
  → ETF 仍在涨但只有少数在涨（龙头集中，多数失速）
  → median_ret 不报警但 ma20_breadth 报警 ✅

场景B：中位收益负了但广度还好
  → 大部分 ETF 还在均线上但整体在跌（缓跌而非崩盘）
  → ma20_breadth 不报警但 median_ret 报警 ✅
```

OR 逻辑保证两种场景都能被捕获。

## 相关概念

- [[median_ret（中位收益）]] — 互补指标，OR 逻辑
- [[ret20_breadth]] — 类似指标但用正收益而非均线，更短期
- [[B3 gate]]
- [[tiered-v2（分层强度防守）]]

~~~