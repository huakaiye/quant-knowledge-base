# 聚宽数据库重构 · 阶段 0：jq_fetcher 直连框架 实现计划

> 历史实施记录：本文中的 V1.4 路径、旧 runner 和当时命令按原证据保留，禁止作为当前执行入口。当前平台为 `${QUANT_PLATFORM_ROOT}`（V2.0），运行必须遵守研究库与平台各自的 `AGENTS.md`。

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 构建可复用的 jqdatasdk 直连拉取底座（认证/凭证/配额/速率/断点续传/重试/进度），供阶段 1 的 13 表拉取共用，并产出速率实测报告作为阶段 1 工期决策依据。

**Architecture:** 新建 `src/quant_v2/jq_fetcher/` 子包，四个模块按职责拆分——`credentials.py`（三级优先级凭证读取，不入库）、`checkpoint.py`（JSON 落盘断点续传）、`quota.py`（配额监控，包装 `get_query_count`）、`core.py`（`JqFetcher` 主类，封装认证 + 重试 + 并发 + 进度 + 集成前三模块）。所有模块纯函数式/小类，对 ClickHouse 零依赖（阶段 0 只拉不写），用 TDD 手写 Fake 类注入测试。

**Tech Stack:** Python 3.10+（实际 3.14）、jqdatasdk（新增依赖）、pandas、concurrent.futures.ThreadPoolExecutor、pytest（手写 Fake 类，不用 unittest.mock）、loguru。

## Global Constraints

- **编码**：所有新增文本文件 UTF-8 无 BOM（遵循 AGENTS.md）。
- **凭证安全**：聚宽账号密码绝不入库、绝不打印到日志；异常信息脱敏（只报"凭证缺失"或"认证失败"）。
- **依赖边界**：jqdatasdk 只加到 `src/requirements.txt`（Windows 数据生产侧），**禁止**加到 `src/requirements-wsl-backtest.txt`（WSL 回测进程不拉数据）。
- **测试风格**：pytest，`cd src && python -m pytest`，手写 Fake 类注入构造函数，裸 `assert`，`test_<场景>_<行为>` 命名。
- **包结构**：`src/quant_v2/jq_fetcher/`，每个 `__init__.py` 做 re-export 并维护 `__all__`。
- **中文 docstring**：简短，遵循平台既有风格。
- **提交规范**：每个 Task 末尾提交，提交说明中文，遵循 `feat(<scope>): <说明>` 格式。
- **密码特殊字符**：聚宽密码含逗号（如 `645123Zz,`），凭证读取必须作为普通字符串处理，不解析逗号。

**参考规格**：`docs/superpowers/specs/2026-07-08-jq-database-overhaul-design.md` §2（阶段 0）。

**参考实现样本**：
- 凭证三级优先级模式参考 `scripts/sync_tushare_real_bars.py:263-275`（Tushare token 读取）。
- jqdatasdk API 调用样本参考 `scripts/jq_export.py:266-291`（get_price）、`:558-602`（get_fundamentals）。
- 配置热加载模式参考 `src/quant_backtest/data/data_router.py:18-31`（mtime + lock）。

---

## 文件结构

| 文件 | 职责 | 创建/修改 |
| --- | --- | --- |
| `src/quant_v2/jq_fetcher/__init__.py` | 包入口，re-export 公共符号 | 创建 |
| `src/quant_v2/jq_fetcher/credentials.py` | `JqCredentials`：三级优先级读取聚宽凭证 | 创建 |
| `src/quant_v2/jq_fetcher/checkpoint.py` | `Checkpoint`：JSON 落盘断点续传 | 创建 |
| `src/quant_v2/jq_fetcher/quota.py` | `QuotaMonitor`：包装 `get_query_count`，阈值告警 | 创建 |
| `src/quant_v2/jq_fetcher/core.py` | `JqFetcher`：认证 + 重试 + 并发 + 进度 + 集成 | 创建 |
| `src/tests/quant_v2/test_jq_credentials.py` | 凭证模块测试 | 创建 |
| `src/tests/quant_v2/test_jq_checkpoint.py` | 断点模块测试 | 创建 |
| `src/tests/quant_v2/test_jq_quota.py` | 配额模块测试 | 创建 |
| `src/tests/quant_v2/test_jq_fetcher_core.py` | 主类测试（Fake jqdatasdk） | 创建 |
| `src/requirements.txt` | 追加 jqdatasdk 依赖 | 修改 |
| `src/pyproject.toml` | 同步 dependencies 数组 | 修改 |
| `.gitignore` | 追加凭证文件名，闭合缺口 | 修改 |
| `scripts/jq_speed_benchmark.py` | 速率实测脚本，产出报告 | 创建 |

---

## Task 1: 凭证管理 + 依赖 + .gitignore 闭合

**Files:**
- Create: `src/quant_v2/jq_fetcher/credentials.py`
- Create: `src/quant_v2/jq_fetcher/__init__.py`（占位，Task 4 补全 re-export）
- Create: `src/tests/quant_v2/test_jq_credentials.py`
- Modify: `src/requirements.txt`（追加一行）
- Modify: `src/pyproject.toml`（dependencies 数组追加）
- Modify: `.gitignore`（追加凭证文件名）

**Interfaces:**
- Produces: `JqCredentials` 类，构造签名 `JqCredentials(username: str | None = None, password: str | None = None, credentials_file: str | Path | None = None)`；方法 `resolve() -> tuple[str, str]` 返回 `(username, password)`，取不到抛 `CredentialNotFoundError`；类方法 `JqCredentials.from_env() -> JqCredentials`。

- [ ] **Step 1: 修改 `.gitignore` 闭合凭证缺口**

读取 `E:\量化平台_V1.4.0\.gitignore`，在文件末尾追加（若已有相关规则则跳过对应行）：

```gitignore

# 凭证与本地配置（绝不入库）— 2026-07-08 聚宽重构新增

> 历史实施记录：本文中的 V1.4 路径、旧 runner 和当时命令按原证据保留，禁止作为当前执行入口。当前平台为 `${QUANT_PLATFORM_ROOT}`（V2.0），运行必须遵守研究库与平台各自的 `AGENTS.md`。
tushare_token.txt
.tushare_token
*token*.txt
jq_credentials.json
.research.local.json
```

- [ ] **Step 2: 验证 .gitignore 生效**

Run: `cd "E:/量化平台_V1.4.0" && git check-ignore jq_credentials.json tushare_token.txt .research.local.json`
Expected: 三行都打印出文件名（exit 0），表示已被忽略。

- [ ] **Step 3: 追加 jqdatasdk 到 requirements.txt**

在 `src/requirements.txt` 末尾（`requests>=2.28.0` 之后）追加：

```
jqdatasdk>=1.9.0
```

- [ ] **Step 4: 同步 pyproject.toml dependencies**

读取 `src/pyproject.toml`，找到 `[project]` 下的 `dependencies = [...]` 数组，在 `requests>=2.28.0` 对应行后追加 `"jqdatasdk>=1.9.0",`（保持数组格式一致）。

- [ ] **Step 5: 安装 jqdatasdk 到 Windows venv**

Run: `cd "E:/量化平台_V1.4.0" && .venv/Scripts/pip.exe install "jqdatasdk>=1.9.0"`
Expected: 安装成功。再运行 `.venv/Scripts/python.exe -c "import jqdatasdk; print(jqdatasdk.__version__)"` 确认版本号，记下实际版本（若 ≥1.9.0 则 requirements 不用改；若更高可保留 `>=1.9.0`）。

- [ ] **Step 6: 写失败测试 test_jq_credentials.py**

Create `src/tests/quant_v2/test_jq_credentials.py`:

```python
# -*- coding: utf-8 -*-

> 历史实施记录：本文中的 V1.4 路径、旧 runner 和当时命令按原证据保留，禁止作为当前执行入口。当前平台为 `${QUANT_PLATFORM_ROOT}`（V2.0），运行必须遵守研究库与平台各自的 `AGENTS.md`。
"""JqCredentials 凭证读取测试。"""
from __future__ import annotations

import json
from pathlib import Path

import pytest

from quant_v2.jq_fetcher.credentials import (
    JqCredentials,
    CredentialNotFoundError,
)


def test_explicit_params_take_precedence(monkeypatch):
    """显式参数优先级最高，即使环境变量也设了。"""
    monkeypatch.setenv("JQ_USERNAME", "env_user")
    monkeypatch.setenv("JQ_PASSWORD", "env_pass")
    creds = JqCredentials(username="explicit", password="explicit_pass")
    assert creds.resolve() == ("explicit", "explicit_pass")


def test_env_vars_used_when_no_explicit(monkeypatch):
    """无显式参数时读环境变量。"""
    monkeypatch.setenv("JQ_USERNAME", "env_user")
    monkeypatch.setenv("JQ_PASSWORD", "env_pass,with,comma")
    creds = JqCredentials()
    assert creds.resolve() == ("env_user", "env_pass,with,comma")


def test_password_with_comma_preserved(monkeypatch):
    """聚宽密码可含逗号，必须原样保留不被解析。"""
    monkeypatch.setenv("JQ_USERNAME", "18514293731")
    monkeypatch.setenv("JQ_PASSWORD", "645123Zz,")
    creds = JqCredentials()
    assert creds.resolve() == ("18514293731", "645123Zz,")


def test_credentials_file_used_when_no_env(monkeypatch, tmp_path):
    """无环境变量时读凭证文件。"""
    monkeypatch.delenv("JQ_USERNAME", raising=False)
    monkeypatch.delenv("JQ_PASSWORD", raising=False)
    cred_file = tmp_path / "jq_credentials.json"
    cred_file.write_text(
        json.dumps({"username": "file_user", "password": "file_pass"}),
        encoding="utf-8",
    )
    creds = JqCredentials(credentials_file=cred_file)
    assert creds.resolve() == ("file_user", "file_pass")


def test_raises_when_all_sources_missing(monkeypatch, tmp_path):
    """三级都取不到抛 CredentialNotFoundError。"""
    monkeypatch.delenv("JQ_USERNAME", raising=False)
    monkeypatch.delenv("JQ_PASSWORD", raising=False)
    creds = JqCredentials(credentials_file=tmp_path / "nonexistent.json")
    with pytest.raises(CredentialNotFoundError, match="凭证"):
        creds.resolve()


def test_raises_when_file_missing_key(monkeypatch, tmp_path):
    """凭证文件缺 password 键也抛错。"""
    monkeypatch.delenv("JQ_USERNAME", raising=False)
    monkeypatch.delenv("JQ_PASSWORD", raising=False)
    cred_file = tmp_path / "jq_credentials.json"
    cred_file.write_text(
        json.dumps({"username": "only_user"}),
        encoding="utf-8",
    )
    creds = JqCredentials(credentials_file=cred_file)
    with pytest.raises(CredentialNotFoundError):
        creds.resolve()


def test_default_credentials_file_path(monkeypatch):
    """from_env 用默认凭证文件路径（仓库外 E:/xtquant/策略/jq_credentials.json）。"""
    monkeypatch.setenv("JQ_USERNAME", "env_user")
    monkeypatch.setenv("JQ_PASSWORD", "env_pass")
    creds = JqCredentials.from_env()
    assert creds.resolve() == ("env_user", "env_pass")
```

- [ ] **Step 7: 运行测试确认失败**

Run: `cd "E:/量化平台_V1.4.0/src" && python -m pytest tests/quant_v2/test_jq_credentials.py -v`
Expected: FAIL with `ModuleNotFoundError: No module named 'quant_v2.jq_fetcher'`（包还不存在）。

- [ ] **Step 8: 创建包目录和占位 __init__.py**

Create `src/quant_v2/jq_fetcher/__init__.py`（本 Task 只导出 credentials，Task 2-4 补全）:

```python
# -*- coding: utf-8 -*-

> 历史实施记录：本文中的 V1.4 路径、旧 runner 和当时命令按原证据保留，禁止作为当前执行入口。当前平台为 `${QUANT_PLATFORM_ROOT}`（V2.0），运行必须遵守研究库与平台各自的 `AGENTS.md`。
"""jqdatasdk 直连拉取框架。

提供聚宽数据的 API 直连拉取能力：认证、配额监控、断点续传、
重试、并发控制。供数据库重构（阶段 1+）的全量数据拉取共用。
"""
from quant_v2.jq_fetcher.credentials import (
    CredentialNotFoundError,
    JqCredentials,
)

__all__ = ["CredentialNotFoundError", "JqCredentials"]
```

- [ ] **Step 9: 写最小实现 credentials.py**

Create `src/quant_v2/jq_fetcher/credentials.py`:

```python
# -*- coding: utf-8 -*-

> 历史实施记录：本文中的 V1.4 路径、旧 runner 和当时命令按原证据保留，禁止作为当前执行入口。当前平台为 `${QUANT_PLATFORM_ROOT}`（V2.0），运行必须遵守研究库与平台各自的 `AGENTS.md`。
"""聚宽凭证管理 — 三级优先级读取，绝不入库。

优先级：
    1. 构造函数显式参数（测试用）
    2. 环境变量 JQ_USERNAME / JQ_PASSWORD
    3. 凭证文件（默认仓库外 E:/xtquant/策略/jq_credentials.json）

凭证值绝不打印到日志；异常信息脱敏。
"""
from __future__ import annotations

import json
import os
from pathlib import Path

# 默认凭证文件路径（仓库外，与 tushare_token.txt 同目录，不入库）

> 历史实施记录：本文中的 V1.4 路径、旧 runner 和当时命令按原证据保留，禁止作为当前执行入口。当前平台为 `${QUANT_PLATFORM_ROOT}`（V2.0），运行必须遵守研究库与平台各自的 `AGENTS.md`。
DEFAULT_CREDENTIALS_FILE = Path("E:/xtquant/策略/jq_credentials.json")


class CredentialNotFoundError(RuntimeError):
    """聚宽凭证缺失或无效。异常信息不含凭证值本身。"""


class JqCredentials:
    """聚宽账号凭证，三级优先级读取。

    Args:
        username: 显式用户名（手机号），最高优先级。
        password: 显式密码（可含逗号等特殊字符），最高优先级。
        credentials_file: 凭证文件路径，默认 DEFAULT_CREDENTIALS_FILE。
    """

    def __init__(
        self,
        username: str | None = None,
        password: str | None = None,
        credentials_file: str | Path | None = None,
    ) -> None:
        self._explicit_username = username
        self._explicit_password = password
        self._credentials_file = (
            Path(credentials_file) if credentials_file else DEFAULT_CREDENTIALS_FILE
        )

    @classmethod
    def from_env(cls) -> "JqCredentials":
        """用默认三级优先级构造（不传显式参数）。"""
        return cls()

    def resolve(self) -> tuple[str, str]:
        """返回 (username, password)。三级都取不到抛 CredentialNotFoundError。

        异常信息脱敏，绝不回显凭证值。
        """
        # 第 1 级：显式参数
        if self._explicit_username and self._explicit_password:
            return self._explicit_username, self._explicit_password

        # 第 2 级：环境变量
        env_user = os.environ.get("JQ_USERNAME")
        env_pass = os.environ.get("JQ_PASSWORD")
        if env_user and env_pass:
            return env_user, env_pass

        # 第 3 级：凭证文件
        if self._credentials_file.exists():
            try:
                data = json.loads(
                    self._credentials_file.read_text(encoding="utf-8")
                )
                file_user = data.get("username")
                file_pass = data.get("password")
                if file_user and file_pass:
                    return str(file_user), str(file_pass)
            except (json.JSONDecodeError, OSError):
                pass  # 文件损坏，落到下面的报错

        # 三级都失败
        raise CredentialNotFoundError(
            "聚宽凭证缺失：未提供显式参数，环境变量 JQ_USERNAME/JQ_PASSWORD 未设置，"
            f"且凭证文件不存在或无效（查找路径：{self._credentials_file}）。"
        )
```

- [ ] **Step 10: 运行测试确认通过**

Run: `cd "E:/量化平台_V1.4.0/src" && python -m pytest tests/quant_v2/test_jq_credentials.py -v`
Expected: 7 passed。

- [ ] **Step 11: 提交**

```bash
cd "E:/量化平台_V1.4.0"
git add src/quant_v2/jq_fetcher/__init__.py src/quant_v2/jq_fetcher/credentials.py \
        src/tests/quant_v2/test_jq_credentials.py src/requirements.txt src/pyproject.toml .gitignore
git commit -m "feat(jq_fetcher): 凭证管理模块 + jqdatasdk依赖 + gitignore闭合

- JqCredentials 三级优先级读取(显式参数/环境变量/凭证文件)
- 密码含逗号原样保留, 异常信息脱敏不回显凭证值
- jqdatasdk>=1.9.0 加入 requirements.txt(仅Windows数据生产侧)
- .gitignore 补 tushare_token/jq_credentials/.research.local 闭合泄露缺口"
```

---

## Task 2: Checkpoint 断点续传模块

**Files:**
- Create: `src/quant_v2/jq_fetcher/checkpoint.py`
- Create: `src/tests/quant_v2/test_jq_checkpoint.py`
- Modify: `src/quant_v2/jq_fetcher/__init__.py`（追加导出）

**Interfaces:**
- Consumes: 无（纯文件 I/O）
- Produces: `Checkpoint` 类，构造签名 `Checkpoint(task_name: str, checkpoint_dir: str | Path)`；方法 `path -> Path`（只读属性）、`exists() -> bool`、`load() -> dict`（不存在返回空结构 dict）、`mark_completed(item: str) -> None`（写盘）、`mark_failed(item: str, reason: str) -> None`（写盘）、`is_completed(item: str) -> bool`、`should_skip(item: str) -> bool`（等价 is_completed）、`summary() -> dict`（含 total/completed/failed/progress_pct）、`reset() -> None`（删文件重新开始）。

- [ ] **Step 1: 写失败测试 test_jq_checkpoint.py**

Create `src/tests/quant_v2/test_jq_checkpoint.py`:

```python
# -*- coding: utf-8 -*-

> 历史实施记录：本文中的 V1.4 路径、旧 runner 和当时命令按原证据保留，禁止作为当前执行入口。当前平台为 `${QUANT_PLATFORM_ROOT}`（V2.0），运行必须遵守研究库与平台各自的 `AGENTS.md`。
"""Checkpoint 断点续传测试。"""
from __future__ import annotations

import time

from quant_v2.jq_fetcher.checkpoint import Checkpoint


def test_new_checkpoint_does_not_exist(tmp_path):
    cp = Checkpoint("test_task", tmp_path)
    assert not cp.exists()
    assert cp.path == tmp_path / "test_task.json"


def test_load_returns_empty_structure_when_absent(tmp_path):
    cp = Checkpoint("test_task", tmp_path)
    data = cp.load()
    assert data["completed_items"] == []
    assert data["failed_items"] == {}
    assert data["total_items"] == 0


def test_mark_completed_persists_and_tracks(tmp_path):
    cp = Checkpoint("test_task", tmp_path)
    cp.mark_completed("000001.XSHE")
    cp.mark_completed("000002.XSHE")
    # 重新加载确认写盘
    cp2 = Checkpoint("test_task", tmp_path)
    assert cp2.is_completed("000001.XSHE")
    assert cp2.is_completed("000002.XSHE")
    assert not cp2.is_completed("000003.XSHE")


def test_mark_failed_records_reason(tmp_path):
    cp = Checkpoint("test_task", tmp_path)
    cp.mark_failed("000003.XSHE", "timeout after 3 retries")
    cp2 = Checkpoint("test_task", tmp_path)
    assert cp2.load()["failed_items"]["000003.XSHE"] == "timeout after 3 retries"


def test_mark_completed_then_failed_keeps_both(tmp_path):
    """先完成后失败的项，completed 和 failed 都有记录（不互删）。"""
    cp = Checkpoint("test_task", tmp_path)
    cp.mark_completed("000001.XSHE")
    cp.mark_failed("000001.XSHE", "later write error")
    data = cp.load()
    assert "000001.XSHE" in data["completed_items"]
    assert data["failed_items"]["000001.XSHE"] == "later write error"


def test_summary_reports_progress(tmp_path):
    cp = Checkpoint("test_task", tmp_path)
    cp.set_total(10)
    for i in range(4):
        cp.mark_completed(f"stock_{i}")
    s = cp.summary()
    assert s["completed"] == 4
    assert s["failed"] == 0
    assert s["total"] == 10
    assert s["progress_pct"] == 40.0


def test_reset_deletes_file(tmp_path):
    cp = Checkpoint("test_task", tmp_path)
    cp.mark_completed("000001.XSHE")
    assert cp.exists()
    cp.reset()
    assert not cp.exists()


def test_updated_at_advances(tmp_path):
    cp = Checkpoint("test_task", tmp_path)
    cp.mark_completed("000001.XSHE")
    first = cp.load()["updated_at"]
    time.sleep(1.1)
    cp.mark_completed("000002.XSHE")
    second = cp.load()["updated_at"]
    assert second > first


def test_corrupt_file_treated_as_empty(tmp_path):
    """checkpoint 文件损坏时当空结构处理，不抛异常。"""
    bad_file = tmp_path / "test_task.json"
    bad_file.write_text("{invalid json", encoding="utf-8")
    cp = Checkpoint("test_task", tmp_path)
    data = cp.load()
    assert data["completed_items"] == []
```

- [ ] **Step 2: 运行测试确认失败**

Run: `cd "E:/量化平台_V1.4.0/src" && python -m pytest tests/quant_v2/test_jq_checkpoint.py -v`
Expected: FAIL with `ModuleNotFoundError: No module named 'quant_v2.jq_fetcher.checkpoint'`。

- [ ] **Step 3: 写实现 checkpoint.py**

Create `src/quant_v2/jq_fetcher/checkpoint.py`:

```python
# -*- coding: utf-8 -*-

> 历史实施记录：本文中的 V1.4 路径、旧 runner 和当时命令按原证据保留，禁止作为当前执行入口。当前平台为 `${QUANT_PLATFORM_ROOT}`（V2.0），运行必须遵守研究库与平台各自的 `AGENTS.md`。
"""断点续传 — JSON 落盘，支持中断后重启跳过已完成项。

每个拉取任务一个 checkpoint 文件（tmp/jq_checkpoint/<task_name>.json），
记录已完成和失败的标的。拉取启动时自动加载，跳过已完成项。
"""
from __future__ import annotations

import json
import time
from pathlib import Path

_EMPTY_STRUCTURE: dict = {
    "task_name": "",
    "started_at": "",
    "updated_at": "",
    "total_items": 0,
    "completed_items": [],
    "failed_items": {},
}


class Checkpoint:
    """单任务的断点续传记录器。

    Args:
        task_name: 任务标识，用作文件名（如 "daily_bar_v3"）。
        checkpoint_dir: checkpoint 文件目录。
    """

    def __init__(self, task_name: str, checkpoint_dir: str | Path) -> None:
        self.task_name = task_name
        self._dir = Path(checkpoint_dir)
        self._dir.mkdir(parents=True, exist_ok=True)

    @property
    def path(self) -> Path:
        return self._dir / f"{self.task_name}.json"

    def exists(self) -> bool:
        return self.path.exists()

    def load(self) -> dict:
        """加载 checkpoint。文件不存在或损坏时返回空结构。"""
        if not self.exists():
            data = dict(_EMPTY_STRUCTURE)
            data["task_name"] = self.task_name
            return data
        try:
            data = json.loads(self.path.read_text(encoding="utf-8"))
            # 字段补全（兼容旧格式）
            for key, default in _EMPTY_STRUCTURE.items():
                if key not in data:
                    data[key] = default() if isinstance(default, list) else default
            return data
        except (json.JSONDecodeError, OSError):
            data = dict(_EMPTY_STRUCTURE)
            data["task_name"] = self.task_name
            return data

    def _save(self, data: dict) -> None:
        data["updated_at"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
        if not data.get("started_at"):
            data["started_at"] = data["updated_at"]
        data["task_name"] = self.task_name
        tmp_path = self.path.with_suffix(".json.tmp")
        tmp_path.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
        tmp_path.replace(self.path)  # 原子写

    def set_total(self, total: int) -> None:
        data = self.load()
        data["total_items"] = total
        self._save(data)

    def mark_completed(self, item: str) -> None:
        data = self.load()
        if item not in data["completed_items"]:
            data["completed_items"].append(item)
        # 完成后从 failed 移除（重试成功的场景）
        data["failed_items"].pop(item, None)
        self._save(data)

    def mark_failed(self, item: str, reason: str) -> None:
        data = self.load()
        data["failed_items"][item] = reason
        self._save(data)

    def is_completed(self, item: str) -> bool:
        return item in self.load()["completed_items"]

    def should_skip(self, item: str) -> bool:
        """拉取循环判断是否跳过该项（已完成则跳过）。"""
        return self.is_completed(item)

    def summary(self) -> dict:
        data = self.load()
        completed = len(data["completed_items"])
        failed = len(data["failed_items"])
        total = data["total_items"]
        progress_pct = round(completed / total * 100, 1) if total > 0 else 0.0
        return {
            "total": total,
            "completed": completed,
            "failed": failed,
            "progress_pct": progress_pct,
        }

    def reset(self) -> None:
        """删除 checkpoint 文件，重新开始。"""
        if self.exists():
            self.path.unlink()
```

- [ ] **Step 4: 运行测试确认通过**

Run: `cd "E:/量化平台_V1.4.0/src" && python -m pytest tests/quant_v2/test_jq_checkpoint.py -v`
Expected: 9 passed。

- [ ] **Step 5: 更新 __init__.py 追加导出**

Modify `src/quant_v2/jq_fetcher/__init__.py`，在现有内容后追加：

```python
from quant_v2.jq_fetcher.checkpoint import Checkpoint
```

并把 `Checkpoint` 加入 `__all__` 列表。

完整文件应为：

```python
# -*- coding: utf-8 -*-

> 历史实施记录：本文中的 V1.4 路径、旧 runner 和当时命令按原证据保留，禁止作为当前执行入口。当前平台为 `${QUANT_PLATFORM_ROOT}`（V2.0），运行必须遵守研究库与平台各自的 `AGENTS.md`。
"""jqdatasdk 直连拉取框架。

提供聚宽数据的 API 直连拉取能力：认证、配额监控、断点续传、
重试、并发控制。供数据库重构（阶段 1+）的全量数据拉取共用。
"""
from quant_v2.jq_fetcher.credentials import (
    CredentialNotFoundError,
    JqCredentials,
)
from quant_v2.jq_fetcher.checkpoint import Checkpoint

__all__ = ["CredentialNotFoundError", "JqCredentials", "Checkpoint"]
```

- [ ] **Step 6: 提交**

```bash
cd "E:/量化平台_V1.4.0"
git add src/quant_v2/jq_fetcher/checkpoint.py src/quant_v2/jq_fetcher/__init__.py \
        src/tests/quant_v2/test_jq_checkpoint.py
git commit -m "feat(jq_fetcher): Checkpoint断点续传模块

- JSON落盘记录已完成/失败标的, 中断重启自动跳过
- 原子写(tmp+replace), 文件损坏容错返回空结构
- mark_completed/mark_failed/summary/reset 完整接口"
```

---

## Task 3: QuotaMonitor 配额监控模块

**Files:**
- Create: `src/quant_v2/jq_fetcher/quota.py`
- Create: `src/tests/quant_v2/test_jq_quota.py`
- Modify: `src/quant_v2/jq_fetcher/__init__.py`（追加导出）

**Interfaces:**
- Consumes: 一个 `query_count_fn: Callable[[], dict]`（生产环境传 `jqdatasdk.get_query_count`，返回 `{"spare": int, "total": int}`；测试传 Fake）；构造参数 `warn_threshold: int = 1_000_000`、`check_interval: int = 500`。
- Produces: `QuotaMonitor` 类；方法 `tick() -> None`（每调用一次内部计数 +1，达到 check_interval 才实际查询配额）、`force_check() -> dict`（强制查询，返回 `{"spare": int, "total": int}`）、`is_low() -> bool`（剩余 < warn_threshold）、`status() -> dict`（含 spare/total/queries_since_check）。

- [ ] **Step 1: 写失败测试 test_jq_quota.py**

Create `src/tests/quant_v2/test_jq_quota.py`:

```python
# -*- coding: utf-8 -*-

> 历史实施记录：本文中的 V1.4 路径、旧 runner 和当时命令按原证据保留，禁止作为当前执行入口。当前平台为 `${QUANT_PLATFORM_ROOT}`（V2.0），运行必须遵守研究库与平台各自的 `AGENTS.md`。
"""QuotaMonitor 配额监控测试。"""
from __future__ import annotations

from quant_v2.jq_fetcher.quota import QuotaMonitor


def make_fake_query_count(spare: int, total: int = 200_000_000):
    """返回一个假的 get_query_count，记录调用次数。"""
    calls = []

    def fake():
        calls.append(1)
        return {"spare": spare, "total": total}

    fake.calls = calls
    return fake


def test_tick_under_interval_does_not_query():
    """未达 check_interval 不实际查询配额。"""
    fn = make_fake_query_count(spare=100_000_000)
    mon = QuotaMonitor(query_count_fn=fn, check_interval=500)
    for _ in range(499):
        mon.tick()
    assert len(fn.calls) == 0


def test_tick_at_interval_triggers_query():
    """达到 check_interval 触发一次配额查询。"""
    fn = make_fake_query_count(spare=100_000_000)
    mon = QuotaMonitor(query_count_fn=fn, check_interval=500)
    for _ in range(500):
        mon.tick()
    assert len(fn.calls) == 1


def test_force_check_always_queries():
    fn = make_fake_query_count(spare=50_000_000)
    mon = QuotaMonitor(query_count_fn=fn)
    result = mon.force_check()
    assert result == {"spare": 50_000_000, "total": 200_000_000}
    assert len(fn.calls) == 1


def test_is_low_true_below_threshold():
    fn = make_fake_query_count(spare=500_000)
    mon = QuotaMonitor(query_count_fn=fn, warn_threshold=1_000_000)
    mon.force_check()
    assert mon.is_low() is True


def test_is_low_false_above_threshold():
    fn = make_fake_query_count(spare=50_000_000)
    mon = QuotaMonitor(query_count_fn=fn, warn_threshold=1_000_000)
    mon.force_check()
    assert mon.is_low() is False


def test_status_reports_state():
    fn = make_fake_query_count(spare=80_000_000, total=200_000_000)
    mon = QuotaMonitor(query_count_fn=fn, check_interval=100)
    for _ in range(100):
        mon.tick()
    s = mon.status()
    assert s["spare"] == 80_000_000
    assert s["total"] == 200_000_000
    assert s["queries_since_check"] == 0  # 刚查完归零


def test_queries_since_check_resets_after_interval_query():
    fn = make_fake_query_count(spare=80_000_000)
    mon = QuotaMonitor(query_count_fn=fn, check_interval=100)
    for _ in range(100):
        mon.tick()
    for _ in range(30):
        mon.tick()
    assert mon.status()["queries_since_check"] == 30
```

- [ ] **Step 2: 运行测试确认失败**

Run: `cd "E:/量化平台_V1.4.0/src" && python -m pytest tests/quant_v2/test_jq_quota.py -v`
Expected: FAIL with `ModuleNotFoundError: No module named 'quant_v2.jq_fetcher.quota'`。

- [ ] **Step 3: 写实现 quota.py**

Create `src/quant_v2/jq_fetcher/quota.py`:

```python
# -*- coding: utf-8 -*-

> 历史实施记录：本文中的 V1.4 路径、旧 runner 和当时命令按原证据保留，禁止作为当前执行入口。当前平台为 `${QUANT_PLATFORM_ROOT}`（V2.0），运行必须遵守研究库与平台各自的 `AGENTS.md`。
"""配额监控 — 包装 jqdatasdk.get_query_count，定期查询剩余配额。

jqdatasdk 正式版每日 2 亿次查询额度。本模块避免每次拉取都查询配额
（查询本身也消耗少量开销），改为每 N 次查询一次，低于阈值时告警。
"""
from __future__ import annotations

from typing import Callable

from loguru import logger


class QuotaMonitor:
    """聚宽 API 配额监控器。

    Args:
        query_count_fn: 返回 {"spare": int, "total": int} 的可调用对象，
            生产环境传 jqdatasdk.get_query_count。
        warn_threshold: 剩余配额低于此值时 is_low() 返回 True。
        check_interval: 每多少次 tick 触发一次实际配额查询。
    """

    def __init__(
        self,
        query_count_fn: Callable[[], dict],
        warn_threshold: int = 1_000_000,
        check_interval: int = 500,
    ) -> None:
        self._query_count_fn = query_count_fn
        self._warn_threshold = warn_threshold
        self._check_interval = check_interval
        self._queries_since_check = 0
        self._last_spare: int | None = None
        self._last_total: int | None = None

    def tick(self) -> None:
        """每次 API 查询后调用一次。达到 check_interval 实际查询配额。"""
        self._queries_since_check += 1
        if self._queries_since_check >= self._check_interval:
            self._refresh()

    def force_check(self) -> dict:
        """强制查询配额，返回 {"spare": int, "total": int}。"""
        self._refresh()
        return {"spare": self._last_spare or 0, "total": self._last_total or 0}

    def _refresh(self) -> None:
        try:
            result = self._query_count_fn()
            self._last_spare = result.get("spare", 0)
            self._last_total = result.get("total", 0)
            self._queries_since_check = 0
            if self.is_low():
                logger.warning(
                    "聚宽配额低：剩余 {spare}/{total}，已低于阈值 {threshold}",
                    spare=self._last_spare, total=self._last_total,
                    threshold=self._warn_threshold,
                )
            else:
                logger.info(
                    "聚宽配额：剩余 {spare}/{total}",
                    spare=self._last_spare, total=self._last_total,
                )
        except Exception as e:
            logger.warning("查询聚宽配额失败（不影响拉取）：{err}", err=str(e))

    def is_low(self) -> bool:
        """剩余配额是否低于告警阈值。"""
        if self._last_spare is None:
            return False
        return self._last_spare < self._warn_threshold

    def status(self) -> dict:
        return {
            "spare": self._last_spare,
            "total": self._last_total,
            "queries_since_check": self._queries_since_check,
        }
```

- [ ] **Step 4: 运行测试确认通过**

Run: `cd "E:/量化平台_V1.4.0/src" && python -m pytest tests/quant_v2/test_jq_quota.py -v`
Expected: 7 passed。

- [ ] **Step 5: 更新 __init__.py 追加导出**

Modify `src/quant_v2/jq_fetcher/__init__.py`，追加：

```python
from quant_v2.jq_fetcher.quota import QuotaMonitor
```

`__all__` 加入 `"QuotaMonitor"`。完整文件：

```python
# -*- coding: utf-8 -*-

> 历史实施记录：本文中的 V1.4 路径、旧 runner 和当时命令按原证据保留，禁止作为当前执行入口。当前平台为 `${QUANT_PLATFORM_ROOT}`（V2.0），运行必须遵守研究库与平台各自的 `AGENTS.md`。
"""jqdatasdk 直连拉取框架。

提供聚宽数据的 API 直连拉取能力：认证、配额监控、断点续传、
重试、并发控制。供数据库重构（阶段 1+）的全量数据拉取共用。
"""
from quant_v2.jq_fetcher.credentials import (
    CredentialNotFoundError,
    JqCredentials,
)
from quant_v2.jq_fetcher.checkpoint import Checkpoint
from quant_v2.jq_fetcher.quota import QuotaMonitor

__all__ = [
    "CredentialNotFoundError",
    "JqCredentials",
    "Checkpoint",
    "QuotaMonitor",
]
```

- [ ] **Step 6: 提交**

```bash
cd "E:/量化平台_V1.4.0"
git add src/quant_v2/jq_fetcher/quota.py src/quant_v2/jq_fetcher/__init__.py \
        src/tests/quant_v2/test_jq_quota.py
git commit -m "feat(jq_fetcher): QuotaMonitor配额监控模块

- 包装get_query_count, 每500次查询一次剩余配额
- 低于阈值(默认100万次)告警, 不阻塞拉取
- tick/force_check/is_low/status 完整接口"
```

---

## Task 4: JqFetcher 拉取核心

**Files:**
- Create: `src/quant_v2/jq_fetcher/core.py`
- Create: `src/tests/quant_v2/test_jq_fetcher_core.py`
- Modify: `src/quant_v2/jq_fetcher/__init__.py`（追加导出）

**Interfaces:**
- Consumes: `JqCredentials`（Task 1）、`Checkpoint`（Task 2）、`QuotaMonitor`（Task 3）。
- Produces: `JqFetcher` 类，核心方法 `fetch_panel(security_list, fetch_fn, *, by="security", task_name=None, checkpoint_dir=None, **fetch_kwargs) -> dict`，返回 `{"data": list[pd.DataFrame], "completed": int, "failed": dict, "summary": dict}`。

**关键设计**：
- 构造时接受可注入的 `jq_module`（生产传 jqdatasdk，测试传 Fake），避免全局 import。
- 认证在 `__init__` 完成，调 `jq_module.auth(username, password)`。
- `fetch_panel` 按标的（by="security"）或按日（by="day"）循环；每项调 `fetch_fn(jq_module, item, **fetch_kwargs)` 返回 DataFrame；成功 mark_completed + 累积，失败重试 retry_max 次后 mark_failed。
- 并发用 `ThreadPoolExecutor(max_workers)`。
- 每项完成后调 `quota_monitor.tick()`。
- 进度用 tqdm + 每 100 项打印一次日志。

- [ ] **Step 1: 写失败测试 test_jq_fetcher_core.py**

Create `src/tests/quant_v2/test_jq_fetcher_core.py`:

```python
# -*- coding: utf-8 -*-

> 历史实施记录：本文中的 V1.4 路径、旧 runner 和当时命令按原证据保留，禁止作为当前执行入口。当前平台为 `${QUANT_PLATFORM_ROOT}`（V2.0），运行必须遵守研究库与平台各自的 `AGENTS.md`。
"""JqFetcher 拉取核心测试 — 用 Fake jqdatasdk 注入。"""
from __future__ import annotations

import pandas as pd

from quant_v2.jq_fetcher.core import JqFetcher


class FakeJqModule:
    """模拟 jqdatasdk 模块。"""

    def __init__(self, price_data: dict | None = None):
        self.auth_calls = []
        self.query_count_calls = 0
        self.price_data = price_data or {}
        self.auth_should_fail = False

    def auth(self, username, password):
        self.auth_calls.append((username, password))
        if self.auth_should_fail:
            raise RuntimeError("模拟认证失败")

    def get_query_count(self):
        self.query_count_calls += 1
        return {"spare": 199_000_000, "total": 200_000_000}

    def get_price(self, security, **kwargs):
        if security not in self.price_data:
            return pd.DataFrame()
        return self.price_data[security]


def make_fetcher(fake_jq, monkeypatch):
    """用 Fake jq 模块构造 JqFetcher（绕过真实认证）。"""
    monkeypatch.setenv("JQ_USERNAME", "test_user")
    monkeypatch.setenv("JQ_PASSWORD", "test_pass")
    return JqFetcher(jq_module=fake_jq)


def test_auth_called_on_init(monkeypatch):
    fake = FakeJqModule()
    fetcher = make_fetcher(fake, monkeypatch)
    assert len(fake.auth_calls) == 1
    assert fake.auth_calls[0] == ("test_user", "test_pass")


def test_fetch_panel_by_security_collects_data(monkeypatch, tmp_path):
    fake = FakeJqModule(price_data={
        "000001.XSHE": pd.DataFrame({"close": [1.0, 2.0]}),
        "000002.XSHE": pd.DataFrame({"close": [3.0, 4.0]}),
    })
    fetcher = make_fetcher(fake, monkeypatch)

    def fetch_fn(jq, security):
        return jq.get_price(security, frequency="daily")

    result = fetcher.fetch_panel(
        ["000001.XSHE", "000002.XSHE"],
        fetch_fn,
        by="security",
        task_name="test_daily",
        checkpoint_dir=tmp_path,
    )
    assert result["completed"] == 2
    assert result["failed"] == {}
    assert len(result["data"]) == 2


def test_fetch_panel_skips_completed_via_checkpoint(monkeypatch, tmp_path):
    """checkpoint 已完成的项跳过，不重复拉取。"""
    fake = FakeJqModule(price_data={
        "000001.XSHE": pd.DataFrame({"close": [1.0]}),
        "000002.XSHE": pd.DataFrame({"close": [2.0]}),
    })
    fetcher = make_fetcher(fake, monkeypatch)

    def fetch_fn(jq, security):
        return jq.get_price(security)

    # 第一次拉取
    fetcher.fetch_panel(
        ["000001.XSHE", "000002.XSHE"], fetch_fn,
        task_name="test_skip", checkpoint_dir=tmp_path,
    )
    # 清空价格数据，第二次拉取若不跳过会返回空 DataFrame
    fake.price_data = {}

    # 用新 fetcher 但同一 checkpoint 目录
    fetcher2 = make_fetcher(FakeJqModule(), monkeypatch)
    result = fetcher2.fetch_panel(
        ["000001.XSHE", "000002.XSHE"], fetch_fn,
        task_name="test_skip", checkpoint_dir=tmp_path,
    )
    # 两项都跳过（completed 计入但 data 为空，因为跳过的不重新拉）
    assert result["completed"] == 2
    assert result["skipped"] == 2


def test_fetch_panel_retries_on_error(monkeypatch, tmp_path):
    """fetch_fn 抛错时重试，超限后记 failed。"""
    fake = FakeJqModule()
    fetcher = make_fetcher(fake, monkeypatch)
    call_count = {"n": 0}

    def flaky_fetch_fn(jq, security):
        call_count["n"] += 1
        if call_count["n"] < 3:  # 前 2 次失败，第 3 次成功
            raise ConnectionError("模拟网络错误")
        return pd.DataFrame({"close": [1.0]})

    result = fetcher.fetch_panel(
        ["000001.XSHE"], flaky_fetch_fn,
        task_name="test_retry", checkpoint_dir=tmp_path,
        retry_max=3, retry_backoff=0.01,  # 测试用短退避
    )
    assert result["completed"] == 1
    assert result["failed"] == {}
    assert call_count["n"] == 3


def test_fetch_panel_records_failed_after_max_retries(monkeypatch, tmp_path):
    fake = FakeJqModule()
    fetcher = make_fetcher(fake, monkeypatch)

    def always_fail(jq, security):
        raise RuntimeError("永久失败")

    result = fetcher.fetch_panel(
        ["000003.XSHE"], always_fail,
        task_name="test_fail", checkpoint_dir=tmp_path,
        retry_max=2, retry_backoff=0.01,
    )
    assert result["completed"] == 0
    assert "000003.XSHE" in result["failed"]
    assert "永久失败" in result["failed"]["000003.XSHE"]


def test_fetch_panel_summary_reports_progress(monkeypatch, tmp_path):
    fake = FakeJqModule(price_data={
        f"stock_{i}.XSHE": pd.DataFrame({"close": [1.0]}) for i in range(5)
    })
    fetcher = make_fetcher(fake, monkeypatch)

    def fetch_fn(jq, security):
        return jq.get_price(security)

    result = fetcher.fetch_panel(
        [f"stock_{i}.XSHE" for i in range(5)], fetch_fn,
        task_name="test_summary", checkpoint_dir=tmp_path,
    )
    assert result["summary"]["completed"] == 5
    assert result["summary"]["progress_pct"] == 100.0


def test_fetch_panel_by_day_iterates_dates(monkeypatch, tmp_path):
    """by="day" 模式按交易日循环（事件类数据如龙虎榜）。"""
    fake = FakeJqModule()
    fetcher = make_fetcher(fake, monkeypatch)
    called_days = []

    def fetch_fn(jq, day):
        called_days.append(day)
        return pd.DataFrame({"code": ["000001.XSHE"]})

    result = fetcher.fetch_panel(
        ["2024-01-02", "2024-01-03", "2024-01-04"], fetch_fn,
        by="day", task_name="test_byday", checkpoint_dir=tmp_path,
    )
    assert result["completed"] == 3
    assert len(called_days) == 3
```

- [ ] **Step 2: 运行测试确认失败**

Run: `cd "E:/量化平台_V1.4.0/src" && python -m pytest tests/quant_v2/test_jq_fetcher_core.py -v`
Expected: FAIL with `ModuleNotFoundError: No module named 'quant_v2.jq_fetcher.core'`。

- [ ] **Step 3: 写实现 core.py**

Create `src/quant_v2/jq_fetcher/core.py`:

```python
# -*- coding: utf-8 -*-

> 历史实施记录：本文中的 V1.4 路径、旧 runner 和当时命令按原证据保留，禁止作为当前执行入口。当前平台为 `${QUANT_PLATFORM_ROOT}`（V2.0），运行必须遵守研究库与平台各自的 `AGENTS.md`。
"""JqFetcher — jqdatasdk 直连拉取核心。

封装认证、配额监控、断点续传、重试、并发、进度，供所有数据拉取
任务共用。核心方法 fetch_panel 按标的或按日循环，每项调用户传入的
fetch_fn 获取数据。
"""
from __future__ import annotations

import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path
from typing import Any, Callable

import pandas as pd
from loguru import logger
from tqdm import tqdm

from quant_v2.jq_fetcher.credentials import JqCredentials
from quant_v2.jq_fetcher.checkpoint import Checkpoint
from quant_v2.jq_fetcher.quota import QuotaMonitor

# 默认 checkpoint 目录

> 历史实施记录：本文中的 V1.4 路径、旧 runner 和当时命令按原证据保留，禁止作为当前执行入口。当前平台为 `${QUANT_PLATFORM_ROOT}`（V2.0），运行必须遵守研究库与平台各自的 `AGENTS.md`。
DEFAULT_CHECKPOINT_DIR = Path(__file__).resolve().parent.parent.parent.parent / "tmp" / "jq_checkpoint"


class JqFetcher:
    """jqdatasdk 直连拉取器。

    Args:
        credentials: 聚宽凭证，默认 JqCredentials.from_env()。
        jq_module: jqdatasdk 模块对象（可注入测试），默认运行时 import。
        max_workers: 并发线程数（jqdatasdk 有速率限制，保守用 4）。
        retry_max: 单项最大重试次数。
        retry_backoff: 指数退避基数（秒）。
        quota_warn_threshold: 配额告警阈值。
        quota_check_interval: 配额查询间隔（每 N 次查询一次）。
    """

    def __init__(
        self,
        credentials: JqCredentials | None = None,
        jq_module: Any | None = None,
        max_workers: int = 4,
        retry_max: int = 3,
        retry_backoff: float = 2.0,
        quota_warn_threshold: int = 1_000_000,
        quota_check_interval: int = 500,
    ) -> None:
        self._credentials = credentials or JqCredentials.from_env()
        # 默认 import jqdatasdk（延迟到构造，便于测试注入）
        if jq_module is None:
            import jqdatasdk as _jq
            jq_module = _jq
        self._jq = jq_module
        self._max_workers = max_workers
        self._retry_max = retry_max
        self._retry_backoff = retry_backoff

        # 认证
        username, password = self._credentials.resolve()
        self._jq.auth(username, password)
        logger.info("聚宽认证成功（用户：{}）", _mask_username(username))

        # 配额监控
        self._quota = QuotaMonitor(
            query_count_fn=self._jq.get_query_count,
            warn_threshold=quota_warn_threshold,
            check_interval=quota_check_interval,
        )

    def fetch_panel(
        self,
        items: list,
        fetch_fn: Callable[..., pd.DataFrame],
        *,
        by: str = "security",
        task_name: str | None = None,
        checkpoint_dir: str | Path | None = None,
        retry_max: int | None = None,
        retry_backoff: float | None = None,
        **fetch_kwargs: Any,
    ) -> dict:
        """通用拉取循环。

        Args:
            items: 待拉取项列表（by="security" 时是标的代码列表，
                by="day" 时是日期字符串列表）。
            fetch_fn: 拉取函数，签名 fetch_fn(jq_module, item, **fetch_kwargs) -> DataFrame。
            by: 循环维度，"security" 按标的 或 "day" 按日。
            task_name: checkpoint 任务名，默认用 fetch_fn 名。
            checkpoint_dir: checkpoint 目录。
            retry_max/retry_backoff: 覆盖构造默认值。
            **fetch_kwargs: 透传给 fetch_fn 的额外参数。

        Returns:
            {"data": list[DataFrame], "completed": int, "failed": dict,
             "skipped": int, "summary": dict}
        """
        if by not in ("security", "day"):
            raise ValueError(f"by 必须是 'security' 或 'day'，得到：{by}")

        cp = Checkpoint(
            task_name or getattr(fetch_fn, "__name__", "jq_fetch"),
            checkpoint_dir or DEFAULT_CHECKPOINT_DIR,
        )
        cp.set_total(len(items))

        retry_max = retry_max if retry_max is not None else self._retry_max
        retry_backoff = retry_backoff if retry_backoff is not None else self._retry_backoff

        results: list[pd.DataFrame] = []
        failed: dict[str, str] = {}
        completed = 0
        skipped = 0

        # 过滤已完成的项
        pending = []
        for item in items:
            if cp.should_skip(item):
                skipped += 1
            else:
                pending.append(item)

        if skipped:
            logger.info("checkpoint 命中，跳过 {n} 项", n=skipped)

        # 并发拉取
        with ThreadPoolExecutor(max_workers=self._max_workers) as pool:
            futures = {
                pool.submit(
                    self._fetch_one, fetch_fn, item, retry_max, retry_backoff, **fetch_kwargs
                ): item
                for item in pending
            }
            for future in tqdm(
                as_completed(futures), total=len(pending),
                desc=cp.task_name, unit="项",
            ):
                item = futures[future]
                try:
                    df, err = future.result()
                except Exception as e:
                    df, err = None, f"unexpected: {e}"

                if err is None and df is not None:
                    results.append(df)
                    cp.mark_completed(item)
                    completed += 1
                else:
                    cp.mark_failed(item, err or "unknown error")
                    failed[item] = err or "unknown error"
                    logger.warning("拉取失败 {item}: {err}", item=item, err=err)

                self._quota.tick()
                # 每 100 项打印进度
                done = completed + skipped + len(failed)
                if done % 100 == 0:
                    logger.info(
                        "进度 {done}/{total}（完成 {ok}，跳过 {skip}，失败 {fail}）",
                        done=done, total=len(items), ok=completed,
                        skip=skipped, fail=len(failed),
                    )

        return {
            "data": results,
            "completed": completed + skipped,
            "failed": failed,
            "skipped": skipped,
            "summary": cp.summary(),
        }

    def _fetch_one(
        self,
        fetch_fn: Callable[..., pd.DataFrame],
        item: str,
        retry_max: int,
        retry_backoff: float,
        **fetch_kwargs: Any,
    ) -> tuple[pd.DataFrame | None, str | None]:
        """拉取单项，带重试。返回 (df, error)。"""
        last_err: str | None = None
        for attempt in range(1, retry_max + 1):
            try:
                df = fetch_fn(self._jq, item, **fetch_kwargs)
                return df, None
            except Exception as e:
                last_err = f"{type(e).__name__}: {e}"
                if attempt < retry_max:
                    wait = retry_backoff ** (attempt - 1)
                    logger.debug(
                        "重试 {item} 第 {n}/{max} 次（等待 {w:.1f}s）：{err}",
                        item=item, n=attempt, max=retry_max, w=wait, err=last_err,
                    )
                    time.sleep(wait)
        return None, last_err

    def quota_status(self) -> dict:
        """返回当前配额状态。"""
        return self._quota.status()


def _mask_username(username: str) -> str:
    """用户名脱敏（保留前 3 后 4 位）。"""
    if len(username) <= 7:
        return username[:3] + "***"
    return username[:3] + "***" + username[-4:]
```

- [ ] **Step 4: 运行测试确认通过**

Run: `cd "E:/量化平台_V1.4.0/src" && python -m pytest tests/quant_v2/test_jq_fetcher_core.py -v`
Expected: 7 passed。

- [ ] **Step 5: 更新 __init__.py 追加导出**

Modify `src/quant_v2/jq_fetcher/__init__.py`，追加：

```python
from quant_v2.jq_fetcher.core import JqFetcher
```

`__all__` 加入 `"JqFetcher"`。完整文件：

```python
# -*- coding: utf-8 -*-

> 历史实施记录：本文中的 V1.4 路径、旧 runner 和当时命令按原证据保留，禁止作为当前执行入口。当前平台为 `${QUANT_PLATFORM_ROOT}`（V2.0），运行必须遵守研究库与平台各自的 `AGENTS.md`。
"""jqdatasdk 直连拉取框架。

提供聚宽数据的 API 直连拉取能力：认证、配额监控、断点续传、
重试、并发控制。供数据库重构（阶段 1+）的全量数据拉取共用。
"""
from quant_v2.jq_fetcher.credentials import (
    CredentialNotFoundError,
    JqCredentials,
)
from quant_v2.jq_fetcher.checkpoint import Checkpoint
from quant_v2.jq_fetcher.quota import QuotaMonitor
from quant_v2.jq_fetcher.core import JqFetcher

__all__ = [
    "CredentialNotFoundError",
    "JqCredentials",
    "Checkpoint",
    "QuotaMonitor",
    "JqFetcher",
]
```

- [ ] **Step 6: 提交**

```bash
cd "E:/量化平台_V1.4.0"
git add src/quant_v2/jq_fetcher/core.py src/quant_v2/jq_fetcher/__init__.py \
        src/tests/quant_v2/test_jq_fetcher_core.py
git commit -m "feat(jq_fetcher): JqFetcher拉取核心

- fetch_panel按标的/按日循环, ThreadPoolExecutor并发
- 重试(指数退避)+断点续传+配额监控+进度集成
- jq_module可注入(测试用Fake), 认证脱敏日志"
```

---

## Task 5: 速率实测脚本 + 阶段 0 集成验收

**Files:**
- Create: `scripts/jq_speed_benchmark.py`

**目标**：用真实聚宽凭证拉取 50 只标的 × 11 年日线 + 50 只标的 × 1 个月分钟线，实测速率并产出报告。这是阶段 0 的硬门槛（规格 §2.7）。

**注意**：此 Task 涉及真实凭证和真实 API 调用，**不写自动化测试**（属于集成验收，由执行者手动运行并核对结果）。脚本本身写完后做 `py_compile` 检查即可。

- [ ] **Step 1: 写速率实测脚本**

Create `scripts/jq_speed_benchmark.py`:

```python
# -*- coding: utf-8 -*-

> 历史实施记录：本文中的 V1.4 路径、旧 runner 和当时命令按原证据保留，禁止作为当前执行入口。当前平台为 `${QUANT_PLATFORM_ROOT}`（V2.0），运行必须遵守研究库与平台各自的 `AGENTS.md`。
"""jqdatasdk 速率实测脚本 — 阶段 0 硬门槛。

实测单次日线/分钟线查询延迟、并发加速比、速率限制阈值，
据此估算全量分钟线工期。结果打印到控制台并写入
tmp/jq_speed_benchmark_report.txt。

运行方式（Windows venv，已设环境变量 JQ_USERNAME/JQ_PASSWORD）：
    cd E:/量化平台_V1.4.0
    .venv/Scripts/python.exe scripts/jq_speed_benchmark.py
"""
from __future__ import annotations

import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

import pandas as pd

from quant_v2.jq_fetcher import JqFetcher

# 实测样本

> 历史实施记录：本文中的 V1.4 路径、旧 runner 和当时命令按原证据保留，禁止作为当前执行入口。当前平台为 `${QUANT_PLATFORM_ROOT}`（V2.0），运行必须遵守研究库与平台各自的 `AGENTS.md`。
SAMPLE_SECURITIES = [
    "000001.XSHE", "000002.XSHE", "000063.XSHE", "000333.XSHE", "000651.XSHE",
    "000858.XSHE", "002007.XSHE", "002027.XSHE", "002230.XSHE", "002415.XSHE",
    "002594.XSHE", "300015.XSHE", "300059.XSHE", "300750.XSHE", "600000.XSHG",
    "600009.XSHG", "600016.XSHG", "600028.XSHG", "600030.XSHG", "600036.XSHG",
    "600276.XSHG", "600309.XSHG", "600519.XSHG", "600585.XSHG", "600690.XSHG",
    "600886.XSHG", "601012.XSHG", "601066.XSHG", "601138.XSHG", "601166.XSHG",
    "601288.XSHG", "601318.XSHG", "601398.XSHG", "601628.XSHG", "601668.XSHG",
    "601688.XSHG", "601728.XSHG", "601857.XSHG", "601888.XSHG", "601939.XSHG",
    "510300.XSHG", "510500.XSHG", "159915.XSHE", "588000.XSHG", "512000.XSHG",
    "512880.XSHG", "515880.XSHG", "518880.XSHG", "159985.XSHE", "513100.XSHG",
]
SAMPLE_COUNT = len(SAMPLE_SECURITIES)  # 50
DAILY_START = "2014-01-01"
DAILY_END = "2025-12-31"
MINUTE_MONTH = "2025-11"  # 单月分钟线
MINUTE_START = "2025-11-01"
MINUTE_END = "2025-11-30"

REPORT_PATH = Path(__file__).resolve().parent.parent / "tmp" / "jq_speed_benchmark_report.txt"

# 全量估算参数

> 历史实施记录：本文中的 V1.4 路径、旧 runner 和当时命令按原证据保留，禁止作为当前执行入口。当前平台为 `${QUANT_PLATFORM_ROOT}`（V2.0），运行必须遵守研究库与平台各自的 `AGENTS.md`。
TOTAL_SECURITIES = 10000  # 全市场标的数
TOTAL_MONTHS = 132        # 11 年 × 12 月（分钟线工期大头）


def _fmt(seconds: float) -> str:
    if seconds < 60:
        return f"{seconds:.2f}s"
    m, s = divmod(seconds, 60)
    if m < 60:
        return f"{int(m)}m{s:.0f}s"
    h, m = divmod(m, 60)
    return f"{int(h)}h{int(m)}m"


def fetch_daily(jq, security):
    return jq.get_price(
        security, start_date=DAILY_START, end_date=DAILY_END,
        frequency="daily", fields=["open", "close", "high", "low", "volume", "money", "factor"],
        fq="pre", panel=False,
    )


def fetch_minute_month(jq, security):
    return jq.get_price(
        security, start_date=MINUTE_START, end_date=MINUTE_END,
        frequency="minute", fields=["open", "close", "high", "low", "volume", "money"],
        fq="pre", panel=False,
    )


def measure_serial(fetcher, fetch_fn, label):
    """串行拉取，测平均延迟。"""
    print(f"\n=== {label}：串行拉取 {SAMPLE_COUNT} 只 ===")
    jq = fetcher._jq
    start = time.time()
    latencies = []
    rows_total = 0
    for sec in SAMPLE_SECURITIES:
        t0 = time.time()
        df = fetch_fn(jq, sec)
        latencies.append(time.time() - t0)
        if isinstance(df, pd.DataFrame):
            rows_total += len(df)
    total = time.time() - start
    avg = sum(latencies) / len(latencies) if latencies else 0
    print(f"  总耗时：{_fmt(total)}，平均延迟：{avg:.3f}s/次，总行数：{rows_total}")
    return {"total": total, "avg_latency": avg, "rows": rows_total}


def measure_parallel(fetcher, fetch_fn, label, max_workers=4):
    """并发拉取，测加速比。"""
    print(f"\n=== {label}：并发 {max_workers} 线程拉取 {SAMPLE_COUNT} 只 ===")
    jq = fetcher._jq
    start = time.time()
    with ThreadPoolExecutor(max_workers=max_workers) as pool:
        futures = {pool.submit(fetch_fn, jq, sec): sec for sec in SAMPLE_SECURITIES}
        for f in as_completed(futures):
            try:
                f.result()
            except Exception as e:
                print(f"  警告：{futures[f]} 拉取失败：{e}")
    total = time.time() - start
    print(f"  总耗时：{_fmt(total)}")
    return total


def main():
    print("=" * 60)
    print("jqdatasdk 速率实测（阶段 0 硬门槛）")
    print("=" * 60)

    fetcher = JqFetcher(max_workers=4)
    quota = fetcher.quota_status()
    print(f"当前配额：spare={quota.get('spare')}, total={quota.get('total')}")

    report_lines = ["jqdatasdk 速率实测报告", "=" * 60, ""]

    # 1. 日线串行
    daily_serial = measure_serial(fetcher, fetch_daily, "日线 11 年")
    report_lines.append(
        f"日线串行：总 {_fmt(daily_serial['total'])}，"
        f"平均 {daily_serial['avg_latency']:.3f}s/次，{daily_serial['rows']} 行"
    )

    # 2. 日线并发
    daily_par = measure_parallel(fetcher, fetch_daily, "日线 11 年", max_workers=4)
    speedup = daily_serial["total"] / daily_par if daily_par > 0 else 0
    report_lines.append(f"日线并发4：{_fmt(daily_par)}，加速比 {speedup:.2f}x")

    # 3. 分钟线串行（单月）
    minute_serial = measure_serial(fetcher, fetch_minute_month, f"分钟线 {MINUTE_MONTH}")
    report_lines.append(
        f"分钟线串行（单月）：总 {_fmt(minute_serial['total'])}，"
        f"平均 {minute_serial['avg_latency']:.3f}s/次，{minute_serial['rows']} 行"
    )

    # 4. 分钟线并发
    minute_par = measure_parallel(fetcher, fetch_minute_month, f"分钟线 {MINUTE_MONTH}", max_workers=4)
    minute_speedup = minute_serial["total"] / minute_par if minute_par > 0 else 0
    report_lines.append(f"分钟线并发4：{_fmt(minute_par)}，加速比 {minute_speedup:.2f}x")

    # 5. 全量工期估算
    print("\n=== 全量工期估算 ===")
    # 分钟线：按并发实测的每只耗时 × 全市场 × 132 月
    per_security_parallel = minute_par / SAMPLE_COUNT
    full_minute_est = per_security_parallel * TOTAL_SECURITIES * TOTAL_MONTHS
    report_lines.append("")
    report_lines.append("全量工期估算（分钟线，工期大头）：")
    report_lines.append(f"  并发4每只单月耗时：{per_security_parallel:.3f}s")
    report_lines.append(
        f"  全量（{TOTAL_SECURITIES}标的 × {TOTAL_MONTHS}月）：{_fmt(full_minute_est)}"
    )
    report_lines.append(
        f"  折合天数：{full_minute_est / 86400:.1f} 天"
    )
    report_lines.append("")
    report_lines.append("门槛判定：")
    if full_minute_est / 86400 <= 7:
        report_lines.append("  ✅ 全量分钟线 ≤ 7 天，纯 API 方案可行")
    else:
        report_lines.append("  ⚠️ 全量分钟线 > 7 天，需评估是否调整（用户已选纯 API）")

    # 写报告
    REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
    report_text = "\n".join(report_lines)
    REPORT_PATH.write_text(report_text, encoding="utf-8")
    print(f"\n报告已写入：{REPORT_PATH}")
    print("\n" + report_text)


if __name__ == "__main__":
    main()
```

- [ ] **Step 2: py_compile 检查脚本语法**

Run: `cd "E:/量化平台_V1.4.0" && .venv/Scripts/python.exe -m py_compile scripts/jq_speed_benchmark.py`
Expected: 无输出（语法正确）。

- [ ] **Step 3: 设置凭证环境变量并运行速率实测**

**注意**：执行此步骤前，执行者必须确保聚宽凭证已通过环境变量设置（`JQ_USERNAME` / `JQ_PASSWORD`）或凭证文件存在。凭证值由用户提供，**绝不写入脚本或提交到 git**。

在 Git Bash 中设置环境变量（凭证值替换为用户提供的真实值）：

```bash
export JQ_USERNAME="18514293731"
export JQ_PASSWORD='645123Zz,'   # 注意单引号，保护逗号
cd "E:/量化平台_V1.4.0"
.venv/Scripts/python.exe scripts/jq_speed_benchmark.py
```

Expected：
- 脚本打印认证成功（用户名脱敏 `185***3731`）
- 打印当前配额（spare 接近 200000000）
- 打印日线串行/并发耗时、分钟线串行/并发耗时、全量工期估算
- 报告写入 `tmp/jq_speed_benchmark_report.txt`

**核对**：记录全量分钟线工期估算天数。若 ≤ 7 天，纯 API 方案确认可行；若 > 7 天，在执行记录中标记风险并报告主控（用户已选纯 API，故为风险记录而非方案变更）。

- [ ] **Step 4: 运行全部 jq_fetcher 测试确认无回归**

Run: `cd "E:/量化平台_V1.4.0/src" && python -m pytest tests/quant_v2/test_jq_credentials.py tests/quant_v2/test_jq_checkpoint.py tests/quant_v2/test_jq_quota.py tests/quant_v2/test_jq_fetcher_core.py -v`
Expected: 全部 passed（7 + 9 + 7 + 7 = 30 passed）。

- [ ] **Step 5: 提交**

```bash
cd "E:/量化平台_V1.4.0"
git add scripts/jq_speed_benchmark.py
git commit -m "feat(jq_fetcher): 速率实测脚本(阶段0硬门槛)

- 50标的×11年日线 + 50标的×单月分钟线实测
- 测串行延迟/并发加速比, 估算全量分钟线工期
- 报告写入tmp/jq_speed_benchmark_report.txt"
```

- [ ] **Step 6: 阶段 0 收尾 — 研究库资产登记**

阶段 0 完成后，在研究库创建资产（遵循 AGENTS.md 命名规范，用 New-ResearchItem.ps1 生成 ID）：

```bash
cd "E:/【笔记库】/量化研究库_V2.0.0"
powershell -ExecutionPolicy Bypass -File tools/New-ResearchItem.ps1 -Type Direction -Title "聚宽数据库全面重构"
```

得到 RD-JQDB 实际 ID 后，再创建实验记录：

```bash
powershell -ExecutionPolicy Bypass -File tools/New-ResearchItem.ps1 -Type Experiment -Title "阶段0基础设施验证" -ParentId "<RD-JQDB实际ID>"
```

在 EX-JQDB-S0 实验记录中填写（遵循每轮实验硬规则）：
- 研究方向 ID：RD-JQDB
- 本次假设：jqdatasdk 直连框架能在 Windows venv 下稳定拉取聚宽数据，配额充足
- 实验前预测：单次日线延迟 < 2s，并发 4 线程加速比 ≥ 3x
- 基准对照：现有离线导出管线（jq_export.py）
- 证伪条件：认证失败 / 配额不足 / 速率实测工期 > 14 天
- 实际观察：填入速率实测报告数值
- 支持证据：tmp/jq_speed_benchmark_report.txt、30 passed 测试
- 新手短总结：用中文解释 jq_fetcher 做了什么、为什么需要它
- 下一步：阶段 1 核心 13 表口径切换

更新台账（UTF-8 无 BOM）：
- `01_台账/实验记录台账.csv` 追加 EX-JQDB-S0 行
- `01_台账/子代理调用台账.csv` 记录本计划的子代理调用

资产变更后重建入口：
```bash
cd "E:/【笔记库】/量化研究库_V2.0.0"
powershell -ExecutionPolicy Bypass -File tools/Build-ResearchBoard.ps1
powershell -ExecutionPolicy Bypass -File tools/Build-ResearchGraph.ps1
```

- [ ] **Step 7: 最终提交（研究库）**

```bash
cd "E:/【笔记库】/量化研究库_V2.0.0"
git add 02_研究方向/ 04_实验记录/ 01_台账/ 00_入口/
git commit -m "feat(JQDB-S0): 聚宽数据库重构方向创建+阶段0实验记录

- RD-JQDB 方向文档
- EX-JQDB-S0 阶段0基础设施验证(速率实测报告)
- 台账同步+入口资产重建"
```

---

## 阶段 0 完成标准

全部 Task 1-5 完成且满足：
1. jqdatasdk 安装成功，`auth()` 通过真实凭证认证
2. 30 个单元测试全部 passed（7+9+7+7）
3. `jq_fetcher` 包 4 个模块（credentials/checkpoint/quota/core）可正常 import
4. 速率实测报告产出，全量分钟线工期已量化
5. 凭证不入库（`.gitignore` 覆盖，`git status` 无凭证文件）
6. 研究库 RD-JQDB 方向 + EX-JQDB-S0 实验记录创建
