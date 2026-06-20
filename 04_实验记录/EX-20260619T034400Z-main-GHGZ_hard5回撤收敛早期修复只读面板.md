---
type: 实验记录
ex_id: EX-20260619T034400Z-main-GHGZ
rd_id: RD-20260605T133318Z-main-H6V3
status: completed
stage: readonly_completed_case_positive_but_controls_not_clean_revise_to_true_path
owner: main
created_at: 2026-06-19T03:44:00Z
updated_at: 2026-06-19T04:08:00Z
strategy_id: DP00-current-live-hard5-tiered-v2
module_type: 核心轮动过热误杀诊断
decision_ids: []
lit_ids:
  - LIT-20260605T133336Z-main-67C4
  - LIT-20260614T112631Z-main-VY4K
  - LIT-20260603T000000Z-mig-2014DAFROGINTHEPANB412A
  - LIT-20260614T112631Z-main-A9BK
  - LIT-20260617T220410Z-main-RDHA
idea_ids:
  - MECH-20260619T025934Z-main-DQUM
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths:
  - scripts/research/analyze_ghgz_hard5_early_repair_panel.py
result_paths:
  - results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T034400Z-main-GHGZ/hard5_early_repair_panel/
summary_paths:
  - results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T034400Z-main-GHGZ/hard5_early_repair_panel/early_repair_rule_summary.csv
  - results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T034400Z-main-GHGZ/hard5_early_repair_panel/early_repair_random_control_summary.csv
  - results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T034400Z-main-GHGZ/hard5_early_repair_panel/early_repair_case_panel.csv
  - results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T034400Z-main-GHGZ/hard5_early_repair_panel/summary.json
quality_gate: readonly_completed_not_strategy_validation_controls_not_clean
subagent_call_ids:
  - SUB-EXEMPT-20260619T041500Z-main-EARLY-REPAIR
subagent_exemption: 当前工具环境没有符合研究库规范的可用子代理调用入口，且系统工具说明限制未显式要求时不应派生多代理；本轮由主控执行并复核。
tags: [双池轮动, hard5, score-cap, 早期修复, 回撤收敛, 普反广度, 只读面板]
---

# hard5回撤收敛早期修复只读面板

## 关联链接

- 研究方向：[[02_研究方向/RD-20260605T133318Z-main-H6V3_双池轮动score过热拥挤机制模块|双池轮动 score 过热拥挤机制模块]]
- 前置实验：[[04_实验记录/EX-20260619T032822Z-main-B3HP_hard5反弹修复误杀只读面板|B3HP hard5 反弹修复误杀只读面板]]
- 机制卡：[[07_因子数据灵感/03_机制/MECH-20260619T025934Z-main-DQUM_hard5过热概率与反弹修复状态框架|hard5 过热概率与反弹修复状态框架]]
- 来源文献或灵感：[[06_文献资料/00_待处理/LIT-20260605T133336Z-main-67C4_score过热拥挤机制文献映射|score 过热拥挤机制文献映射]]；[[06_文献资料/00_待处理/LIT-20260614T112631Z-main-VY4K_动量崩溃保护Daniel Moskowitz 2016|动量崩溃保护 Daniel Moskowitz 2016]]；[[06_文献资料/00_待处理/LIT-20260614T112631Z-main-A9BK_52周高点动量George Hwang 2004|52 周高点动量 George Hwang 2004]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：B3HP 发现 `ret5` 已转正的修复规则完全没有样本，那么真正的 hard5 误杀是否发生在更早阶段：标的仍然有明显回撤、`ret5` 甚至仍为负，但候选池广度已经修复，且标的从近端低点开始抬升。

我们原本预计：早期修复样本会很少，不能证明策略有效；如果这个方向有价值，应该表现为 H5/H10 相对 hard5 替代标的为正，且无广度或无回撤收敛的对照明显更差。

实际看到：`early_repair_core` 只有 8 个事件，H10 相对 hard5 替代为正，但 H5 均值为负；`early_repair_strict` 5 个事件表现强，但样本太少。更关键的是，`drawdown_no_breadth_control` 和同日随机 Top10 也能复制一部分 H10 正收益，说明这条日频事件阈值路线还不能区分“真正修复”与“市场普反 beta”。

这说明：用户观察到的反弹误杀问题是真问题，但不能靠当前这组 `drawdown_narrowing/ret5_negative + breadth` 日频阈值直接解决。下一步必须转向真实持仓路径：区分已经持有的亏损修复、刚卖出后的回补、完全新买入追高，而不是继续只看 raw Top1 高分事件。

但还不能说明：本实验只是只读事件面板，不包含真实持仓、真实换仓成本、实盘 13:09 tick，也不能直接修改 hard5。

下一步要做：新开真实持仓路径误杀索引实验，优先寻找 `held_repair` 和 `rebuy_repair` 事件；本实验不进入 formal、不改 hard5、不扩早期修复阈值网格。

## 2. 研究背景

B3HP 的核心发现是：`conservative_repair` 和 `balanced_repair` 均 0 事件，说明“已经反弹到 ret5 为正”的定义太晚或太窄。用户描述的场景更像“持仓还没完全修复亏损，但市场已经普反，hard5 却因为近端 score/状态把它当过热处理”。因此本实验把修复条件改成：

- 当前仍有明显回撤；
- 候选池或同日 Top10 出现普反广度；
- 标的从近端低点抬升，或当前回撤比 3 日前收敛；
- `ret5` 允许仍为负。

本实验承认它是 B3HP 派生探索，因此只能给出 L1 诊断，不能作为 formal 或交易规则。

## 3. 实验前假设

如果 hard5 误杀的真实形态是“早期修复”而不是“已转正修复”，则 `score>5`、回撤仍明显、`ret5<0`、候选池普反广度高、且存在低点抬升或回撤收敛的事件，应在 H5/H10 上相对 hard5 替代标的更好。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：`early_repair_core` 在 H5/H10 的均值为正，H10 胜率高于 `60%`；由于样本预期小于 30，只能作为案例证据。
- 交易行为：`cap30/hard5_next_best` 和 `cap30/keep_cash` 的 H10 不应明显为负；若只有 full allow 好，小预算不好，则不能继续。
- 风险表现：H10 左尾不能比 `drawdown_no_breadth_control` 更差；false allow loss 不应集中出现。
- 分段表现：若全部来自 2026_to_date，只能标记为近端案例，不支持泛化。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| hard5_next_best | 当前 hard5 拦截后的实际替代标的，是主基准 | `${QUANT_PLATFORM_ROOT}/results/v2/research/R010-A16/hot_state_panel/hot_state_event_panel.csv` |
| keep_cash | 剩余预算转现金，检验小预算是否过度依赖 hard5 替代弱 | 本实验脚本派生 |
| same_day_random_top10 | 同日 Top10 随机候选，检验市场普反 beta | 本实验脚本派生 |
| drawdown_no_breadth_control | 有回撤和 ret5<0，但无普反广度 | 本实验脚本派生 |
| breadth_no_narrowing_control | 有回撤和普反广度，但没有低点抬升或回撤收敛 | 本实验脚本派生 |
| chase_hot_control | 无明显回撤、只是高分上涨 | 本实验脚本派生 |

## 6. 预注册规则矩阵

| 规则 | 定义 | 用途 |
| --- | --- | --- |
| early_repair_core | `score>5`、`drawdown_abs>=8%`、`ret5<0`、`top10_breadth_ret5>=65%`、`low_to_current_10>=2% or drawdown_narrowing_3d>=1.5%`、`jump_ratio20<=55%` | 主规则，验证亏损仍在但开始修复 |
| early_repair_strict | `score>5`、`drawdown_abs>=10%`、`ret5<0`、`top10_breadth_ret5>=65%`、`low_to_current_10>=3% or drawdown_narrowing_3d>=3%`、`jump_ratio20<=45%` | 高置信但预计样本更少 |
| early_repair_score5_7 | `5<score<=7`、`drawdown_abs>=8%`、`ret5<0`、`top10_breadth_ret5>=65%`、`low_to_current_10>=2% or drawdown_narrowing_3d>=1.5%` | 检查是否只在中等过热分数有效 |
| drawdown_no_breadth_control | `score>5`、`drawdown_abs>=8%`、`ret5<0`、`top10_breadth_ret5<55%`、有低点抬升或回撤收敛 | 广度负控 |
| breadth_no_narrowing_control | `score>5`、`drawdown_abs>=8%`、`ret5<0`、`top10_breadth_ret5>=65%`、无低点抬升且无回撤收敛 | 修复形态负控 |
| chase_hot_control | `score>5`、`drawdown_abs<8%` | 追高风险对照 |

预算档固定为 `hold_only_proxy`、`cap30`、`cap50`、`full_allow`；主观察为 `cap30`。剩余预算只报告 `hard5_next_best` 和 `keep_cash`，不在本轮模拟 `current_holding_rest`、`defensive_asset` 或 `pro_rata_topk`。

## 7. 竞争性解释

即使结果符合预期，也可能是：

- 样本极少，单个 2026 反弹窗口支配结果。
- 同日随机 Top10 也能复制正收益，说明只是市场普反。
- hard5 替代标的刚好弱，原始高分标的不是因为早期修复而强。
- 日频 close 代理不等于实盘 13:09 可见信号。
- 没有真实持仓路径，无法区分续持和新买。

## 8. 证伪条件

出现以下情况，本假设不通过或只能作为案例库：

- `early_repair_core` 事件数低于 10：只做案例，不继续日频事件阈值。
- `early_repair_core` H5/H10 均值任一为负。
- `same_day_random_top10`、`drawdown_no_breadth_control` 或 `breadth_no_narrowing_control` 复制主规则收益。
- H10 左尾低于 `-8%`，或 false allow loss 数量超过样本的 `20%`。
- 结果集中在单一标的、单一月份或单一主题。

## 9. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 预注册要求 | 特征只用事件日及之前日线；forward return 只作标签 |
| 信号生成和成交价格不存在同 bar 泄漏 | 预注册限制 | 本实验是 daily close 只读代理，不能交易化 |
| 股票池或 ETF 池不存在未来成分泄漏 | 待检查 | 复用 A11/A16 事件面板和日线查询逻辑 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 不使用财务、宏观或估值字段 |
| Shadow 或观察信号未被当成默认交易信号 | 通过预注册 | 不生成策略配置，不改默认 hard5 |

负控或错位检查：

- 同日随机 Top10。
- `drawdown_no_breadth_control`。
- `breadth_no_narrowing_control`。
- 若结果强，再另开 `shift_prev1/shift_next1` 状态错位复核。

## 10. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 是 | 3 个主规则、3 个对照、4 个预算档 |
| 样本内、验证集、样本外划分清楚 | 弱 | 本轮只读样本有限，只能输出 2024/2025/2026_to_date |
| 邻近参数敏感性合理 | 待检查 | 不扩网格，仅看 core/strict/score5_7 |
| 成本、滑点或换手扰动已检查 | 否 | 事件级只读，不评估交易成本 |
| 已做消融或负控 | 预注册 | 随机 Top10、无广度、无收敛、追高 |
| 未只报告最优结果 | 预注册要求 | 输出全部规则和预算档 |

证据等级：`L1` 只读案例面板；不能 promote。

## 11. 子代理调用记录

适配判断：适合调用子代理做路径核对和结果复核；实际调用受工具规则限制。

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：当前工具环境没有符合研究库规范的可用子代理调用入口，且系统工具说明限制未显式要求时不应派生多代理；主控：gpt-5-codex；时间：2026-06-19T04:15:00Z
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-EXEMPT-20260619T041500Z-main-EARLY-REPAIR | 无 | SUBTASK-HARD5-EARLY-REPAIR-PANEL | 无 | 2026-06-19T04:15:00Z | B3HP 实验与结果、H6V3、MECH-DQUM、A16/A11 平台结果 | 本实验记录、平台脚本、台账 | WSL 前台执行 GHGZ 只读面板并保存 tee 日志 | 只读案例面板，不判断 promote | 样本极小，随机负控和无广度负控复制部分收益 | 已复核；结论为 revise_to_true_path | 不支持阈值升级，支持转真实持仓路径预注册 |

台账行：已同步。

## 12. 执行记录

### 平台配置

```text
${QUANT_PLATFORM_ROOT}/scripts/research/analyze_ghgz_hard5_early_repair_panel.py
```

### 运行命令

```bash
cd '${QUANT_PLATFORM_ROOT}' && mkdir -p 'results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T034400Z-main-GHGZ/hard5_early_repair_panel' && PYTHONPATH=src python3 -m py_compile scripts/research/analyze_ghgz_hard5_early_repair_panel.py && PYTHONPATH=src PYTHONUNBUFFERED=1 python3 scripts/research/analyze_ghgz_hard5_early_repair_panel.py 2>&1 | tee 'results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T034400Z-main-GHGZ/hard5_early_repair_panel/run_ghgz_early_repair_panel.log'
```

### 可见进度与日志

- 是否过程可见：是，计划使用 WSL 前台命令和 tee 保存日志。
- 日志路径：`results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T034400Z-main-GHGZ/hard5_early_repair_panel/run_ghgz_early_repair_panel.log`
- 查看进度命令：`Get-Content -Tail 50 ${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T034400Z-main-GHGZ/hard5_early_repair_panel/run_ghgz_early_repair_panel.log`
- 异常判断：脚本退出码非 0、输出缺 summary.json、主规则和对照均为 0 事件视为执行失败。
- 后台回测豁免：不适用，非后台，非正式回测。

### 结果路径

```text
${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T034400Z-main-GHGZ/hard5_early_repair_panel/
```

## 13. 实际观察

GHGZ 扫描 212 个 high-score hard5 事件。主规则 `early_repair_core` 命中 8 个事件，低于预注册的 10 个最低案例门槛；`early_repair_strict` 命中 5 个事件；`early_repair_score5_7` 只有 1 个事件，不能解释 hard5 主要误杀。

核心结果如下：

| 规则 | 预算/剩余路由 | 事件数 | H5 相对 hard5 | H10 相对 hard5 | H10 胜率 | H10 左尾 p05 | false allow H10 |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| early_repair_core | hold_only_proxy / hard5_next_best | 8 | -0.10pp | +8.38pp | 62.50% | -14.91pp | 2 |
| early_repair_core | cap30 / hard5_next_best | 8 | -0.03pp | +2.51pp | 62.50% | -4.47pp | 1 |
| early_repair_strict | hold_only_proxy / hard5_next_best | 5 | +2.98pp | +15.74pp | 80.00% | -0.38pp | 0 |
| early_repair_strict | cap30 / hard5_next_best | 5 | +0.89pp | +4.72pp | 80.00% | -0.11pp | 0 |
| drawdown_no_breadth_control | hold_only_proxy / hard5_next_best | 16 | +3.54pp | +4.59pp | 72.73% | -17.79pp | 2 |
| drawdown_no_breadth_control | cap30 / hard5_next_best | 16 | +1.06pp | +1.38pp | 72.73% | -5.34pp | 2 |
| chase_hot_control | cap30 / hard5_next_best | 167 | +0.45pp | +0.27pp | 56.69% | -7.19pp | 18 |

随机对照同样提示不能直接升级：

- `same_day_random_top10_all_high_score_events` 全样本 H10 均值 `+1.70pp`、胜率 `56.02%`；其中 2026_to_date H10 均值 `+4.26pp`、胜率 `66.67%`。
- `same_day_random_top10_ret5neg_dd8_breadth65` 10 个事件，H10 均值 `+3.55pp`、胜率 `70.00%`，但 H5 均值 `-3.90pp`。

## 14. 支持证据

- `early_repair_strict` 虽只有 5 个事件，但 H5/H10 同时为正，H10 左尾接近 0，说明“回撤更深、确有低点抬升或回撤收敛、且跳涨占比不高”的案例有研究价值。
- `early_repair_core` 的 H10 为正，说明用户提出的“反弹没吃满”在事件标签上能被部分捕捉。
- `chase_hot_control` 167 个事件的 H10 左尾更差，说明不应把所有高分上涨都当作可追状态；hard5 的保护价值仍存在。

## 15. 反对证据

- `early_repair_core` 事件数只有 8，且 H5 均值为负，触发预注册证伪条件。
- `drawdown_no_breadth_control` 16 个事件同样 H5/H10 为正，说明“普反广度”不是当前定义下的干净解释变量。
- 同日随机 Top10 在高分全体和 `ret5<0 + drawdown>=8% + breadth>=65%` 子集里都能复制一部分 H10 正收益，不能排除市场普反 beta 或样本窗口效应。
- `breadth_no_narrowing_control` 只有 2 个事件，不足以支持“回撤收敛”这个形态变量独立有效。

## 16. 偏差诊断

本实验继续沿用 A16/A11 的 raw Top1 high-score 事件，因此更像“候选事件诊断”，不是用户真正描述的“已持有 A 从亏损中修复却被 hard5 阻断”。这会造成两个偏差：

- 把已持有续持、卖出后回补、完全新买入追高混在一起；
- 用同日 Top10 广度解释反弹，容易把全市场 beta 当成修复 alpha。

因此 GHGZ 的最大价值不是给出放行阈值，而是证明下一步必须进入真实持仓路径。

## 17. 研究判断

建议状态：`revise_to_true_holding_path`

理由：早期修复定义比 B3HP 的 `ret5` 已转正定义更接近用户观察，但日频 high-score 事件样本太少、H5 不稳、负控不干净。当前不能进入 formal、shadow、observe 或默认策略；也不能在 GHGZ 结果上继续扩 `drawdown/breadth/narrowing/jump` 阈值网格。

## 18. 下一步

新开真实持仓路径误杀索引只读实验。最小要求：

- 从真实 hard5 路径或可审计 backtest logs/trades 中抽取当前持仓、被卖出/降仓、hard5 替代标的和后续 H5/H10；
- 分开标注 `held_repair`、`rebuy_repair`、`new_buy_repair`、`chase_hot`；
- 先只验证 `hold_only` 与 `cap30`，剩余预算比较 `hard5_next_best`、`keep_cash`、`current_holding_rest`；
- 如果 `held_repair` 有效而 `new_buy_repair` 无效，后续只能研究持仓续持例外，不能推广为追高买入。
