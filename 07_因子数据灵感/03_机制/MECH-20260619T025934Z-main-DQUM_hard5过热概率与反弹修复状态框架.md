---
type: 因子数据灵感
idea_id: MECH-20260619T025934Z-main-DQUM
status: draft
owner: main
created_at: 2026-06-19T02:59:34Z
updated_at: 2026-06-19T07:30:00Z
source_lit_ids:
  - LIT-20260605T133336Z-main-67C4
  - LIT-20260614T112631Z-main-VY4K
  - LIT-20260603T000000Z-mig-2014DAFROGINTHEPANB412A
  - LIT-20260614T112631Z-main-A9BK
  - LIT-20260603T000000Z-mig-2014KELLYJIANG35CAF
  - LIT-20260617T220410Z-main-RDHA
related_rd_ids:
  - RD-20260605T133318Z-main-H6V3
  - RD-20260614T115209Z-main-MCYG
category: 机制
tags: [双池轮动, hard5, score-cap, 过热概率, 反弹修复, 状态转移, 顶刊启发]
---

# hard5过热概率与反弹修复状态框架

## 关联链接

- 来源文献：[[06_文献资料/00_待处理/LIT-20260605T133336Z-main-67C4_score过热拥挤机制文献映射|score过热拥挤机制文献映射]]；[[06_文献资料/00_待处理/LIT-20260614T112631Z-main-VY4K_动量崩溃保护Daniel Moskowitz 2016|动量崩溃保护 Daniel Moskowitz 2016]]；[[06_文献资料/00_待处理/LIT-20260614T112631Z-main-A9BK_52周高点动量George Hwang 2004|52周高点动量 George Hwang 2004]]；[[06_文献资料/00_待处理/LIT-20260617T220410Z-main-RDHA_顶刊拟合目标替代与动量崩溃前置暴露|顶刊拟合目标替代与动量崩溃前置暴露]]
- 相关方向：[[02_研究方向/RD-20260605T133318Z-main-H6V3_双池轮动score过热拥挤机制模块|双池轮动 score 过热拥挤机制模块]]；[[02_研究方向/RD-20260614T115209Z-main-MCYG_双池轮动动量崩溃事前暴露管理|双池轮动动量崩溃事前暴露管理]]
- 升级实验：[[04_实验记录/EX-20260619T032822Z-main-B3HP_hard5反弹修复误杀只读面板|B3HP hard5 反弹修复误杀只读面板]]；[[04_实验记录/EX-20260619T034400Z-main-GHGZ_hard5回撤收敛早期修复只读面板|GHGZ hard5 回撤收敛早期修复只读面板]]；[[04_实验记录/EX-20260619T035511Z-main-96SF_hard5真实持仓修复误杀路径索引只读面板|96SF hard5 真实持仓修复误杀路径索引]]；[[04_实验记录/EX-20260619T040913Z-main-8SH4_hard5修复误杀dry-run观察门禁|8SH4 hard5 修复误杀 dry-run 观察门禁]]；[[04_实验记录/EX-20260619T042345Z-main-8WGC_hard5修复误杀真实dry-run采集归因|8WGC hard5 修复误杀真实 dry-run 采集归因]]；[[04_实验记录/EX-20260619T062915Z-main-6EV3_hard5追高可追不可追状态分层只读面板|6EV3 hard5 追高可追不可追状态分层]]；[[04_实验记录/EX-20260619T064629Z-main-P97J_hard5高分事件盘中路径可追状态只读面板|P97J hard5 高分事件盘中路径可追状态只读面板]]；[[04_实验记录/EX-20260619T071136Z-main-7X8F_hard5真实订单层QMT连接失败诊断只读面板|7X8F hard5 真实订单层 QMT 连接失败诊断]]
- 相关术语：[[09_术语库/术语库#hard5|hard5]]；[[09_术语库/术语库#FIP 连续信息|FIP 连续信息]]；[[09_术语库/术语库#状态转移守门|状态转移守门]]；[[09_术语库/术语库#事件簇 hazard|事件簇 hazard]]；[[09_术语库/术语库#下尾经济损失校准|下尾经济损失校准]]

## 一句话说明

把 `score > 5` 从机械硬拦截，改写为三个可校准概率的组合：修复性延续概率、真正过热概率、动量崩溃或下尾损失概率。

## 来源

本机制来自用户对当前市场普反的观察：持仓 A 先亏损约 10%，随后市场普遍快速反弹，A 也开始修复，但 hard5 因近端上涨或 score 抬升把它判为过热，导致续持、回补或吃满反弹受到阻断。

已有库内证据支持这个问题存在但不能粗暴放开：

- [[04_实验记录/EX-20260605T165020Z-main-Z5EP_A19 ret5延续高分放行关键窗口与稳定性回测|A19]] 显示 `ret5_9_12` 在 2025_20260519 明显强于 hard5，说明高分上涨并非全是过热；但 2022_2023 明显弱于 hard5，说明无条件放行会失败。
- [[04_实验记录/EX-20260605T184943Z-main-Q3YU_A20-A21市场状态高分延续放行formal V2与路径依赖反证|A20/A21]] 显示市场状态条件化有效但仍受 broad blowoff 和路径依赖限制。
- [[04_实验记录/EX-20260607T102858Z-main-AURT_当前实盘权益回撤全级别恢复门控二级预算预注册|AURT]] 记录过强反弹误伤，说明恢复期门控确实可能错杀 V 型修复。
- [[04_实验记录/EX-20260618T145033Z-main-KFSQ_confirmed_state单组件episode随机负控只读复核|KFSQ]] 和 [[04_实验记录/EX-20260618T052620Z-main-Z78J_过热后趋势继续判别只读面板|Z78J]] 提醒：状态转移或 hazard 必须经过随机、错位和外部样本验证。

本轮外部检索补充的顶刊或高质量来源：

- Daniel and Moskowitz, 2016, Journal of Financial Economics, Momentum Crashes: [ScienceDirect](https://www.sciencedirect.com/science/article/pii/S0304405X16301490)、[NBER PDF](https://www.nber.org/system/files/working_papers/w20439/w20439.pdf)。
- Da, Gurun and Warachka, Frog in the Pan: Continuous Information and Momentum: [SSRN](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=1777988)、[PDF](https://www3.nd.edu/~zda/Frog.pdf)。
- George and Hwang, 2004, The Journal of Finance, The 52-Week High and Momentum Investing: [PDF](https://www.bauer.uh.edu/tgeorge/papers/gh4-paper.pdf)。
- Phillips, Shi and Yu, 2015, International Economic Review, Testing for Multiple Bubbles: [Wiley/IER](https://onlinelibrary.wiley.com/doi/abs/10.1111/iere.12131)、[PDF](http://korora.econ.yale.edu/phillips/pubs/art/p1498.pdf)。
- Bali, Cakici and Whitelaw, 2011, Journal of Financial Economics, Stocks as Lotteries and the Cross-Section of Expected Returns: [ScienceDirect](https://www.sciencedirect.com/science/article/abs/pii/S0304405X1000190X)、[PDF](https://pages.stern.nyu.edu/~rwhitela/papers/max%20jfe11.pdf)。
- Kelly and Jiang, 2014, Review of Financial Studies, Tail Risk and Asset Prices: [RFS](https://academic.oup.com/rfs/article-abstract/27/10/2841/1607080)、[NBER PDF](https://www.nber.org/system/files/working_papers/w19375/w19375.pdf)。

## 可实现定义

### 1. 从硬阈值改为三概率

对每个候选或当前持仓 `i,t`，不再直接用 `I(score_i,t > 5)` 决定拦截，而是估计：

```text
p_repair(i,t,H) = P(未来 H 日继续修复或相对 hard5 替代标的为正 | 当前可见状态)
p_overheat(i,t,H) = P(当前上涨属于尾段过热、彩票式跳涨或泡沫式扩张 | 当前可见状态)
p_crash(i,t,H) = P(未来 H 日出现下尾损失或动量崩溃 | 当前可见状态)
```

动作层只使用概率组合：

```text
allow_budget = clip(base_budget
                    + a * p_repair
                    - b * p_overheat
                    - c * p_crash,
                    min_budget,
                    max_budget)
```

通俗解释：如果它是亏损后的普反修复，应该提高允许续持或回补的预算；如果它是单日暴涨、低广度拥挤或泡沫式爆发，应该降低预算；如果组合层下尾风险高，也应该降低预算。

### 2. 修复性延续概率

用于解决“亏损 10% 后刚反弹却被 hard5 误杀”的核心问题。

候选字段：

- `prior_drawdown_10/20`：标的近期从局部高点的回撤。
- `ret5/ret10`：修复速度。
- `market_rebound_breadth`：池内上涨比例、`ma20_breadth`、`median_ret5/20`。
- `held_flag`：是否是当前持仓；当前持仓和新买入应分开评估。
- `rebound_from_loss_flag`：先有亏损再反弹，而不是一路新高加速。
- `same_theme_breadth`：同主题是否扩散，避免孤立拉升。
- `FIP_continuity`：上涨是否由连续小步构成，而不是少数跳涨。

标签：

```text
label_repair_h5 = future_h5_return(raw_or_current_holding) - future_h5_return(hard5_actual_replacement)
label_repair_h10 = future_h10_return(raw_or_current_holding) - future_h10_return(hard5_actual_replacement)
```

### 3. 真正过热概率

用于避免把 hard5 过度放松成追涨。

候选字段：

- `max_daily_return_20`：近 20 日最大单日涨幅，来自 MAX/l彩票式过热思想。
- `jump_ratio_20`：累计涨幅中由最大几日贡献的比例。
- `near_52w_high`：当前价格距离 52 周高点的比例；它不是天然负面，但和跳涨、成交量冲击、低广度同现时更像过热。
- `recursive_explosive_score`：参考 PSY/GSADF 的递归右尾单位根或爆炸性价格检测，先只读实现，不直接交易化。
- `volume_shock`：成交量冲击。
- `breadth_low_hot`：标的热但市场或主题广度低。
- `top5_exhausted`：候选前列过度拥挤或过滤耗尽。

标签：

```text
label_overheat_h5 = I(future_h5_relative <= -threshold)
label_overheat_dd10 = I(future_10d_min_return <= -drawdown_threshold)
```

### 4. 动量崩溃或下尾概率

候选字段：

- `market_recent_drawdown`：市场或组合刚经历下跌。
- `market_volatility`：市场高波动。
- `tail_risk_proxy`：横截面下尾、极端负收益比例或 Hill tail 代理。
- `episode_age`：风险状态已经持续多久。
- `confirmed_state_run_len`：参考 KFSQ 的单组件外部验证候选。

标签：

```text
label_tail_h10 = future_10d_min_return 或 H10 内相对 hard5 的下尾损失
```

### 5. 决策不是二选一，而是持仓/新买分层

同一个高分标的，动作应区分：

| 场景 | 默认 hard5 机械动作 | 本机制目标 |
| --- | --- | --- |
| 已持有且先亏后修复 | 可能过热拦截或无法吃满 | 优先评估续持收益和反弹修复概率 |
| 新买入且单日暴涨 | 可能同样只是 score>5 | 更严格看跳涨、低广度、泡沫和下尾风险 |
| 市场普反且同主题扩散 | hard5 可能仍拦 | 条件化放开或给预算 |
| broad blowoff 或低广度冲顶 | A20 已显示风险 | 降预算或继续 hard5 |

## 预期作用

- 降低 hard5 对亏损后普反修复的误杀，改善用户观察到的“反弹没有吃满”。
- 保留 hard5 对真正过热、彩票式跳涨和 broad blowoff 的保护。
- 把 A19/A20/A22/KFSQ 这些线索统一到一个可解释数学框架，而不是继续各自扫阈值。
- 让后续动作可以从 `hard filter` 变成 `soft budget`、`hold-only exception` 或 `new-buy stricter gate`。

## 首轮实验反馈

[[04_实验记录/EX-20260619T032822Z-main-B3HP_hard5反弹修复误杀只读面板|B3HP]] 已执行只读面板。结果对本机制有一个重要修正：预注册的 `conservative_repair` 和 `balanced_repair` 均为 0 事件，说明“`ret5` 已经转正到 3%-12% 的温和修复”不是当前 A11/A16 事件里的主要误杀形态。反而 `stress_repair` 的 18 个事件和约束诊断提示，用户观察到的场景更可能是“回撤仍在、`ret5` 可能仍为负，但候选池广度已明显修复”的早期阶段。

因此下一轮不能在 B3HP 内临时改阈值，必须新开预注册实验，把修复定义改为 `drawdown_narrowing/ret5_negative + breadth`，并补错位状态和真实持仓路径。当前机制仍只支持只读研究，不支持改变 hard5 默认逻辑。

[[04_实验记录/EX-20260619T034400Z-main-GHGZ_hard5回撤收敛早期修复只读面板|GHGZ]] 已执行上述早期修复检验。结果进一步修正本机制：`early_repair_core` 8 个事件 H10 为正但 H5 为负；`early_repair_strict` 5 个事件表现强但样本太少；无广度负控和同日随机 Top10 能复制部分 H10 正收益。这说明“回撤仍在 + 广度修复”是更接近用户观察的候选形态，但仍不是可交易规则。下一步不应继续扫 `drawdown/breadth/narrowing/jump` 阈值，而应转向真实持仓路径：只有 `held_repair` 或 `rebuy_repair` 通过，才可能研究持仓续持例外；`new_buy_repair` 和 `chase_hot` 必须更严格。

[[04_实验记录/EX-20260619T035511Z-main-96SF_hard5真实持仓修复误杀路径索引只读面板|96SF]] 已完成真实 hard5 持仓路径索引。结果把本机制进一步收窄：真实 `held_repair` 只有 2 个事件，且 H10 相对 hard5 实际路径平均 `-11.80pp`、胜率 `0%`；`rebuy_repair` 只有 1 个事件且 H5/H10 均为负。`new_buy_repair` H10 虽为正，但它不是用户描述的“已持有亏损修复被卖飞”，且 H5 为负、左尾较大。因此当前不能把 `p_repair` 写成 hold-only 或 cap30 动作规则。机制卡只保留为解释框架和外部观察清单；后续必须依赖真实 dry-run JSON 或成交日志累积新的 `held_repair` 样本。

[[04_实验记录/EX-20260619T040913Z-main-8SH4_hard5修复误杀dry-run观察门禁|8SH4]] 已补齐真实观察入口。它不重新证明 `p_repair`，只解决下一步证据链问题：未来拿到 B5JS `--output-json` 生成的真实 dry-run JSON 后，可把订单与 hard5 修复状态 CSV 关联，识别是否真的出现 `held_repair` 或 `rebuy_repair`。当前样例负控读取 1 条样例订单和 178 条 96SF 状态源，`match_count=0`，没有把无关订单误归因为修复误杀。该结果仍不支持改变 hard5，只说明等待真实 dry-run JSON 时已有可复用归因门禁。

[[04_实验记录/EX-20260619T042345Z-main-8WGC_hard5修复误杀真实dry-run采集归因|8WGC]] 已尝试推进到 Windows 真实 dry-run。结果显示 `C:\Python311\python.exe` 与 `E:\xtquant\国金QMT交易端模拟\userdata_mini` 均存在，`--check-only` 配置校验通过；但 `--connect-check` 和 `--dry-run-once` 均在 MiniQMT 连接层返回 `-1`，当前未发现 QMT 相关进程，也没有生成 `live_dry_run_once.json`。因此本机制仍停在观察门禁阶段：没有真实 JSON 前，不应继续扩 `p_repair` 阈值、预算比例或 hold-only 规则；下一步必须先启动并登录 QMT 模拟客户端，拿到真实 dry-run JSON 后再用 8SH4 归因。

[[04_实验记录/EX-20260619T062915Z-main-6EV3_hard5追高可追不可追状态分层只读面板|6EV3]] 检验了“除了修复外，还有哪些可以继续追高”的日频状态。预注册的 `repair_breadth_chase`、`broad_repricing_chase`、`steady_continuation_chase` 都未通过。最接近的 `repair_breadth_chase` 布尔状态有 20 个事件，H10 均值为正，但 H10 胜率只有 `50%`、p10 为 `-18.03%`，且 17 个事件与 `late_spike_no_chase` 重叠；按主分类排除尾段尖峰后只剩 3 个事件。该结果进一步约束本机制：顶刊启发的状态转移、FIP 或 hazard 框架不能直接落成当前日频阈值放行。后续不要在这组 96SF 事件上继续扫 `ret5/ret10/breadth/score/drawdown`，只能转真实 dry-run JSON 或盘口/成交/订单层证据。

[[04_实验记录/EX-20260619T064629Z-main-P97J_hard5高分事件盘中路径可追状态只读面板|P97J]] 把证据层从日频推进到 13:09 前分钟路径。这个设计更贴近用户说的“信息滞后”，但结果仍未支持放行：分钟覆盖率 `96.07%`，`intraday_steady_chase` 主分类 35 事件 H10 均值 `-4.29pp`、胜率 `34.29%`，`intraday_pullback_repair_chase` 主分类 6 事件 H10 胜率 `0%`。因此本机制的数学框架仍可作为问题分解方式，但当前不能写成日频或分钟 bar 阈值规则；下一轮证据必须来自真实 dry-run JSON、订单生命周期、盘口/逐笔或成交滑点。

[[04_实验记录/EX-20260619T071136Z-main-7X8F_hard5真实订单层QMT连接失败诊断只读面板|7X8F]] 继续推进到真实订单层前置诊断，但没有改变策略结论。它把 8WGC 的 `connect=-1` 拆成可审计条件后发现：配置、账号目录、`MiniConfig.xml`、userdata 新鲜度和 Python 3.11 `xtquant` 模块均通过；唯一 required failure 是 `qmt_process_found`，候选 QMT 进程数为 0。机制边界因此更清楚：现在不能继续优化 `p_repair/p_overheat/p_crash` 的阈值或预算，而是先让 QMT 模拟客户端启动、登录并形成可见会话，再采集真实 dry-run JSON 进入 8SH4 归因链路。

## 可以继续追高或续持的候选状态

以下状态只作为下一轮只读面板候选，不代表已验证交易规则。

| 状态 | 直觉解释 | 可见字段 | 主要风险 |
| --- | --- | --- | --- |
| 回撤后普反修复 | 标的不是高位冲顶，而是先跌后随市场修复 | `prior_drawdown_10/20`、`market_rebound_breadth`、`held_flag`、`ret5` | 弱市反弹尾声会伪装成修复 |
| 连续小步上涨 | 上涨由多日小幅推进构成，更像信息逐步反映 | `up_share20`、`jump_ratio20`、`max_daily_return_20` | ETF 日频 FIP 已有失败证据，必须换口径验证 |
| 新高突破但广度同步 | 接近 52 周高点不是天然过热，若主题和市场同步扩散，可能是趋势确认 | `near_52w_high`、同主题上涨比例、池内中位收益 | broad blowoff 中也会广度过满 |
| 中期强势仍在早中段 | 不是刚刚一两天冲高，而是中期动量背景下的短期再加速 | `ret60/120`、`ret20`、`episode_age` | 5KZW 已反证简单多周期确认，不能直接复用 |
| 隔夜延续强且日内不回落 | 趋势收益来自重新定价，而不是日内追高冲回落 | 隔夜收益、日内收益、日内回撤、收盘相对 VWAP | 当前分钟/隔夜链路需继续审计 |
| 高流动性承接 | 放量但价格推进有效，说明有承接而非单边拥挤 | 成交额冲击、价格相对 VWAP、放量后回撤 | 没有盘口/逐笔时只能弱代理 |
| 相对强度扩散 | 同主题或同风险桶多个标的一起走强，不是单票孤立尖峰 | theme breadth、topK 同向、横截面相关性 | 主题簇交易化曾失败，只能诊断 |
| 风险调整后仍强 | 高收益没有伴随同步高波动和下尾恶化 | realized vol、tail loss proxy、risk-adjusted momentum | 可能变成普通波动率缩放，需防复活已失败路线 |
| 持仓续持优先于新买 | 对已经持有的修复标的放宽，对新买入仍严格 | `held_flag`、actual holding、hard5 replacement | 需要真实路径反事实，避免只读近似误判 |

首轮优先级应是：先验证 `回撤后普反修复`、`连续小步上涨`、`持仓续持优先于新买` 三类。它们最直接对应用户观察到的 hard5 误杀反弹问题，且比“全面追高”风险小。

## 实验参数矩阵

正式实验不能只测试一个“修复性高分放行”版本，必须把以下自由度预注册成小矩阵，先做只读反事实，再决定是否进入 formal。

### 1. 修复性高分定义

`score > 5` 不是一个足够精细的状态。首轮建议把修复性高分拆成三个桶：

| 桶 | 定义 | 研究含义 |
| --- | --- | --- |
| repair_score_5_6 | `5 < score <= 6` | 最可能是 hard5 机械误杀区，优先验证 |
| repair_score_6_7 | `6 < score <= 7` | 趋势更强，但过热风险也更高 |
| repair_score_gt7 | `score > 7` | 只做风险观察，原则上不先放开 |

修复条件也要有档位：

| 条件 | 档位 |
| --- | --- |
| prior_drawdown | `>=8%`、`>=10%`、`>=15%` |
| market_rebound_breadth | `>=55%`、`>=65%`、`>=75%` |
| ret5 修复速度 | `3%-8%`、`5%-12%`、`8%-15%` |
| jump_ratio 上限 | `<=45%`、`<=55%` |
| max_daily_return_20 上限 | `<=6%`、`<=8%`、不限制 |

首轮主假设不应使用全组合爆炸网格，而是固定三组代表性规则：

| 规则 | 用途 |
| --- | --- |
| conservative_repair | `5<score<=6`、回撤 `>=10%`、广度 `>=65%`、jump_ratio `<=45%` |
| balanced_repair | `5<score<=7`、回撤 `>=8%`、广度 `>=55%`、jump_ratio `<=55%` |
| stress_repair | `score>5`、回撤 `>=10%`、广度 `>=65%`、不限制 jump，用来观察过热误伤边界 |

### 2. 预算大小

预算不能只写“小预算”，必须明确候选档：

| 预算档 | 含义 |
| --- | --- |
| hold_only | 已持有标的允许续持，不新增买入 |
| cap30 | 修复性高分最多拿目标风险仓的 30% |
| cap50 | 修复性高分最多拿目标风险仓的 50% |
| cap70 | 对齐 A22 cap70，上限较高，仅作挑战组 |
| full_allow | 正控，观察全面放开会造成多大风险，不作为候选 |

第一轮最重要的是 `hold_only` 和 `cap30`。如果这两档都没有优势，说明机制本身可能不成立；如果只有 `cap70/full_allow` 有优势，优先怀疑强趋势样本拟合。

### 3. 剩余预算去向

剩余预算不能默认消失，也不能默认全给 next-best。必须单独比较：

| 剩余预算路由 | 说明 | 适合检验的问题 |
| --- | --- | --- |
| keep_cash | 剩余转现金或防御仓 | 放开失败时是否能控制回撤 |
| hard5_next_best | 剩余给原 hard5 选择的替代标的 | 判断修复标的相对 hard5 备选是否更好 |
| current_holding_rest | 剩余留给原持仓或旧仓 | 判断是否应减少切换 |
| defensive_asset | 剩余给当前防御资产或低风险资产 | 判断反弹修复是否只应拿小仓 |
| pro_rata_topk | 剩余按 TopK 非过热标的分散 | 判断是否因集中追高导致风险 |

首轮只读面板至少要报告 `hard5_next_best`、`keep_cash`、`current_holding_rest` 三个路由。formal 阶段再决定是否加入 `defensive_asset` 和 `pro_rata_topk`。

### 4. 持仓和新买入分流

必须分四类事件，不允许混在一起：

| 事件类型 | 初始动作建议 |
| --- | --- |
| held_repair | 当前已持有，且满足修复条件；优先测试续持 |
| rebuy_repair | 近期刚卖出或降仓，现在重新满足修复条件；只读观察 |
| new_buy_repair | 未持有的新标的满足修复条件；更严格，只能 cap30 起步 |
| chase_hot | 无明显回撤修复，只是高分上涨；继续 hard5 或只做风险观察 |

如果 `held_repair` 有效而 `new_buy_repair` 无效，后续动作只能做持仓续持例外，不能推广为追高买入规则。

### 5. 输出指标

每个矩阵单元必须输出：

- `event_count`
- `mean_h5/h10_vs_hard5_next_best`
- `median_h5/h10_vs_hard5_next_best`
- `win_rate_h5/h10`
- `left_tail_h10`
- `max_adverse_excursion_h10`
- `turnover_delta`
- `missed_rebound_capture_ratio`
- `false_allow_loss_count`
- 分段结果：2020_2021、2022_2023、2024、2025_20260519、post_design forward

### 6. 证伪边界

任一候选进入 formal 前，至少满足：

- `held_repair` 事件数不少于 30；全部事件不少于 50。
- H5/H10 均值为正，且中位数不显著为负。
- 胜率不低于 `52%`。
- 至少 `3/4` 历史分段方向一致。
- `shift_next1`、`shift_prev1`、同日随机同规模、无普反同回撤桶都不能复制主结果。
- `full_allow` 如果远强于所有小预算候选，不能直接晋级；必须解释为什么不是强趋势窗口拟合。
- `repair_score_gt7` 若下尾损失明显恶化，则后续规则必须显式排除 `score>7`。

## 风险

- 数据是否可得：日频价格、成交量、持仓、候选排序和 hard5 替代路径可得；PSY/GSADF、tail risk、FIP 代理可先用日频实现；真实盘口/订单层不是本机制第一阶段必要条件。
- 是否可能未来函数：所有状态字段必须只使用 `signal_date` 当时可见数据；52 周高点、局部高点回撤和成交量冲击都要严格排除未来日；持仓续持标签只能用于事后评估，不能反向写入信号。
- 是否可能过拟合：风险很高。A19、A20、FIPQ、KFSQ 都显示过“只读有线索但负控或外部样本不足”。第一阶段必须只读，不允许直接动作化。
- 是否影响交易成本：如果用于新买入放行，可能增加换手；如果先用于 hold-only 续持例外，成本影响较小，更适合作为首轮。

## 升级为实验的条件

- 先新建只读实验：`hard5 反弹修复误杀只读面板`。
- 事件定义必须预注册：
  - 当前持仓或 raw Top1 被 hard5/A22 类规则限制；
  - 标的此前存在 `>=8%` 或 `>=10%` 的局部回撤；
  - 当天或近 3 日市场进入普反状态；
  - 标的 score 抬升但不允许直接解释为有效。
- 第一轮只读门槛：
  - `blocked_repair_event_count >= 50`，若不足只能记为案例库；
  - H5/H10 相对 hard5 实际替代的均值为正；
  - H5/H10 胜率不低于 `52%`；
  - 至少 `3/4` 分段方向一致；
  - 同日随机候选、错位状态 `shift_next1/shift_prev1`、无普反同回撤桶负控不能复制主结果；
  - false-allow 的下尾损失不能超过 hard5 基线可接受边界。
- 如果只读通过，第二阶段优先做 `hold-only repair exception`，即只允许当前持仓在修复期续持，不先放开新买入。
- 禁止事项：不得直接把 `ret5`、`FIP`、`52周高点`、`PSY` 或 `tail risk` 任一单项指标写成交易规则；不得在看完结果后扩阈值网格；不得绕过 A19/A20 已有反证。

## 子代理调用记录

- 任务代号：SUBTASK-HARD5-MATH-LITERATURE
- 调用 ID：SUB-EXEMPT-20260619T021800Z-main-HOT-MATH-LIT
- 平台昵称：无
- 模型：无
- 发起时间：2026-06-19T02:18:00Z
- 读取文件：README.md；00_入口/研究驾驶舱.md；00_入口/当前状态.md；08_方法论/研究方法论.md；08_方法论/研究质量审计规范.md；08_方法论/平台协作规范.md；08_方法论/子代理调度规范.md；相关文献台账；H6V3/A19/AURT 摘要
- 修改文件：本机制卡
- 执行命令：Firecrawl search 检索动量崩溃、FIP、PSY 多重泡沫、52 周高点、MAX/l彩票式过热、尾部风险和 regime switching 相关来源
- 结论边界：只形成机制灵感和实验设计，不构成有效策略，不改变 hard5 默认逻辑
- 风险点：文献多来自股票横截面或市场指数，直接迁移到 ETF 双池轮动可能失效；必须做只读面板、错位/随机/分段负控和后续 formal
- 主控复核：采用为下一轮只读面板设计依据
- 结果对决策影响：不改变当前决策；支持新建反弹修复误杀只读实验
