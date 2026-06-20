---
type: 实验记录
ex_id: EX-20260617T151048Z-main-MYHU
rd_id: RD-20260613T002916Z-main-5BNB
status: completed
stage: readonly_listwise_v2_failed
owner: main
created_at: 2026-06-17T15:10:48Z
updated_at: 2026-06-17T15:18:00Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 核心轮动诊断模块
decision_ids: [DEC-20260617T151659Z-main-UAYF]
lit_ids: [LIT-20260613T002924Z-main-RY67]
idea_ids: []
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths:
  - scripts/research/analyze_5bnb_listwise_ranker_v2.py
result_paths:
  - results/v2/research/RD-20260613T002916Z-main-5BNB/EX-20260617T151048Z-main-MYHU/
summary_paths:
  - results/v2/research/RD-20260613T002916Z-main-5BNB/EX-20260617T151048Z-main-MYHU/summary.json
quality_gate: readonly_pass_false_main_guard_failed
subagent_call_ids: []
subagent_exemption: 系统工具要求只有用户显式授权子代理时才可调用；本轮用户未显式授权，主控直接执行并记录豁免。
tags: [双池轮动, 盘中事件, R方之外, listwise-ranker, 前热残余过滤, 只读面板, 预注册, no-live-change]
---

# R方之外Listwise排序与前热残余过滤只读面板

## 关联链接

- 研究方向：[[02_研究方向/RD-20260613T002916Z-main-5BNB_双池轮动盘中可交易热点事件诊断|双池轮动盘中可交易热点事件诊断]]
- 前序实验：[[04_实验记录/EX-20260617T150155Z-main-GU38_R方之外滚动收缩排序只读面板|GU38 R方之外滚动收缩排序只读面板]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 来源文献或灵感：[[06_文献资料/00_待处理/LIT-20260613T002924Z-main-RY67_顶刊盘中交易与注意力机制灵感综述|顶刊盘中交易与注意力机制灵感综述]]
- 术语：[[09_术语库/术语库#Learning-to-rank|Learning-to-rank]]；[[09_术语库/术语库#排序损失|排序损失]]；[[09_术语库/术语库#收缩排序|收缩排序]]
- 产生的决策：无。本轮只读，不改默认策略。
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：GU38 已经证明“直接预测未来 H5 超额收益”比 R² 和阈值更接近问题，但仍输给前移一日同代码。MYHU 进一步把目标改成同日横截面排序，并显式处理前 5 日同代码/同主题已热残余，看是否能减少滞后。

我们原本预计：如果 GU38 的失败主要来自标签和候选池仍混入旧热点残余，那么 listwise 排序 + 前热残余过滤应当提高 H5 相对 hard5 的中位数、胜率，并打赢前移一日同代码。

实际看到：主模型 `listwise_code_guard` 的 H5 均值 `0.5311%`，高于 hard5 `0.4552%`、随机权重 `0.2550%`、错位 rank `0.3977%` 和同日随机 `0.1505%`；但 H5 超额中位数仍为 `0`，超额胜率 `49.81%`，分段只有 `2/4` 正，前移一日同代码 H5 均值 `0.5725%` 仍高于主模型。更重要的是，去掉前热过滤的 `listwise_no_guard` H5 均值 `0.7253%`，高于主模型，说明前热过滤没有修复问题，反而削弱了收益。

这说明：MYHU 未能把 GU38 的“有增量但不稳定”推进到可交易证据。13:09 盘中热点单线已经连续被 Top1、首次冲击、滚动收缩排序和 listwise 前热过滤负控阻断，应当 park。

但还不能说明：通过也只是只读排序面板，不等于组合回测，不允许直接写入策略或 shadow。

下一步要做：实现无新依赖的滚动 listwise ridge v2，前台可见运行，结果同步到本实验记录和台账。

## 2. 研究背景

本实验属于 [[02_研究方向/RD-20260613T002916Z-main-5BNB_双池轮动盘中可交易热点事件诊断|5BNB]]。前序 GU38 使用滚动 IC/Ridge 收缩直接预测未来 H5 相对 hard5 超额收益，已经打赢随机权重、错位标签和同日随机，但两个核心门槛失败：

- H5 超额中位数仍为 `0`，超额胜率约 `45%`。
- 前移一日同代码 H5 均值 `0.9539%` 高于主模型 `0.5538%/0.5448%`。

这说明直接收益回归有信息，但仍可能在追“旧热度残余”。MYHU 不继续调 GU38 的窗口、lambda 或特征池，而是改变两个机制：

- 标签从收益数值改为同日横截面 label rank，更贴近轮动排序任务。
- 选择池排除前 5 个交易日同代码已热，另设同主题残余严格变体，专门审计前移一日负控。

## 3. 实验前假设

若 GU38 的剩余失败主要来自“旧热点残余”和“收益回归不等于排序任务”，则滚动 listwise 排序加前热残余过滤，应比 GU38、hard5、随机权重、错位标签和前移一日同代码更稳定。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：主模型 `listwise_code_guard` 的 H5 相对 hard5 均值和中位数为正，超额胜率不低于 `52%`。
- 交易行为：本轮不下单，不撮合；每日从 13:09 前可见候选池只读选择一个 ETF，以 13:10 close proxy 开始计算 H0/H1/H3/H5 标签。
- 风险表现：若旧热点残余过滤有效，前移一日同代码控制不应再强于主模型。
- 分段表现：2020_2021、2022_2023、2024、2025_20260519 四段中，至少 `3/4` 分段 H5 相对 hard5 均值为正。

固定口径：

```text
input_panel = results/v2/research/RD-20260613T002916Z-main-5BNB/EX-20260617T144855Z-main-VZDA/first_shock_candidate_panel.csv
candidate_base = full_event_ready == true
label = date-wise percentile rank of (ret_1310_to_h5 - same_day_hard5_ret_h5), centered at 0
train_window_days = 504
label_gap_days = 5
min_train_days = 252
ridge_lambda = 10
stale_window_days = 5
code_hot_today = intraday_rank_1309 <= 10 AND ret_prevclose_to_1309_fixed >= 0.01
theme_hot_today = any ETF in same theme with intraday_rank_1309 <= 10 AND ret_prevclose_to_1309_fixed >= 0.02
code_guard = prev5_code_hot_count == 0
theme_guard = prev5_theme_hot_days <= 2
```

固定选择器：

```text
listwise_no_guard: train/select candidate_base
listwise_code_guard: train/select candidate_base AND code_guard
listwise_code_theme_guard: train/select candidate_base AND code_guard AND theme_guard
random_weight_score: fixed random weights on same features
shuffled_rank_score: rolling listwise ridge with date-wise shuffled rank labels
```

主模型为 `listwise_code_guard`。`listwise_code_theme_guard` 是严格变体，只作为支持或反对证据，不以后验替代主模型。

固定特征池：

```text
score_25d
score_5d
volume_ratio
ret_prevclose_to_1309_fixed
ret_open_to_1309
close_vs_vwap_1309
drawdown_from_high_1309
intraday_rank_1309
theme_top10_positive_count
theme_top10_pos_ret_share
prev5_code_hot_count
prev5_theme_hot_days
```

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| hard5 proxy | 当前默认日线候选代理。 | 现场从 VZDA candidate panel 构造 |
| listwise_no_guard | 检查 listwise 标签本身是否有增量。 | `scripts/research/analyze_5bnb_listwise_ranker_v2.py` |
| listwise_code_guard | 主模型，检查排除前 5 日同代码已热后是否减少滞后。 | 同上 |
| listwise_code_theme_guard | 严格变体，检查同主题残余是否仍污染。 | 同上 |
| random_weight_score | 固定随机权重控制。 | 同上 |
| shuffled_rank_score | 日期内 rank 标签错位控制。 | 同上 |
| 同日随机 ETF | 检查是否只是当天 ETF 普涨。 | 固定种子 `20260617`，每个可选日期 `100` 次抽样 |
| 前移/后移一日同代码 | 检查时点是否仍滞后或提前。 | 同一 ETF 错位日期标签 |

## 6. 竞争性解释

即使结果符合预期，也可能是：

- 过滤前热残余后样本变少，均值改善可能来自少数年份或主题。
- 前 5 日窗口可能不足以覆盖更慢的主题热度残余。
- 13:09 候选池仍来自价格结果变量，缺少真实订单流。
- 只读选择每日一个 ETF，不含真实换手、成本、滑点和容量。
- 复用 VZDA candidate panel，仍继承 9QRG/VGMH 的候选母集边界。

## 7. 证伪条件

出现以下情况，本假设不通过：

- 主模型可评估事件数低于 `500`。
- 主模型 H5 相对 hard5 均值或中位数不为正。
- 主模型 H5 相对 hard5 胜率低于 `52%`。
- 主模型 H5 均值不高于 hard5、GU38、随机权重、错位标签或同日随机。
- H5 相对 hard5 正均值分段少于 `3/4`。
- 前移一日同代码 H5 均值仍高于主模型。
- 结果主要来自少数主题、少数 ETF 或单一分段。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 预检查通过 | 特征均来自 13:09 前、前 5 个交易日或历史训练标签。 |
| 信号生成和成交价格不存在同 bar 泄漏 | 预检查通过 | 选择日信号使用 13:09 前字段，收益从 13:10 close proxy 计算。 |
| 训练标签不存在近期泄漏 | 预检查通过 | 任一预测日训练样本只使用至少 `5` 个交易日前的 H5 标签。 |
| 股票池或 ETF 池不存在未来成分泄漏 | 有边界 | 复用 9QRG/VGMH/VZDA 候选母集；本轮只读，不声明完整动态池无泄漏。 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 本轮不使用财务、宏观或估值。 |
| Shadow 或观察信号未被当成默认交易信号 | 通过 | 本轮不写交易配置，不改默认策略，不改实盘。 |

负控或错位检查：

- 随机权重模型。
- 标签错位模型。
- 同日随机 ETF。
- 前移/后移一日同代码。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | 固定训练窗口、gap、lambda、前热窗口、主模型和特征池。 |
| 样本内、验证集、样本外划分清楚 | 通过 | 每个预测日只用过去滚动窗口训练，天然滚动样本外。 |
| 邻近参数敏感性合理 | 未做 | 本轮只验证一个 v2 机制，不看结果调窗口或过滤阈值。 |
| 成本、滑点或换手扰动已检查 | 不适用 | 本轮不是组合回测，只读 H0/H1/H3/H5 毛收益标签。 |
| 已做消融或负控 | 通过 | 已输出 no_guard、code_guard、code_theme_guard、随机权重、错位标签、同日随机和前后错位。 |
| 未只报告最优结果 | 通过 | 主模型固定为 code_guard；no_guard 虽收益更高但未以后验替代主模型。 |

证据等级：`L2_readonly_listwise_ranker_v2_failed`。不进入交易回测或实盘。

## 10. 子代理调用记录

适配判断：`适合调用，但系统工具边界禁止本轮调用`

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：系统工具要求只有用户显式要求子代理/委派/并行 agent 工作时才可调用；本轮用户未显式授权；主控：main；时间：2026-06-17T15:10:56Z
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 无 | 无 | 无 | 无 | 无 | 无 | 无 | 无 | 系统工具授权边界，不代表任务不适合子代理 | 主控需自行复核脚本、输出和负控 | 已复核脚本、日志、summary 和负控表 | 本轮不改默认策略；MYHU 支持 5BNB park |

台账行：不新增子代理调用台账；正文记录系统工具授权豁免。

## 11. 执行记录

### 平台配置

```text
scripts/research/analyze_5bnb_listwise_ranker_v2.py
```

### 运行命令

```bash
cd ${QUANT_PLATFORM_ROOT}
set -o pipefail && PYTHONUNBUFFERED=1 PYTHONPATH=src python3 scripts/research/analyze_5bnb_listwise_ranker_v2.py 2>&1 | tee results/v2/research/RD-20260613T002916Z-main-5BNB/EX-20260617T151048Z-main-MYHU/run.log
```

### 可见进度与日志

- 是否过程可见：`是`
- 日志路径：`results/v2/research/RD-20260613T002916Z-main-5BNB/EX-20260617T151048Z-main-MYHU/run.log`
- 查看进度命令：前台运行时直接查看终端；运行后查看 `run.log`。
- 异常判断：正式运行返回 `exit_status=0`；`readonly_pass=false` 是研究门槛失败，不是脚本失败。
- 后台回测豁免：无，正式运行前台可见。

```text
无后台或静默运行。
```

### 结果路径

```text
results/v2/research/RD-20260613T002916Z-main-5BNB/EX-20260617T151048Z-main-MYHU/
```

主要输出：

```text
prediction_panel.csv
selector_event_panel.csv
model_weight_history.csv
control_return_panel.csv
summary_by_control.csv
summary_by_control_event_segment.csv
random_draw_summary.csv
summary.json
run.log
```

## 12. 实际观察

总体：`1285` 个滚动样本外事件日；VZDA 原始候选 `88198` 行，`full_event_ready=88115`，`code_guard_rows=58308`，`code_theme_guard_rows=53750`。

H5 主结果：

| 控制组 | 事件数 | H0均值 | H1均值 | H3均值 | H5均值 | H5中位数 | H5胜率 | H5相对hard5均值 | H5相对hard5中位数 | H5相对hard5胜率 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| listwise_no_guard | 1285 | 0.2763% | 0.3997% | 0.6242% | 0.7253% | 0.1732% | 61.17% | 0.2701% | 0.0000% | 47.78% |
| listwise_code_guard | 1285 | 0.2871% | 0.3592% | 0.4253% | 0.5311% | 0.1101% | 62.96% | 0.0759% | 0.0000% | 49.81% |
| listwise_code_theme_guard | 1285 | 0.2908% | 0.3872% | 0.4157% | 0.4801% | 0.1252% | 63.81% | 0.0249% | 0.0000% | 49.42% |
| random_weight_score | 1285 | -0.0126% | 0.0069% | 0.1122% | 0.2550% | 0.0421% | 58.21% | -0.2003% | 0.0000% | 49.81% |
| shuffled_rank_score | 1285 | 0.0729% | 0.2623% | 0.2804% | 0.3977% | 0.0534% | 58.83% | -0.0575% | 0.0667% | 50.82% |
| hard5_proxy | 1285 | 0.0409% | 0.1374% | 0.3433% | 0.4552% | 0.0273% | 50.19% | 0.0000% | 0.0000% | 0.00% |
| listwise_code_guard_delayed_h0 | 1285 | 0.0000% | 0.0717% | 0.1368% | 0.2427% | 0.0593% | 58.13% | -0.2126% | 0.0822% | 51.36% |
| random_same_day_code_guard | 1285 | 0.0404% | 0.0677% | 0.1097% | 0.1505% | 0.0433% | 60.61% | -0.3047% | 0.0000% | 49.94% |
| shift_next1_same_code | 1158 | 0.2981% | 0.2863% | 0.3623% | 0.4427% | 0.1214% | 63.47% | -0.0318% | 0.1228% | 51.64% |
| shift_prev1_same_code | 1103 | 0.3049% | 0.4644% | 0.5242% | 0.5725% | 0.1431% | 64.91% | 0.2036% | 0.4575% | 54.31% |

分段结果：

| 模型 | 分段 | 事件数 | H5均值 | H5中位数 | H5胜率 | H5相对hard5均值 | H5相对hard5中位数 | H5相对hard5胜率 |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| listwise_no_guard | 2020_2021 | 229 | 0.6127% | 0.1211% | 55.90% | 0.1297% | 0.0000% | 48.47% |
| listwise_no_guard | 2022_2023 | 484 | 0.2817% | 0.0310% | 56.20% | 0.3413% | 0.0000% | 41.53% |
| listwise_no_guard | 2024 | 242 | 1.5564% | 2.0008% | 83.06% | 1.1907% | 1.3751% | 59.50% |
| listwise_no_guard | 2025_20260519 | 330 | 0.8447% | 0.0770% | 56.06% | -0.4121% | 0.0000% | 47.88% |
| listwise_code_guard | 2020_2021 | 229 | 0.3327% | 0.0387% | 55.46% | -0.1503% | 0.0000% | 44.54% |
| listwise_code_guard | 2022_2023 | 484 | 0.2002% | 0.0310% | 58.26% | 0.2598% | 0.0000% | 46.69% |
| listwise_code_guard | 2024 | 242 | 1.4187% | 1.9936% | 85.54% | 1.0530% | 1.5303% | 62.40% |
| listwise_code_guard | 2025_20260519 | 330 | 0.5034% | 0.0662% | 58.48% | -0.7533% | 0.0000% | 48.79% |
| listwise_code_theme_guard | 2020_2021 | 229 | 0.3457% | 0.0333% | 51.97% | -0.1373% | 0.0000% | 42.79% |
| listwise_code_theme_guard | 2022_2023 | 484 | 0.2692% | 0.0419% | 59.92% | 0.3289% | 0.0000% | 47.31% |
| listwise_code_theme_guard | 2024 | 242 | 1.2517% | 1.9936% | 86.36% | 0.8859% | 1.6162% | 61.98% |
| listwise_code_theme_guard | 2025_20260519 | 330 | 0.3168% | 0.0655% | 61.21% | -0.9399% | -0.0152% | 47.88% |

质量门槛：

| 门槛 | 结果 |
| --- | --- |
| `event_count_ge_500` | true |
| `h5_excess_mean_positive` | true |
| `h5_excess_median_positive` | false |
| `h5_excess_winrate_ge_52pct` | false |
| `segments_h5_excess_mean_positive_ge_3_of_4` | false |
| `beats_no_guard_h5_mean` | false |
| `beats_random_weight_h5_mean` | true |
| `beats_shuffled_rank_h5_mean` | true |
| `beats_random_same_day_h5_mean` | true |
| `beats_shift_prev1_h5_mean` | false |
| `selector_pass` | false |
| `readonly_pass` | false |

## 13. 支持证据

- 主模型 `listwise_code_guard` 打赢 hard5、随机权重、错位 rank、同日随机和延迟入场，说明 listwise 排序仍含有可解释信息。
- 原始 H5 胜率较高：主模型 `62.96%`，严格变体 `63.81%`，高于 hard5 `50.19%`。
- 2024 段改善明显，主模型 H5 均值 `1.4187%`，相对 hard5 均值 `1.0530%`。

## 14. 反对证据

- 主模型没有打赢 `listwise_no_guard`：H5 均值 `0.5311%` vs `0.7253%`，说明前热残余过滤不是有效修复。
- H5 相对 hard5 中位数仍为 `0`，超额胜率 `49.81%`，低于 `52%` 门槛。
- 分段只有 `2/4` H5 超额均值为正，2020_2021 和 2025_20260519 对 hard5 为负。
- 前移一日同代码 H5 均值 `0.5725%` 仍高于主模型 `0.5311%`，前移负控未解除。

## 15. 偏差诊断

实验前预测认为 code_guard 应该减少旧热度残余并改善前移一日负控。实际相反：code_guard 和 code+theme_guard 都比 no_guard 弱，说明“前 5 日同代码/同主题已热”不是当前剩余滞后的主要解释，或过滤方式丢掉了本来有延续价值的事件。

这使 5BNB 的问题从“缺一个更聪明的阈值/排序器”转成更本质的问题：13:09 盘中热点仍主要由已经形成的价格与主题走势驱动，少数强日能提高均值，但不稳定到足以替代 hard5 或通过负控。

## 16. 研究判断

建议状态：`park`

理由：VGMH、VZDA、GU38、MYHU 连续只读推进后，朴素 Top1、首次冲击、滚动收缩收益排序、listwise 前热过滤均未通过门槛。MYHU 进一步反证了“只要过滤旧热度残余就能解决滞后”的修订假设。本方向不应继续单线投入。

## 17. 下一步

已新增 [[05_研究决策/DEC-20260617T151659Z-main-UAYF_盘中热点与R方之外排序连续负控失败后park|UAYF 5BNB park 决策卡]]。后续若还使用本方向成果，只能把 R² 之外排序、注意力反转、订单压力弱代理等方法迁移到更广义的核心轮动模型中，不能继续围绕 13:09 盘中热点单线调参。
