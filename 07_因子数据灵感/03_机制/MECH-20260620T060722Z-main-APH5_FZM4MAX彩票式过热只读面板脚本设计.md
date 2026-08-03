---
type: 因子数据灵感
idea_id: MECH-20260620T060722Z-main-APH5
status: draft
owner: main
created_at: 2026-06-20T06:07:22Z
updated_at: 2026-06-20T06:07:22Z
source_lit_ids: [LIT-20260620T022539Z-main-36A6]
related_rd_ids: [RD-20260620T022601Z-main-GHZL]
category: 机制
tags: [双池轮动, hard5, MAX, 彩票式过热, 只读面板, 脚本设计, FZM4, Bali十分位]
---

# FZM4 MAX 彩票式过热只读面板脚本设计

## 关联链接

- 来源文献：[[06_文献资料/00_待处理/LIT-20260620T022539Z-main-36A6_MAX彩票式过热BaliCakiciWhitelaw2011|MAX 彩票式过热 Bali Cakici Whitelaw 2011]]
- 相关方向：[[02_研究方向/RD-20260620T022601Z-main-GHZL_双池轮动MAX彩票式过热信号|双池轮动 MAX 彩票式过热信号]]
- 升级实验：[[04_实验记录/EX-20260620T022611Z-main-FZM4_MAX彩票式过热只读面板预注册|MAX 彩票式过热只读面板预注册]]
- 上游数据门禁（m04 strong hint，max_ret20 口径来源）：[[04_实验记录/EX-20260619T113348Z-main-UN96_A28非QMT量价结构状态机数据门禁|A28 非 QMT 量价结构状态机数据门禁]]
- 关联框架（p_overheat 字段候选）：[[07_因子数据灵感/03_机制/MECH-20260619T025934Z-main-DQUM_hard5过热概率与反弹修复状态框架|hard5 过热概率与反弹修复状态框架]]
- 相关术语：MAX（过去 N 日最大单日涨幅）、彩票式过热（单日跳涨型）、Bali 十分位（横截面 10 分位排序）、jump_ratio（最大几日涨幅贡献占比）

## 一句话说明

这是 MAX 彩票式过热只读面板（EX-FZM4）的平台脚本设计卡：把 A28 的 m04 veto 二元版升级为 Bali 横截面十分位，复用 A16 的 212 个 hard5 高分事件源和 VZ8Q 的随机同桶/错位一日负控框架，纯日频数据、不连 QMT、不改 hard5。

## 来源

来自 Bali-Cakici-Whitelaw 2011（JFE）的 MAX 效应顶刊方法，结合研究库 A28 已识别的 m04_lottery_extreme_return_veto strong hint（24 事件、H10 effect +4.19pp、胜率 66.67%，方向与 Bali 一致）。A28 只做了 veto 二元（max_ret20>=0.08），本设计把它升级为 Bali 横截面十分位排序，并补 A 股涨停制度交互。

## 平台脚本定位

- 脚本名：`analyze_fzm4_max_lottery_overheat_readonly.py`
- 存放目录：`${LEGACY_QUANT_PLATFORM_ROOT}/scripts/research/`
- 性质：只读初筛脚本，不跑回测、不改配置、不连 MiniQMT、不写库、不改 hard5。参照 A28 的只读面板风格。
- 输出目录：`${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260620T022601Z-main-GHZL/EX-20260620T022611Z-main-FZM4/fzm4_max_lottery_panel/`

## 复用映射（已核实精确行号）

| FZM4 需求 | 复用来源 | 平台路径 / 位置 |
| --- | --- | --- |
| 事件源（212 hard5 高分事件） | A16 面板 | `results/v2/research/R010-A16/hot_state_panel/hot_state_event_panel.csv` |
| 事件定义（score>=5、动态池+静态池、cap=5） | A11 | `scripts/research/analyze_r010a11_score_cap_readonly.py` 行 310-483 |
| MAX 字段口径（max_ret20，过去 20 日最大单日涨幅） | A28 | `scripts/research/analyze_a28_volume_price_structure_gate.py` 行 379 |
| m04 veto 二元版（升级为 Bali 十分位的起点） | A28 | 同上文件 行 540-544 |
| jump_ratio_20 / return_discreteness20 | A28 | 同上文件 行 380-382 |
| 涨停状态字段（hit_limit_intraday / close_lock_limit / failed_limit_pressure） | A28 | 同上文件 行 409-411 |
| 日频 OHLCV 数据 | ClickHouse | 表 `quant.jq_bar_daily`，端口 9001，字段 symbol/exchange/datetime/open_price/high_price/low_price/close_price/volume/turnover/pre_close/limit_up |
| 只读面板风格 + H1/H5/H10 effect 口径 | A28 + A16 | A28 行 581-637；A16 行 187-301 |
| 随机同桶负控 | VZ8Q | `scripts/research/analyze_vz8q_short_hot_miss_readonly.py` 行 353-419 |
| 错位一日负控（shift_prev1/shift_next1） | VZ8Q | 同上文件 行 433-469 |
| 同主题字段（raw_top_theme / same_theme_count_top10 / same_theme_corr20_mean） | A16 | A16 CSV 表头 + 行 279-290 |
| 质量门（min_events、win_rate、分段一致、负控不可复制） | VZ8Q | `_gate_summary` 行 490-529 |

## 可实现定义

### 1. 事件源

- 读取 A16 的 `hot_state_event_panel.csv`（212 事件），取每个事件的 `date`、`segment`、`raw_top_qmt`（事件标的）、`raw_top_score`、`raw_top_theme`、`hard5_first_qmt`（hard5 实际持仓标的）、`raw_top_ret_h1/h3/h5/h10`、`raw_top_diff_h5/h10_vs_hard5`。
- segment 沿用 A11/A16 四段：`2020_2021`、`2022_2023`、`2024`、`2025_20260519`。

### 2. MAX 字段计算（复用 A28 行 379 口径，严格对齐 signal_date 当时可见）

对每个事件标的，在 signal_date 当天及之前的历史日频上计算：

```text
ret1 = close_price / pre_close - 1      # 单日收益，|ret1|>0.5 设 NaN（除权保护，复用 A28 行 371-372）
max_ret20 = ret1.rolling(20, min_periods=8).max()   # 过去 20 日最大单日涨幅（复用 A28 行 379）
max_ret5  = ret1.rolling(5,  min_periods=3).max()   # 过去 5 日最大单日涨幅（A28 行 378）
jump_ratio_20 = max_abs_ret20 / abs_sum_ret20       # = A28 的 return_discreteness20，行 380-382
up_day_share20 = (ret1>0).rolling(20, min_periods=8).mean()   # A28 行 383
limit_up_count20 = 过去 20 日涨停天数（hit_limit_intraday 或 close==limit_up 计数，复用 A28 行 409-411）
```

取 signal_date 当天的值作为该事件的 MAX 特征。**未来函数审计**：所有字段只取 signal_date 当天及之前，ret1 用 pre_close（前一日收盘）算，不含 signal_date 之后任何价格。吸取 52 周高点 lookback 滑入未来的教训。

### 3. Bali 横截面十分位（核心升级）

A28 的 m04 是 `max_ret20>=0.08` 的二元 veto。FZM4 升级为横截面十分位：

```text
# 在每个事件日，对该日全池候选（A11 动态池 + 静态 ETF 池）按 max_ret20 排序
max_decile = pd.qcut(pool_max_ret20, q=10, labels=False, duplicates='drop')
# 事件标的的 max_decile 即为该事件的 Bali 十分位（0=最低 MAX，9=最高 MAX）
```

同时保留二元对照：`is_high_max = max_ret20 >= 0.08`（A28 m04 阈值），用于和 A28 veto 结果直接对比，确认十分位是否比二元阈值有增量。

### 4. 分桶与 effect 计算

- 主分桶：高 MAX 桶（decile 8-9）vs 低 MAX 桶（decile 0-1）vs 全体。
- effect 口径复用 A28：`effect_h10 = raw_top_ret_h10 - hard5_first_ret_h10`（即追 raw Top1 相对 hard5 实际路径的超额，正数=追高更差，支持保守）。
- 对每个桶算：event_count、seg_count、effect_mean/median、win_rate（effect>0 比例）、p10（下尾）、分段明细。
- horizons：H5、H10（沿用 A28/EX 预注册；H1 备用）。

### 5. 四类负控（复用 VZ8Q 框架 + 扩展）

| 负控 | 实现 | 复用 |
| --- | --- | --- |
| 随机同 MAX 桶 | 每个事件日从同 max_decile 池随机抽一个候选（排除 baseline 和 event code），算 H5/H10 excess，重复 500 次，输出 random_mean 的 p10/p50/p90 和 `p_random_ge_actual` | VZ8Q `_random_control` 行 353-419，改 rank_5d 池为 max_decile 同桶池 |
| 错位一日 | offset ∈ {-1, +1}，取错位日的 hard5 baseline，原 event code 在错位日算前向收益 | VZ8Q `_shifted_control` 行 433-469 |
| 同主题随机同规模 | 每个事件日从同 raw_top_theme 池随机抽同规模候选，算 H5/H10 excess | A16 已有 raw_top_theme，扩展 VZ8Q `_random_control` |
| 涨停板分层 | 按过去 20 日涨停天数（limit_up_count20）分层，检验"涨停封顶的 MAX"vs"自然跳涨的 MAX"是否不同 | A28 已有 failed_limit_pressure 等，新增计数 |

### 6. 质量门（复用 VZ8Q `_gate_summary` 行 490-529，按 EX 预注册调整）

过只读门槛的条件（全部满足才考虑进 formal）：

- 事件数 `>=50`（高/低 MAX 桶各）。
- H5/H10 effect 均值差异显著，且中位不显著为负。
- 胜率 `>=52%`（高 MAX 桶 effect>0 比例，即追高更差）。
- `>=3/4` 分段方向一致。
- 四类负控不可复制：`p_random_ge_actual < 0.30`、错位一日不完整复制、同主题随机不复制、涨停分层有差异。

## 预期输出文件

```text
fzm4_max_lottery_panel/
├── fzm4_event_panel.csv          # 每事件：date/segment/symbol/max_ret20/max_decile/is_high_max/jump_ratio_20/limit_up_count20/effect_h5/effect_h10/...
├── fzm4_decile_summary.csv       # 十分位汇总：decile/event_count/effect_h5_mean/effect_h10_mean/win_rate/p10/seg_coverage
├── fzm4_high_vs_low_summary.csv  # 高MAX桶 vs 低MAX桶 主对比
├── fzm4_random_control_summary.csv   # 随机同桶负控
├── fzm4_shifted_control_summary.csv  # 错位一日负控
├── fzm4_theme_control_summary.csv    # 同主题随机负控
├── fzm4_limit_up_strat_summary.csv   # 涨停板分层
├── fzm4_feature_coverage.csv     # 字段覆盖率（最低覆盖率应 >=98%，参照 A28）
└── summary.json                  # 质量门判定 + 关键指标
```

## 历史运行命令（V1.4 只读证据，禁止在 V2 执行）

下面的命令记录 2026-06-20 当时的设计，包含 V1.4 路径、裸 `python3` 和旧研究脚本布局。它不能作为当前执行入口。若继续该方向，必须新开实验，把脚本迁入 V2、建立受控入口并按当前平台规范重新登记结果路径。

```bash
# 平台根 WSL 路径
platformWsl=/mnt/e/量化平台_V1.4.0
wsl -- bash -lc "cd '$platformWsl' && PYTHONPATH=src PYTHONUNBUFFERED=1 python3 scripts/research/analyze_fzm4_max_lottery_overheat_readonly.py \
  --event-csv results/v2/research/R010-A16/hot_state_panel/hot_state_event_panel.csv \
  --out-dir results/v2/research/RD-20260620T022601Z-main-GHZL/EX-20260620T022611Z-main-FZM4/fzm4_max_lottery_panel \
  --clickhouse-port 9001 \
  --clickhouse-database quant \
  --random-reps 500 \
  --random-seed 20260620 \
  --horizons 5,10 \
  --segments 2020_2021,2022_2023,2024,2025_20260519 \
  2>&1 | tee results/v2/research/RD-20260620T022601Z-main-GHZL/EX-20260620T022611Z-main-FZM4/fzm4_run.log"
```

- `PYTHONUNBUFFERED=1` + `tee` 保证过程可见（AGENTS.md 平台命令边界要求）。
- 纯只读，无后台、无静默。预计耗时取决于 ClickHouse 查询，前台执行。

## 预期作用

回答 EX-FZM4 的核心不确定性：MAX（过去 20 日最大单日涨幅）的 Bali 横截面十分位，在 A 股 ETF 池（已分散特质风险、有涨停制度）是否还保留 Bali 2011 顶刊里的彩票型过热信号，高 MAX 桶（单日跳涨型）是否后续系统性弱于低 MAX 桶（连续温和上涨型），且不能被四类负控复制。若过门槛，MAX 作为 MECH-DQUM 框架 `p_overheat` 独立字段候选；若不过门槛，本方向 park。

## 风险

- **数据是否可得**：是。日频 OHLCV 走 ClickHouse `quant.jq_bar_daily`，A28 已验证最低覆盖率 98.88%；事件源 A16 面板已存在。无需 QMT（与 HJGJ 决策一致）。
- **是否可能未来函数**：需审计。所有 MAX 字段只用 signal_date 当天及之前数据，ret1 用 pre_close 算。脚本必须显式断言 `所有特征时间戳 <= signal_date`，并在 summary.json 输出未来函数检查结果。吸取 52 周高点 lookback 滑入未来教训。
- **是否可能过拟合**：参数已预注册（窗口=20 日、十分位、不看完结果再扩）。窗口 15/20/25 邻域敏感性在执行后报告，但本轮不调参。
- **是否影响交易成本**：不适用。只读面板，无交易动作，默认 hard5 不变。

## 升级为实验的条件

- 本脚本只是只读面板，不是 formal 实验。
- 过质量门（见上文 6 项）后，才把 MAX 作为 MECH-DQUM `p_overheat` 独立字段进入 formal 预注册（新开 EX）。
- 不过门槛则 park，转 CS dispersion（BL8Y）或 GSADF（UEAC）。
- 不直接写成 hard5 过滤规则，不 shadow/observe。

## 子代理调用记录

```text
子代理豁免：脚本设计阶段调用 Explore 子代理盘点 A28/A16/VZ8Q 脚本结构（SUBTASK-PLATFORM-SCRIPT-AUDIT），其结论用于本设计卡的复用映射；主控负责脚本设计和未来函数审计边界；时间：2026-06-20T06:07:22Z
```

子代理盘点调用 ID：`SUB-20260620T060000Z-main-SCRIPTAUDIT`，任务代号 `SUBTASK-PLATFORM-SCRIPT-AUDIT`，已记录到子代理调用台账。
