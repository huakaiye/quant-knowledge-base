---
type: 术语
term_id: TERM-20260604T000000Z-mig-B3GATETIEREDV2BAD04
legacy_id: "B3-gate-tiered-v2"
migration_status: migrated_unverified
evidence_level: legacy_raw
source_old_path: 'E:\【笔记库】\量化研究库\📖 概念\B3-gate-tiered-v2.md'
source_old_relative_path: '📖 概念/B3-gate-tiered-v2.md'
owner: mig
created_at: 2026-06-05T12:00:00Z
updated_at: 2026-06-05T12:00:00Z
tags: [旧库迁移, 未复核]
---

# B3-gate-tiered-v2（策略组件导航）

## 迁移说明

- 迁移状态：机械迁移，尚未人工复核。
- 原旧库 ID：`B3-gate-tiered-v2`
- 来源旧库路径：`E:\【笔记库】\量化研究库\📖 概念\B3-gate-tiered-v2.md`
- 新库 ID：`TERM-20260604T000000Z-mig-B3GATETIEREDV2BAD04`
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
aliases: [B3 gate tiered v2, tiered-v2, 分层防守]
topic_id: B3-gate-tiered-v2
status: 实盘
related_strategies: ETF双池动量轮动
tags:
  - 概念/策略组件
  - 概念/导航页
~~~
## 旧库原文

~~~markdown
# B3-gate-tiered-v2（策略组件导航）

> 这是一个**导航页**，汇总了 ETF 双池动量轮动防守系统的所有组件。每个概念有独立的详细页面。

## 组件链路

```
[[A2-slope004]]（选股端）
        ↓
[[B3全弱信号]]（原始风险检测）
        ↓
[[B3 gate]]（确认门控 — 过滤噪音）
        ↓
[[tiered-v2（分层强度防守）]]（强度分层 — 三层降仓）
        ↓
最终仓位
```

## 各组件独立页面

| 组件 | 状态 | 一句话 |
|------|------|--------|
| [[A2-slope004]] | 🟢 实盘 | 进攻增强底座，减少追高换仓 |
| [[B3全弱信号]] | 🟢 实盘 | 池内 Top5 ETF 趋势全线走弱时的候选风险信号 |
| [[B3 gate]] | 🟢 实盘 | 用 median_ret 和 ma20_breadth 过滤 B3 全弱中的假信号 |
| [[tiered-v2（分层强度防守）]] | 🟢 实盘 | 三层分级：normal cap80 / strong cap70 / extreme cap60 |

## 关键指标页面

| 指标 | 用途 |
|------|------|
| [[median_ret（中位收益）]] | 判断整体涨跌方向 |
| [[ma20_breadth（广度）]] | 判断趋势覆盖面 |

## 当前实盘状态

- **MiniQMT v19** 默认启用：`A2-slope004 + B3-gate-tiered-v2`
- **启动审计**：21/21 通过
- **首个交易日待核验**：B3 gate active 日志、tiered_level、tiered_effective_cap、目标仓位

## 研究总结

完整演进历史和四段数据见：[[R20260601-029_R010B4_B3Gate强度分层TieredV2预注册]] 与 [[D20260601-R010B4-tiered-v2四段验证通过]]。

## 相关决策

- [[D20260601-R010B3-gate成为当前主候选]]
- [[D20260601-R010B4-tiered-v2四段验证通过]]
- [[D20260602-R010B4-tiered-v2实盘启用]]

~~~