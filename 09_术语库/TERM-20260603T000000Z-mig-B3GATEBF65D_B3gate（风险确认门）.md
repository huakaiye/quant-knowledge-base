---
type: 术语
term_id: TERM-20260603T000000Z-mig-B3GATEBF65D
legacy_id: "B3 gate"
migration_status: reviewed_readonly_baseline_skeleton
evidence_level: L2_readonly_platform_review
source_old_path: 'E:\【笔记库】\量化研究库\📖 概念\B3 gate.md'
source_old_relative_path: '📖 概念/B3 gate.md'
owner: mig
created_at: 2026-06-05T12:00:00Z
updated_at: 2026-06-08T01:12:30Z
tags: [旧库迁移, 已复核, 防御骨架]
---

# B3 gate（风险确认门）

## 迁移说明

- 迁移状态：已由 [[04_实验记录/EX-20260608T005518Z-main-XK5W_B3Gate与TieredV2旧证据复核|XK5W]] 只读复核。
- 原旧库 ID：`B3 gate`
- 来源旧库路径：`E:\【笔记库】\量化研究库\📖 概念\B3 gate.md`
- 新库 ID：`TERM-20260603T000000Z-mig-B3GATEBF65D`
- 证据等级：L2_readonly_platform_review
- 结论边界：B3 gate 被新库采纳为防御仓位骨架的风险确认门；它只约束全弱持续状态下的风险仓，不是独立 alpha，也不代表旧实盘开关已通过当前生产 promote。

## 关联链接

- 迁移总卡：[[11_迁移暂存/MIG-20260605T120000Z-mig-BATCH_旧库批量迁移总卡|旧库批量迁移总卡]]
- 关联方向：待复核
- 关联策略：待复核
- 迁移规范：[[08_方法论/研究库迁移规范|研究库迁移规范]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 新库复核：[[04_实验记录/EX-20260608T005518Z-main-XK5W_B3Gate与TieredV2旧证据复核|B3Gate 与 TieredV2 旧证据复核]]
- 当前决策：[[05_研究决策/DEC-20260608T005556Z-main-U7FN_B3Gate与TieredV2复核后保留为防御骨架决策|B3Gate 与 TieredV2 保留为防御骨架]]

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
aliases: [gate, B3gate, 风险门控, 确认门]
status: 实盘
related_strategies: ETF双池动量轮动
tags:
  - 概念/策略组件
  - 防守端
~~~
## 旧库原文

~~~markdown
# B3 gate（风险确认门）

## 定义

B3 gate 是 B3 全弱信号的**二次确认过滤器**。B3 raw 信号噪音大（122 天触发，其中近半可能是假警报），gate 在 raw 信号之上加一层"市场整体是否也在走弱"的检查，过滤掉只是"短暂喘息"的误触发。

## 确认条件

```text
B3 raw 通过（cum_days ≥ 8 或 consecutive_days ≥ 3）
AND
(
  median_ret ≤ 0           ← 池内中位收益为负（整体在跌）
  OR
  ma20_breadth ≤ 0.40      ← 池内不到 40% 的 ETF 在 20 日均线上方
)
```

**OR 逻辑的用意**：不需要两个条件同时满足——只要有一个亮红灯就确认风险。这样在"中位收益还好但广度已经崩了"或"广度还行但整体在跌"两种场景下都能捕获。

## 效果

| | gate 拦截（被过滤掉） | gate active（确认风险） |
|---|---|---|
| 历史天数 | 44 天 | 66 天 |
| 后续 10 日出现 -5% 下跌 | 8 天（18%） | 18 天（27%） |

Gate 有效地区分了高风险日和低风险日——被拦截的 44 天确实风险更低。

## Gate 通过后的动作

Gate active → 进入 [[tiered-v2（分层强度防守）]] 判断降仓力度：
- 普通风险 → cap80
- 强风险 → cap70
- 极端风险 → cap60

## 在当前策略中的位置

```
A2-slope004（选股）→ B3 全弱（候选信号）→ B3 gate（确认过滤）→ tiered-v2（强度分层）→ 最终仓位
```

## 相关概念

- [[B3全弱信号]] — gate 的输入信号
- [[tiered-v2（分层强度防守）]] — gate 通过后的强度分层
- [[median_ret（中位收益）]] — gate 的确认指标之一
- [[ma20_breadth（广度）]] — gate 的确认指标之二
- [[limited2]] — 旧版方案，被 gate 取代

## 相关决策

- [[D20260601-R010B3-gate成为当前主候选]]

~~~
