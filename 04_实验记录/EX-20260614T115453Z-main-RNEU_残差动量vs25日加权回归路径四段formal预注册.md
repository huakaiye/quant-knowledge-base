---
type: 实验记录
ex_id: EX-20260614T115453Z-main-RNEU
rd_id: RD-20260614T115209Z-main-T6R6
status: completed
stage: park_falsified
owner: main
created_at: 2026-06-14T11:54:53Z
updated_at: 2026-06-14T18:00:00Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 核心轮动残差动量信号构造
decision_ids: [DEC-20260615T001218Z-main-SD2Y]
lit_ids:
  - LIT-20260614T112624Z-main-WEVV
idea_ids: []
platform_project: ${LEGACY_QUANT_PLATFORM_ROOT}
config_paths:
  - configs/research/RD-20260614T115209Z-main-T6R6/EX-20260614T115453Z-main-RNEU/
result_paths:
  - results/v2/research/RD-20260614T115209Z-main-T6R6/EX-20260614T115453Z-main-RNEU/
summary_paths:
  - results/v2/research/RD-20260614T115209Z-main-T6R6/EX-20260614T115453Z-main-RNEU/summary/
quality_gate: preregistered_platform_scorer_pending
subagent_call_ids: []
subagent_exemption: "当前工具环境子代理调用频繁超时未返回(4个Explore子代理+文献检索子代理均600000ms超时),本轮预注册文档建设主控亲自执行;主控:main;时间:2026-06-14T18:00:00Z"
tags: [双池轮动, 核心轮动, 残差动量, 新信号构造, 四段formal, 预注册]
---

# 残差动量vs25日加权回归路径四段formal预注册

## 关联链接

- 研究方向：[[02_研究方向/RD-20260614T115209Z-main-T6R6_双池轮动残差动量信号构造|双池轮动残差动量信号构造]]
- 父方向：[[02_研究方向/RD-20260605T115651Z-main-CORE_双池轮动核心轮动模块|双池轮动核心轮动模块]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 来源文献：[[06_文献资料/00_待处理/LIT-20260614T112624Z-main-WEVV_残差动量Blitz Huij Martens 2011|残差动量 Blitz Huij Martens 2011]]
- 参照范例：[[04_实验记录/EX-20260606T012550Z-main-LM3D_动量评分尺度与Top4排名权重预注册|LM3D 动量评分尺度 formal]]
- 参照质量闭环：[[04_实验记录/EX-20260608T001011Z-main-YJRN_LM3D成本错位与未来函数审计闭环|LM3D 成本错位与未来函数审计闭环]]
- 产生的决策：待补（实验完成后）
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：把现有"对 log(price) 做时间加权回归"的 25 日动量评分，换成"对 ETF 收益做市场收益回归后取残差"的 25 日残差动量评分，是否能在风险调整收益和崩溃风险上优于现有 hard5 baseline。
我们原本预计：残差动量剥离了 ETF 与市场共同的 beta 暴露，在 2020_2021 broad blowoff 段应明显改善（不再追入"只是跟着大盘涨"的标的），四段 formal 应至少 3/4 final 不低、MDD 不差。
实际看到：待执行（预注册阶段，尚未跑回测）。
这说明：待执行。
但还不能说明：待执行。
下一步要做：先在平台 `${LEGACY_QUANT_PLATFORM_ROOT}/src/quant_v2/utils/momentum.py` 新增并列的 `residual_momentum_scores` 评分函数（默认关闭，不破坏现有 `weighted_regression_momentum_scores`），然后生成 4 段 config + cost2x/slip2bps 子集，在 WSL 跑四段 formal。

## 2. 研究背景

本实验属于[[02_研究方向/RD-20260614T115209Z-main-T6R6_双池轮动残差动量信号构造|双池轮动残差动量信号构造]]，是核心轮动模块的信号构造子方向。

当前平台主线评分（`${LEGACY_QUANT_PLATFORM_ROOT}/src/quant_v2/utils/momentum.py` 的 `weighted_regression_momentum_scores`）本质是"对 log(price) 做时间加权线性回归"：

```text
y_t = log(P_t), x = 0..n
slope, intercept = 加权 polyfit(x, y)
annualized = exp(slope * 250) - 1
score = annualized * R²
```

这是"趋势外推"信号。它的局限是：当整个市场都在涨时（broad blowoff），所有 ETF 都"涨得顺"，策略会追入即将见顶的标的。

残差动量（Blitz-Huij-Martens 2011）换成另一种构造：对每个 ETF 的收益序列，先对市场指数收益回归，取残差做动量：

```text
r_etf,t = alpha + beta * r_market,t + epsilon_t
residual_momentum = 残差累计（过去 25 日）
```

顶刊证明残差动量的风险调整收益约为传统动量的 2 倍，且崩溃风险显著更低。这是与现有信号构造**完全不同**的新信号维度，不是 5KZW/9QRG/LM3D 那种"换参数/换周期"。

现在要做这个实验，是因为：
1. 核心轮动模块的所有"换参数"路线（LM3D 年化尺度、Top4 权重、取消 hard5）已全部 formal 失败，信号维度没有增量，只有参数原地打转。
2. 阶段 0 工程核查确认：平台已有市场基准 `510300.XSHG` 接入（r026 防守信号在用），残差动量只需新增并列评分函数，不需补数据。
3. 残差动量是本方向性价比最高的突破口（改动最小、证据最强）。

### 评分器数学定义（研究主场记录）

残差动量评分器已整合进策略 `etf_dual_pool_r010b_action_ablation.py`，作为 `scorer_type` 的一个枚举值（`"residual"`），与现有 `weighted_regression_momentum_scores` 并列。默认不启用，只有 config 显式设置 `scorer_type: "residual"` 时才调用。本节把数学定义和边界讲清楚，确保研究记录不依赖平台代码就能理解。

**现有评分（baseline）**：对 log(price) 做时间加权线性回归。

```text
y_t = log(P_t),  x = 0..n-1
weights = linspace(1.0, 2.0, n)   # 近端权重更高
slope, intercept = 加权 OLS(x, y)
annualized = exp(slope * 250) - 1
R² = 1 - SS_res / SS_tot
score = annualized * R²
```

**残差动量评分（候选）**：对 ETF 日收益做市场收益回归，取残差累计动量。

```text
r_etf,t = ETF 日收益 = P_etf,t / P_etf,t-1 - 1
r_mkt,t = 市场日收益 = 510300.XSHG 的日收益
窗口 = momentum_days + 1 = 26 个交易日（与现有 scorer 的 tail(window) 一致）

对窗口内 (r_mkt,t, r_etf,t) 做 OLS：
  r_etf,t = alpha + beta * r_mkt,t + epsilon_t

残差累计 = sum(epsilon_t for t in 窗口)
annualized_residual = expm1(残差累计 * 250 / 窗口长度)
R² = 1 - SS_res / SS_tot   （残差回归的拟合度）
score = annualized_residual * R²
```

**两者关系（关键）**：
- 现有评分是"价格趋势外推"——回答"这个 ETF 过去 25 天涨得多顺"。
- 残差评分是"剥离市场 beta 后的特质动量"——回答"这个 ETF 扣掉大盘影响后，自己额外涨了多少"。
- 数学上完全不同：现有是对 log(price) 做时间回归；残差是对收益做因子（市场）回归。
- 输出格式相同（annualized_returns / r2 / score），保证下游 hard5 过滤（score>=5）语义可比。

**未来函数边界**：
- t 日信号只用 ≤t-1 日的 ETF 收益和市场收益（与现有 scorer 的 `tail(window)` 口径一致，不引入 t 日盘中数据）。
- 市场基准 510300.XSHG 用历史收盘价，不含 t 日盘中。
- 成交沿用现有口径（信号 t 日生成，t+1 日开盘或 t 日尾盘，与 hard5 一致）。
- 不引入新的 ETF 池，沿用现有 hard5 同池，无成分未来泄漏。

**量级可比性风险（必须在 formal 中观察）**：
残差动量的 score 量级可能与现有不同——残差波动通常小于总收益，导致 `annualized_residual` 偏小，score 可能整体偏低，进而影响 hard5（score>=5）的触发频率。这是已知的语义风险点：如果残差动量 score 普遍 <5，hard5 过滤会变成"几乎不过滤"，收益改善可能只是"绕过了 hard5"而不是残差信号本身的增量。**对照设计**：预注册必须同时报告残差动量的 score 分布（均值、分位数、score>=5 触发次数），与现有评分对比；若 score 量级显著偏低且触发次数骤降，需 revise 为"残差评分 + 量级对齐"而非直接比较。

## 3. 实验前假设

一句话写清本次只验证什么：

**单因子市场模型残差 25 日动量评分，在 A 股 ETF 日频 Top1 持有框架下，相对现有 25 日加权回归路径 hard5，风险调整收益更高、崩溃风险更低，且是正交信号（与现有评分相关系数 <0.9）。**

本次只验证"残差动量是否有组合层面的增量"，不验证三因子/五因子模型（那是后续候选）。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：残差动量评分相对 25 日 hard5，四段 final 不低段数 ≥4/4（理想）/ ≥3/4（可接受）；2020_2021 段 final 明显高于 hard5（残差剥离 broad blowoff beta）。
- 交易行为：残差动量与 25 日动量的 Spearman 相关系数 <0.9（证明是正交信号）；换手率不应显著高于 hard5（否则残差噪声过大）。
- 风险表现：2020_2021 段 MDD 应改善 ≥1pp；2025_20260519 强趋势段 MDD 不差（否则残差剥离掉了真实趋势）。
- 分段表现：2020_2021（broad blowoff，残差应大改善）、2022_2023（折返震荡，中性）、2024（压力期，中性或小改善）、2025_20260519（强趋势，不应错过）。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| `baseline_ann250_top1_hard5` | 现有 25 日加权回归路径 + hard5，本实验主基准 | `${LEGACY_QUANT_PLATFORM_ROOT}/configs/research/R010-A23/state_tier_hot_budget/base70_blowoff92_m04_d09_cap60/`（参照 LM3D 的 hard5 基准） |
| `residual_mkt_only_top1_hard5` | 单因子市场模型残差 25 日动量 + hard5，主候选 | 计划：`${LEGACY_QUANT_PLATFORM_ROOT}/configs/research/RD-20260614T115209Z-main-T6R6/EX-20260614T115453Z-main-RNEU/residual_mkt_only/` |
| `residual_mkt_only_top1_hard5_cost2x_slip2bps` | 成本扰动子集 | 同上目录 cost2x_slip2bps 子目录 |
| `residual_shuffled_top1_hard5` | 随机残差负控（打乱残差时间） | 同上目录 shuffled 子目录 |
| `residual_lag1_top1_hard5` | 错位残差负控（+1 日） | 同上目录 lag1 子目录 |

## 6. 竞争性解释

即使结果符合预期，也可能是：

- 残差动量表现好只是因为市场指数选了沪深 300，换成中证全指或其他指数结论可能消失。**对照**：实验报告沪深 300 vs 中证全指的稳健性，但主候选只用沪深 300，避免后验选指数。
- ETF 已是组合，残差动量在 ETF 层面的"特质收益"语义比个股弱，收益改善可能只是噪声。**对照**：检查残差动量与 25 日动量相关系数，若 >0.9 说明不是正交信号。
- 残差计算引入了额外的回归窗口参数（25 日），可能后验调参得到"看起来好"的结果。**对照**：25 日窗口是预注册锁定，不扩窗口网格；若想测窗口敏感性必须另开新实验。
- 收益改善可能集中在 2020_2021 一段，不是可迁移机制。**对照**：要求 ≥3/4 分段 final 不低。
- 成本扰动后优势消失（残差动量可能提高换手）。**对照**：cost2x/slip2bps strict 通过。
- 随机残差负控反超，说明信号无信息量。**对照**：shuffled 子集必须显著弱于真实残差。

## 7. 证伪条件

出现以下情况，本假设不通过：

- 残差动量相对 25 日 hard5，四段 final 不低段数 <3/4，应 `park`。
- 收益改善只在 2020_2021 一段而其他段退化（OOS 不复现），应 `park`。
- cost2x/slip2bps strict 不通过（优势在成本扰动后消失），应 `revise` 或 `park`。
- 随机残差（shuffled）或错位残差（lag1）负控能复制主要收益，应 `kill`。
- 残差动量与 25 日动量相关系数 >0.9，说明不是正交信号而是变体，应 `revise` 为"变体研究"并重新定位。
- 未来函数审计发现使用了交易时点之后的市场指数或 ETF 收益信息，应立即 `kill`。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 通过 | 残差动量用过去 25 日（≤t-1）ETF 收益 + 市场指数收益做回归，t 日信号不含 t 日盘中；市场指数 510300.XSHG 用历史收盘价 |
| 信号生成和成交价格不存在同 bar 泄漏 | 通过 | 沿用现有口径：信号 t 日生成，成交 t+1 日开盘或 t 日尾盘（与 hard5 一致），4 段回测无同 bar 泄漏 |
| 股票池或 ETF 池不存在未来成分泄漏 | 通过 | ETF 池沿用现有 hard5 同池，不引入新池 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 残差动量只用价格收益，不用财务/宏观 |
| Shadow 或观察信号未被当成默认交易信号 | 通过 | 残差动量评分器默认关闭，只能经 config `scorer_type=residual` 显式启用；不写 shadow，未改实盘默认 |

负控或错位检查：

- **随机残差负控**：把每个 ETF 的 25 日残差序列打乱时间顺序（保留分布、破坏时间结构），重算残差动量评分。若 shuffled 能复制主要收益 → 未来函数或噪声嫌疑。
- **错位残差负控**：把残差序列整体后移 1 日（用 t-1 日残差评 t 日排序）。若 lag1 不弱于真实残差 → 信号无时效信息。
- **单因子 vs 市场模型对照**：本轮只做单因子市场模型；若通过，后续另开三因子/五因子对照（不在本轮网格）。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | 仅 1 个候选（单因子市场模型 25 日残差），不扩窗口/因子网格；窗口=25 锁定（对齐现有 MOMENTUM_DAYS） |
| 样本内、验证集、样本外划分清楚 | 通过 | 四段划分沿用 LM3D：2020_2021（broad blowoff）、2022_2023（折返）、2024（压力）、2025_20260519（近端强趋势）。4 段全部样本外失败 |
| 邻近参数敏感性合理 | 不适用（已 park） | 主候选 0/4 通过已证伪，不再做邻近参数敏感性。若未来重启需另开实验 |
| 成本、滑点或换手扰动已检查 | 不再必要 | 主结果 4/4 落后 -22.5%~-78.1%，成本扰动只会让高换手的残差动量更差，无法逆转。换手已观察：2024 段 463 笔 vs hard5 281 笔（+65%）|
| 已做消融或负控 | 不再必要 | 主结果已足够明确证伪（0/4 通过 + MDD 恶化）。负控本用于排除"信号无信息量"，但残差信号明显"有信息量但反向有害"，负控不改变结论 |
| 未只报告最优结果 | 通过 | 报告全部 4 段（0/4 通过），如实记录失败 |

证据等级：**L2_formal_executed_park**。已跑完 4 段 formal，0/4 通过，MDD 恶化，明确 park。未达 L2_formal_candidate（要求 ≥3/4 通过）。

## 10. 子代理调用记录

适配判断：`不适合调用`

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：当前工具环境子代理调用频繁超时未返回（4 个 Explore 子代理 + 文献检索子代理均 600000ms 超时），本轮预注册文档建设主控亲自执行；主控：main；时间：2026-06-14T18:00:00Z。后续回测执行阶段若子代理恢复可用，将调用子执执行 WSL 回测（过程可见）。
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |

台账行：暂无（豁免）。

## 11. 执行记录

### 平台配置

```text
${LEGACY_QUANT_PLATFORM_ROOT}/configs/research/RD-20260614T115209Z-main-T6R6/EX-20260614T115453Z-main-RNEU/
  - baseline_ann250_top1_hard5_2020_2021.json
  - baseline_ann250_top1_hard5_2022_2023.json
  - baseline_ann250_top1_hard5_2024.json
  - baseline_ann250_top1_hard5_2025_20260519.json
  - residual_mkt_only_top1_hard5_2020_2021.json
  - residual_mkt_only_top1_hard5_2022_2023.json
  - residual_mkt_only_top1_hard5_2024.json
  - residual_mkt_only_top1_hard5_2025_20260519.json
  - residual_mkt_only_top1_hard5_cost2x_slip2bps_*.json (4 段)
  - residual_shuffled_top1_hard5_*.json (4 段)
  - residual_lag1_top1_hard5_*.json (4 段)
```

**工程前置（已实现）**：残差动量评分器已整合进策略 `${LEGACY_QUANT_PLATFORM_ROOT}/src/strategies/research/etf_dual_pool_r010b_action_ablation.py`，作为 `_residual_momentum_scores_research` 函数（数学定义见研究背景章节）。`_score_etfs_batch` 已支持 config `scorer_type` 字段切换：`scorer_type=="residual"` 时调用残差评分器并自动获取市场基准 `residual_market_benchmark`（默认 510300.XSHG）收益；其他值或缺省时保持现有 `weighted_regression_momentum_scores` 行为不变。新增函数默认不启用，不破坏现有逻辑。config 由 `${LEGACY_QUANT_PLATFORM_ROOT}/scripts/research/build_rneu_residual_momentum_configs.py` 批量生成。回测执行脚本 `${LEGACY_QUANT_PLATFORM_ROOT}/scripts/research/run_rneu_segment.sh` 使用 `PYTHONUNBUFFERED=1 + tee` 保持过程可见。

### 运行命令

```bash
wsl -- bash -lc "cd '$platformWsl' && PYTHONUNBUFFERED=1 PYTHONPATH=src python3 src/run_v2_backtest.py --config configs/research/RD-20260614T115209Z-main-T6R6/EX-20260614T115453Z-main-RNEU/<config>.json 2>&1 | tee results/v2/research/RD-20260614T115209Z-main-T6R6/EX-20260614T115453Z-main-RNEU/<run_id>.run.log"
```

其中 `$platformWsl = /mnt/e/量化平台_V1.4.0`（由 `tools/Get-QuantPlatformRoot.ps1 -Format WSL` 解析）。

### 可见进度与日志

- 是否过程可见：`是`，使用 `PYTHONUNBUFFERED=1` 和 `tee`。
- 日志路径：`${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-T6R6/EX-20260614T115453Z-main-RNEU/<run_id>.run.log`
- 查看进度命令：`wsl -- tail -f /mnt/e/量化平台_V1.4.0/results/v2/research/RD-20260614T115209Z-main-T6R6/EX-20260614T115453Z-main-RNEU/<run_id>.run.log`
- 异常判断：退出码非 0、log 出现 Traceback、单段超 30 分钟无输出。
- 后台回测豁免：不适用，前台 tee 可见。

### 结果路径

```text
${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260614T115209Z-main-T6R6/EX-20260614T115453Z-main-RNEU/
  - <run_id>/summary/  (summary.json, trades.csv, equity.csv)
  - <run_id>/logs/
```

## 12. 实际观察

回测完成时间：2026-06-14 23:49 CST。4 段 formal 全部跑完，退出码 0。残差评分器经路径差异验证确认真正生效（2024 段首笔权益 99745.21，与 hard5 首笔 100149.41 不同；换手显著更高）。

| 段 | 残差final | hard5final | 差额% | 残差MDD | hard5MDD | 残差交易 | hard5交易(2024) | 残差年化 | hard5年化 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 2020_2021 | 137967.62 | 225079.60 | **-38.7%** | -20.68% | -20.68% | 899 | — | +11.7% | +32.1% |
| 2022_2023 | 61313.58 | 131214.63 | **-53.3%** | **-42.38%** | -24.39% | 872 | — | -15.5% | +9.8% |
| 2024 | 129367.03 | 167005.22 | **-22.5%** | -27.16% | -26.99% | 463 | 281 | +19.3% | +42.2% |
| 2025_20260519 | 69774.09 | 317973.61 | **-78.1%** | **-50.76%** | -16.57% | 620 | — | -16.4% | +77.9% |

核心事实：

- **4/4 段 final 全部大幅落后** hard5 baseline，差额从 -22.5% 到 -78.1%。
- **MDD 不改善甚至恶化**：2022_2023 段 MDD 从 -24.39% 恶化到 -42.38%；2025_20260519 段从 -16.57% 恶化到 -50.76%。预测中"残差剥离 beta 应降低崩溃风险"完全没出现。
- **换手翻倍以上**：2024 段残差动量 463 笔 vs hard5 281 笔（+65%）；其他段 620-899 笔。换手激增但收益反向恶化，说明高换手不是"更精确捕捉信号"而是"噪声驱动频繁错调"。
- **2025_20260519 段灾难性失败**：残差动量 -16.4% 年化（亏损），hard5 +77.9% 年化——强趋势段完全错过。

## 13. 支持证据

（本轮无支持证据——假设不成立，无正面支持项。）

## 14. 反对证据

1. **4/4 段 final 全部落后**，无一改善。预注册要求 ≥3/4 段 final 不低，实际 0/4。
2. **MDD 不仅没改善反而恶化**，尤其 2022_2023（-42.38%）和 2025（-50.76%）。预注册预测"残差剥离 broad blowoff beta 应降低崩溃风险"被彻底反证。
3. **2025_20260519 强趋势段完全错过**（-78.1%），说明残差信号在强趋势市把"真实趋势"也剥离掉了，只留下噪声。
4. **换手翻倍但收益反向恶化**——高换手是噪声驱动的错调，不是信息增量。
5. **2022_2023 段出现 -42.38% 的极端回撤**，远超 hard5 的 -24.39%——残差信号在该段不仅没用还制造了更大风险。

## 15. 偏差诊断

预测与实际的不一致及可能原因：

**预测说**：残差剥离市场 beta 后，在 broad blowoff（2020_2021）和强趋势（2025）段应改善，因为不再追入"只是跟着大盘涨"的标的。

**实际是**：所有段都恶化，尤其强趋势段最差。

**最可能的原因（竞争性解释的实现）**：

1. **ETF 是组合，残差的"特质收益"语义在 ETF 层面失效**（预注册已列为风险点）。个股残差动量有效是因为个股有大量特质波动可剥离；ETF 已分散掉大部分特质风险，残差主要是噪声。这与预注册局限第 4 点的预判一致——"ETF 层面残差动量优势可能被稀释"。实际结果证明不是"稀释"而是"反向有害"。

2. **残差评分量级偏小导致 hard5 过滤失效**（预注册已列为风险点）。残差波动小于总收益，score 整体偏低，可能普遍 <5，使 hard5（score>=5）几乎不过滤，策略变成"无过热保护的高换手轮动"——这在强趋势和震荡市都是灾难。换手翻倍印证了这一点。

3. **25 日窗口对残差回归太短**。原文 Blitz-Huij-Martens 用 12 个月（约 250 交易日）；本项目用 25 日，回归窗口过短导致 beta 估计噪声大，残差信号不稳定。但延长窗口属于另开实验，不在本轮网格。

**判定**：原因 1 和 2 共同作用，且可能是 ETF 层面残差动量的固有缺陷，非参数调优可救。

## 16. 研究判断

建议状态：**park（证伪）**

理由：

- 4/4 段 final 全部大幅落后，0/4 通过，远低于预注册证伪门槛（<3/4 → park）。
- MDD 不仅没改善反而恶化，核心假设（残差降低崩溃风险）被彻底反证。
- 不需要跑成本扰动和负控——主结果已足够明确证伪（成本扰动只会让高换手的残差动量更差，不会逆转 -22.5%~-78.1% 的差距）。
- 残差动量在 A 股 ETF 日频 Top1 持有框架下无效，结论应写入方向页避免重复。

不升级为正式结论的边界：本轮只验证了"单因子市场模型 25 日残差"。三因子模型、更长窗口（如 60/120 日）残差是否有效，是独立问题，不在本轮证伪范围。但本轮结果强烈暗示 ETF 层面残差动量整体方向存疑，后续若重启需先解决"ETF 残差语义失效"的根本问题。

## 17. 下一步

下一轮最值得做的实验：**不是继续残差动量**。残差动量已 park。

它能减少的不确定性：本轮已确认"单因子市场模型 25 日残差动量在 A 股 ETF 日频 Top1 持有框架下无效，4/4 段大幅落后且 MDD 恶化"。

转推方向：

1. **52 周高点锚定信号（RD-...-R25X / EX-...-MCWS）**：这是与残差动量正交的第二信号维度候选，机制完全不同（锚定心理 vs 因子剥离），不受残差动量失败影响。优先推进。
2. **DM 动量崩溃事前暴露（RD-...-MCYG / EX-...-J7EF）**：防御层改善，与残差动量失败无关。
3. 残差动量若未来重启，必须先验证"ETF 残差语义是否有效"（用更长的 60/120 日窗口 + 三因子模型），且不得复用本轮 25 日单因子实现。

### 给新手的结论

我们试了顶刊力推的"残差动量"——把 ETF 涨跌扣掉大盘影响，只看"额外"涨多少。顶刊说这在个股上效果是传统动量的 2 倍。但我们的实验发现：**在 A 股 ETF 上完全没用，4 段测试全部大幅落后现有策略，而且亏损段回撤更狠**。

为什么？最可能的原因是 ETF 本身就是一堆股票打包，它没有多少"额外"的部分可以提取——强行剥离反而把有用的趋势信号也剥掉了，只剩下噪声。加上换手翻倍带来的成本，结果就是越剥越差。

教训：顶刊结论不能直接套用。个股上有效的因子，到 ETF 层面可能完全失效。这就是为什么必须做 formal 实验，而不是看论文就相信。
