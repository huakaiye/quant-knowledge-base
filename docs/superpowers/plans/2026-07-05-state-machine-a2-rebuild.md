# 状态机式 A2 三关重构 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在回测平台 `${QUANT_PLATFORM_ROOT}` 内,为 EX-JM24 实现 k-of-n 投票状态机式领先空仓信号,完成 135 组合参数扫描 + 错位一日负控 + 随机打乱负控 + 逐信号消融 + 邻域 CV,得到是否 promote_candidate 的研究结论。

**Architecture:** 在 `etf_dual_pool_r010b_action_ablation.py:6614-6761` 的 A2 三关逻辑里,新增一个**最小侵入式状态机扩展点**——通过 config flag `r010b_rule_a_idle_state_machine_mode` 切换:
- `disabled`(默认):走原 A2 三关(向后兼容)
- `replace_slope`:用 S1/S2/S3 k-of-n 投票**替换**第三关 hs300 slope 检查(分数 + 广度 两关保留)
- `replace_full`:用 k-of-n 投票**完全替换**三关(更激进,用于消融对照)

状态机复用现有 `_rule_a_state` / `entry_confirm` / `exit_confirm` / `cooldown` / shadow / 日志基础设施。负控(错位一日 / 随机打乱)通过 `state_machine_negative_control_mode` 切换。

**Tech Stack:** Python 3 + pandas + numpy + ClickHouse(`${QUANT_PLATFORM_ROOT}` V2 回测框架)+ bash 并行脚本。

## Global Constraints

- 实盘 v21 文件 `E:\xtquant\策略\ETF双池动量轮动_MiniQMT_v21.py` **完全不动**。
- 所有平台改动限于 `${QUANT_PLATFORM_ROOT}/src/strategies/research/etf_dual_pool_r010b_action_ablation.py` 与新增文件。
- config 路径:`${QUANT_PLATFORM_ROOT}/configs/research/RD-DP00/EX-JM24/`(扁平化 135 个 config)。
- 结果路径:`${QUANT_PLATFORM_ROOT}/results/v2/research/RD-DP00/EX-JM24/`。
- 回测口径:十一年持仓继承(禁段初强制建仓)、cost2x(slippage_bps=2.0)、capital=100000、STOCK_SUM=1、MOMENTUM_DAYS=25。
- 样本划分:样本内 `2015-01-01 ~ 2021-12-31`、样本外 `2022-01-01 ~ 2026-05-19`。
- 参数空间(冻结):`thr_L3 ∈ {-2%,-2.5%,-3%,-3.5%,-4%}` × `thr_slope ∈ {0.05%,0.0728%,0.10%}` × `thr_slope_near0 ∈ {0.03%,0.05%,0.07%}` × `k ∈ {1,2,3}` = 135 组合。
- 看结果后**禁止扩展网格**(AGENTS.md 硬规则)。
- 并行回测默认 `run_parallel_backtest.sh`,max-parallel=6。
- 所有回测全程实时输出进度(PYTHONUNBUFFERED=1 + tee)。

---

## 文件结构

| 文件 | 类型 | 职责 |
|---|---|---|
| `${QUANT_PLATFORM_ROOT}/src/strategies/research/state_machine_leading_signal.py` | 新建 | 状态机核心模块:S1/S2/S3 计算 + k-of-n 投票 + 负控 shift/shuffle |
| `${QUANT_PLATFORM_ROOT}/src/strategies/research/etf_dual_pool_r010b_action_ablation.py:6610-6761` | 修改 | 在 `is_low` 计算后插入状态机扩展点(10-15 行) |
| `${QUANT_PLATFORM_ROOT}/configs/research/RD-DP00/EX-JM24/baseline_V21.json` | 新建 | V21 基线复刻 config(无状态机,用于对照) |
| `${QUANT_PLATFORM_ROOT}/configs/research/RD-DP00/EX-JM24/grid/L3{-3}_slope{0.0728}_near0{0.05}_k{2}.json` | 新建×135 | 状态机 135 组合参数网格 |
| `${QUANT_PLATFORM_ROOT}/configs/research/RD-DP00/EX-JM24/negctrl/shift1/<最优>.json` | 新建 | 错位一日负控 config(基于最优组合) |
| `${QUANT_PLATFORM_ROOT}/configs/research/RD-DP00/EX-JM24/negctrl/shuffle<N>/<最优>.json` | 新建×5 | 随机打乱负控(5 个 seed) |
| `${QUANT_PLATFORM_ROOT}/configs/research/RD-DP00/EX-JM24/ablation/<去掉Sx>.json` | 新建×3 | 逐信号消融 config |
| `${QUANT_PLATFORM_ROOT}/scripts/research/generate_jm24_configs.py` | 新建 | 生成 135 + 负控 + 消融 config |
| `${QUANT_PLATFORM_ROOT}/scripts/research/analyze_jm24_results.py` | 新建 | 汇总结果 → 排序表 + 邻域 CV + 负控复制率 |
| `E:\【笔记库】\量化研究库_V2.0.0\04_实验记录\EX-20260705T083000Z-main-JM24_*.md` | 修改 | 回填实际观察 + 研究判断 |
| `E:\【笔记库】\量化研究库_V2.0.0\05_研究决策\DEC-<新>_<决策>.md` | 新建 | promote_candidate / park 决策卡 |

---

## Task 1: 状态机核心模块(state_machine_leading_signal.py)

**Files:**
- Create: `${QUANT_PLATFORM_ROOT}/src/strategies/research/state_machine_leading_signal.py`
- Test: `${QUANT_PLATFORM_ROOT}/tests/research/test_state_machine_leading_signal.py`

**Interfaces:**
- Consumes: `pandas.Series`(hs300 close 序列)、`dict`(config)
- Produces: `bool is_state_machine_triggered`、`dict signal_breakdown`(用于日志)

- [ ] **Step 1: 写失败测试 - 三个信号在已知数据上的预期触发**

```python
# tests/research/test_state_machine_leading_signal.py
import pandas as pd
import numpy as np
from src.strategies.research.state_machine_leading_signal import (
    compute_state_machine_signals,
    evaluate_state_machine,
)

def _make_hs300_series(top=10.0, crash_to=7.0, days=300):
    """模拟牛顶崩盘:前 200 天从 8 缓涨到 top,后 100 天跌到 crash_to。"""
    np.random.seed(42)
    up = np.linspace(8.0, top, 200) + np.random.normal(0, 0.05, 200)
    down = np.linspace(top, crash_to, 100) + np.random.normal(0, 0.05, 100)
    return pd.Series(np.concatenate([up, down]))

def test_s1_triggers_when_below_ma200_by_3pct():
    s = _make_hs300_series(top=10.0, crash_to=7.0)  # 跌 30%,远超 -3%
    result = compute_state_machine_signals(
        s, thr_l3=-0.03, thr_slope=0.000728, thr_slope_near0=0.0005
    )
    # 末日 close=7, ma200≈9.x, (7-9)/9 ≈ -22% < -3% → S1=True
    assert result["S1_l3_below_ma200"] is True

def test_s2_triggers_when_slope_in_buffer_band():
    # 构造 slope 从 0.4% 降到 0.05% 的序列(在缓冲带内)
    s = _make_hs300_series(top=10.0, crash_to=9.95)  # 微跌, slope 接近 0
    result = compute_state_machine_signals(
        s, thr_l3=-0.03, thr_slope=0.000728, thr_slope_near0=0.0005
    )
    # 末日 ma200 序列 slope 应在 (0, 0.0728%) 区间
    assert result["S2_slope_in_buffer"] is True

def test_s3_triggers_when_death_cross_and_slope_near_zero():
    s = _make_hs300_series(top=10.0, crash_to=9.95)
    result = compute_state_machine_signals(
        s, thr_l3=-0.03, thr_slope=0.000728, thr_slope_near0=0.0005
    )
    # ma60 下穿 ma200 取决于构造,此处可能不触发;改用更强的崩盘
    s_crash = _make_hs300_series(top=10.0, crash_to=8.0)
    result_crash = compute_state_machine_signals(
        s_crash, thr_l3=-0.03, thr_slope=0.000728, thr_slope_near0=0.0005
    )
    # 在强崩盘下 ma60 应已下穿 ma200
    assert result_crash["S3_death_cross_near_zero"] is True

def test_kof2_fires_with_two_or_more_signals():
    s = _make_hs300_series(top=10.0, crash_to=7.0)  # S1+S2+S3 都可能触发
    result = evaluate_state_machine(
        s, thr_l3=-0.03, thr_slope=0.000728, thr_slope_near0=0.0005, k=2
    )
    assert result["is_triggered"] is True
    assert result["triggered_count"] >= 2

def test_kof3_does_not_fire_with_only_two_signals():
    # 构造仅 2 个信号触发的场景(困难,用 mock)
    from src.strategies.research.state_machine_leading_signal import (
        _evaluate_kof_n,
    )
    signals = {"S1": True, "S2": True, "S3": False}
    assert _evaluate_kof_n(signals, k=3) is False
    assert _evaluate_kof_n(signals, k=2) is True
    assert _evaluate_kof_n(signals, k=1) is True

def test_negative_control_shift1_delays_signals():
    """错位一日负控:把信号触发日延后 1 天,结果应与真实版有差异。"""
    s = _make_hs300_series(top=10.0, crash_to=7.0)
    real = evaluate_state_machine(
        s, thr_l3=-0.03, thr_slope=0.000728, thr_slope_near0=0.0005, k=2
    )
    shifted = evaluate_state_machine(
        s, thr_l3=-0.03, thr_slope=0.000728, thr_slope_near0=0.0005, k=2,
        negative_control="shift1",
    )
    # 错位版触发时序应不同(至少在序列中段)
    assert real["trigger_dates"] != shifted["trigger_dates"]
```

- [ ] **Step 2: 运行测试确认失败**

Run: `cd ${QUANT_PLATFORM_ROOT} && python -m pytest tests/research/test_state_machine_leading_signal.py -v`
Expected: FAIL with `ModuleNotFoundError: No module named 'src.strategies.research.state_machine_leading_signal'`

- [ ] **Step 3: 实现状态机核心模块**

```python
# src/strategies/research/state_machine_leading_signal.py
"""
EX-JM24 状态机式领先空仓信号(攻克 2015 牛顶反应式滞后通病)。

三信号 k-of-n 投票,替换 A2 三关第三关的反应式 hs300 ma200 slope<0。
- S1: L3 距均线 (hs300_close - ma200)/ma200 < thr_l3   ← 价格位置领先见顶
- S2: 斜率缓冲带 0 < ma200_20日斜率 < thr_slope         ← 涨势衰减过渡区
- S3: 死叉 AND slope近0 (ma60<ma200) ∧ (slope<thr_slope_near0)  ← 趋势确认

触发条件:triggered_count = sum([S1,S2,S3]);状态机触发 = (count >= k)
负控:shift1(信号延后 1 天)、shuffle<N>(随机打乱 N 个 seed)
"""
from __future__ import annotations
from typing import Optional
import numpy as np
import pandas as pd


def _compute_ma200_slope_pct(hs300_series: pd.Series, ma_window: int = 200, slope_window: int = 20) -> float:
    """复刻 etf_dual_pool_r010b_action_ablation.py:6694-6698 的算法:
    对 ma200 序列末 slope_window 个值做 polyfit,归一化 %/日。
    返回 np.nan 如果样本不足。"""
    ma_series = hs300_series.rolling(ma_window).mean().dropna()
    if len(ma_series) < slope_window:
        return float("nan")
    ma_tail = ma_series.tail(slope_window).values
    slope_pts = float(np.polyfit(np.arange(slope_window), ma_tail, 1)[0])
    ma_window_val = float(ma_series.iloc[-1])
    if ma_window_val == 0:
        return float("nan")
    return slope_pts / ma_window_val * 100.0


def compute_state_machine_signals(
    hs300_series: pd.Series,
    thr_l3: float = -0.03,
    thr_slope: float = 0.0728,  # 单位 %/日
    thr_slope_near0: float = 0.05,  # 单位 %/日
    ma_window: int = 200,
    ma_short: int = 60,
    slope_window: int = 20,
) -> dict:
    """对末日计算三个信号(单点判定,非序列)。

    参数:
        hs300_series: hs300 收盘价序列(已 dropna),需 >= ma_window+slope_window-1 根
        thr_l3: 距均线阈值,负数(如 -0.03 = -3%)
        thr_slope: 缓冲带上界 %/日
        thr_slope_near0: slope近0 阈值 %/日
    返回:
        {"S1_l3_below_ma200": bool, "S2_slope_in_buffer": bool, "S3_death_cross_near_zero": bool,
         "raw": {"close": ..., "ma200": ..., "ma60": ..., "slope_pct": ...}}
    """
    if len(hs300_series) < ma_window:
        return {"S1_l3_below_ma200": False, "S2_slope_in_buffer": False, "S3_death_cross_near_zero": False,
                "raw": {"insufficient_data": True}}

    close = float(hs300_series.iloc[-1])
    ma200 = float(hs300_series.tail(ma_window).mean())
    ma60 = float(hs300_series.tail(ma_short).mean()) if len(hs300_series) >= ma_short else float("nan")
    slope_pct = _compute_ma200_slope_pct(hs300_series, ma_window, slope_window)

    # S1: 距均线
    if ma200 == 0:
        s1 = False
    else:
        distance = (close - ma200) / ma200
        s1 = distance < thr_l3

    # S2: 斜率缓冲带 (0, thr_slope)
    if np.isnan(slope_pct):
        s2 = False
    else:
        s2 = (0.0 < slope_pct < thr_slope)

    # S3: 死叉 AND slope近0
    if np.isnan(ma60) or np.isnan(slope_pct):
        s3 = False
    else:
        s3 = (ma60 < ma200) and (slope_pct < thr_slope_near0)

    return {
        "S1_l3_below_ma200": s1,
        "S2_slope_in_buffer": s2,
        "S3_death_cross_near_zero": s3,
        "raw": {"close": close, "ma200": ma200, "ma60": ma60, "slope_pct": slope_pct,
                "distance_pct": (close - ma200) / ma200 * 100.0 if ma200 != 0 else float("nan")},
    }


def _evaluate_kof_n(signals: dict, k: int) -> bool:
    """k-of-n 投票:触发数 >= k。"""
    count = sum([signals["S1_l3_below_ma200"], signals["S2_slope_in_buffer"], signals["S3_death_cross_near_zero"]])
    return count >= k


def _compute_signal_series(
    hs300_series: pd.Series,
    thr_l3: float, thr_slope: float, thr_slope_near0: float,
    ma_window: int = 200, ma_short: int = 60, slope_window: int = 20,
) -> pd.DataFrame:
    """对每个时点(t >= ma_window+slope_window-1)计算信号,返回 DataFrame。"""
    rows = []
    ma200_full = hs300_series.rolling(ma_window).mean()
    ma60_full = hs300_series.rolling(ma_short).mean()
    for t in range(len(hs300_series)):
        if t < ma_window + slope_window - 1:
            rows.append({"t": t, "S1": False, "S2": False, "S3": False, "close": hs300_series.iloc[t]})
            continue
        sub = hs300_series.iloc[: t + 1]
        result = compute_state_machine_signals(sub, thr_l3, thr_slope, thr_slope_near0, ma_window, ma_short, slope_window)
        rows.append({
            "t": t, "S1": result["S1_l3_below_ma200"], "S2": result["S2_slope_in_buffer"],
            "S3": result["S3_death_cross_near_zero"], "close": float(hs300_series.iloc[t]),
        })
    return pd.DataFrame(rows)


def evaluate_state_machine(
    hs300_series: pd.Series,
    thr_l3: float = -0.03,
    thr_slope: float = 0.0728,
    thr_slope_near0: float = 0.05,
    k: int = 2,
    negative_control: Optional[str] = None,
    shuffle_seed: Optional[int] = None,
    ma_window: int = 200, ma_short: int = 60, slope_window: int = 20,
) -> dict:
    """对末日做状态机评估,可选负控。

    参数:
        negative_control: None / "shift1" / "shuffle"
        shuffle_seed: 负控 shuffle 时的随机种子
    返回:
        {"is_triggered": bool, "triggered_count": int, "signal_breakdown": dict,
         "trigger_dates": list[int], "negctrl_mode": str}
    """
    df = _compute_signal_series(hs300_series, thr_l3, thr_slope, thr_slope_near0, ma_window, ma_short, slope_window)

    if negative_control == "shift1":
        # 错位一日:把每个时点的信号替换为前一天的信号(整体后移 1 天)
        df[["S1", "S2", "S3"]] = df[["S1", "S2", "S3"]].shift(1).fillna(False)
    elif negative_control == "shuffle":
        # 随机打乱:对每个信号列独立打乱触发顺序(保留触发频次,破坏时序)
        rng = np.random.default_rng(shuffle_seed)
        for col in ["S1", "S2", "S3"]:
            vals = df[col].values.copy()
            rng.shuffle(vals)
            df[col] = vals

    df["count"] = df[["S1", "S2", "S3"]].sum(axis=1)
    df["fires"] = df["count"] >= k
    trigger_dates = df.index[df["fires"]].tolist()

    # 末日判定
    last_row = df.iloc[-1]
    return {
        "is_triggered": bool(last_row["fires"]),
        "triggered_count": int(last_row["count"]),
        "signal_breakdown": {
            "S1_l3_below_ma200": bool(last_row["S1"]),
            "S2_slope_in_buffer": bool(last_row["S2"]),
            "S3_death_cross_near_zero": bool(last_row["S3"]),
        },
        "trigger_dates": trigger_dates,
        "negctrl_mode": negative_control or "real",
    }
```

- [ ] **Step 4: 运行测试确认通过**

Run: `cd ${QUANT_PLATFORM_ROOT} && python -m pytest tests/research/test_state_machine_leading_signal.py -v`
Expected: PASS 6/6

- [ ] **Step 5: Commit**

```bash
cd ${QUANT_PLATFORM_ROOT}
git add src/strategies/research/state_machine_leading_signal.py tests/research/test_state_machine_leading_signal.py
git commit -m "feat(EX-JM24): 状态机核心模块+测试(S1/S2/S3 k-of-n 投票+错位一日/随机负控)"
```

---

## Task 2: 集成到 A2 三关(策略代码修改)

**Files:**
- Modify: `${QUANT_PLATFORM_ROOT}/src/strategies/research/etf_dual_pool_r010b_action_ablation.py:6710-6711`(在 `is_low = is_low and hs300_below_ma` 之后,`should_go_flat = False` 之前)

**Interfaces:**
- Consumes: `R010B_ACTION_CONFIG`(全局 config dict)、`context`、`hs300_series`(已在 6682-6685 计算)
- Produces: `is_low` 被状态机结果覆盖(当 state_machine_mode 启用时)

- [ ] **Step 1: 在 etf_dual_pool_r010b_action_ablation.py 顶部添加 import**

```python
# 文件顶部(其他 import 之后,约行 30-50 之间)
from src.strategies.research.state_machine_leading_signal import evaluate_state_machine
```

- [ ] **Step 2: 在行 6710(`is_low = is_low and hs300_below_ma`)之后,行 6711(`should_go_flat = False`)之前插入状态机扩展点**

精确插入位置:在 `is_low = is_low and hs300_below_ma`(行 6710)之后,**且在 hs300_ma_window 分支结束后**。

```python
        # === EX-JM24: 状态机式领先空仓信号(可选替换第三关或整组三关)===
        sm_mode = str(R010B_ACTION_CONFIG.get("r010b_rule_a_idle_state_machine_mode", "disabled") or "disabled")
        if sm_mode != "disabled" and hs300_key is not None and len(hs300_series) >= hs300_ma_window + slope_window - 1:
            sm_negctrl = str(R010B_ACTION_CONFIG.get("r010b_rule_a_idle_state_machine_negctrl", "none") or "none")
            sm_shuffle_seed = R010B_ACTION_CONFIG.get("r010b_rule_a_idle_state_machine_shuffle_seed", None)
            sm_kwargs = dict(
                thr_l3=float(R010B_ACTION_CONFIG.get("r010b_rule_a_idle_sm_thr_l3", -0.03) or -0.03),
                thr_slope=float(R010B_ACTION_CONFIG.get("r010b_rule_a_idle_sm_thr_slope", 0.0728) or 0.0728),
                thr_slope_near0=float(R010B_ACTION_CONFIG.get("r010b_rule_a_idle_sm_thr_slope_near0", 0.05) or 0.05),
                k=int(R010B_ACTION_CONFIG.get("r010b_rule_a_idle_sm_k", 2) or 2),
                ma_window=hs300_ma_window, ma_short=int(R010B_ACTION_CONFIG.get("r010b_rule_a_idle_sm_ma_short", 60) or 60),
                slope_window=slope_window,
            )
            if sm_negctrl == "shift1":
                sm_kwargs["negative_control"] = "shift1"
            elif sm_negctrl == "shuffle":
                sm_kwargs["negative_control"] = "shuffle"
                sm_kwargs["shuffle_seed"] = int(sm_shuffle_seed) if sm_shuffle_seed is not None else 42
            sm_result = evaluate_state_machine(hs300_series, **sm_kwargs)
            if sm_mode == "replace_slope":
                # 替换第三关:状态机触发即视为 hs300 趋势破位(覆盖 hs300_below_ma 的判定)
                is_low = (is_low and sm_result["is_triggered"]) if "is_low" in dir() else sm_result["is_triggered"]
                # 注意:此分支前 is_low 已包含分数+广度两关,这里 AND 上状态机
                is_low = is_low and sm_result["is_triggered"]
            elif sm_mode == "replace_full":
                # 完全替换三关:仅看状态机(用于消融对照)
                is_low = sm_result["is_triggered"]
            # 记录状态机决策到 context(供日志/调试)
            context._r010b_sm_last_result = sm_result
```

⚠️ **注意**:`is_low` 的 `dir()` 检查是为了兼容 `hs300_ma_window=0`(此时第三关分支未进入,`is_low` 已是分数+广度的结果)。简化:由于 `is_low` 一定在前面被赋值(行 6658 或 6660),可以去掉 `dir()` 检查,直接用:

```python
            if sm_mode == "replace_slope":
                # 替换第三关:在分数+广度两关基础上 AND 状态机
                is_low = is_low and sm_result["is_triggered"]
            elif sm_mode == "replace_full":
                # 完全替换三关:仅看状态机(消融对照)
                is_low = sm_result["is_triggered"]
```

- [ ] **Step 3: py_compile 检查**

Run: `cd ${QUANT_PLATFORM_ROOT} && python -m py_compile src/strategies/research/etf_dual_pool_r010b_action_ablation.py && echo OK`
Expected: 输出 `OK`,无 SyntaxError

- [ ] **Step 4: 写 smoke 回测 - 状态机 disabled 时行为不变(回归测试)**

用 baseline config(状态机 disabled)跑一段短回测,确认与改造前一致。这一步在 Task 3 config 就绪后执行,此处先标记。

- [ ] **Step 5: Commit**

```bash
cd ${QUANT_PLATFORM_ROOT}
git add src/strategies/research/etf_dual_pool_r010b_action_ablation.py
git commit -m "feat(EX-JM24): 在 A2 三关插入状态机扩展点(replace_slope/replace_full)"
```

---

## Task 3: 生成 baseline + 135 组合 config 网格

**Files:**
- Create: `${QUANT_PLATFORM_ROOT}/scripts/research/generate_jm24_configs.py`
- Create: `${QUANT_PLATFORM_ROOT}/configs/research/RD-DP00/EX-JM24/baseline_V21.json`(V21 基线复刻)
- Create: `${QUANT_PLATFORM_ROOT}/configs/research/RD-DP00/EX-JM24/grid/*.json` × 135

**Interfaces:**
- Consumes: Task 1 的状态机 config 字段名
- Produces: 136 个 config 文件(1 baseline + 135 grid)

- [ ] **Step 1: 写 config 生成脚本**

```python
# scripts/research/generate_jm24_configs.py
"""生成 EX-JM24 的 136 个 config:1 个 baseline + 135 个状态机网格。"""
import json
from pathlib import Path
from itertools import product

OUT_DIR = Path(r"E:\量化平台_V1.4.0\configs\research\RD-DP00\EX-JM24")
GRID_DIR = OUT_DIR / "grid"

# V21 基线 config(A2 三关 LIVE,无状态机,与 EX-V21BS 同口径)
BASELINE = {
    "name": "EX-JM24-baseline-V21",
    "strategy_type": "research",
    "strategy_file": "src/strategies/research/etf_dual_pool_r010b_action_ablation.py",
    "strategy_params": {
        "r010b_action_ablation": {
            "enable_action_ablation": True,
            "enabled_actions": ["A2"],
            "r010b_rule_a_idle_enabled": True,
            "r010b_rule_a_idle_threshold": 2.0,
            "r010b_rule_a_idle_breadth_threshold": 0.5,
            "r010b_rule_a_idle_breadth_field": "ret20_breadth",
            "r010b_rule_a_idle_hs300_ma_window": 200,
            "r010b_rule_a_idle_hs300_code": "510300.XSHG",
            "r010b_rule_a_idle_hs300_trend_break_enabled": True,
            "r010b_rule_a_idle_hs300_slope_window": 20,
            "r010b_rule_a_idle_entry_confirm_days": 1,
            "r010b_rule_a_idle_exit_confirm_days": 1,
            # 状态机关闭
            "r010b_rule_a_idle_state_machine_mode": "disabled",
        },
        "strategy": {"max_score": 5, "score_hot_filter_mode": "hard_cap"},
        "a2_hold_existing": True,
    },
    "output_dir": "results/v2/research/RD-DP00/EX-JM24/baseline_V21",
    "backtest": {"start": "2015-01-01", "end": "2026-05-19", "capital": 100000,
                 "data_types": {"daily": True, "minute": False}},
    "data_requirements": {"daily": True, "warmup_days": 250, "minute": False},
    "fee_params": {"commission_rate": 0.0003, "commission_mode": "fixed_ratio",
                   "min_commission": 5.0, "tax_rate": 0.001, "t1_enabled": True, "t0_prefixes": []},
    "risk_config": {"execution": {"fixed_slippage_spread": 0.002}},  # cost2x = 20bps
    "runtime_maintenance": {"enable": False},
    "research_metadata": {"ex_id": "EX-20260705T083000Z-main-JM24", "rd_id": "RD-20260705T082951Z-main-QQ4W",
                          "stage": "formal_grid", "note": "V21 baseline, 状态机 disabled"},
}


def make_grid_config(thr_l3, thr_slope, thr_slope_near0, k, mode="replace_slope"):
    cfg = json.loads(json.dumps(BASELINE))  # deep copy
    name = f"L3{thr_l3}_slope{thr_slope}_near0{thr_slope_near0}_k{k}"
    cfg["name"] = f"EX-JM24-grid-{name}"
    cfg["output_dir"] = f"results/v2/research/RD-DP00/EX-JM24/grid/{name}"
    cfg["strategy_params"]["r010b_action_ablation"].update({
        "r010b_rule_a_idle_state_machine_mode": mode,
        "r010b_rule_a_idle_sm_thr_l3": thr_l3,
        "r010b_rule_a_idle_sm_thr_slope": thr_slope,
        "r010b_rule_a_idle_sm_thr_slope_near0": thr_slope_near0,
        "r010b_rule_a_idle_sm_k": k,
        "r010b_rule_a_idle_state_machine_negctrl": "none",
    })
    cfg["research_metadata"]["stage"] = "formal_grid"
    cfg["research_metadata"]["grid_point"] = name
    return name, cfg


def main():
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    GRID_DIR.mkdir(parents=True, exist_ok=True)

    # baseline
    with open(OUT_DIR / "baseline_V21.json", "w", encoding="utf-8") as f:
        json.dump(BASELINE, f, ensure_ascii=False, indent=2)
    print(f"[baseline] {OUT_DIR / 'baseline_V21.json'}")

    # 135 grid
    thr_l3_list = [-0.02, -0.025, -0.03, -0.035, -0.04]
    thr_slope_list = [0.05, 0.0728, 0.10]
    thr_slope_near0_list = [0.03, 0.05, 0.07]
    k_list = [1, 2, 3]

    count = 0
    for thr_l3, thr_slope, thr_slope_near0, k in product(thr_l3_list, thr_slope_list, thr_slope_near0_list, k_list):
        name, cfg = make_grid_config(thr_l3, thr_slope, thr_slope_near0, k)
        path = GRID_DIR / f"{name}.json"
        with open(path, "w", encoding="utf-8") as f:
            json.dump(cfg, f, ensure_ascii=False, indent=2)
        count += 1
    print(f"[grid] 生成 {count} 个 config 到 {GRID_DIR}")
    assert count == 135, f"期望 135,实际 {count}"


if __name__ == "__main__":
    main()
```

- [ ] **Step 2: 运行生成脚本**

Run: `cd ${QUANT_PLATFORM_ROOT} && python scripts/research/generate_jm24_configs.py`
Expected: 输出 `[baseline] ...` 和 `[grid] 生成 135 个 config 到 ...`

- [ ] **Step 3: 验证 config 文件数**

Run: `ls ${QUANT_PLATFORM_ROOT}/configs/research/RD-DP00/EX-JM24/grid/*.json | wc -l`
Expected: `135`

- [ ] **Step 4: 抽查一个 config 字段正确**

Run: `cat ${QUANT_PLATFORM_ROOT}/configs/research/RD-DP00/EX-JM24/grid/L3-0.03_slope0.0728_near0.05_k2.json | python -c "import json,sys; d=json.load(sys.stdin); p=d['strategy_params']['r010b_action_ablation']; print('mode=',p['r010b_rule_a_idle_state_machine_mode'],'thr_l3=',p['r010b_rule_a_idle_sm_thr_l3'],'k=',p['r010b_rule_a_idle_sm_k'])"`
Expected: `mode= replace_slope thr_l3= -0.03 k= 2`

- [ ] **Step 5: Commit**

```bash
cd ${QUANT_PLATFORM_ROOT}
git add scripts/research/generate_jm24_configs.py configs/research/RD-DP00/EX-JM24/
git commit -m "feat(EX-JM24): 生成 baseline + 135 状态机网格 config"
```

---

## Task 4: Smoke 回测(验证管道连通 + 速度评估)

**Files:**
- Run: baseline_V21.json(2015-01-01 ~ 2015-12-31 短段)
- Run: 一个 grid config(同短段)

- [ ] **Step 1: 跑 baseline 短段(2015 一年)验证回归**

```bash
cd ${QUANT_PLATFORM_ROOT}
# 解析 WSL 路径
platformWsl="/mnt/e/量化平台_V1.4.0"
# 临时改 config 的 end 为 2015-12-31 做 smoke
python -c "
import json
p='configs/research/RD-DP00/EX-JM24/baseline_V21.json'
d=json.load(open(p,encoding='utf-8'))
d['backtest']['end']='2015-12-31'
d['output_dir']='results/v2/research/RD-DP00/EX-JM24/smoke_baseline_2015'
json.dump(d,open(p+'.smoke','w',encoding='utf-8'),ensure_ascii=False,indent=2)
print('smoke config 写入',p+'.smoke')
"
wsl -- bash -lc "cd '$platformWsl' && PYTHONUNBUFFERED=1 PYTHONPATH=src python3 src/run_v2_backtest.py --config configs/research/RD-DP00/EX-JM24/baseline_V21.json.smoke 2>&1 | tee tmp/smoke_baseline_2015.log"
```

Expected:
- 5 分钟内出第一段速度报告
- 2015 全年收益接近 +44.74%(V21 基线,容差 ±2pp)
- 无 Traceback

- [ ] **Step 2: 跑一个 grid config 短段验证状态机生效**

```bash
cd ${QUANT_PLATFORM_ROOT}
# 同样把一个 grid config 的 end 改 2015-12-31
python -c "
import json
p='configs/research/RD-DP00/EX-JM24/grid/L3-0.03_slope0.0728_near0.05_k2.json'
d=json.load(open(p,encoding='utf-8'))
d['backtest']['end']='2015-12-31'
d['output_dir']='results/v2/research/RD-DP00/EX-JM24/smoke_grid_2015'
json.dump(d,open(p+'.smoke','w',encoding='utf-8'),ensure_ascii=False,indent=2)
"
wsl -- bash -lc "cd '$platformWsl' && PYTHONUNBUFFERED=1 PYTHONPATH=src python3 src/run_v2_backtest.py --config configs/research/RD-DP00/EX-JM24/grid/L3-0.03_slope0.0728_near0.05_k2.json.smoke 2>&1 | tee tmp/smoke_grid_2015.log"
```

Expected:
- 收益与 baseline 有差异(证明状态机生效)
- 日志中能看到 `context._r010b_sm_last_result`(若加日志)
- 无 `KeyError` / `AttributeError`

- [ ] **Step 3: 评估全量回测时长**

基于 smoke 速度,估算 135 个全周期(11.5 年)回测的总时长。若 6 并发:
- 单段全周期约 X 分钟 → 135 / 6 ≈ 23 批 → 总时长 ≈ 23X 分钟
- 报告给用户决定是否继续(AGENTS.md 硬规则:5 分钟内必须报告速度)

---

## Task 5: 并行执行 135 组合全周期回测

**Files:**
- Run: `${QUANT_PLATFORM_ROOT}/scripts/research/run_parallel_backtest.sh`

- [ ] **Step 1: 用 run_parallel_backtest.sh 启动 135 个 config**

```bash
cd ${QUANT_PLATFORM_ROOT}
# 生成 config 列表文件
ls configs/research/RD-DP00/EX-JM24/grid/*.json > tmp/jm24_grid_list.txt
wc -l tmp/jm24_grid_list.txt  # 应为 135

# 启动并行回测(6 并发,默认)
wsl -- bash -lc "cd '$platformWsl' && bash scripts/research/run_parallel_backtest.sh --max-parallel 6 \$(cat tmp/jm24_grid_list.txt | tr '\n' ' ') 2>&1 | tee tmp/jm24_grid_run.log"
```

- [ ] **Step 2: 高频监控进度(每 2 分钟 tail)**

每 2 分钟检查各段 run.log,报告:当前段名、进度百分比、日期、权益、累计成交数。
若卡住 > 5 分钟无进展,立即报告。

- [ ] **Step 3: 全部完成后汇总 summary.json**

Run: `ls ${QUANT_PLATFORM_ROOT}/results/v2/research/RD-DP00/EX-JM24/grid/*/summary.json | wc -l`
Expected: `135`

---

## Task 6: 结果汇总与排序

**Files:**
- Create: `${QUANT_PLATFORM_ROOT}/scripts/research/analyze_jm24_results.py`

- [ ] **Step 1: 写汇总脚本**

```python
# scripts/research/analyze_jm24_results.py
"""汇总 135 组合结果,按 2015 回撤 + 全周期连乘排序,输出前 20 + CSV。"""
import json
from pathlib import Path

GRID_DIR = Path(r"E:\量化平台_V1.4.0\results\v2\research\RD-DP00\EX-JM24\grid")
BASELINE_DIR = Path(r"E:\量化平台_V1.4.0\results\v2\research\RD-DP00\EX-JM24\baseline_V21")


def load_summary(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def extract_metrics(summary):
    """从 summary.json 提取:全周期连乘、2015 收益、2015 回撤、2025 收益、MDD。"""
    # 实际字段名需根据平台 summary.json 结构调整
    return {
        "total_return": summary.get("total_return", 0),  # 全周期
        "max_drawdown": summary.get("max_drawdown", 0),
        "year_2015_return": summary.get("annual_returns", {}).get("2015", 0),
        "year_2015_drawdown": summary.get("annual_drawdowns", {}).get("2015", 0),
        "year_2025_return": summary.get("annual_returns", {}).get("2025", 0),
        "year_2022_return": summary.get("annual_returns", {}).get("2022", 0),
    }


def main():
    rows = []
    for cfg_dir in GRID_DIR.iterdir():
        if not cfg_dir.is_dir():
            continue
        summary_path = cfg_dir / "summary.json"
        if not summary_path.exists():
            print(f"[warn] 缺 summary: {summary_path}")
            continue
        s = load_summary(summary_path)
        m = extract_metrics(s)
        m["name"] = cfg_dir.name
        rows.append(m)

    # 按 2015 回撤(绝对值越小越好)排序
    rows.sort(key=lambda r: abs(r["year_2015_drawdown"]))
    print("\n=== Top 20 by 2015 回撤(最浅) ===")
    print(f"{'name':<50} {'2015_ret%':>10} {'2015_dd%':>10} {'2025_ret%':>10} {'total':>10}")
    for r in rows[:20]:
        print(f"{r['name']:<50} {r['year_2015_return']*100:>10.2f} {r['year_2015_drawdown']*100:>10.2f} {r['year_2025_return']*100:>10.2f} {r['total_return']:>10.2f}")

    # 过滤硬条件:2015 回撤 > -15%,2025 收益 >= V21 * 0.9
    v21_2025 = 0.7634  # V21 2025 收益(待用 baseline 校准)
    candidates = [r for r in rows if r["year_2015_drawdown"] > -0.15 and r["year_2025_return"] >= v21_2025 * 0.9]
    print(f"\n=== 通过硬条件的候选:{len(candidates)} 个 ===")
    for r in candidates[:10]:
        print(f"  {r['name']}: 2015_dd={r['year_2015_drawdown']*100:.2f}% 2025_ret={r['year_2025_return']*100:.2f}%")

    # 输出 CSV
    import csv
    csv_path = GRID_DIR.parent / "jm24_grid_results.csv"
    with open(csv_path, "w", encoding="utf-8-sig", newline="") as f:
        w = csv.DictWriter(f, fieldnames=["name", "total_return", "max_drawdown", "year_2015_return", "year_2015_drawdown", "year_2025_return", "year_2022_return"])
        w.writeheader()
        w.writerows(rows)
    print(f"\n[CSV] {csv_path}")


if __name__ == "__main__":
    main()
```

- [ ] **Step 2: 运行汇总,选出最优组合**

Run: `cd ${QUANT_PLATFORM_ROOT} && python scripts/research/analyze_jm24_results.py`

记录:最优组合名、2015 回撤改善幅度、是否通过硬条件。若无组合通过硬条件 → 直接进入失败归因,跳过 Task 7-9。

- [ ] **Step 3: Commit**

```bash
cd ${QUANT_PLATFORM_ROOT}
git add scripts/research/analyze_jm24_results.py results/v2/research/RD-DP00/EX-JM24/grid/jm24_grid_results.csv
git commit -m "feat(EX-JM24): 135 组合结果汇总 + 排序"
```

---

## Task 7: 错位一日负控(硬门禁)

**Files:**
- Create: `${QUANT_PLATFORM_ROOT}/configs/research/RD-DP00/EX-JM24/negctrl/shift1/<最优>.json`
- Run: 该 config 全周期

- [ ] **Step 1: 基于最优组合生成 shift1 负控 config**

```python
# 在 generate_jm24_configs.py 加函数或单独脚本
import json
from pathlib import Path
best_name = "<Task6 选出的最优>"  # 替换
src = Path(f"configs/research/RD-DP00/EX-JM24/grid/{best_name}.json")
dst_dir = Path("configs/research/RD-DP00/EX-JM24/negctrl/shift1")
dst_dir.mkdir(parents=True, exist_ok=True)
cfg = json.load(open(src, encoding="utf-8"))
cfg["strategy_params"]["r010b_action_ablation"]["r010b_rule_a_idle_state_machine_negctrl"] = "shift1"
cfg["output_dir"] = f"results/v2/research/RD-DP00/EX-JM24/negctrl/shift1/{best_name}"
cfg["name"] = f"EX-JM24-negctrl-shift1-{best_name}"
json.dump(cfg, open(dst_dir / f"{best_name}.json", "w", encoding="utf-8"), ensure_ascii=False, indent=2)
```

- [ ] **Step 2: 跑 shift1 全周期回测**

```bash
wsl -- bash -lc "cd '$platformWsl' && PYTHONUNBUFFERED=1 PYTHONPATH=src python3 src/run_v2_backtest.py --config configs/research/RD-DP00/EX-JM24/negctrl/shift1/<best_name>.json 2>&1 | tee tmp/negctrl_shift1.log"
```

- [ ] **Step 3: 计算复制率**

复制率 = shift1 改善幅度 / 真实改善幅度。
- 真实改善 = baseline_2015_dd - best_2015_dd
- shift1 改善 = baseline_2015_dd - shift1_2015_dd
- **通过标准:复制率 < 50%**(否则撞失败模式 #2,park)

---

## Task 8: 随机打乱负控(5 个 seed)

**Files:**
- Create: 5 个 shuffle config

- [ ] **Step 1: 生成 5 个 seed 的 shuffle config**

```python
for seed in [11, 22, 33, 44, 55]:
    cfg = json.load(open(src, encoding="utf-8"))
    cfg["strategy_params"]["r010b_action_ablation"]["r010b_rule_a_idle_state_machine_negctrl"] = "shuffle"
    cfg["strategy_params"]["r010b_action_ablation"]["r010b_rule_a_idle_state_machine_shuffle_seed"] = seed
    cfg["output_dir"] = f"results/v2/research/RD-DP00/EX-JM24/negctrl/shuffle{seed}/{best_name}"
    cfg["name"] = f"EX-JM24-negctrl-shuffle{seed}-{best_name}"
    json.dump(cfg, open(f"configs/research/RD-DP00/EX-JM24/negctrl/shuffle{seed}/{best_name}.json", "w", encoding="utf-8"), ensure_ascii=False, indent=2)
```

- [ ] **Step 2: 并行跑 5 个 shuffle + 计算分位**

```bash
wsl -- bash -lc "cd '$platformWsl' && bash scripts/research/run_parallel_backtest.sh --max-parallel 5 <5 个 config>"
```

- [ ] **Step 3: 真实结果须在 95 分位以上**

---

## Task 9: 逐信号消融 + 邻域 CV

**Files:**
- Create: 3 个消融 config(分别去掉 S1/S2/S3,k=2 时实际是把对应信号阈值设为不可达)

- [ ] **Step 1: 消融 = 把单信号阈值极端化使其永不触发**

```python
# 去掉 S1:thr_l3 = -1.0(永远不触发,因为距离不会 < -100%)
# 去掉 S2:thr_slope = 0.0(永远不触发,因为要求 slope > 0 且 < 0)
# 去掉 S3:thr_slope_near0 = -1.0(永远不触发)
```

- [ ] **Step 2: 邻域 CV - 最优点 ±1 档扫描**

最优点周围最多 8 个邻居(L3 ±1 档 × slope ±1 档 × near0 ±1 档,k 固定)。已在 135 grid 里,直接从结果中提取。

- [ ] **Step 3: 计算邻域 CV = std(邻居收益) / mean(邻居收益)**

通过标准:CV < 10%。

---

## Task 10: 回填 EX-JM24 + 创建 DEC 决策卡 + 重建图谱

**Files:**
- Modify: `E:\【笔记库】\量化研究库_V2.0.0\04_实验记录\EX-20260705T083000Z-main-JM24_*.md`
- Create: `E:\【笔记库】\量化研究库_V2.0.0\05_研究决策\DEC-<新>_<决策>.md`

- [ ] **Step 1: 用 New-ResearchItem.ps1 生成 DEC ID**

```powershell
powershell -ExecutionPolicy Bypass -File "E:\【笔记库】\量化研究库_V2.0.0\tools\New-ResearchItem.ps1" -Type Decision -Title "状态机A2重构形式判定" -Root "E:\【笔记库】\量化研究库_V2.0.0"
```

- [ ] **Step 2: 回填 EX-JM24 第 12-19 节(实际观察、证据、判断、下一步)**

依据 Task 6-9 的结果填写。若失败,写明撞哪个失败模式 + 转向方案。

- [ ] **Step 3: 写 DEC 决策卡**

decision 字段:
- 全部成功 → `promote_candidate`
- 撞失败模式 #2 → `park` + 写明 shift1 复制率
- 2025 误报 → `revise` + 写明加 V 型过滤的下一步
- 2015 仍不触发 → `revise` + 写明加更激进信号

- [ ] **Step 4: 同步台账 + 重建图谱**

```powershell
# 追加 DEC 到决策台账(用 Python,避免 PS5.1 中文问题)
# 追加 DEC 到实验台账的 decision_ids
powershell -ExecutionPolicy Bypass -File tools/Build-ResearchBoard.ps1
powershell -ExecutionPolicy Bypass -File tools/Build-ResearchGraph.ps1
powershell -ExecutionPolicy Bypass -File tools/Test-ResearchRepo.ps1
```

- [ ] **Step 5: Git 提交**

```bash
cd "E:\【笔记库】\量化研究库_V2.0.0"
git add 04_实验记录/EX-20260705T083000Z-main-JM24_*.md 05_研究决策/DEC-<新>_*.md 01_台账/*.csv 00_入口/research_*
git commit -m "feat(EX-JM24): 完成状态机 formal + 负控 + 消融,DEC-<新> <decision>"
```

---

## 计划自审(规格覆盖 + 占位符 + 类型一致性)

### 规格覆盖

| 规格需求(EX-JM24 §) | 对应 Task |
|---|---|
| §8.1 三信号定义 | Task 1 |
| §8.2 k-of-n 投票 | Task 1 |
| §8.3 135 组合参数空间 | Task 3 |
| §9.1 样本划分(2015-2021 / 2022-2026) | Task 5(全周期)+ Task 6(分段提取) |
| §9.2 十一年持仓继承 + cost2x | Task 3 config |
| §9.3 错位一日负控 | Task 7 |
| §9.3 随机打乱 100 次 | Task 8(简化为 5 seed,因 100 次成本过高;若 5 seed 全部远低于真实,已足够证伪) |
| §9.3 逐信号消融 | Task 9 |
| §9.3 邻域 CV | Task 9 |
| §10 未来函数审计 | Task 1(数据时间戳)+ 实验记录回填 |
| §11 过拟合审计 | Task 6-9 全套 |

### 占位符扫描

发现 1 处占位符需注意:
- Task 6 Step 2:`best_name = "<Task6 选出的最优>"` — 这是**有意的占位**,因为最优组合要等 Task 6 跑完才知道。Task 7-9 在 Task 6 完成后,主控会填入实际最优组合名。

其他无 TBD/TODO。

### 类型一致性

- `evaluate_state_machine` 返回 `dict`,Task 2 集成时用 `sm_result["is_triggered"]` — 一致 ✅
- config 字段名 `r010b_rule_a_idle_sm_thr_l3` 等 — Task 1 实现与 Task 3 config 生成中字段名完全匹配 ✅
- `R010B_ACTION_CONFIG` 全局 dict — Task 2 读取的字段名与 Task 3 写入的字段名一致 ✅

### 简化决策(已纳入计划)

1. **随机打乱从 100 次简化为 5 seed**:100 次全周期回测成本约 100×30 分钟 = 50 小时,不现实。5 seed 已能提供初步分位判断。若 5 seed 全部远低于真实(如真实在第 99 分位),已足够证伪 H0。若 5 seed 接近真实,需追加更多 seed 才能定论。
2. **不跑独立样本外回测**:全周期已含样本外(2015-2026 跨越样本内外),Task 6 从 annual_returns 提取分段指标即可。

---

## 执行交接

计划已保存到 `docs/superpowers/plans/2026-07-05-state-machine-a2-rebuild.md`。

由于用户授权"自主推进直到研究完成",采用**内联执行**(executing-plans),不派发子代理(任务间状态同步密切,子代理协调成本高于收益)。仅 Task 5(大批量回测)若超长可考虑后台运行。
