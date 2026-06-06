---
type: 术语
term_id: TERM-20260603T000000Z-mig-TIEREDV252E3B
legacy_id: "tiered-v2（分层强度防守）"
migration_status: migrated_unverified
evidence_level: legacy_raw
source_old_path: 'E:\【笔记库】\量化研究库\📖 概念\tiered-v2（分层强度防守）.md'
source_old_relative_path: '📖 概念/tiered-v2（分层强度防守）.md'
owner: mig
created_at: 2026-06-05T12:00:00Z
updated_at: 2026-06-05T12:00:00Z
tags: [旧库迁移, 未复核]
---

# tiered-v2（分层强度防守）

## 迁移说明

- 迁移状态：机械迁移，尚未人工复核。
- 原旧库 ID：`tiered-v2（分层强度防守）`
- 来源旧库路径：`E:\【笔记库】\量化研究库\📖 概念\tiered-v2（分层强度防守）.md`
- 新库 ID：`TERM-20260603T000000Z-mig-TIEREDV252E3B`
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
aliases: [tiered-v2, 分层强度防守, tiered_v2]
status: 实盘
related_strategies: ETF双池动量轮动
tags:
  - 概念/策略组件
  - 防守端
~~~
## 旧库原文

~~~markdown
# tiered-v2（分层强度防守）

## 定义

tiered-v2 是当前 ETF 双池动量轮动的**防守强度分层系统**。在 [[B3 gate]] 确认风险后，它根据风险信号的持续时间和衰竭程度，将防守分为三档——而不是对所有风险日一律降仓到相同水平。

## 三层分级规则

```
B3 gate active → 进入 tiered-v2 判断

normal（普通风险）：
  gate active 但不满足 strong_risk
  → 最终 cap = 80%

strong_risk（强风险）：
  cum_days ≥ 10               ← 全弱信号持续了至少 10 天
  AND median_ret ≤ 0          ← 中位收益仍是负的
  AND top5_exhausted ≥ 4      ← Top5 中至少 4 个在衰竭
  → 最终 cap = 70%

extreme_risk（极端风险）：
  strong_risk 成立
  AND (median_ret ≤ -0.015 OR ma20_breadth ≤ 0.25)  ← 严重恶化
  → 最终 cap = 60%
```

## 为什么分三档而不是两档

| 档位 | 适用场景 | 不适用场景 |
|------|---------|-----------|
| cap80 | 市场轻微走弱 | 深度恶化时防守不足 |
| cap70 | 持续走弱 + 强势 ETF 也在跌 | 只是短期调整时过度防守 |
| cap60 | 极少数极端窗口（池内崩溃） | 长期低仓会拖累收益 |

**关键设计**：极端层用 OR 逻辑而非 AND——只有 `median_ret 深度恶化` **或** `广度极度萎缩` 之一满足即可。这比 tiered-v1（被淘汰的前身）的 AND 逻辑更敏感，能在 2024 主回撤窗口和 2025-04 冲击窗口中生效。

## 四段回测表现

| | 复合收益 | 最大回撤 | 相对 B3-gate-cap80 | 动作日胜率 |
|---|---|---|---|---|
| tiered-v2 | +1468% | -27.13% | +117pp, +2.88pp | 77.3% |

## 实盘状态

- **MiniQMT v19**：默认启用（`ENABLE_B3_GATE_TIERED_V2=1`）
- **启动审计**：21/21 通过
- **影子观察**：关闭（`SHADOW=0`，交易实盘生效）

## 相关概念

- [[B3 gate]] — tiered-v2 的上游模块
- [[B3全弱信号]] — 原始风险信号
- [[median_ret（中位收益）]] — 分层依据
- [[ma20_breadth（广度）]] — 分层依据
- [[limited2]] — 旧版方案，被 tiered-v2 取代
- [[tiered-v1]] — 已淘汰的前身

## 相关决策

- [[D20260601-R010B4-tiered-v2四段验证通过]]
- [[D20260602-R010B4-tiered-v2实盘启用]]

~~~