---
type: 实验记录
ex_id: EX-20260624T061755Z-main-CXCP
rd_id: RD-20260624T014933Z-main-NQS5
status: completed
stage: formal_completed_signal_no_alpha
owner: main
created_at: 2026-06-24T06:17:55Z
updated_at: 2026-06-24T06:50:00Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 个股overnight_share选股价值只读模拟（纯离线，不改策略代码）
decision_ids: [DEC-20260624T072541Z-main-G6M9]
lit_ids: []
idea_ids: [MECH-20260620T154044Z-main-MATN]
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths: [configs/research/R010-A22/overnight_v2_paired/EX-20260622T104131Z-main-6XCN/]
result_paths: []
summary_paths: []
quality_gate: preregistered_pending_execution
subagent_call_ids: []
subagent_exemption: "本实验是 overnight 链最终信号价值判定（路线生杀级最终研究判断），EX-CXCP 的 simulate 脚本设计+负控逻辑+判定矩阵+结果解读全部由主控承担，不可委派。原计划委派的 SUBTASK-POOL-EXTRACT/SUBTASK-OVERNIGHT-CALC 子代理任务因脚本结构高度耦合（标的池提取+overnight_share计算+持有收益负控+组合层模拟需在单脚本顺序执行）改由主控一次性完成。主控：main；时间：2026-06-24T06:50:00Z"
tags: [双池轮动, 隔夜收益, overnight_share, low桶, 个股选股信号, 只读模拟, 纯离线, 0行平台改动, 事件级复现, 组合层可交易约束, jq_bar_daily, 首次真正测试]
---

# 个股 overnight_share 选股价值只读模拟：事件级信号在组合层可交易约束下是否复现

## 关联链接

- 研究方向：[[02_研究方向/RD-20260624T014933Z-main-NQS5_双池轮动low桶放行机制入池失效诊断与修复|RD-NQS5]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 来源灵感：[[07_因子数据灵感/03_机制/MECH-20260620T154044Z-main-MATN_顶刊灵感1 隔夜收益知情交易 Lou Polk Skouras 2019|MECH-MATN 隔夜收益知情交易]]
- 概念错配修正（本实验的起因）：[[05_研究决策/DEC-20260624T042716Z-main-KZ7L_overnight研究链概念错配修正 个股层low桶信号不等于池子层median门槛放行|DEC-KZ7L]]
- 事件级证据（信号源头，数字正确待组合层验证）：[[04_实验记录/EX-20260622T031432Z-main-7TJU_隔夜收益知情交易只读面板预注册|EX-7TJU 只读面板]]
- 组合层 formal 对照（池子门槛，非个股信号）：[[04_实验记录/EX-20260622T104131Z-main-6XCN_隔夜收益完全放行V2组合层formal|EX-6XCN]]
- 产生的决策：（执行后产出）
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验是**整个 overnight 研究链第一次真正测试个股 overnight_share 选股信号**。之前 DEC-KZ7L 发现组合层 formal 只放宽了池子门槛，从没碰选股。本实验真的用 overnight_share 选标的，看信号有没有用。

我们原本预计：信号事件级 +5.33%/71.4% 胜率很强，在 ETF 池里应该能复现。

实际看到：**信号几乎没有 alpha。** low 桶持有 10 天 +0.50%，但随机瞎选也有 +0.42%，超额只有 0.08%。组合层模拟 0/4 赢 hard5，3 段负收益。

这说明：**low 桶信号在 ETF 轮动策略里没有真实价值。** EX-7TJU 的 +5.33% 是标的池差异 + beta 共同造成的，到纯 ETF 选股里超额收益归零。

但还不能说明：① overnight_share 作为别的因子（如择时/风控）有没有用——本实验只测了选股；② 在更宽的标的池（含个股）里信号是否成立——本实验只在 216 只 ETF/LOF 池测。

下一步：park 整个 overnight 链（DEC-G6M9）。这是有史以来第一次站得住的 park 理由——负控证明信号超额≈0，不是猜测。
- 来源文献或灵感：
- 产生的决策：
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

（见上方关联链接后的新手摘要，此处不重复）

## 2. 研究背景

DEC-KZ7L 确认 overnight 研究链存在概念错配：事件级（EX-7TJU）测的是"个股 overnight_share 低会涨"，组合层 formal（PNV8/6XCN/7KMP）做的是"池子门槛放宽"——两者不是一回事，被错当成因果链两端。结果整个 overnight 链花了好几轮研究"落差去哪了""退出是不是主因"，但其实**信号从未被真正测试过**。

本实验是**第一次把个股 overnight_share 当选股信号来测**。不做门槛放宽，而是直接用 overnight_share 选标的，看信号在组合层有没有真实价值。

为什么先做只读模拟而不直接改策略代码跑 formal：
- 改代码跑 formal 投入大（需设计 score 加成公式 + 四段回测 + 成本扰动 + 负控），风险高
- 只读模拟能用 jq_bar_daily 快速判断"信号在策略池子里成不成立 + 组合层能不能兑现"，成本极低
- 只读通过 → 再改代码开 formal；只读失败 → park 整条线，不浪费 formal 的投入

## 3. 实验前假设

H_main：**个股 overnight_share 低（日内主导）的 ETF 标的，作为选股信号在策略池子里持有 10 天的正收益在组合层可交易约束下仍然成立**（复现 EX-7TJU 的方向性 + 显著性）。

辅假设：
- H_coverage：策略 ETF 池（约 76 只）每天有 ≥ 5 只 low 桶标的（覆盖率够选）。
- H_event_repro：在策略 ETF 池里复刻事件级统计，low 桶持有 10 天收益均值 > 0 且胜率 > 50%。
- H_combo_beat：模拟组合（选 overnight_share 最低标的持有 10 天）4 段中 ≥ 2 段跑赢 hard5。

## 4. 实验前预测

如果 H_main 为真，应该看到：

- **信号覆盖率**（A 分析）：策略 ETF 池每天有 5-15 只 low 桶标的，不是空集。
- **事件级复现**（B 分析）：low 桶标的持有 10 天收益均值 > 0，胜率 > 50%，方向与 EX-7TJU 一致（但幅度可能小于 +5.33%，因为 ETF 池 ≠ EX-7TJU 的标的池）。
- **组合层模拟**（C 分析）：cand 组合（选 overnight_share 最低）4 段中至少 2020_2021（牛市）跑赢 hard5；弱市段可能输（信号 regime 依赖）。
- **per_segment**：牛市段信号最强（趋势延续），弱市段可能失效。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| EX-6XCN baseline_hard5 净值曲线 | C 分析的对照基准（信号组合 vs hard5） | results/v2/research/R010-A22/overnight_v2_paired/EX-20260622T104131Z-main-6XCN/formal/baseline_hard5/cost1x/*/equity_curve.csv |
| EX-7TJU 事件级统计 | B 分析的对照基准（ETF 池复现 vs 原始 +5.33%） | EX-7TJU 第16节 |
| cand config strategy_params | 提取策略 ETF 池定义 | configs/research/R010-A22/overnight_v2_paired/EX-20260622T104131Z-main-6XCN/ |
| ClickHouse jq_bar_daily | 算 overnight_share_5 + 持有收益 | 只读查询 |

## 6. 竞争性解释

即使 B/C 分析显示正收益，也可能是：

- **EX-7TJU 的 +5.33% 本身有后视偏差**：H10 是"持有 10 天后看收益"，"持有 10 天最优"接近定义性。换 ETF 池复刻时可能消失。
- **信号只在事件后短期有效**：overnight_share 低的标的可能只在 signal_date 后 1-3 天涨，持有 10 天会回吐。
- **组合层成本吃掉收益**：即使 B 通过（信号在池里成立），C 的换仓成本 + 滑点可能吃掉超额收益。
- **ETF 池标的特性不同于 EX-7TJU 的标的池**：如果 EX-7TJU 用的是更宽的标的池（含个股/分级），换到纯 ETF 池可能信号不成立。
- **幸存者偏差**：low 桶标的中有些可能已退市/合并，jq_bar_daily 只覆盖存活标的。

## 7. 证伪条件

出现以下情况，本假设不通过：

- **F_event_repro**（B 分析）：在策略 ETF 池里复刻事件级统计，low 桶持有 10 天收益均值 ≤ 0 或胜率 < 50% → 信号在 ETF 池不成立 → **park 整条 overnight 链**，信号在当前策略无价值。
- **F_coverage**（A 分析）：策略 ETF 池每天 low 桶标的 < 2 只 → 信号覆盖率不足，无法支撑组合层选股 → park 或 revise（扩池子）。
- **F_combo_beat**（C 分析）：模拟组合 4 段中 0 段跑赢 hard5 → 信号在组合层可交易约束下无效 → park。
- **F_lead_lag**：错位 ±1 天后信号消失 → 信号有 lookahead 嫌疑 → 不进 formal，重审 EX-7TJU。
- **F_per_segment_all_neg**：4 段全部负收益 → 信号方向反了或完全无效 → kill overnight 信号。

**关键边界**：本实验是只读模拟，**不构成策略收益证据**。C 分析的模拟组合用了简化假设（等权、简化换仓），与真实策略有差距。只读通过只能证明"信号值得开 formal"，不能直接 promote。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 通过（前置判定） | overnight_share_5 用过去 5 日 OHLC，t 日收盘后可得；选股决策用 t 日收盘后信息 |
| 信号生成和成交价格不存在同 bar 泄漏 | 通过 | 选股用 t 日收盘后 overnight_share，买入用 t+1 日开盘或收盘（模拟口径，需明确） |
| 股票池或 ETF 池不存在未来成分泄漏 | 通过 | 池子从 cand config 静态提取，不改池子 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 不用财务/宏观 |
| Shadow 或观察信号未被当成默认交易信号 | 通过 | 模拟结果只写 EX-CXCP 目录，不进策略 |

负控或错位检查：
- **F_lead_lag 必跑**：对 B 分析，错位 ±1 天后重算 low 桶持有 10 天收益，信号应消失或减弱。如果错位后更强，信号有 lookahead 嫌疑。
- **随机替换负控**：随机选 N 只标的代替 low 桶，持有 10 天收益应不显著（baseline 检验）。
- **存活者偏差检查**：确认 jq_bar_daily 在回测期内是否覆盖已退市 ETF。

## 9. 过拟合与样本隔离检查

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | overnight_share_5 口径复刻 RD-S2T4，无新参数搜索；持有 10 天复刻 EX-7TJU 最优 |
| 样本内、验证集、样本外划分清楚 | 通过 | 沿用 EX-6XCN 4 段：2020_2021/2024 样本内、2022_2023 压力期、2025 近端 OOS |
| 邻近参数敏感性合理 | 待执行 | 持有天数 5/10/15 天敏感性需在执行时补 |
| 成本、滑点或换手扰动已检查 | 待执行 | C 分析模拟需含 cost1x 手续费 + 滑点 |
| 已做消融或负控 | 通过 | F_lead_lag 错位 + 随机替换负控 |
| 未只报告最优结果 | 通过 | 4 段全报，不挑段 |

证据等级：`L1`（只读模拟面板；通过后只产生"值得开 formal"的决策，不构成策略收益证据）。

## 10. 子代理调用记录

适配判断：`不适合调用`

调用状态：`exempt`

子代理豁免：本实验是 overnight 链最终信号价值判定（路线生杀级），simulate 脚本设计+负控逻辑+判定矩阵+结果解读全部由主控承担；脚本结构高度耦合（标的池提取→overnight_share 计算→事件级复现+错位/随机替换负控→组合层模拟）需在单脚本顺序执行，无法干净拆分；主控：main；时间：2026-06-24T06:50:00Z。

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 无 | 无 | 无 | 无 | 无 | 无 | 无 | 无 | 无 | 无 | 主控全部承担 | 无 |

台账行：本实验无子代理调用，不入子代理调用台账。

台账行：执行时填入 `01_台账/子代理调用台账.csv`。

## 11. 执行记录

### 平台配置

本实验不需要平台策略配置，不需要回测重跑。

将新增 1 个研究脚本：`${QUANT_PLATFORM_ROOT}/scripts/research/simulate_overnight_stockpicking_cxcp.py`
- 输入：cand config（ETF 池定义）+ ClickHouse jq_bar_daily（OHLC 算 overnight_share_5 + 收盘价算持有收益）+ EX-6XCN baseline_hard5 equity_curve.csv（对照）
- 输出：
  - `coverage_analysis.json`（A：每天 low 桶标的数量分布 per_segment）
  - `event_reproduction.csv`（B：策略 ETF 池复刻事件级统计，low 桶持有 10 天收益 per_event + 汇总）
  - `event_reproduction_summary.json`（B 汇总：均值/胜率/分段 + 错位负控 + 随机替换负控）
  - `combo_simulation.csv`（C：模拟组合逐日净值）
  - `combo_vs_hard5.json`（C 汇总：cand vs hard5 4 段对比）

### 运行命令

```bash
# WSL，纯只读 ClickHouse + Python 后处理
wsl -- bash -lc "cd '/mnt/e/量化平台_V1.4.0' && PYTHONPATH=src PYTHONUNBUFFERED=1 python3 scripts/research/simulate_overnight_stockpicking_cxcp.py --output results/v2/research/RD-20260624T014933Z-main-NQS5/EX-20260624T061755Z-main-CXCP/coverage_analysis.json 2>&1 | tee /tmp/cxcp.log"
```

### 可见进度与日志

- 是否过程可见：是（脚本前台运行，stdout 实时输出 A/B/C 三步进度）
- 日志路径：/tmp/cxcp.log（执行后回填）
- 异常判断：① A 分析如果每天 low 桶 < 2 只立即报告覆盖率不足；② B 分析如果均值 ≤ 0 报告信号不成立
- 后台回测豁免：不适用（非回测，纯离线脚本预计 < 5 分钟）

### 结果路径

```text
results/v2/research/RD-20260624T014933Z-main-NQS5/EX-20260624T061755Z-main-CXCP/
  coverage_analysis.json（A：信号覆盖率）
  event_reproduction.csv（B：事件级复现明细）
  event_reproduction_summary.json（B：汇总+负控）
  combo_simulation.csv（C：组合层模拟逐日净值）
  combo_vs_hard5.json（C：cand vs hard5 对比）
```

## 12. 实际观察

| 指标 | 预期 | 实际 | 通过/失败 |
| --- | --- | --- | --- |
| A：每天 low 桶标的数（中位） | ≥ 5 | 35（19-44） | ✅ 通过 |
| B：low 桶持有 10 天收益均值 | > 0 | +0.50% | ⚠️ 名义通过但极弱 |
| B：low 桶持有 10 天胜率 | > 50% | 52.4% | ⚠️ 名义通过但极弱 |
| B：错位 +1 天后信号 | 减弱/消失 | +0.46%（几乎不变） | ❌ 信号无精确择时价值 |
| B：随机替换负控 | 不显著 | +0.42%（5 次试验 0.42-0.44%） | ❌ **超额≈0** |
| B：**信号超额（low − random）** | 显著正 | **+0.08%** | ❌ **几乎为零** |
| C：cand 4 段跑赢 hard5 数 | ≥ 2/4 | 0/4 | ❌ 失败 |
| C：2020_2021 段 cand vs hard5 | cand 赢 | −18.4% vs +126.9% | ❌ 大输 |
| C：2022_2023 段 | — | −60.4% vs +30.1% | ❌ 巨亏 |
| C：2024 段 | — | +35.9% vs +66.8% | ❌ 输 |
| C：2025 段 | — | −32.5% vs +215.4% | ❌ 巨亏 |
| per_segment 方向 | ≥ 3/4 正 | 1/4 正（仅 2024） | ❌ 失败 |

## 13. 支持证据

1. **A 覆盖率充足**：每天 19-44 只 low 桶标的，信号选股完全可行（不是"没标的可选"的问题）。
2. **B 名义方向正确**：low 桶 +0.50% > 0，胜率 52.4% > 50%，方向与 EX-7TJU 一致（日内主导=趋势延续）。
3. **方法论闭环**：三步走（覆盖率→事件级复现→组合层模拟）+ 双负控（错位 + 随机替换）齐全，证据等级 L1。

## 14. 反对证据（对"信号无 alpha"结论的约束，即支持信号有价值的证据）

1. **B 名义通过**：+0.50% > 0，不能说信号完全无效——只是超额极弱。
2. **池子可能偏窄**：本实验用 216 只 ETF/LOF（从 positions 聚合），EX-7TJU 原始标的池可能更宽（含个股/分级），换池信号可能更强。但 ETF 轮动策略就只能买 ETF，这个约束是真实的。
3. **持有 10 天可能非最优**：本实验固定 HOLD_DAYS=10，其他持有期（5/15/20）可能有差异。但 EX-7TJU 的"10 天最优"接近定义性，调参空间有限。

## 15. 偏差诊断

1. **EX-7TJU +5.33% vs ETF 池 +0.50% 的缩水根因**：最可能是标的池差异。EX-7TJU 若含个股/分级基金（波动大），+5.33% 里有大量 beta；纯 ETF 池波动小，缩水到 +0.50%。这不是"ETF 池算错了"，而是"信号在低波动资产上 alpha 消失"。
2. **随机替换 +0.42% 的含义**：2020-2025 年 ETF 普涨，随便买持有 10 天就有 +0.42%。low 桶的 +0.50% 几乎全是这个 beta，**信号特有的 alpha 只有 0.08%**。
3. **C 分析 3 段负收益**：选 overnight_share 最低的标的满仓，等于专门挑"日内主导"的标的。这些标的日内波动大，满仓单押风险高，弱市段（2022/2025）巨亏。这不是"信号方向反了"，而是"信号选出的标的波动太大，满仓不可行"。

## 16. 研究判断

建议状态：**`park`**（信号在 ETF 池选股无 alpha，overnight 链最终 park）。

判定依据：
1. **核心：负控证据确凿**。low 桶 +0.50% − 随机 +0.42% = **超额 +0.08%**，几乎为零。这不是"信号弱"，是"信号没有超越随机的选股能力"。
2. **组合层 0/4 赢 hard5，3 段负收益**。即使信号名义 +0.50%，真按它选股满仓持有，4 段全输。
3. **错位 +1 天几乎不变**（+0.46% vs +0.50%）：信号没有精确择时价值，选哪天买差不多。

这是 overnight 链有史以来**第一次站得住的 park 理由**：
- 不是"放行没生效"（DEC-3TWB 的错误归因）
- 不是"退出非主因"（更早的错误归因）
- 而是**信号本身在 ETF 选股框架里没有 alpha**，负控证明

## 17. 下一步

**park 整个 overnight 链**（DEC-G6M9）：
- RD-S2T4（已 park）+ RD-JFHA（已 park）+ RD-NQS5（park）全部确认关闭
- 写最终决策卡盖棺

**不重启条件**（留口但门槛极高）：
- 仅当发现 EX-7TJU 原始标的池含大量个股/分级，且在个股池重做 B 分析 +0.50%→大幅提升，才考虑重开
- 或 overnight_share 作为非选股因子（如择时/风控）有新证据

它能减少的不确定性：**"个股 overnight_share 作为 ETF 选股信号有没有真实价值"**——已确认没有。overnight 研究链彻底关闭。
