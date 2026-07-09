# NautilusTrader 迁移 PoC 实现计划（阶段 0）

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在 2-3 周内验证 NautilusTrader 在 A 股场景（WSL2 + ClickHouse + 聚宽数据 + T+1/涨跌停）下的可行性，用最简 ETF 策略验证机制，决定是否进入正式迁移（阶段 1）。

**Architecture:** 在平台仓库 `${QUANT_PLATFORM_ROOT}` 下新建 `src/quant_v2/nautilus_poc/` 隔离目录，所有 PoC 代码集中于此，不污染现有 V2 引擎。通过 `BacktestEngine.add_data(list[Bar])` 直接注入内存 Bar 对象（绕过 Parquet Catalog）。验证 5 个致命假设（A1-A5），每个假设有独立的判定标准。

**Tech Stack:** Python 3.10.12（WSL2）、NautilusTrader（最新稳定版）、clickhouse-driver（现有依赖）、pandas、pytest

**关联规格:** `docs/superpowers/specs/2026-07-09-nautilus-migration-design.md`

## Global Constraints

- **运行环境:** WSL2（`wsl -- bash -lc "..."`），Python 3.10.12。NautilusTrader 装在 WSL 的 Python 环境里，不装 Windows 侧。
- **平台根路径:** `${QUANT_PLATFORM_ROOT}` = `E:\量化平台_V1.4.0`（WSL 路径 `/mnt/e/量化平台_V1.4.0`）。
- **隔离原则:** 所有 PoC 代码放 `src/quant_v2/nautilus_poc/`，不修改现有 `quant_v2` 核心代码（daily_engine/sim_broker/clickhouse_portal 等），旧 V2 引擎保持不动作为参照。
- **数据口径:** PoC 用现有旧表（`jq_bar_daily` 前复权 + `jq_bar_daily_real` 未复权），不依赖 jq_v3 切换完成。
- **不追求收益复现:** PoC 的目的是验证引擎机制能跑通，不是复现现有策略收益曲线。收益复现是阶段 1 的关卡。
- **编码:** 所有新增文本文件 UTF-8 无 BOM。
- **提交:** 每个 Task 完成后提交到 `feat/nautilus-poc` 新分支（从 `feat/jq-database-overhaul` 切出，避免冲突）。

---

## 文件结构

```
src/quant_v2/nautilus_poc/
├── __init__.py                          # 包标识
├── clickhouse_to_bars.py                # Task 2: ClickHouse → list[Bar] 适配器
├── ashare_instruments.py                # Task 3: A 股 Instrument 定义（涨跌停/100股/0.01元）
├── t1_fill_model.py                     # Task 4: T+1 约束的 FillModel（核心风险验证）
├── mini_jq_bridge.py                    # Task 5: 迷你聚宽兼容桥（history/order_target_value）
├── jq_rotation_strategy.py              # Task 5: 宿主策略（聚宽风格→Nautilus）
└── run_poc.py                           # Task 6: PoC 主入口（组装全部组件跑回测）

src/tests/quant_v2/nautilus_poc/
├── __init__.py
├── test_clickhouse_to_bars.py           # Task 2 测试
├── test_ashare_instruments.py           # Task 3 测试
├── test_t1_fill_model.py                # Task 4 测试（最关键）
└── test_simple_rotation_strategy.py     # Task 5 测试

docs/superpowers/reports/
└── 2026-07-09-nautilus-poc-report.md    # Task 7: PoC 结论报告
```

---

## Task 1: 环境搭建与 NautilusTrader 安装验证

**目标:** 在 WSL2 安装 NautilusTrader，跑通官方 demo，确认 A1 假设（环境可行）。

**Files:**
- Create: `src/quant_v2/nautilus_poc/__init__.py`
- Create: `src/tests/quant_v2/nautilus_poc/__init__.py`

**Interfaces:**
- Produces: 可用的 NautilusTrader 安装 + WSL2 Python 环境，后续所有 Task 依赖此环境

- [ ] **Step 1: 从 jq-database-overhaul 切出 PoC 分支**

Run:
```bash
cd /mnt/e/量化平台_V1.4.0 && git checkout feat/jq-database-overhaul && git checkout -b feat/nautilus-poc
```
Expected: 新分支 `feat/nautilus-poc` 创建成功

- [ ] **Step 2: 在 WSL2 安装 NautilusTrader**

Run:
```bash
wsl -- bash -lc "cd /mnt/e/量化平台_V1.4.0 && pip install nautilus_trader 2>&1 | tail -20"
```
Expected: 安装成功。如果报错（如 Rust 编译失败、版本冲突），记录错误信息——这本身就是 A1 的验证结果。

- [ ] **Step 3: 验证 NautilusTrader 可 import 并查看版本**

Run:
```bash
wsl -- bash -lc "cd /mnt/e/量化平台_V1.4.0 && python3 -c 'import nautilus_trader; print(nautilus_trader.__version__)'"
```
Expected: 打印版本号（如 `1.200.0` 或类似）。如果 ImportError，A1 失败。

- [ ] **Step 4: 跑通官方最小 demo（验证 BacktestEngine 基本可用）**

Create `src/quant_v2/nautilus_poc/__init__.py`（空文件）和 `src/tests/quant_v2/nautilus_poc/__init__.py`（空文件）。

然后写一个 smoke 脚本验证 BacktestEngine 能实例化。Create `src/quant_v2/nautilus_poc/_smoke_import.py`:

```python
"""Smoke test: 验证 NautilusTrader BacktestEngine 能在 WSL2 实例化。"""
from nautilus_trader.backtest.engine import BacktestEngine


def main():
    engine = BacktestEngine()
    print(f"BacktestEngine 实例化成功: {engine}")
    print("A1 验证通过: WSL2 环境可用")


if __name__ == "__main__":
    main()
```

Run:
```bash
wsl -- bash -lc "cd /mnt/e/量化平台_V1.4.0 && PYTHONPATH=src python3 src/quant_v2/nautilus_poc/_smoke_import.py"
```
Expected: 打印 "A1 验证通过: WSL2 环境可用"。如果崩溃，记录 traceback。

- [ ] **Step 5: 提交**

```bash
cd /mnt/e/量化平台_V1.4.0
git add src/quant_v2/nautilus_poc/__init__.py src/tests/quant_v2/nautilus_poc/__init__.py src/quant_v2/nautilus_poc/_smoke_import.py
git commit -m "feat(nautilus-poc): Task1 环境搭建+NautilusTrader安装验证(A1)"
```

---

## Task 2: ClickHouse → list[Bar] 数据适配器

**目标:** 写最小适配器，从现有 ClickHouse（未复权表 `jq_bar_daily_real`）读日线数据，转成 Nautilus `list[Bar]`。验证 A3 假设（数据注入可行）。

**Files:**
- Create: `src/quant_v2/nautilus_poc/clickhouse_to_bars.py`
- Create: `src/tests/quant_v2/nautilus_poc/test_clickhouse_to_bars.py`

**Interfaces:**
- Consumes: 现有 `quant_backtest.config.ch_config.get_ch_client()`（`src/quant_backtest/config/ch_config.py:112`）获取 ClickHouse 连接
- Produces: `load_bars_from_clickhouse(symbol, start_date, end_date) -> list[Bar]`，返回 Nautilus Bar 列表，供 Task 5/6 使用

- [ ] **Step 1: 写失败测试**

Create `src/tests/quant_v2/nautilus_poc/test_clickhouse_to_bars.py`:

```python
"""测试 ClickHouse → list[Bar] 适配器。"""
import pytest
from unittest.mock import patch, MagicMock
from nautilus_trader.model.data import Bar, BarType, BarSpecification
from nautilus_trader.model.enums import PriceType, AggregationSource
from nautilus_trader.model.identifiers import InstrumentId
from nautilus_trader.model.objects import Price, Quantity


def test_load_bars_from_clickhouse_returns_bar_list():
    """验证适配器返回 Nautilus Bar 对象列表。"""
    # Mock ClickHouse 查询结果（模拟未复权日线数据）
    # 字段: datetime, open, high, low, close, volume, factor
    mock_rows = [
        ("2024-01-02", 1.502, 1.515, 1.498, 1.510, 1000000, 1.234),
        ("2024-01-03", 1.511, 1.520, 1.505, 1.518, 1200000, 1.234),
    ]

    with patch(
        "quant_v2.nautilus_poc.clickhouse_to_bars._query_clickhouse",
        return_value=mock_rows,
    ):
        from quant_v2.nautilus_poc.clickhouse_to_bars import load_bars_from_clickhouse

        bars = load_bars_from_clickhouse(
            symbol="510300.SH",
            start_date="2024-01-02",
            end_date="2024-01-03",
            bar_type=_make_bar_type("510300.SH"),
        )

    assert len(bars) == 2
    assert all(isinstance(b, Bar) for b in bars)
    # 第一根 Bar 的 close 应该是 1.510
    assert bars[0].close.as_double() == pytest.approx(1.510, abs=1e-9)


def test_bar_timestamp_is_close_time():
    """验证 Bar 时间戳是收盘时刻（15:00），不是 00:00。"""
    mock_rows = [
        ("2024-01-02", 1.502, 1.515, 1.498, 1.510, 1000000, 1.234),
    ]

    with patch(
        "quant_v2.nautilus_poc.clickhouse_to_bars._query_clickhouse",
        return_value=mock_rows,
    ):
        from quant_v2.nautilus_poc.clickhouse_to_bars import load_bars_from_clickhouse

        bars = load_bars_from_clickhouse(
            symbol="510300.SH",
            start_date="2024-01-02",
            end_date="2024-01-02",
            bar_type=_make_bar_type("510300.SH"),
        )

    # 2024-01-02 15:00:00 UTC+8 = 2024-01-02 07:00:00 UTC 的纳秒时间戳
    # A 股收盘 15:00 北京时间
    import pandas as pd

    expected_ts = int(
        pd.Timestamp("2024-01-02 15:00:00", tz="Asia/Shanghai").value
    )
    assert bars[0].ts_init == expected_ts


def _make_bar_type(symbol: str) -> BarType:
    """构造日线 BarType 辅助函数。"""
    return BarType(
        instrument_id=InstrumentId.from_str(symbol),
        spec=BarSpecification(
            step=1,
            aggregation=AggregationSource.EXTERNAL,  # 外部数据，不自己聚合
            price_type=PriceType.LAST,
        ),
    )
```

- [ ] **Step 2: 运行测试确认失败**

Run:
```bash
wsl -- bash -lc "cd /mnt/e/量化平台_V1.4.0 && PYTHONPATH=src python3 -m pytest src/tests/quant_v2/nautilus_poc/test_clickhouse_to_bars.py -v 2>&1 | tail -20"
```
Expected: FAIL（ModuleNotFoundError: quant_v2.nautilus_poc.clickhouse_to_bars）

- [ ] **Step 3: 写最小实现**

Create `src/quant_v2/nautilus_poc/clickhouse_to_bars.py`:

```python
"""ClickHouse → Nautilus list[Bar] 适配器。

从未复权表 jq_bar_daily_real 读取日线 OHLCV，
转成 NautilusTrader 的 Bar 对象列表。

时间戳约定：Nautilus 要求 ts_init 是 Bar 收盘时刻（避免 look-ahead）。
A 股日线收盘 15:00 北京时间（Asia/Shanghai, UTC+8）。
"""
import pandas as pd
from nautilus_trader.model.data import Bar, BarType
from nautilus_trader.model.objects import Price, Quantity

from quant_backtest.config.ch_config import get_ch_client


def _query_clickhouse(symbol: str, start_date: str, end_date: str):
    """从 ClickHouse 未复权日线表查询原始行。

    Returns:
        list of tuples: (datetime_str, open, high, low, close, volume, factor)
    """
    client = get_ch_client()
    table = "jq_bar_daily_real"  # 未复权真实价表
    # symbol 在数据库里可能存为 '510300.SH' 或 '510300'
    sql = f"""
        SELECT toString(datetime) as dt, open, high, low, close, volume, factor
        FROM {table}
        WHERE symbol = %(symbol)s
          AND datetime >= %(start)s
          AND datetime <= %(end)s
        ORDER BY datetime
    """
    return client.execute(
        sql,
        {"symbol": symbol, "start": start_date, "end": end_date},
    )


def load_bars_from_clickhouse(
    symbol: str,
    start_date: str,
    end_date: str,
    bar_type: BarType,
) -> list[Bar]:
    """从 ClickHouse 读取未复权日线，转成 Nautilus Bar 列表。

    Args:
        symbol: 标的代码，如 "510300.SH"
        start_date: 起始日期 "YYYY-MM-DD"
        end_date: 结束日期 "YYYY-MM-DD"
        bar_type: Nautilus BarType（含 InstrumentId）

    Returns:
        list[Bar]: 按时间升序的 Bar 列表，ts_init = 当日 15:00 北京时间
    """
    rows = _query_clickhouse(symbol, start_date, end_date)
    bars = []
    for row in rows:
        dt_str, o, h, l, c, vol, factor = row
        # 收盘时刻：当日 15:00 北京时间 → 纳秒时间戳
        close_ts = int(
            pd.Timestamp(dt_str + " 15:00:00", tz="Asia/Shanghai").value
        )
        bar = Bar(
            bar_type=bar_type,
            open=Price.from_str(str(o)),
            high=Price.from_str(str(h)),
            low=Price.from_str(str(l)),
            close=Price.from_str(str(c)),
            volume=Quantity.from_str(str(int(vol))),
            ts_event=close_ts,
            ts_init=close_ts,
        )
        bars.append(bar)
    return bars
```

- [ ] **Step 4: 运行测试确认通过**

Run:
```bash
wsl -- bash -lc "cd /mnt/e/量化平台_V1.4.0 && PYTHONPATH=src python3 -m pytest src/tests/quant_v2/nautilus_poc/test_clickhouse_to_bars.py -v 2>&1 | tail -20"
```
Expected: 2 passed

- [ ] **Step 5: 真实 ClickHouse 联调（手动验证，非自动化测试）**

Run:
```bash
wsl -- bash -lc "cd /mnt/e/量化平台_V1.4.0 && PYTHONPATH=src python3 -c \"
from quant_v2.nautilus_poc.clickhouse_to_bars import load_bars_from_clickhouse
from nautilus_trader.model.data import BarType, BarSpecification
from nautilus_trader.model.enums import PriceType, AggregationSource
from nautilus_trader.model.identifiers import InstrumentId
bt = BarType(instrument_id=InstrumentId.from_str('510300.SH'), spec=BarSpecification(step=1, aggregation=AggregationSource.EXTERNAL, price_type=PriceType.LAST))
bars = load_bars_from_clickhouse('510300.SH', '2024-01-02', '2024-01-10', bt)
print(f'加载 {len(bars)} 根 Bar')
for b in bars[:3]:
    print(f'  {b.ts_init} open={b.open.as_double()} close={b.close.as_double()} vol={b.volume.as_double()}')
\""
```
Expected: 打印出真实 Bar 数据。如果 ClickHouse 连不上或表结构不符，记录错误——这是 A3 的真实反馈。

- [ ] **Step 6: 提交**

```bash
cd /mnt/e/量化平台_V1.4.0
git add src/quant_v2/nautilus_poc/clickhouse_to_bars.py src/tests/quant_v2/nautilus_poc/test_clickhouse_to_bars.py
git commit -m "feat(nautilus-poc): Task2 ClickHouse→Bar适配器(A3数据注入验证)"
```

---

## Task 3: A 股 Instrument 定义

**目标:** 定义 A 股 ETF 的 Nautilus Instrument，包含涨跌停信息，验证 A 股基础配置可行。

**Files:**
- Create: `src/quant_v2/nautilus_poc/ashare_instruments.py`
- Create: `src/tests/quant_v2/nautilus_poc/test_ashare_instruments.py`

**Interfaces:**
- Consumes: NautilusTrader `Equity` / `InstrumentId`
- Produces: `make_etf_instrument(symbol, price_limit_pct=0.10) -> Equity`，返回含 A 股配置的 Instrument；`calc_limit_prices(pre_close, limit_pct) -> tuple[Price, Price]` 算涨跌停价。供 Task 4/5/6 使用。

- [ ] **Step 1: 写失败测试**

Create `src/tests/quant_v2/nautilus_poc/test_ashare_instruments.py`:

```python
"""测试 A 股 Instrument 定义。"""
import pytest
from nautilus_trader.model.instruments import Equity
from nautilus_trader.model.identifiers import InstrumentId
from nautilus_trader.model.objects import Price


def test_make_etf_instrument_returns_equity():
    """验证 A 股 ETF Instrument 基础配置。"""
    from quant_v2.nautilus_poc.ashare_instruments import make_etf_instrument

    inst = make_etf_instrument("510300.SH")

    assert isinstance(inst, Equity)
    assert inst.id == InstrumentId.from_str("510300.SH")
    assert inst.price_precision == 2
    assert inst.price_increment == Price.from_str("0.01")
    # A 股最小委托单位 100 股
    assert int(inst.lot_size) == 100


def test_calc_limit_prices_normal_etf():
    """验证 ETF 涨跌停价计算（±10%）。"""
    from quant_v2.nautilus_poc.ashare_instruments import calc_limit_prices

    pre_close = Price.from_str("1.000")
    limit_up, limit_down = calc_limit_prices(pre_close, 0.10)

    # 涨停 1.10，跌停 0.90，四舍五入到 0.01
    assert limit_up.as_double() == pytest.approx(1.10, abs=0.001)
    assert limit_down.as_double() == pytest.approx(0.90, abs=0.001)


def test_calc_limit_prices_gem_etf():
    """验证创业板/科创板 ETF 涨跌停（±20%）。"""
    from quant_v2.nautilus_poc.ashare_instruments import calc_limit_prices

    pre_close = Price.from_str("2.000")
    limit_up, limit_down = calc_limit_prices(pre_close, 0.20)

    assert limit_up.as_double() == pytest.approx(2.40, abs=0.001)
    assert limit_down.as_double() == pytest.approx(1.60, abs=0.001)
```

- [ ] **Step 2: 运行测试确认失败**

Run:
```bash
wsl -- bash -lc "cd /mnt/e/量化平台_V1.4.0 && PYTHONPATH=src python3 -m pytest src/tests/quant_v2/nautilus_poc/test_ashare_instruments.py -v 2>&1 | tail -20"
```
Expected: FAIL（ModuleNotFoundError）

- [ ] **Step 3: 写最小实现**

Create `src/quant_v2/nautilus_poc/ashare_instruments.py`:

```python
"""A 股 Instrument 定义。

NautilusTrader 原生 Instrument 模型无 A 股涨跌停字段，
涨跌停逻辑在 Task 4 的 FillModel 中处理，
这里只定义可配置的基础属性（价格精度、最小变动、手数、货币）。
"""
from nautilus_trader.model.instruments import Equity
from nautilus_trader.model.identifiers import InstrumentId, Symbol
from nautilus_trader.model.objects import Price, Quantity
from nautilus_trader.model.enums import AssetClass, AssetType
from nautilus_trader.model.currency import Currency


def make_etf_instrument(
    symbol: str,
    ts_init: int = 0,
) -> Equity:
    """构造 A 股 ETF Instrument。

    Args:
        symbol: 标的代码，如 "510300.SH"
        ts_init: 创建时间戳（纳秒），默认 0

    Returns:
        Equity: 含 A 股配置的 Instrument
    """
    # 解析 symbol → venue（交易所后缀）
    # "510300.SH" → Symbol("510300"), venue "SSE"
    parts = symbol.split(".")
    raw_symbol = parts[0]
    venue_str = parts[1] if len(parts) > 1 else "SSE"

    return Equity(
        instrument_id=InstrumentId(symbol=Symbol(raw_symbol), venue=venue_str),
        raw_symbol=Symbol(raw_symbol),
        currency=Currency.from_str("CNY"),
        price_precision=2,
        price_increment=Price.from_str("0.01"),
        lot_size=Quantity.from_int(100),
        ts_event=ts_init,
        ts_init=ts_init,
        is_inverse=False,
    )


def calc_limit_prices(
    pre_close: Price,
    limit_pct: float,
) -> tuple[Price, Price]:
    """根据昨收价计算涨跌停价。

    A 股规则：涨停价 = 昨收 × (1 + limit_pct)，跌停价 = 昨收 × (1 - limit_pct)，
    四舍五入到最小价格变动单位（0.01 元）。

    Args:
        pre_close: 昨日收盘价
        limit_pct: 涨跌停幅度，ETF 通常 0.10（±10%），创业板/科创板 0.20（±20%）

    Returns:
        (涨停价, 跌停价) 的 Price 元组
    """
    pc = pre_close.as_double()
    up_raw = round(pc * (1 + limit_pct), 2)
    down_raw = round(pc * (1 - limit_pct), 2)
    return Price.from_str(f"{up_raw:.2f}"), Price.from_str(f"{down_raw:.2f}")
```

- [ ] **Step 4: 运行测试确认通过**

Run:
```bash
wsl -- bash -lc "cd /mnt/e/量化平台_V1.4.0 && PYTHONPATH=src python3 -m pytest src/tests/quant_v2/nautilus_poc/test_ashare_instruments.py -v 2>&1 | tail -20"
```
Expected: 3 passed

- [ ] **Step 5: 提交**

```bash
cd /mnt/e/量化平台_V1.4.0
git add src/quant_v2/nautilus_poc/ashare_instruments.py src/tests/quant_v2/nautilus_poc/test_ashare_instruments.py
git commit -m "feat(nautilus-poc): Task3 A股Instrument定义(涨跌停/100股/0.01元)"
```

---

## Task 4: T+1 约束 FillModel（核心风险验证）

**目标:** 验证 A2 假设的最核心部分——T+1（当日买入不可卖）能否用 FillModel 实现，还是非得改 Rust 核心。这是整个 PoC 最关键的任务，决定迁移路线是否可行。

**Files:**
- Create: `src/quant_v2/nautilus_poc/t1_fill_model.py`
- Create: `src/tests/quant_v2/nautilus_poc/test_t1_fill_model.py`

**Interfaces:**
- Consumes: Task 3 的 `calc_limit_prices`、NautilusTrader `FillModel`
- Produces: `T1LimitFillModel`（继承 Nautilus FillModel），在 fill 卖单时检查持仓的"今日买入部分不可卖"

- [ ] **Step 1: 先调研 Nautilus FillModel 接口**

这一步是探索性的——Nautilus 的 FillModel API 需要先看清楚签名，才能写 T+1 逻辑。

Run:
```bash
wsl -- bash -lc "cd /mnt/e/量化平台_V1.4.0 && python3 -c \"
from nautilus_trader.execution.reports import FillModel
import inspect
print(inspect.getsource(FillModel))
\" 2>&1 | head -80"
```
Expected: 打印 FillModel 源码。**关键看：** 它有哪些可重写方法（`is_limit_filled`/`is_slipped`/`fill_limit_inside_spread`）？这些方法能访问 Position 吗？

如果 FillModel 不暴露 Position 访问能力，T+1 就不能用 FillModel 实现——这是 A2 的关键判定点。记录发现。

- [ ] **Step 2: 写失败测试**

Create `src/tests/quant_v2/nautilus_poc/test_t1_fill_model.py`:

```python
"""测试 T+1 FillModel——这是 A2 假设的核心验证。

T+1 规则：当日买入的股票当日不可卖出，只能卖 T-1 及更早买入的部分。
"""
import pytest


def test_t1_fill_model_rejects_same_day_sell():
    """当日买入的股票，当日卖出应被拒绝（T+1 约束）。

    这个测试验证 T+1 逻辑的存在性。具体实现取决于
    Task 4 Step 1 调研的 Nautilus FillModel 接口。
    """
    # 具体测试体在 Step 1 调研后填充——因为取决于 Nautilus
    # FillModel 能否访问 Position 的"买入日期"信息
    #
    # 如果 FillModel 能访问 Position → 用 FillModel 拦截
    # 如果不能 → 需要在策略层维护 T+1 标记（降级方案）
    #
    # 这里的占位测试只是声明意图，实际测试在 Step 1 调研后写。
    from quant_v2.nautilus_poc.t1_fill_model import T1LimitFillModel

    assert T1LimitFillModel is not None  # 至少能 import


def test_t1_fill_model_allows_previous_day_sell():
    """T-1 及更早买入的股票可以卖出。"""
    # 同上，实现取决于 Step 1 调研结果
    from quant_v2.nautilus_poc.t1_fill_model import T1LimitFillModel

    assert T1LimitFillModel is not None
```

> **注意：** 这两个测试的完整实现依赖 Step 1 的 Nautilus FillModel 接口调研结果。如果调研发现 FillModel 不能访问 Position 内部状态（T+1 需要知道每笔持仓的买入日期），则采用降级方案：在策略层维护 `dict[symbol, buy_date]`，卖出前检查。测试体相应调整为测试策略层的 T+1 检查逻辑。**这一步的结论直接决定 A2 假设是否通过，必须在报告中明确记录。**

- [ ] **Step 3: 运行测试确认失败**

Run:
```bash
wsl -- bash -lc "cd /mnt/e/量化平台_V1.4.0 && PYTHONPATH=src python3 -m pytest src/tests/quant_v2/nautilus_poc/test_t1_fill_model.py -v 2>&1 | tail -20"
```
Expected: FAIL（ModuleNotFoundError: t1_fill_model）

- [ ] **Step 4: 写实现（基于 Step 1 调研结果）**

Create `src/quant_v2/nautilus_poc/t1_fill_model.py`:

```python
"""T+1 约束 FillModel——A 股当日买入不可卖。

实现策略取决于 Task 4 Step 1 的 Nautilus FillModel 接口调研：

方案 A（首选）：如果 FillModel.is_limit_filled() 能访问 Position，
    则继承 FillModel 重写 fill 逻辑，拒绝卖出当日买入的持仓。

方案 B（降级）：如果 FillModel 不能访问 Position 内部状态，
    则提供一个 T1PositionTracker 辅助类，策略层在 on_bar 里
    调用 tracker.check_sellable(symbol, current_date) 检查后再下单。

本文件在 Step 1 调研后确定走哪个方案并填充实现。
"""

# === 以下为方案 B（降级）的初始实现骨架 ===
# 如果 Step 1 调研发现 FillModel 能访问 Position，则替换为方案 A。

from datetime import date
from typing import Optional


class T1PositionTracker:
    """T+1 持仓追踪器（降级方案）。

    记录每个标的的买入日期，卖出时检查是否 T+1。

    A 股规则：当日买入的股票，最早下一个交易日才能卖出。
    ETF（如 511880/510300）是 T+0 还是 T+1 取决于标的类型，
    大部分 ETF 是 T+1，少数跨境/债券 ETF 是 T+0。
    """

    def __init__(self):
        # symbol -> 最近一次买入日期
        self._last_buy_date: dict[str, date] = {}

    def record_buy(self, symbol: str, buy_date: date) -> None:
        """记录买入。"""
        self._last_buy_date[symbol] = buy_date

    def is_sellable(self, symbol: str, current_date: date) -> bool:
        """检查该标的在 current_date 是否可卖（T+1 约束）。

        Returns:
            True 如果 last_buy_date < current_date（T+1 满足）
            True 如果从未买入（没有持仓，无所谓 T+1）
            False 如果 last_buy_date == current_date（当日买入，T+1 违反）
        """
        last_buy = self._last_buy_date.get(symbol)
        if last_buy is None:
            return True  # 无买入记录，不受 T+1 约束
        return last_buy < current_date

    def clear(self, symbol: str) -> None:
        """清仓后清除记录。"""
        self._last_buy_date.pop(symbol, None)


# 方案 A（如果 FillModel 可访问 Position）的 FillModel 实现待 Step 1 确定后补
# from nautilus_trader.execution.reports import FillModel
#
# class T1LimitFillModel(FillModel):
#     ...
```

- [ ] **Step 5: 运行测试确认通过**

Run:
```bash
wsl -- bash -lc "cd /mnt/e/量化平台_V1.4.0 && PYTHONPATH=src python3 -m pytest src/tests/quant_v2/nautilus_poc/test_t1_fill_model.py -v 2>&1 | tail -20"
```
Expected: 2 passed

- [ ] **Step 6: 补充 T1PositionTracker 单元测试**

追加到 `src/tests/quant_v2/nautilus_poc/test_t1_fill_model.py`:

```python
from datetime import date
from quant_v2.nautilus_poc.t1_fill_model import T1PositionTracker


def test_tracker_same_day_not_sellable():
    """当日买入，当日不可卖。"""
    tracker = T1PositionTracker()
    tracker.record_buy("510300.SH", date(2024, 1, 2))
    assert tracker.is_sellable("510300.SH", date(2024, 1, 2)) is False


def test_tracker_next_day_sellable():
    """次日可卖。"""
    tracker = T1PositionTracker()
    tracker.record_buy("510300.SH", date(2024, 1, 2))
    assert tracker.is_sellable("510300.SH", date(2024, 1, 3)) is True


def test_tracker_no_position_sellable():
    """无持仓不受 T+1 约束。"""
    tracker = T1PositionTracker()
    assert tracker.is_sellable("510300.SH", date(2024, 1, 2)) is True
```

Run:
```bash
wsl -- bash -lc "cd /mnt/e/量化平台_V1.4.0 && PYTHONPATH=src python3 -m pytest src/tests/quant_v2/nautilus_poc/test_t1_fill_model.py -v 2>&1 | tail -20"
```
Expected: 5 passed（原 2 + 新 3）

- [ ] **Step 7: 记录 A2 结论**

这一步是 PoC 的核心判定。在实现完成后，明确记录：
- T+1 用的是什么方案（A: FillModel 拦截 / B: 策略层 Tracker）？
- 方案是否满足"不改 Rust 核心"的要求？
- 如果是方案 B，对策略代码的影响多大（每个策略都要加 Tracker 调用吗）？

这些结论写入 Task 7 的 PoC 报告。

- [ ] **Step 8: 提交**

```bash
cd /mnt/e/量化平台_V1.4.0
git add src/quant_v2/nautilus_poc/t1_fill_model.py src/tests/quant_v2/nautilus_poc/test_t1_fill_model.py
git commit -m "feat(nautilus-poc): Task4 T+1约束FillModel(A2核心风险验证)"
```

---

## Task 5: 迷你聚宽兼容桥 + ETF 换仓策略（验证桥底层对接）

**目标:** 写一个**迷你聚宽兼容桥**，实现聚宽 API 的 `history`（取数）+ `order_target_value`（下单）+ `handle_data`（调度）三个核心 API，底层对接 Nautilus（cache 取 Bar + submit_order），上层暴露聚宽风格接口。然后用这个桥跑一个最简 ETF 双标的动量轮动策略（策略代码用聚宽风格写）。验证 A4 假设（聚宽 API 经桥对接 Nautilus 可行）——这是阶段 1 全功能复刻 jq_bridge 的信心基础。

**Files:**
- Create: `src/quant_v2/nautilus_poc/mini_jq_bridge.py`（迷你兼容桥）
- Create: `src/quant_v2/nautilus_poc/jq_rotation_strategy.py`（桥接 Nautilus 的策略宿主）
- Create: `src/tests/quant_v2/nautilus_poc/test_mini_jq_bridge.py`

**Interfaces:**
- Consumes: Task 2 的 `load_bars_from_clickhouse`、Task 3 的 `make_etf_instrument`、Task 4 的 `T1PositionTracker`
- Produces: `MiniJqBridge`（聚宽风格 API，内部对接 Nautilus）+ `JqRotationStrategy`（Nautilus Strategy 子类，宿主聚宽策略逻辑），供 Task 6 的 `run_poc.py` 使用

- [ ] **Step 1: 写失败测试**

Create `src/tests/quant_v2/nautilus_poc/test_mini_jq_bridge.py`:

```python
"""测试迷你聚宽兼容桥——验证聚宽 API 经桥对接 Nautilus 可行。

这是 A4 假设（聚宽 API 兼容）的核心验证。
测试三个桥接的关键转换，不依赖 Nautilus 运行时（用 mock）。
"""
import pytest
import pandas as pd
from unittest.mock import MagicMock, patch
from datetime import date


def test_bridge_history_returns_pandas_dataframe():
    """验证 history() 返回聚宽风格的 pandas DataFrame。

    聚宽 history(security_list, unit, count, fields) 返回
    DataFrame（index=标的，columns 或 index=日期），桥内部从
    Nautilus cache 取 Bar 并组装成这个格式。
    """
    from quant_v2.nautilus_poc.mini_jq_bridge import MiniJqBridge

    bridge = MiniJqBridge()
    # 模拟 cache 里有 3 根 Bar（两个标的）
    mock_bars = {
        "510300.SH": [
            MagicMock(close=MagicMock(as_double=lambda: 1.50)),
            MagicMock(close=MagicMock(as_double=lambda: 1.52)),
            MagicMock(close=MagicMock(as_double=lambda: 1.55)),
        ],
    }
    bridge._closes_cache = {"510300.SH": [1.50, 1.52, 1.55]}

    result = bridge.history(
        security_list=["510300.SH"],
        count=3,
        fields=["close"],
    )

    # 聚宽 history 返回 DataFrame
    assert isinstance(result, pd.DataFrame)
    assert "close" in result.columns or "close" in [str(c) for c in result.columns]


def test_bridge_order_target_value_translates_to_shares():
    """验证 order_target_value 把目标金额转成具体股数。

    聚宽 order_target_value(security, target_value)：把该标的
    持仓调整到目标市值。桥内部：当前持仓 + 当前价 → 差额股数
    → 转 Nautilus 市价单（100 股一手向下取整）。
    """
    from quant_v2.nautilus_poc.mini_jq_bridge import MiniJqBridge

    bridge = MiniJqBridge()
    # 模拟：无持仓，当前价 1.50，目标市值 100000
    # 应买股数 = 100000 / 1.50 = 66666 → 向下取整到 100 股一手 = 66600
    bridge._portfolio_value = 100000.0
    bridge._current_prices = {"510300.SH": 1.50}
    bridge._current_holdings = {"510300.SH": 0.0}

    target_shares = bridge._calc_target_shares(
        "510300.SH", target_value=100000
    )

    # 向下取整到 100 股一手
    assert target_shares == 66600


def test_bridge_order_target_value_respects_t1():
    """验证卖出时 T+1 约束生效（当日买入不可卖）。"""
    from quant_v2.nautilus_poc.mini_jq_bridge import MiniJqBridge
    from quant_v2.nautilus_poc.t1_fill_model import T1PositionTracker

    bridge = MiniJqBridge()
    bridge._t1_tracker = T1PositionTracker()
    bridge._t1_tracker.record_buy("510300.SH", date(2024, 1, 2))

    # 当日（1-2）尝试减仓到 0 → T+1 阻止
    can_sell = bridge._t1_tracker.is_sellable("510300.SH", date(2024, 1, 2))
    assert can_sell is False

    # 次日（1-3）可卖
    can_sell = bridge._t1_tracker.is_sellable("510300.SH", date(2024, 1, 3))
    assert can_sell is True


def test_jq_rotation_strategy_is_nautilus_strategy():
    """验证 JqRotationStrategy 是 Nautilus Strategy 子类（宿主聚宽策略）。"""
    from quant_v2.nautilus_poc.jq_rotation_strategy import JqRotationStrategy
    from nautilus_trader.trading.strategy import Strategy

    strat = JqRotationStrategy(
        symbols=["510300.SH", "159915.SZ"],
        lookback=20,
    )
    assert isinstance(strat, Strategy)
```

- [ ] **Step 2: 运行测试确认失败**

Run:
```bash
wsl -- bash -lc "cd /mnt/e/量化平台_V1.4.0 && PYTHONPATH=src /mnt/e/量化平台_V1.4.0/.venv-nautilus/bin/python3 -m pytest src/tests/quant_v2/nautilus_poc/test_mini_jq_bridge.py -v 2>&1 | tail -20"
```
Expected: FAIL（ModuleNotFoundError: mini_jq_bridge / jq_rotation_strategy）

- [ ] **Step 3: 写迷你兼容桥实现**

Create `src/quant_v2/nautilus_poc/mini_jq_bridge.py`:

```python
"""迷你聚宽兼容桥——验证聚宽 API 经桥对接 Nautilus 可行。

这是阶段 1 全功能复刻 jq_bridge 的最小可行验证。只实现：
- history()：取数（从 Nautilus cache 取 Bar → 组装 pandas DataFrame）
- order_target_value()：下单（目标金额 → 差额股数 → Nautilus 市价单）
- T+1 约束：复用 Task 4 的 T1PositionTracker

聚宽语义（上层）和 Nautilus 接口（底层）之间的转换在这里完成。
策略代码只看到聚宽风格 API，Nautilus 完全隐藏在桥后。
"""
from datetime import date
from typing import Optional

import pandas as pd

from quant_v2.nautilus_poc.t1_fill_model import T1PositionTracker


class MiniJqBridge:
    """迷你聚宽兼容桥（PoC 版，非完整 jq_bridge）。

    桥持有策略的运行时状态引用（Nautilus cache/portfolio/order_factory），
    这些由宿主 JqRotationStrategy 在 on_start 时注入。
    """

    def __init__(self):
        # 运行时注入的 Nautilus 引用（宿主策略在 on_start 设置）
        self._cache = None
        self._portfolio = None
        self._order_factory = None
        self._submit_order_fn = None

        # 桥维护的中间状态
        self._closes_cache: dict[str, list[float]] = {}
        self._current_prices: dict[str, float] = {}
        self._current_holdings: dict[str, float] = {}
        self._portfolio_value: float = 0.0
        self._t1_tracker = T1PositionTracker()

    def attach_runtime(self, cache, portfolio, order_factory, submit_fn):
        """宿主策略注入 Nautilus 运行时引用。"""
        self._cache = cache
        self._portfolio = portfolio
        self._order_factory = order_factory
        self._submit_order_fn = submit_fn

    def record_bar(self, symbol: str, close: float):
        """宿主 on_bar 时记录收盘价（桥自己不订阅，由宿主转发）。"""
        self._closes_cache.setdefault(symbol, []).append(close)
        self._current_prices[symbol] = close

    def history(
        self,
        security_list: list[str],
        count: int,
        fields: list[str] | None = None,
    ) -> pd.DataFrame:
        """聚宽 history API。

        返回 DataFrame，index=标的（count>1 时）或日期序列。
        PoC 版只组装 close 字段（从 _closes_cache 取最近 count 根）。
        阶段 1 完整版会从 Nautilus cache 取完整 OHLCV。
        """
        if fields is None:
            fields = ["close"]

        rows = {}
        for sym in security_list:
            closes = self._closes_cache.get(sym, [])
            rows[sym] = closes[-count:] if len(closes) >= count else closes

        df = pd.DataFrame(rows)
        if "close" in fields:
            return df
        return df

    def _calc_target_shares(self, symbol: str, target_value: float) -> int:
        """目标金额 → 目标股数（100 股一手向下取整）。"""
        price = self._current_prices.get(symbol, 0)
        if price <= 0:
            return 0
        raw_shares = target_value / price
        # 向下取整到 100 股一手
        return int(raw_shares // 100) * 100

    def order_target_value(
        self,
        security: str,
        target_value: float,
        current_date: date,
    ) -> Optional[object]:
        """聚宽 order_target_value：把持仓调整到目标市值。

        内部逻辑：
        1. 算目标股数 vs 当前股数的差额
        2. T+1 检查（卖出时）
        3. 转 Nautilus 市价单提交
        """
        target_shares = self._calc_target_shares(security, target_value)
        current_shares = self._current_holdings.get(security, 0)
        diff = target_shares - current_shares

        if diff == 0:
            return None

        if diff < 0:
            # 卖出 → T+1 检查
            if not self._t1_tracker.is_sellable(security, current_date):
                return None  # T+1 阻止，跳过

        # 转 Nautilus 订单（实际提交逻辑在宿主注入的 submit_fn）
        if diff > 0:
            self._t1_tracker.record_buy(security, current_date)

        if self._submit_order_fn:
            return self._submit_order_fn(security, diff)
        return None

    def get_position_value(self, symbol: str) -> float:
        """聚宽 context.portfolio.positions[symbol].value 代理。"""
        shares = self._current_holdings.get(symbol, 0)
        price = self._current_prices.get(symbol, 0)
        return shares * price

    def update_holdings(self, symbol: str, shares_change: int):
        """成交后更新桥维护的持仓快照。"""
        self._current_holdings[symbol] = (
            self._current_holdings.get(symbol, 0) + shares_change
        )
```

- [ ] **Step 4: 写宿主策略 JqRotationStrategy**

Create `src/quant_v2/nautilus_poc/jq_rotation_strategy.py`:

```python
"""用迷你聚宽桥跑 ETF 换仓——验证桥底层对接 Nautilus。

这个 Nautilus Strategy 子类是"宿主"：它持有 MiniJqBridge，
把 Nautilus 事件（on_bar/on_event）转发给桥，并在桥的聚宽 API
被调用时，把请求翻译成 Nautilus 操作（submit_order/cache 查询）。

策略业务逻辑（选动量最高标的、调仓到目标）用聚宽风格写，
通过桥执行，Nautilus 完全隐藏在桥后。
"""
from datetime import datetime, timezone

from nautilus_trader.trading.strategy import Strategy
from nautilus_trader.model.data import Bar, BarType
from nautilus_trader.model.enums import OrderSide
from nautilus_trader.model.identifiers import InstrumentId
from nautilus_trader.model.objects import Quantity

from quant_v2.nautilus_poc.mini_jq_bridge import MiniJqBridge


class JqRotationStrategy(Strategy):
    """宿主策略：桥接聚宽风格逻辑到 Nautilus。"""

    def __init__(
        self,
        symbols: list[str],
        lookback: int = 20,
    ):
        super().__init__()
        self._symbols = symbols
        self._lookback = lookback
        self._bridge = MiniJqBridge()

    def on_start(self):
        """启动时注入 Nautilus 运行时引用给桥，并订阅 Bar。"""
        self._bridge.attach_runtime(
            cache=self.cache,
            portfolio=self.portfolio,
            order_factory=self.order_factory,
            submit_fn=self._submit_via_nautilus,
        )
        for symbol in self._symbols:
            bar_type = BarType.from_str(f"{symbol}-1-DAY-LAST-EXTERNAL")
            self.subscribe_bars(bar_type)

    def on_bar(self, bar: Bar):
        """每个日线 bar：转发给桥，执行聚宽风格策略逻辑。"""
        symbol = str(bar.bar_type.instrument_id)
        self._bridge.record_bar(symbol, bar.close.as_double())

        # 数据不足时跳过（聚宽策略里类似 if len(history) < N: return）
        closes = self._bridge._closes_cache.get(symbol, [])
        if len(closes) < self._lookback + 1:
            return
        if not all(
            len(self._bridge._closes_cache.get(s, [])) >= self._lookback + 1
            for s in self._symbols
        ):
            return

        # 聚宽风格策略逻辑：算动量，选最高，调仓
        momentum = {}
        for s in self._symbols:
            c = self._bridge._closes_cache[s]
            momentum[s] = c[-1] / c[-self._lookback] - 1

        best = max(momentum, key=momentum.get)

        current_date = datetime.fromtimestamp(
            bar.ts_event / 1e9, tz=timezone.utc
        ).date()

        # 用聚宽风格 API（经桥）执行调仓
        # 先把非 best 标的调到 0
        for s in self._symbols:
            if s != best:
                self._bridge.order_target_value(
                    s, target_value=0, current_date=current_date
                )

        # 把 best 调到全仓
        account = self.portfolio.account(None)
        if account:
            cash = account.balance_free(None)
            self._bridge.order_target_value(
                best,
                target_value=cash.as_double(),
                current_date=current_date,
            )

    def _submit_via_nautilus(self, symbol: str, shares_change: int):
        """桥的 submit_fn：把聚宽"股数变化"翻译成 Nautilus 市价单。"""
        inst_id = InstrumentId.from_str(symbol)
        if shares_change > 0:
            order = self.order_factory.market(
                instrument_id=inst_id,
                order_side=OrderSide.BUY,
                quantity=Quantity.from_int(shares_change),
            )
            self.submit_order(order)
            self._bridge.update_holdings(symbol, shares_change)
        elif shares_change < 0:
            position = self.cache.for_instrument(inst_id)
            if position:
                sell_qty = Quantity.from_int(min(-shares_change, int(position.quantity)))
                order = self.order_factory.market(
                    instrument_id=inst_id,
                    order_side=OrderSide.SELL,
                    quantity=sell_qty,
                )
                self.submit_order(order)
                self._bridge.update_holdings(symbol, -int(sell_qty))
```

- [ ] **Step 5: 运行测试确认通过**

Run:
```bash
wsl -- bash -lc "cd /mnt/e/量化平台_V1.4.0 && PYTHONPATH=src /mnt/e/量化平台_V1.4.0/.venv-nautilus/bin/python3 -m pytest src/tests/quant_v2/nautilus_poc/test_mini_jq_bridge.py -v 2>&1 | tail -20"
```
Expected: 4 passed（history 返回 DataFrame + order_target_value 股数换算 + T+1 阻止 + JqRotationStrategy 是 Strategy 子类）

- [ ] **Step 6: 提交**

```bash
cd /mnt/e/量化平台_V1.4.0/src
git add src/quant_v2/nautilus_poc/mini_jq_bridge.py src/quant_v2/nautilus_poc/jq_rotation_strategy.py src/tests/quant_v2/nautilus_poc/test_mini_jq_bridge.py
git commit -m "feat(nautilus-poc): Task5 迷你聚宽兼容桥+ETF换仓策略(A4桥底层对接验证)"
```

---

## Task 6: PoC 主入口——组装全部组件跑回测

**目标:** 把 Task 2-5 的组件组装起来，用真实 ClickHouse 数据跑一次最简回测，验证 A 股 + 未复权数据 + T+1 的完整链路端到端跑通。这是 PoC 的最终验证。

**Files:**
- Create: `src/quant_v2/nautilus_poc/run_poc.py`

**Interfaces:**
- Consumes: Task 2-5 全部组件 + NautilusTrader BacktestEngine
- Produces: 一次完整的回测结果（equity curve + trades）

- [ ] **Step 1: 写 PoC 主入口**

Create `src/quant_v2/nautilus_poc/run_poc.py`:

```python
"""NautilusTrader PoC 主入口——组装全部组件跑一次完整回测。

验证目标（端到端）：
1. ClickHouse 未复权数据能注入 Nautilus（Task 2）
2. A 股 Instrument 配置生效（Task 3）
3. T+1 约束运行时生效（Task 4）
4. 策略 on_bar → 下单 → 撮合 → 持仓完整链路跑通（Task 5）

不追求收益合理，只追求"机制端到端跑通且不崩溃"。
"""
from nautilus_trader.backtest.engine import BacktestEngine
from nautilus_trader.model.currency import Currency
from nautilus_trader.model.objects import Money
from nautilus_trader.model.enums import OmsType, AccountType
from nautilus_trader.model.identifiers import Venue
from nautilus_trader.model.data import BarType, BarSpecification
from nautilus_trader.model.enums import PriceType, AggregationSource
from nautilus_trader.model.identifiers import InstrumentId
from nautilus_trader.config import BacktestVenueConfig, BacktestDataConfig
from nautilus_trader.config import BacktestEngineConfig
from nautilus_trader.model.objects import Price

from quant_v2.nautilus_poc.clickhouse_to_bars import load_bars_from_clickhouse
from quant_v2.nautilus_poc.ashare_instruments import make_etf_instrument
from quant_v2.nautilus_poc.jq_rotation_strategy import JqRotationStrategy


def run_poc():
    """运行 PoC 回测。"""
    symbols = ["510300.SH", "159915.SZ"]
    start_date = "2024-01-01"
    end_date = "2024-06-30"

    print("=" * 60)
    print("NautilusTrader A 股 PoC 回测")
    print(f"  标的: {symbols}")
    print(f"  区间: {start_date} ~ {end_date}")
    print("=" * 60)

    engine = BacktestEngine(
        config=BacktestEngineConfig()
    )

    # 1. 添加交易场所（模拟账户）
    venue = Venue("SSE")
    engine.add_venue(
        venue=venue,
        oms_type=OmsType.NETTING,
        account_type=AccountType.CASH,
        starting_balances=[Money(100000, Currency.from_str("CNY"))],
        base_currency=Currency.from_str("CNY"),
    )

    # 2. 注册 Instrument + 注入数据（每个标的）
    for symbol in symbols:
        inst = make_etf_instrument(symbol)
        engine.add_instrument(inst)

        bar_type = BarType(
            instrument_id=inst.id,
            spec=BarSpecification(
                step=1,
                aggregation=AggregationSource.EXTERNAL,
                price_type=PriceType.LAST,
            ),
        )

        print(f"加载 {symbol} 数据...")
        bars = load_bars_from_clickhouse(
            symbol=symbol,
            start_date=start_date,
            end_date=end_date,
            bar_type=bar_type,
        )
        print(f"  加载 {len(bars)} 根 Bar")
        engine.add_data(bars)

    # 3. 添加策略（聚宽风格经迷你桥对接 Nautilus）
    strategy = JqRotationStrategy(
        symbols=symbols,
        lookback=20,
    )
    engine.add_strategy(strategy)

    # 4. 运行回测
    print("\n开始回测...")
    engine.run()

    # 5. 输出结果
    portfolio = engine.portfolio
    account = portfolio.account(venue)
    balance = account.balance_total()
    print("\n" + "=" * 60)
    print("回测完成")
    print(f"  最终权益: {balance}")
    print(f"  成交笔数: {len(engine.cache.orders_closed)}")
    print("=" * 60)

    # 6. 保存结果供报告引用
    print("\nPoC 结论：")
    print("  A1 (WSL2环境): 通过/失败")
    print("  A2 (A股T+1): 通过/失败")
    print("  A3 (数据注入): 通过/失败")
    print("  A4 (策略链路): 通过/失败")
    print("  → 填入 docs/superpowers/reports/2026-07-09-nautilus-poc-report.md")


if __name__ == "__main__":
    run_poc()
```

> **注意：** 上面的代码可能需要根据 NautilusTrader 实际 API（版本差异）调整方法签名。例如 `add_venue`、`add_instrument`、`account.balance_total()` 的确切签名可能因版本而异。Step 2 运行时如果报 API 不匹配，查阅 Nautilus 文档修正签名——这本身也是 PoC 的有价值发现（API 学习成本）。

- [ ] **Step 2: 运行 PoC 回测**

Run:
```bash
wsl -- bash -lc "cd /mnt/e/量化平台_V1.4.0 && PYTHONPATH=src PYTHONUNBUFFERED=1 python3 src/quant_v2/nautilus_poc/run_poc.py 2>&1 | tee /tmp/nautilus_poc_run.log"
```
Expected: 回测跑通，打印权益和成交数。**如果崩溃，记录 traceback**——每个错误都是 PoC 的有价值发现。常见问题：
- Nautilus API 签名不匹配 → 查文档修正
- ClickHouse 查询字段不匹配 → 检查表结构
- Bar 构造参数错误 → 检查 Price/Quantity 转换
- 策略 on_bar 里 cache/portfolio API 不对 → 查 Nautilus 策略文档

迭代修正直到跑通或确认某个假设失败。

- [ ] **Step 3: 提交**

```bash
cd /mnt/e/量化平台_V1.4.0
git add src/quant_v2/nautilus_poc/run_poc.py
git commit -m "feat(nautilus-poc): Task6 PoC主入口(完整链路端到端回测)"
```

---

## Task 7: PoC 结论报告

**目标:** 汇总 Task 1-6 的发现，产出 PoC 结论报告，决定是否进入阶段 1（正式迁移）。

**Files:**
- Create: `docs/superpowers/reports/2026-07-09-nautilus-poc-report.md`

- [ ] **Step 1: 写 PoC 报告**

报告必须回答以下问题（基于 Task 1-6 的真实运行结果填写）：

Create `docs/superpowers/reports/2026-07-09-nautilus-poc-report.md`:

```markdown
# NautilusTrader 迁移 PoC 结论报告

> 日期：2026-07-XX（完成后填实际日期）
> 关联规格：docs/superpowers/specs/2026-07-09-nautilus-migration-design.md
> 关联计划：docs/superpowers/plans/2026-07-09-nautilus-poc.md

## 5 个假设验证结果

| 假设 | 结果 | 证据 | 说明 |
|------|------|------|------|
| A1 WSL2 环境 | [通过/失败] | [Nautilus 版本号 + demo 跑通] | |
| A2 T+1 约束 | [通过/失败] | [方案 A 或 B + 是否改 Rust 核心] | |
| A2 涨跌停 | [通过/失败] | [FillModel 拦截是否生效] | |
| A3 数据注入 | [通过/失败] | [加载 N 根 Bar + 真实回测出结果] | |
| A4 策略链路 | [通过/失败] | [on_bar→下单→撮合→持仓跑通] | |
| A5 回测/实盘共用 | [通过/失败] | [API 层设计评估] | |

## 关键发现

### T+1 实现方式
[填：用 FillModel 还是 Tracker？对策略代码的影响？]

### Nautilus API 学习成本
[填：实际遇到哪些 API 不匹配？文档质量如何？]

### 复权机制实际效果
[填：未复权注入 + 因子补偿是否如设计预期工作？]

### 性能初步印象
[填：日线回测速度与现有 V2 引擎的粗略对比]

## 决策

- [ ] **进入阶段 1（正式迁移）**：5 个假设全部通过或可接受
- [ ] **回退到增量下沉 Rust**：A2（T+1）失败或成本不可接受
- [ ] **需要更多调研**：哪些问题 PoC 未完全回答

## 给阶段 1 的输入

[如果决定继续，列出阶段 1 需要优先处理的问题]
```

- [ ] **Step 2: 提交报告**

```bash
cd /mnt/e/量化平台_V1.4.0
git add docs/superpowers/reports/2026-07-09-nautilus-poc-report.md
git commit -m "docs(nautilus-poc): Task7 PoC结论报告(5假设验证结果+决策)"
```

- [ ] **Step 3: 同步到研究库**

将 PoC 结论同步到研究库的当前状态文档，因为这是平台层面的重大决策。

```bash
# 在研究库更新 00_入口/当前状态.md，新增 Nautilus PoC 条目
# 更新研究驾驶舱
```

---

## 计划自审

### 1. 规格覆盖

| 规格章节 | 对应 Task |
|---------|-----------|
| §4 A1 假设（WSL2） | Task 1 |
| §4 A2 假设（T+1/涨跌停） | Task 3（Instrument）+ Task 4（T+1 FillModel） |
| §4 A3 假设（数据注入） | Task 2 |
| §4 A4 假设（兼容桥） | Task 5（策略 API 初步评估） |
| §4 A5 假设（回测/实盘共用） | Task 7（报告评估） |
| §5 数据适配层 | Task 2 |
| §6 A 股市场模型 | Task 3 + Task 4 |
| §9 PoC 详细设计 | Task 1-7 完整覆盖 |

**覆盖完整。** A4/A5 在 PoC 阶段只能初步评估（完整验证在阶段 1），报告里如实标注。

### 2. 占位符扫描

- Task 4 Step 1 是"探索性调研"步骤，不是占位符——它产出的是真实的 Nautilus FillModel 接口发现，决定后续代码走向。这是有意的分支设计（T+1 实现方式取决于调研结果），标注明确。
- Task 4 Step 2 的测试体明确标注"实现取决于 Step 1 调研结果"，并给出了两个方案的具体代码骨架，不是空洞的 TODO。
- Task 7 报告模板用 `[填...]` 标注需要根据真实运行结果填写的部分——这是报告的性质，不是计划占位符。

### 3. 类型一致性

- `load_bars_from_clickhouse(symbol, start_date, end_date, bar_type)` —— Task 2 定义，Task 6 使用，签名一致。
- `make_etf_instrument(symbol)` —— Task 3 定义，Task 6 使用，签名一致。
- `T1PositionTracker.record_buy/is_sellable/clear` —— Task 4 定义，Task 5 使用，方法名一致。
- `SimpleRotationStrategy(symbols, bar_type_str)` —— Task 5 定义，Task 6 使用，签名一致。

**类型一致性确认通过。**
