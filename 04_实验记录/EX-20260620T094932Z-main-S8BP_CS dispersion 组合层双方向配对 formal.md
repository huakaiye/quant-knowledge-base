---
type: 实验记录
ex_id: EX-20260620T094932Z-main-S8BP
rd_id: RD-20260620T052147Z-main-8AB7
status: park
stage: completed
owner: main
created_at: 2026-06-20T09:49:32Z
updated_at: 2026-06-20T18:30:00Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 组合层横截面离散度保守开关 formal
decision_ids: [DEC-20260620T150805Z-main-XSNQ]
lit_ids: [LIT-20260620T052147Z-main-86GQ]
idea_ids: [MECH-20260619T025934Z-main-DQUM, MECH-20260620T154044Z-main-MATN, MECH-20260620T154049Z-main-2JVB]
platform_project: ${LEGACY_QUANT_PLATFORM_ROOT}
config_paths: [configs/research/R010-A22/cs_dispersion_paired/EX-20260620T094932Z-main-S8BP/formal/manifest.json]
result_paths: [results/v2/research/R010-A22/cs_dispersion_paired/EX-20260620T094932Z-main-S8BP/formal]
summary_paths: [results/v2/research/R010-A22/cs_dispersion_paired/EX-20260620T094932Z-main-S8BP/summary/formal/summary.json]
quality_gate: completed_not_passed
subagent_call_ids: [SUB-20260620T130000Z-main-A7K3, SUB-20260620T150000Z-main-D4E6, SUB-20260620T153000Z-main-E7F8]
subagent_exemption: 预注册的研究假设、证伪规则、未来函数审计、方向判断和最终 park 决策由主控承担；SUB-A7K3 提取阈值、SUB-D4E6 盘点术语库/方向页、SUB-E7F8 储备顶刊灵感，均不独立决定决策状态；主控：main；时间：2026-06-20T18:30:00Z
tags: [双池轮动, hard5, CS-dispersion, 横截面离散度, 组合层开关, 双方向配对, formal, park, 参数矩阵无必要]
---

# CS dispersion 组合层双方向配对 formal

## 关联链接

- 研究方向：[[02_研究方向/RD-20260620T052147Z-main-8AB7_双池轮动横截面离散度组合层保守开关|双池轮动横截面离散度组合层保守开关]]
- 父方向：[[02_研究方向/RD-20260605T133318Z-main-H6V3_双池轮动score过热拥挤机制模块|双池轮动 score 过热拥挤机制模块]]（H6V3）
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 上游只读面板（全门槛通过，本实验来源）：[[04_实验记录/EX-20260620T052156Z-main-BL8Y_横截面离散度组合层保守开关只读面板预注册|BL8Y CS dispersion 只读面板]]
- 上游决策：[[05_研究决策/DEC-20260620T063105Z-main-7TBK_横截面离散度observeM10正交性成立|DEC-7TBK CS dispersion 升级 promote_candidate]]
- 来源文献：[[06_文献资料/00_待处理/LIT-20260620T052147Z-main-86GQ_横截面收益离散度StiversSun2010|横截面收益离散度 Stivers Sun 2010]]
- 关联框架（`p_crash` 组合层字段）：[[07_因子数据灵感/03_机制/MECH-20260619T025934Z-main-DQUM_hard5过热概率与反弹修复状态框架|hard5 过热概率与反弹修复状态框架]]
- 姊妹方向（MAX p_overheat，A29 frozen-veto formal）：[[04_实验记录/EX-20260619T113348Z-main-UN96_A28非QMT量价结构状态机数据门禁|A28 量价结构门禁]]、[[05_研究决策/DEC-20260619T114146Z-main-5E5G_A28量价结构门禁通过后转过热veto正式实验|DEC-5E5G]]
- 同口径模板（成本扰动 + strict 门禁）：[[04_实验记录/EX-20260607T103055Z-main-K3AC_A23同成本配对formal AB预注册|K3AC A22/A23 同成本配对 formal]]
- 产生的决策：（待执行后产生）
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：BL8Y 只读面板已经发现"横截面离散度"（当日全 ETF 池收益的分化程度）这个组合层信号，在 hard5 高分事件上确实把"该不该追高"分成了两类。现在要把这个信号真正接进策略，按四段历史（2020-2026）正式回测，看它能不能替代或补充默认的 hard5。

我们原本预计：基于 BL8Y 实测数据，低离散日（普涨）的 hard5 高分标的后续 H10 比 hard5 保守持仓多赚 +3.13%（胜率 56.9%），高离散日反而少赚 -1.68%。所以"低离散日放行追高（cap70）、其他日维持 hard5"这个候选可能成立。**但这次数据方向与 Stivers-Sun 2010 理论及研究库文档表述相反**，为避免赌错，本轮同时测两个方向（低离散放行 vs 高离散放行），让四段数据自己裁决。

实际看到：（待执行后填写）

这说明：（待执行后填写）

但还不能说明：（待执行后填写）

下一步要做：（待执行后填写）

## 2. 研究背景

### 2.1 为什么现在做

BL8Y（`EX-20260620T052156Z-main-BL8Y`）已把 CS dispersion 做成只读面板，经 2020 版扩展（361 事件/7 段）和错位负控 bug 修复（`build_daily_lookup` 补 `hard5_first_qmt` baseline，valid_count 54→307）后**全门槛通过**（passes_gate=True）：

- 低离散桶（decile 0-1）73 事件，H10 effect +0.0313、胜率 56.9%。
- 高离散桶（decile 8-9）72 事件，H10 effect −0.0168、胜率 40.6%。
- 低 vs 高 effect 差 +0.0481，分段一致 3/5（2023/2025/2026 正，2022/2024 负）。
- M10 市场趋势正交性成立（市场涨+低离散 +0.034 vs 高离散 −0.013）。
- 错位负控不反转（shift_prev1 +0.017），随机负控不可复制。

DEC-7TBK 据此把 CS dispersion 升级 `promote_candidate`，明确"进入 formal 候选"。它是三个顶刊正交维度（MAX/GSADF/CS dispersion）中唯一全门槛通过的方向，所以本轮主攻它。

### 2.2 关键方向矛盾（必须在预注册阶段说清）

BL8Y 的 effect 符号经核实（`analyze_r010a16_hot_state_panel.py:277`，`raw_top_diff_h10_vs_hard5 = 追高标的收益 − hard5保守持仓收益`，正值=追高胜=hard5误杀）：

- **实测数据方向**：低离散日 hard5 误杀（应放行追高），高离散日 hard5 正确（应维持保守）。
- **Stivers-Sun 2010 理论**：高离散=分化健康=动量有效=可追高，低离散=普涨普跌=动量失效=应保守。
- **研究库现有文档**（驾驶舱 L301、DEC-7TBK、BL8Y §16）：沿用理论表述，写"低离散保守、高离散允许追高"，**与实测符号相反**。

本轮采用**双方向配对**设计，不预设立场。formal 完成后无论结论如何，都回头修正研究库文档的方向符号解释（见 §17 follow-up，不阻塞本轮）。

### 2.3 与已 park 路线的区分

CS dispersion 是**组合层/日期级**信号（每个交易日全池算一个标量），不精修 score 阈值，不复活任何已 park 路线：

- 不是 A20/A21 市场状态条件化（那是 MA20 广度+slope+ret5，M10 同族），CS dispersion 与 M10 正交。
- 不是 G4NN 宽基波动率缩放（那是波动率族），CS dispersion 经 M10 正交性确认不退化。
- 不是 MAX 十分位或 GSADF（那是 p_overheat 过程/单日跳），CS dispersion 是 p_crash 横截面分化。

## 3. 实验前假设

一句话：把 CS dispersion 作为组合层状态 gate，当日 dispersion 落在某一端（低或高）时对高分标的放开 A22 cap70 风险预算（允许 score>=5，risk_cap=0.70），其余日维持 hard5；在四段历史中，至少有一个方向能让组合 final 4/4 段不低于 hard5 且 3/4 段 MDD 不差，且该优势在 cost2x/slip2bps 下不消失，而另一方向作为负控不满足。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标（某 cand 对 baseline_hard5）：
  - final 4/4 段不低于 hard5。
  - MDD ≥3/4 段不差于 hard5。
  - 交易数变化可解释（放行日多开仓，其余日等同 hard5）。
- 交易行为：loosen 日 hard5 高分标的不被拦截，按 risk_cap=0.70 占位；非 loosen 日与 hard5 一致。
- 风险表现：cand 的 loosen 日若普涨冲顶后回落，组合回撤应不超过 hard5（否则 cap70 放行反而有害，是反证）。
- 分段表现：基于 BL8Y 分段（低离散 3/5 段正），预测 `cand_loosen_on_low_disp` 更可能赢，`cand_loosen_on_high_disp` 更可能输或平；但本轮不预设结果，两候选都跑。
- 负控预测：两候选不应同时满足门槛（若都满足，说明 cap70 放行本身在驱动而非 dispersion gate，需二次裁决）。

## 5. 基准和对照

| 对照 | 用途 | 关键配置 |
| --- | --- | --- |
| `baseline_hard5` | 主对比基准，当前生产默认 | `max_score=5, score_hot_filter_mode=hard_cap`，cs_dispersion_gate disabled |
| `ref_a22_cap70_always` | 上界参照，无条件 cap70（验证"是否 dispersion gate 本身有信息量，还是单纯放行就赢"） | `r010a22_hot_score_budget_enabled=true, base_risk_cap=0.70, loosen_direction=disabled（全程 cap70）` |
| `cand_loosen_on_low_disp` | 候选1：低离散日→cap70，其他→hard5 | cs_dispersion_gate enabled, loosen_direction=low |
| `cand_loosen_on_high_disp` | 候选2：高离散日→cap70，其他→hard5 | cs_dispersion_gate enabled, loosen_direction=high |

四段：2020-01-01~2021-12-31 / 2022-01-01~2023-12-31 / 2024-01-01~2024-12-31 / 2025-01-01~2026-05-19（同 K3AC/A22N）。
成本：cost1x（commission 0.0001，无 slippage）+ cost2x_slip2bps（commission 0.0002，slippage_bps=2.0）。
配对矩阵：4 变体 × 4 段 × 2 成本 = 32 回测。

## 6. 竞争性解释

即使某候选 4/4 赢 hard5，也可能是：

- cap70 单纯放行驱动，与 dispersion 无关（需对照 `ref_a22_cap70_always`：若 cand ≈ ref，说明 gate 无信息量）。
- 历史分段不足：BL8Y 低离散桶 H10 只 3/5 段正（2022/2024 负），组合层可能更脆弱。
- decile 切点（0.0112 / 0.0148）是 BL8Y v2 全样本（2020-2026）冻结值，有样本特定性；2020-2023 早段分布可能漂移。
- ETF 池小（41 代码，pool_count 过滤后标准差统计噪声大）。
- CS dispersion 只是 M10 或波动率的弱代理，formal 跨段后退化（BL8Y M10 正交仅"初步"，市场跌时样本不足）。
- loosen 日触发次数过少，组合层效应被稀释（BL8Y 低离散 73/361 ≈ 20% 事件率，组合层每段触发日数待执行后核对）。

## 7. 证伪条件

出现以下任一，对应候选不通过：

- 该候选 4/4 段 final 不低于 hard5 不成立（即 ≤3/4 段赢）。
- 该候选 ≥3/4 段 MDD 不差于 hard5 不成立。
- 该候选在 cost2x/slip2bps 下门槛被翻转（成本脆弱）。
- 该候选与 `ref_a22_cap70_always` 四段 final 几乎完全相同（差 <0.5%），说明 dispersion gate 无独立信息量，只是 cap70 放行在驱动。
- 该候选 loosen 日触发次数过低（如某段 <5 个交易日），效应不可信。

整体证伪：若两候选都 ≤2/4 段赢 hard5 → CS dispersion 组合层开关整体 `park`（诚实记录），不复活、不后验调 decile 切点/窗口/risk_cap。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 预注册通过（待执行复核） | cs_dispersion_20 = 当日全池 ret1 横截面 std → rolling 20 日均值，只用 signal_date 及之前；BL8Y `future_function_check` valid_ratio=1.0 |
| 信号生成和成交价格不存在同 bar 泄漏 | 预注册通过（待执行复核） | dispersion 是日级状态，不直接用未来价；成交按平台 V2 引擎次日撮合，与 A22 同口径 |
| 股票池或 ETF 池不存在未来成分泄漏 | 预注册通过（待执行复核） | 沿用 A11/A16 既有 hard5 事件池 + ETF 前缀过滤（15/16/50/51/52/56/58），与 BL8Y 同 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 本实验只用日频收盘价 |
| Shadow 或观察信号未被当成默认交易信号 | 预注册通过（待执行复核） | cs_dispersion_gate 默认 enabled=False；hard5 默认路径不受影响（参考 YA5R shadow 隔离口径） |

负控或错位检查：

- 成本扰动负控：cost2x/slip2bps（K3AC 同口径）。
- 上界对照：`ref_a22_cap70_always`（区分"gate 信息量"与"cap70 放行效应"）。
- 反向候选负控：`cand_loosen_on_high_disp` 是 `cand_loosen_on_low_disp` 的方向反控，两候选互验。
- 错位负控：BL8Y 已在事件级完成（shift_prev1/next1 +0.017 不反转）；本轮组合层不再重做事件级错位，但汇总时核对 loosen 触发日分布是否合理。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 是 | 全部参数冻结见下表，不看结果后调 |
| 样本内、验证集、样本外划分清楚 | 部分 | 四段全历史回测；2024 为历史负控段（K3AC 惯例），2025_20260519 含 post-design 但 BL8Y 已用 |
| 邻近参数敏感性合理 | 不在首轮范围 | 首轮固定预注册值；若通过再补窗口 15/25 邻域 |
| 成本、滑点或换手扰动已检查 | 是 | cost1x + cost2x_slip2bps 两套 |
| 已做消融或负控 | 是 | ref_cap70 上界对照 + 反向候选方向负控 + 2024 历史负控段 |
| 未只报告最优结果 | 是 | 两候选、四段、两成本全部报告，含输的一方和反方向段 |

预注册冻结参数（写死，禁止看结果后改）：

| 参数 | 冻结值 | 来源 |
| --- | --- | --- |
| cs_dispersion 窗口 | 20（rolling mean，min_periods=8） | BL8Y `DISP_WINDOW=20` |
| cs_dispersion ret 口径 | ret1 = close_price/pre_close − 1，\|ret1\|>0.5 置 NaN | BL8Y `build_cs_dispersion` |
| pool_count 过滤 | ≥20 才有效 | BL8Y `L191` |
| 低离散阈值（loosen_direction=low 触发） | cs_dispersion_20 ≤ 0.0111815542229467（取整等价 0.0112） | SUB-A7K3 从 BL8Y v2 panel q=0.2 提取 |
| 高离散阈值（loosen_direction=high 触发） | cs_dispersion_20 > 0.0147988704542829（取整等价 0.0148） | SUB-A7K3 从 BL8Y v2 panel q=0.8 提取 |
| loosen 风险预算 | risk_cap=0.70（对齐 A22 cap70） | A22 `r010a22_hot_score_budget_base_risk_cap` |
| loosen 适用 score | score >= 5（high-score 区） | hard5/A22 同口径 |
| 四段 daterange | 见 §5 | K3AC/A22N |
| 成本 baseline | commission 0.0001，无 slippage | A22 baseline |
| 成本扰动 | commission 0.0002，slippage_bps=2.0 | K3AC cost2x_slip2bps |

证据等级目标：`L2`（预注册四段 formal + 成本扰动 + 负控，通过后可 promote_candidate→promote 候选）。

## 10. 子代理调用记录

适配判断：`适合调用`（本轮涉及策略代码、配置生成、回测执行、汇总门禁，均适合委派子代理；研究假设与决策由主控承担）。

调用状态：`called`（阈值提取已完成；策略代码/回测/汇总待子执执行）

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-20260620T130000Z-main-A7K3 | 待返回 | SUBTASK-20260620T130000Z-main-A7K3_子查_BL8Y decile切点阈值提取 | explore | 2026-06-20T13:00:00Z | bl8y_2020_panel_v2/bl8y_event_panel.csv | 无（只读） | python3 pandas 提取 qcut 切点 | 仅提供阈值数值，不影响假设设计 | 切点为全样本冻结值，样本外可能漂移 | 采用 low=0.0112、high=0.0148 冻结入 config | 冻结预注册阈值，防止看结果后调 |

后续子执（待调用，记录于执行后补登台账）：

- 策略代码：新增 cs_dispersion 计算 + `r010cs_dispersion_gate_*` 开关族 + 注入点 + 单测。
- WSL dry-run：1 个 cand config（2024 段）验证链路。
- 配置生成：32 configs。
- 回测执行：分批跑四段，tee 可见。
- 汇总 + strict 门禁。

## 11. 执行记录

### 平台配置

```text
已生成 32 configs（4 变体 × 4 段 × 2 成本），路径根：
configs/research/R010-A22/cs_dispersion_paired/EX-20260620T094932Z-main-S8BP/formal/<variant>/<cost>/<segment>/s8bp_<variant>_<cost>_<segment>.json
manifest: configs/research/R010-A22/cs_dispersion_paired/EX-20260620T094932Z-main-S8BP/formal/manifest.json
变体：baseline_hard5 / ref_a22_cap70_always / cand_loosen_on_low_disp / cand_loosen_on_high_disp
四段：2020_2021 / 2022_2023 / 2024 / 2025_20260519
成本：cost1x / cost2x_slip2bps
脚本：generate_s8bp_cs_dispersion_paired_configs.py / run_s8bp_cs_dispersion_paired.sh / summarize_s8bp_cs_dispersion_paired.py
```

### 运行命令

```bash
# 批量执行（幂等跳过已完成，并发护栏，全程 tee 可见）
wsl -- bash -lc "cd /mnt/e/量化平台_V1.4.0 && bash scripts/research/run_s8bp_cs_dispersion_paired.sh"
# 汇总 + strict 门禁
wsl -- bash -lc "cd /mnt/e/量化平台_V1.4.0 && PYTHONPATH=src python3 scripts/research/summarize_s8bp_cs_dispersion_paired.py --strict"
```

### 可见进度与日志

- 是否过程可见：`是`（PYTHONUNBUFFERED=1 + tee，每段 run.log 全程可见）
- 日志路径：`results/v2/research/R010-A22/cs_dispersion_paired/EX-20260620T094932Z-main-S8BP/logs/formal/<variant>_<cost>_<segment>.run.log`
- 查看进度命令：`tail -f` 上述 run.log，或 `tail -f .../batch_2024.out.log`
- 后台回测豁免：32 段全历史回测总耗时约 1.5-2 小时，前台阻塞会占用整轮对话；改为后台分批跑（2024 批 + 其余 3 段批），每段 tee 落盘 run.log 可见；进程标识 run_s8bp_cs_dispersion_paired.sh；日志根如上；查看进度 `tail -f <variant>_<cost>_<seg>.run.log`；停止方式 `pkill -f run_v2_backtest.py`；预计耗时 2024 批约 30 分钟，全 32 段约 1.5-2 小时。

### 结果路径

```text
results/v2/research/R010-A22/cs_dispersion_paired/EX-20260620T094932Z-main-S8BP/formal/<variant>/<cost>/<segment>/<job_id>/{summary.json, equity_curve.csv, trades.csv, ...}
汇总：results/v2/research/R010-A22/cs_dispersion_paired/EX-20260620T094932Z-main-S8BP/summary/formal/{summary.json, segment_metrics.csv}
```

### 2024 单段 dry-run 验证（cand_loosen_on_low_disp + shadow + cost1x）

回测前用 1 个带 shadow 的 cand config（2024 段）验证 gate 链路：

| 检查项 | 结果 |
| --- | --- |
| 配置 schema | `--dry-run` 校验通过 |
| 回测执行 | 完整跑完 2024 段，无报错/Traceback，final 173712、272 笔 |
| gate loosen 触发 | 89/242 交易日（36.8%，低离散桶） |
| shadow 每日记录 | 242 条，dispersion min 0.00916 / max 0.02332 / median 0.01196 |
| 口径核对 | 与 BL8Y 全样本（0.00845/0.02330/0.01298）量级一致 |
| 桶分布 | 低桶 89 日 / 中间 108 日 / 高桶 45 日 |
| pool_count | 193-197（全池充足） |
| 初步收益 | cand 173712 vs hard5 baseline 167005.22（+6707，方向支持低离散放行） |

该 dry-run 只证明 gate 机制按预注册设计正确生效，不是四段 formal 结论。

## 12. 实际观察

### 12.1 32 段结果矩阵（cost1x，vs baseline_hard5）

| 段 | baseline_hard5 | ref_a22_cap70 | cand_loosen_low | cand_loosen_high |
| --- | --- | --- | --- | --- |
| 2020_2021 | **224943** (-0.207) | 132765 (-0.255) | 175866 (-0.262) ❌ | 194498 (-0.233) ❌ |
| 2022_2023 | **131215** (-0.271) | 103364 (-0.229) | 120278 (-0.270) ❌ | 117585 (-0.275) ❌ |
| 2024 | 167005 (-0.270) | 162437 (-0.272) | **173712** (-0.268) ✅ | 172694 (-0.271) ✅ |
| 2025_20260519 | 317974 (-0.166) | 59923 (-0.557) | **423802** (-0.234) ✅ | 178629 (-0.459) ❌ |

cost2x_slip2bps 趋势与 cost1x 一致（cand_low 2024/2025 赢、2020_2021/2022_2023 输；cand_high 仅 2024 微赢）。

### 12.2 门禁结果（summarize --strict，evidence_complete=True）

| Gate | 结果 | 值 |
| --- | --- | --- |
| cand_low final 4/4 vs hard5 | ❌ | 2/4 段赢 |
| cand_low mdd 3/4 vs hard5 | ❌ | 2/4 段不差 |
| cand_low cost2x 稳健 | ❌ | 2/4 段赢 |
| cand_high final 4/4 vs hard5 | ❌ | 1/4 段赢 |
| cand_high mdd 3/4 vs hard5 | ❌ | 0/4 段不差 |
| cand_high cost2x 稳健 | ❌ | 1/4 段赢 |
| 两 cand 互为负控 | ✅ | 确实都未过（符合预期） |
| cand≠ref（gate 有独立信息量） | ✅ | low 差异 32%、high 差异 47% |

decision_hint：`cs_dispersion_gate_park`（两候选均未过门槛）。

### 12.3 loosen 触发频率（cand_loosen_on_low_disp，cost1x 各段）

| 段 | loosen 触发次数 | 该段结果 |
| --- | --- | --- |
| 2020_2021 | 166 | ❌ 输 hard5 -22% |
| 2022_2023 | 183 | ❌ 输 hard5 -8% |
| 2024 | 89 | ✅ 赢 hard5 +4% |
| 2025_20260519 | 101 | ✅ 赢 hard5 +33% |

早段（2020-2023）触发频繁（166-183 次）却输；晚段（2024-2025）触发适中（89-101 次）才赢。

## 13. 支持证据

- **gate 有独立信息量**：cand≠ref 通过（low 差异 32%、high 差异 47%）。ref_a22_cap70_always 无条件放行惨败（2025 段 59923 vs hard5 317974，-81%，MDD -55.7%），证明 dispersion gate 确实在区分"该不该放行"，不是单纯 cap70 在驱动。
- **cand_low 在 2025 段大幅领先**：423802 vs 317974（+33%），且 cost2x 下仍领先（405303 vs 302895）。说明 dispersion 信号在 2025 段提供了正向价值。
- **cand_low 在 2024 段稳健领先**：cost1x +4%、cost2x +4%，方向一致。
- **两 cand 互为负控通过**：low 和 high 两个方向不同时满足门槛（low 2/4、high 1/4），符合"dispersion 桶方向有区分度"的预期。

## 14. 反对证据

- **cand_low 早段惨败**：2020_2021 段 175866 vs 224943（-22%），2022_2023 段 120278 vs 131215（-8%）。早段放行 cap70 引入了弱标的。
- **cand_high 2025 段惨败**：178629 vs 317974（-44%，MDD -45.9%）。高离散日放行在 2025 段放行了错误的标的（爆炸性冲顶）。
- **不满足预注册证伪条件**：两候选都未达 4/4 final + 3/4 MDD 门槛。按预注册硬规则，整体 park。
- **早段触发过频但事件级低桶稀少**：2020_2021 段 loosen 触发 166 次，但 BL8Y 事件级 2020 年低桶占比 0%——说明 loosen 触发的多是**非高分事件的普通交易日**，cand_low 在低离散日对整个组合放行 cap70，引入了与高分无关的弱标的。这是组合层标量信号的固有局限。

## 15. 偏差诊断

**预测与实际的不一致**：

1. 预测 cand_low（数据方向，低离散放行）更可能赢——实际 cand_low 确实比 cand_high 好（2/4 vs 1/4），但**仍未过门槛**。预测高估了数据方向的稳健性。
2. 预测两 cand 互为负控（不同时满足）——实际成立（✅），这部分预测正确。
3. **未预测到的核心偏差**：早段（2020-2023）loosen 触发过频（166-183 次）导致输。BL8Y 只读面板只验证了高分事件的 H10 effect，没验证"组合层放行对非高分标的的副作用"——cand_low 在低离散日对全组合放行 cap70，但低离散日的高分标的少，放行的主要是中低分标的，这些标的在早段普涨牛市里质量差。

**根本原因**：CS dispersion 是**组合层标量**，它无法区分"低离散=普涨健康（2020 牛市）"vs"低离散=普涨冲顶（2025 结构分化）"两种截然相反的含义。同一个低离散状态在不同时段含义相反，导致阈值无法两全。

**参数矩阵必要性评估**（objective 第3项）：
- 阈值漂移确实存在（BL8Y 事件级 2023 中位数 0.0108 < 阈值 0.0112，2020 中位数 0.0194 远高于阈值）。
- 但**调阈值/窗口无法解决核心矛盾**——问题是"低离散含义时段依赖"，不是"阈值卡错"。在早段调高阈值减少触发 = 用结果反推参数 = 过拟合（违反预注册硬规则"不看结果后调"）。
- **结论：参数矩阵回测无必要**。即使扫阈值（0.009/0.011/0.013）和窗口（15/20/25），也无法让一个组合层标量同时适应 2020 牛市普涨和 2025 结构分化。

## 16. 研究判断

建议状态：`park`（CS dispersion 组合层开关方向暂停）。

理由：
1. 两候选均未满足预注册证伪条件（4/4 final + 3/4 MDD + cost2x 稳健），按硬规则 park。
2. 根本矛盾是组合层标量信号的固有局限（低离散含义时段依赖），非参数问题，参数矩阵无意义。
3. gate 确实有独立信息量（cand≠ref 通过、2025 段 +33%），但信息量不足以稳健 4/4，且无法通过调参弥补。
4. 诚实结论：CS dispersion 作为 MECH-DQUM 的 `p_crash` 组合层字段，**单独使用不可行**。但其 2025 段的正向价值暗示，它可能在与个股层信号**联合**时有辅助价值（如作为 MECH-DQUM 双概率软预算的条件先验），不排除未来以"辅助字段"身份复活，但本轮不 promote_candidate。

## 17. 下一步

下一轮最值得做：**转向个股层信号**，解决"组合层标量无法区分普涨类型"的根本矛盾。

**首选立项**：MECH-MATN 隔夜收益知情交易（Lou Polk Skouras 2019）——个股层信号，与三维完全正交，数据链路最干净，直接喂 `p_repair`。这是顶刊灵感储备 Top 1，已存档 MECH-20260620T154044Z-main-MATN。

它能减少的不确定性："高分标的的上涨是知情延续（放行）还是噪声追高（保守）"——这是 CS dispersion 组合层无法回答、但 hard5 误杀/误放核心痛点急需的判别。

**次选**：MECH-2JVB 拥挤度同质化（Stein 2009）——组合层但看"多标的同步结构"而非"横截面离散度"，需先做与 CS dispersion 的消融确认非镜像。

**CS dispersion 本身**：park，不复活单独 formal。其 2025 段正向价值留作未来 MECH-DQUM 双概率联合的候选条件先验，本轮不展开。

### Follow-up（已识别，本轮处理）

- 文档方向符号修正：CS dispersion 方向 park，DEC-7TBK / 驾驶舱 L301 / BL8Y §16 的"低离散保守、高离散允许追高"表述需更正为"组合层开关未通过 formal（低离散含义时段依赖，无法两全）"。本轮在 DEC-XSNQ 和文档同步中一并修正。
- XX6D（错位负控方法论诊断）台账状态回填：BL8Y 已应用 v2 修复，XX6D 应标 completed，本轮同步。
