# 聚宽数据库重构 · 阶段 0：jq_fetcher 直连框架 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 构建一个可复用的聚宽数据拉取底座（jq_fetcher 模块），供阶段 1 的 13 表全量拉取和阶段 2-4 的全新数据接入共用，包含认证、配额、速率、断点续传、错误重试、checkpoint、日志八项能力，并以速率实测报告作为阶段 0 验收交付物。

**Architecture:** 在平台仓库 `E:\量化平台_V1.4.0` 的 `src/quant_v2/jq_fetcher/` 新建子包，遵循现有 `quant_v2` 包结构（`__init__.py` re-export、`from __future__ import annotations`、PEP 604 联合类型）。对 jqdatasdk 的依赖通过构造函数注入 `api_client` 参数实现可测试性——测试注入 FakeApiClient，生产用动态 `import jqdatasdk`。所有真实 jqdatasdk 调用隔离在 `core.py` 内，纯逻辑组件（credentials/checkpoint/quota）完全不依赖 jqdatasdk，可离线完整测试。

**Tech Stack:** Python 3.10+（实际 3.14.4）、pytest、jqdatasdk、pandas、tqdm、loguru、pathlib、dataclasses、concurrent.futures.ThreadPoolExecutor

**执行位置：** 平台仓库 `E:\量化平台_V1.4.0`。开始前建议开分支 `feat/jq-database-overhaul`。所有 `git` 命令在该仓库根执行。测试命令在 `src/` 目录下执行（`cd src && python -m pytest`）。

**规格来源：** `docs/superpowers/specs/2026-07-08-jq-database-overhaul-design.md` §2（阶段 0）。

## Global Constraints

（从规格 §1.1、§2 复制，所有任务隐式遵循）

- 凭证值绝不打印到日志；异常信息脱敏，只报"凭证缺失"或"认证失败"，不回显密码。
- jqdatasdk 仅加入 `src/requirements.txt`（Windows 数据生产侧），不进 `src/requirements-wsl-backtest.txt`（WSL 回测进程只读 ClickHouse）。
- 新增文本文件优先 UTF-8 无 BOM。
- 遵循平台现有测试风格：pytest 纯函数式，手写 Fake 类注入（不用 unittest.mock），裸 assert，`cd src && python -m pytest`。
- 文档字符串用简短中文。
- 提交说明用中文，遵循平台现有 commit 风格（`feat: ...` / `fix: ...`）。

## 文件结构

| 文件 | 职责 | 任务 |
| --- | --- | --- |
| `src/quant_v2/jq_fetcher/__init__.py` | 包入口，re-export 公开 API | Task 1, 4 |
| `src/quant_v2/jq_fetcher/credentials.py` | 凭证管理（三级优先级读取） | Task 1 |
| `src/tests/quant_v2/jq_fetcher/__init__.py` | 测试包标记（空） | Task 1 |
| `src/tests/quant_v2/jq_fetcher/test_credentials.py` | 凭证管理测试 | Task 1 |
| `src/quant_v2/jq_fetcher/checkpoint.py` | 断点续传 JSON 存储 | Task 2 |
| `src/tests/quant_v2/jq_fetcher/test_checkpoint.py` | 断点续传测试 | Task 2 |
| `src/quant_v2/jq_fetcher/quota.py` | 配额监控 | Task 3 |
| `src/tests/quant_v2/jq_fetcher/test_quota.py` | 配额监控测试 | Task 3 |
| `src/quant_v2/jq_fetcher/core.py` | JqFetcher 拉取核心（整合认证/重试/速率/断点/配额） | Task 4 |
| `src/tests/quant_v2/jq_fetcher/test_fetcher.py` | JqFetcher 测试 | Task 4 |
| `scripts/jq_fetcher/jq_speed_benchmark.py` | 速率实测脚本（阶段 0 验收） | Task 5 |
| `.gitignore`（平台根，修改） | 追加凭证文件名闭合缺口 | Task 1 |
| `src/requirements.txt`（修改） | 追加 jqdatasdk 依赖 | Task 1 |
| `src/pyproject.toml`（修改） | dependencies 数组同步追加 jqdatasdk | Task 1 |

---

## Task 1: 依赖接入与凭证管理

构建 jq_fetcher 包骨架、添加 jqdatasdk 依赖、实现凭证管理（JqCredentials）、补 `.gitignore` 凭证缺口。交付物：可从环境变量/文件加载聚宽凭证，凭证不入库。

**Files:**
- Create: `E:\量化平台_V1.4.0\src\quant_v2\jq_fetcher\__init__.py`
- Create: `E:\量化平台_V1.4.0\src\quant_v2\jq_fetcher\credentials.py`
- Create: `E:\量化平台_V1.4.0\src\tests\quant_v2\jq_fetcher\__init__.py`
- Create: `E:\量化平台_V1.4.0\src\tests\quant_v2\jq_fetcher\test_credentials.py`
- Modify: `E:\量化平台_V1.4.0\src\requirements.txt`
- Modify: `E:\量化平台_V1.4.0\src\pyproject.toml`
- Modify: `E:\量化平台_V1.4.0\.gitignore`

**Interfaces:**
- Produces: `JqCredentials` 类（`credentials.py`），签名：
  - `JqCredentials(username: str, password: str)` —— 构造
  - `JqCredentials.load(username: str | None = None, password: str | None = None, credentials_file: str | Path | None = None) -> JqCredentials` —— 三级优先级加载
  - `JqCredentials.is_loaded() -> bool` —— 是否已加载（供 JqFetcher Task 4 消费）
- Produces: `CredentialNotFoundError`（`credentials.py`），`Exception` 子类
- 供 Task 4 消费：`JqCredentials.load()` 的返回值

- [ ] **Step 1: 开平台分支**

```bash
cd "E:/量化平台_V1.4.0"
git checkout -b feat/jq-database-overhaul
```

- [ ] **Step 2: 添加 jqdatasdk 依赖到 requirements.txt**

在 `src/requirements.txt` 末尾（`requests>=2.28.0` 之后）追加一行：

```
jqdatasdk>=1.9.0
```

- [ ] **Step 3: 同步 pyproject.toml**

读 `src/pyproject.toml`，在 `[project] dependencies` 数组里追加 `"jqdatasdk>=1.9.0"`（与 requirements.txt 一致）。

- [ ] **Step 4: 补 .gitignore 凭证缺口**

在平台根 `.gitignore` 末尾追加：

```gitignore

# 凭证与本地配置（绝不入库）
tushare_token.txt
.tushare_token
*token*.txt
jq_credentials.json
.research.local.json
```

- [ ] **Step 5: 创建 jq_fetcher 包目录结构**

创建以下空文件占位（Task 4 会填充 `__init__.py` 的 re-export，本步先建空 `__init__.py` 让包可导入）：

`src/quant_v2/jq_fetcher/__init__.py`（本步只写 docstring，re-export 留到 Task 4）：

```python
# -*- coding: utf-8 -*-
"""聚宽数据拉取框架（jq_fetcher）。

提供认证管理、配额监控、速率控制、断点续传、错误重试，供阶段 1-4 的
全量数据拉取共用。详见 docs/superpowers/specs/2026-07-08-jq-database-overhaul-design.md §2。
"""
```

`src/tests/quant_v2/jq_fetcher/__init__.py`（空文件）：

```python
```

- [ ] **Step 6: 写失败测试 test_credentials.py**

`src/tests/quant_v2/jq_fetcher/test_credentials.py`：

```python
# -*- coding: utf-8 -*-
"""JqCredentials 凭证管理测试。"""
from __future__ import annotations

import json
import os
from pathlib import Path

import pytest

from quant_v2.jq_fetcher.credentials import (
    JqCredentials,
    CredentialNotFoundError,
)


def test_explicit_args_take_priority():
    """显式参数优先于环境变量和文件。"""
    creds = JqCredentials.load(username="explicit_user", password="explicit_pw")
    assert creds.username == "explicit_user"
    assert creds.password == "explicit_pw"
    assert creds.is_loaded() is True


def test_env_vars_used_when_no_explicit_args(monkeypatch):
    """无显式参数时读环境变量 JQ_USERNAME/JQ_PASSWORD。"""
    monkeypatch.setenv("JQ_USERNAME", "env_user")
    monkeypatch.setenv("JQ_PASSWORD", "env_pw")
    monkeypatch.setattr(Path, "exists", lambda self: False)  # 屏蔽文件读取
    creds = JqCredentials.load()
    assert creds.username == "env_user"
    assert creds.password == "env_pw"


def test_credentials_file_used_when_no_env(monkeypatch, tmp_path):
    """无环境变量时读 jq_credentials.json 文件。"""
    monkeypatch.delenv("JQ_USERNAME", raising=False)
    monkeypatch.delenv("JQ_PASSWORD", raising=False)
    cred_file = tmp_path / "jq_credentials.json"
    cred_file.write_text(
        json.dumps({"username": "file_user", "password": "file_pw"}),
        encoding="utf-8",
    )
    creds = JqCredentials.load(credentials_file=cred_file)
    assert creds.username == "file_user"
    assert creds.password == "file_pw"


def test_password_with_comma_preserved(monkeypatch, tmp_path):
    """聚宽密码可能含逗号，必须原样保留。"""
    cred_file = tmp_path / "jq_credentials.json"
    cred_file.write_text(
        json.dumps({"username": "18514293731", "password": "645123Zz,"}),
        encoding="utf-8",
    )
    creds = JqCredentials.load(credentials_file=cred_file)
    assert creds.password == "645123Zz,"


def test_missing_all_sources_raises(monkeypatch):
    """三级都取不到则抛 CredentialNotFoundError。"""
    monkeypatch.delenv("JQ_USERNAME", raising=False)
    monkeypatch.delenv("JQ_PASSWORD", raising=False)
    monkeypatch.setattr(Path, "exists", lambda self: False)
    with pytest.raises(CredentialNotFoundError):
        JqCredentials.load()


def test_partial_env_missing_password_raises(monkeypatch):
    """只有用户名没有密码也视为缺失。"""
    monkeypatch.setenv("JQ_USERNAME", "only_user")
    monkeypatch.delenv("JQ_PASSWORD", raising=False)
    monkeypatch.setattr(Path, "exists", lambda self: False)
    with pytest.raises(CredentialNotFoundError):
        JqCredentials.load()


def test_partial_file_missing_password_raises(monkeypatch, tmp_path):
    """凭证文件缺 password 字段也视为缺失。"""
    monkeypatch.delenv("JQ_USERNAME", raising=False)
    monkeypatch.delenv("JQ_PASSWORD", raising=False)
    cred_file = tmp_path / "jq_credentials.json"
    cred_file.write_text(json.dumps({"username": "no_pw_user"}), encoding="utf-8")
    with pytest.raises(CredentialNotFoundError):
        JqCredentials.load(credentials_file=cred_file)
```

- [ ] **Step 7: 运行测试确认失败**

```bash
cd "E:/量化平台_V1.4.0/src"
python -m pytest tests/quant_v2/jq_fetcher/test_credentials.py -v
```

Expected: FAIL，报 `ModuleNotFoundError: No module named 'quant_v2.jq_fetcher.credentials'`

- [ ] **Step 8: 实现 credentials.py**

`src/quant_v2/jq_fetcher/credentials.py`：

```python
# -*- coding: utf-8 -*-
"""聚宽凭证管理。

三级优先级读取（对齐 Tushare token 现有三段式）：
1. 显式参数 username/password
2. 环境变量 JQ_USERNAME / JQ_PASSWORD
3. 凭证文件 jq_credentials.json（仓库外）或 .research.local.json

凭证值绝不打印到日志。
"""
from __future__ import annotations

import json
import os
from pathlib import Path


class CredentialNotFoundError(RuntimeError):
    """三级来源都取不到聚宽凭证。"""


class JqCredentials:
    """聚宽账号凭证（手机号 + 密码）。"""

    def __init__(self, username: str, password: str):
        self.username = username
        self.password = password

    def is_loaded(self) -> bool:
        """是否已加载有效凭证。"""
        return bool(self.username) and bool(self.password)

    @classmethod
    def load(
        cls,
        username: str | None = None,
        password: str | None = None,
        credentials_file: str | Path | None = None,
    ) -> "JqCredentials":
        """三级优先级加载凭证。

        优先级：显式参数 > 环境变量 > 文件。任一级同时拿到 username 和
        password 即返回；否则尝试下一级。三级都失败抛
        CredentialNotFoundError。
        """
        # 第 1 级：显式参数
        if username and password:
            return cls(username, password)

        # 第 2 级：环境变量
        env_user = os.environ.get("JQ_USERNAME")
        env_pw = os.environ.get("JQ_PASSWORD")
        if env_user and env_pw:
            return cls(env_user, env_pw)

        # 第 3 级：文件
        file_creds = cls._load_from_file(credentials_file)
        if file_creds is not None:
            return file_creds

        raise CredentialNotFoundError(
            "聚宽凭证缺失：未提供显式参数，且环境变量 JQ_USERNAME/JQ_PASSWORD "
            "和凭证文件均无有效凭证。"
        )

    @staticmethod
    def _load_from_file(
        credentials_file: str | Path | None,
    ) -> "JqCredentials | None":
        """从 JSON 文件读取凭证。

        优先 credentials_file 参数；否则尝试默认路径 jq_credentials.json
        （平台根，已 .gitignore）和 .research.local.json。
        """
        candidate_paths: list[Path] = []
        if credentials_file is not None:
            candidate_paths.append(Path(credentials_file))
        else:
            platform_root = Path(__file__).resolve().parents[4]
            candidate_paths.append(platform_root / "jq_credentials.json")
            candidate_paths.append(platform_root / ".research.local.json")

        for p in candidate_paths:
            if not p.exists():
                continue
            try:
                data = json.loads(p.read_text(encoding="utf-8-sig"))
            except (json.JSONDecodeError, OSError):
                continue
            user = data.get("username") or data.get("jq_username")
            pw = data.get("password") or data.get("jq_password")
            if user and pw:
                return JqCredentials(user, pw)
        return None
```

- [ ] **Step 9: 运行测试确认通过**

```bash
cd "E:/量化平台_V1.4.0/src"
python -m pytest tests/quant_v2/jq_fetcher/test_credentials.py -v
```

Expected: PASS（7 个测试全通过）

- [ ] **Step 10: 验证 .gitignore 覆盖**

```bash
cd "E:/量化平台_V1.4.0"
echo '{"username":"test","password":"test"}' > jq_credentials.json
git check-ignore jq_credentials.json
```

Expected: 命令输出 `jq_credentials.json`（exit 0，表示被忽略）。然后清理测试文件：

```bash
rm jq_credentials.json
```

- [ ] **Step 11: 安装 jqdatasdk 并验证可导入**

```bash
cd "E:/量化平台_V1.4.0"
.venv/Scripts/pip install "jqdatasdk>=1.9.0"
.venv/Scripts/python -c "import jqdatasdk; print('jqdatasdk', jqdatasdk.__version__)"
```

Expected: 输出 jqdatasdk 版本号（如 `jqdatasdk 1.9.x`）。记录该版本号，用于 Step 12 固定 requirements.txt 下限。

- [ ] **Step 12: 固定 jqdatasdk 实际版本到依赖文件**

用 Step 11 输出的实际版本号更新 `src/requirements.txt`（把 `>=1.9.0` 改为实际查到的版本，如 `jqdatasdk==1.9.5` 或保持 `>=<实际版本>`）。同步更新 `src/pyproject.toml` 的对应行。

- [ ] **Step 13: 提交**

```bash
cd "E:/量化平台_V1.4.0"
git add src/quant_v2/jq_fetcher/__init__.py src/quant_v2/jq_fetcher/credentials.py src/tests/quant_v2/jq_fetcher/__init__.py src/tests/quant_v2/jq_fetcher/test_credentials.py src/requirements.txt src/pyproject.toml .gitignore
git commit -m "feat(jq_fetcher): 添加jqdatasdk依赖与凭证管理(Task 1)

- 新增 quant_v2/jq_fetcher 包骨架
- JqCredentials 三级优先级加载(显式参数>环境变量>文件)
- 凭证值不入库, .gitignore 补 tushare/jq 凭证文件缺口
- jqdatasdk 加入 requirements.txt(仅Windows数据生产侧)"
```

---

## Task 2: Checkpoint 断点续传

实现断点续传 JSON 存储，供 JqFetcher 记录已完成/失败的拉取项，中断后重启无缝续传。交付物：Checkpoint 类可加载/标记/保存/汇总。

**Files:**
- Create: `E:\量化平台_V1.4.0\src\quant_v2\jq_fetcher\checkpoint.py`
- Create: `E:\量化平台_V1.4.0\src\tests\quant_v2\jq_fetcher\test_checkpoint.py`

**Interfaces:**
- Consumes: 无（纯存储组件）
- Produces: `Checkpoint` 类（`checkpoint.py`），签名：
  - `Checkpoint(task_name: str, checkpoint_dir: str | Path)` —— 构造（自动加载已有文件）
  - `Checkpoint.set_total(total: int) -> None` —— 设置拉取项总数（用于进度百分比，供 Task 4 消费）
  - `Checkpoint.mark_completed(item: str) -> None` —— 标记完成
  - `Checkpoint.mark_failed(item: str, reason: str) -> None` —— 标记失败（带原因）
  - `Checkpoint.is_completed(item: str) -> bool` —— 查询是否已完成（供 Task 4 消费）
  - `Checkpoint.save() -> None` —— 落盘
  - `Checkpoint.summary() -> dict` —— 返回 `{task_name, total, completed, failed, last_progress_pct}`
- 供 Task 4 消费：`set_total()` / `is_completed()` / `mark_completed()` / `mark_failed()` / `save()` / `summary()`

- [ ] **Step 1: 写失败测试 test_checkpoint.py**

`src/tests/quant_v2/jq_fetcher/test_checkpoint.py`：

```python
# -*- coding: utf-8 -*-
"""Checkpoint 断点续传测试。"""
from __future__ import annotations

import json
from pathlib import Path

from quant_v2.jq_fetcher.checkpoint import Checkpoint


def test_new_checkpoint_starts_empty(tmp_path):
    """新任务无历史文件时从空开始。"""
    cp = Checkpoint("test_task", tmp_path)
    assert cp.is_completed("000001.XSHE") is False
    s = cp.summary()
    assert s["completed"] == 0
    assert s["failed"] == 0


def test_mark_completed_persists_after_save(tmp_path):
    """标记完成后保存，重新加载仍保留。"""
    cp = Checkpoint("task_a", tmp_path)
    cp.mark_completed("000001.XSHE")
    cp.mark_completed("000002.XSHE")
    cp.save()

    cp2 = Checkpoint("task_a", tmp_path)
    assert cp2.is_completed("000001.XSHE") is True
    assert cp2.is_completed("000002.XSHE") is True
    assert cp2.is_completed("000003.XSHE") is False


def test_mark_failed_records_reason(tmp_path):
    """失败项记录原因，不与完成项混淆。"""
    cp = Checkpoint("task_b", tmp_path)
    cp.mark_failed("000003.XSHE", "timeout after 3 retries")
    cp.save()

    cp2 = Checkpoint("task_b", tmp_path)
    assert cp2.is_completed("000003.XSHE") is False
    assert cp2.summary()["failed"] == 1
    # 失败项可重新标记完成（修复后重试）
    cp2.mark_completed("000003.XSHE")
    cp2.save()

    cp3 = Checkpoint("task_b", tmp_path)
    assert cp3.is_completed("000003.XSHE") is True
    assert cp3.summary()["failed"] == 0


def test_summary_progress_pct(tmp_path):
    """summary 返回进度百分比。"""
    cp = Checkpoint("task_c", tmp_path)
    cp.set_total(10)
    for i in range(4):
        cp.mark_completed(f"stock_{i}")
    cp.save()
    s = cp.summary()
    assert s["total"] == 10
    assert s["completed"] == 4
    assert s["last_progress_pct"] == 40.0


def test_checkpoint_file_path_convention(tmp_path):
    """checkpoint 文件名为 <task_name>.json。"""
    cp = Checkpoint("daily_bar_v3", tmp_path)
    cp.save()
    assert (tmp_path / "daily_bar_v3.json").exists()


def test_checkpoint_json_structure(tmp_path):
    """JSON 结构含 task_name/completed_items/failed_items。"""
    cp = Checkpoint("task_d", tmp_path)
    cp.set_total(5)
    cp.mark_completed("a")
    cp.mark_failed("b", "rate limit")
    cp.save()

    data = json.loads((tmp_path / "task_d.json").read_text(encoding="utf-8"))
    assert data["task_name"] == "task_d"
    assert "a" in data["completed_items"]
    assert data["failed_items"]["b"] == "rate limit"
    assert data["total_items"] == 5
    assert "started_at" in data
    assert "updated_at" in data
```

- [ ] **Step 2: 运行测试确认失败**

```bash
cd "E:/量化平台_V1.4.0/src"
python -m pytest tests/quant_v2/jq_fetcher/test_checkpoint.py -v
```

Expected: FAIL，报 `ModuleNotFoundError: No module named 'quant_v2.jq_fetcher.checkpoint'`

- [ ] **Step 3: 实现 checkpoint.py**

`src/quant_v2/jq_fetcher/checkpoint.py`：

```python
# -*- coding: utf-8 -*-
"""断点续传 JSON 存储。

每个拉取任务对应一个 checkpoint JSON 文件，记录已完成/失败的拉取项，
中断后重启自动跳过已完成项，无缝续传。
"""
from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path


class Checkpoint:
    """断点续传存储，JSON 落盘。"""

    def __init__(self, task_name: str, checkpoint_dir: str | Path):
        self.task_name = task_name
        self._dir = Path(checkpoint_dir)
        self._path = self._dir / f"{task_name}.json"
        self._total: int = 0
        self._completed: set[str] = set()
        self._failed: dict[str, str] = {}
        self._started_at: str = ""
        self._load()

    def _load(self) -> None:
        """加载已有 checkpoint 文件（若存在）。"""
        if not self._path.exists():
            self._started_at = datetime.now(timezone.utc).isoformat()
            return
        try:
            data = json.loads(self._path.read_text(encoding="utf-8"))
        except (json.JSONDecodeError, OSError):
            self._started_at = datetime.now(timezone.utc).isoformat()
            return
        self._total = data.get("total_items", 0)
        self._completed = set(data.get("completed_items", []))
        self._failed = dict(data.get("failed_items", {}))
        self._started_at = data.get("started_at", datetime.now(timezone.utc).isoformat())

    def set_total(self, total: int) -> None:
        """设置拉取项总数（用于进度百分比）。"""
        self._total = total

    def mark_completed(self, item: str) -> None:
        """标记某项完成（同时从失败项移除）。"""
        self._completed.add(item)
        self._failed.pop(item, None)

    def mark_failed(self, item: str, reason: str) -> None:
        """标记某项失败（带原因）。"""
        self._failed[item] = reason

    def is_completed(self, item: str) -> bool:
        """查询某项是否已完成。"""
        return item in self._completed

    def save(self) -> None:
        """落盘到 JSON 文件。"""
        self._dir.mkdir(parents=True, exist_ok=True)
        data = {
            "task_name": self.task_name,
            "started_at": self._started_at,
            "updated_at": datetime.now(timezone.utc).isoformat(),
            "total_items": self._total,
            "completed_items": sorted(self._completed),
            "failed_items": self._failed,
            "last_progress_pct": round(self._progress_pct(), 1),
        }
        self._path.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")

    def _progress_pct(self) -> float:
        if self._total <= 0:
            return 0.0
        return len(self._completed) / self._total * 100.0

    def summary(self) -> dict:
        """返回汇总字典。"""
        return {
            "task_name": self.task_name,
            "total": self._total,
            "completed": len(self._completed),
            "failed": len(self._failed),
            "last_progress_pct": round(self._progress_pct(), 1),
        }
```

- [ ] **Step 4: 运行测试确认通过**

```bash
cd "E:/量化平台_V1.4.0/src"
python -m pytest tests/quant_v2/jq_fetcher/test_checkpoint.py -v
```

Expected: PASS（6 个测试全通过）

- [ ] **Step 5: 提交**

```bash
cd "E:/量化平台_V1.4.0"
git add src/quant_v2/jq_fetcher/checkpoint.py src/tests/quant_v2/jq_fetcher/test_checkpoint.py
git commit -m "feat(jq_fetcher): 添加Checkpoint断点续传(Task 2)

- 每任务一个JSON文件, 记录完成/失败项
- 中断重启自动跳过已完成项
- summary返回进度百分比"
```

---

## Task 3: 配额监控

实现配额监控，定期调用 jqdatasdk `get_query_count()` 检查剩余配额，低于阈值告警。交付物：QuotaMonitor 类可注入查询函数（可测试）。

**Files:**
- Create: `E:\量化平台_V1.4.0\src\quant_v2\jq_fetcher\quota.py`
- Create: `E:\量化平台_V1.4.0\src\tests\quant_v2\jq_fetcher\test_quota.py`

**Interfaces:**
- Consumes: 无（`query_count_fn` 注入，生产用 jqdatasdk.get_query_count）
- Produces: `QuotaMonitor` 类（`quota.py`），签名：
  - `QuotaMonitor(check_interval: int = 500, warn_threshold: int = 1_000_000, query_count_fn: Callable[[], dict] | None = None)` —— 构造
  - `QuotaMonitor.record_query() -> dict | None` —— 每次查询后调用，达 check_interval 时触发检查，返回配额状态 dict 或 None
  - `QuotaMonitor.get_status() -> dict | None` —— 强制立即检查
  - 返回的 dict 格式：`{"total": int, "spare": int, "used_pct": float, "should_warn": bool}`
- 供 Task 4 消费：`record_query()` / `get_status()`

- [ ] **Step 1: 写失败测试 test_quota.py**

`src/tests/quant_v2/jq_fetcher/test_quota.py`：

```python
# -*- coding: utf-8 -*-
"""QuotaMonitor 配额监控测试。"""
from __future__ import annotations

from quant_v2.jq_fetcher.quota import QuotaMonitor


def test_record_query_returns_none_before_interval():
    """未达 check_interval 时不触发检查，返回 None。"""
    calls = []

    def fake_count():
        calls.append(1)
        return {"total": 200000000, "spare": 199000000}

    monitor = QuotaMonitor(check_interval=5, warn_threshold=1000000, query_count_fn=fake_count)
    for _ in range(4):
        assert monitor.record_query() is None
    assert len(calls) == 0  # 未触发实际查询


def test_record_query_returns_status_at_interval():
    """达到 check_interval 时触发检查，返回配额状态。"""
    calls = []

    def fake_count():
        calls.append(1)
        return {"total": 200000000, "spare": 199000000}

    monitor = QuotaMonitor(check_interval=3, warn_threshold=1000000, query_count_fn=fake_count)
    monitor.record_query()
    monitor.record_query()
    status = monitor.record_query()  # 第 3 次触发
    assert status is not None
    assert status["total"] == 200000000
    assert status["spare"] == 199000000
    assert status["used_pct"] == 0.5  # 用了 100万/2亿
    assert status["should_warn"] is False
    assert len(calls) == 1


def test_warn_flag_when_below_threshold():
    """剩余配额低于阈值时 should_warn=True。"""
    def fake_count():
        return {"total": 200000000, "spare": 500000}  # 50万 < 100万阈值

    monitor = QuotaMonitor(check_interval=1, warn_threshold=1000000, query_count_fn=fake_count)
    status = monitor.record_query()
    assert status is not None
    assert status["should_warn"] is True


def test_get_status_forces_check():
    """get_status 立即检查，不受计数影响。"""
    calls = []

    def fake_count():
        calls.append(1)
        return {"total": 200000000, "spare": 100000000}

    monitor = QuotaMonitor(check_interval=100, query_count_fn=fake_count)
    status = monitor.get_status()  # 计数为 0 也立即查
    assert status is not None
    assert status["spare"] == 100000000
    assert len(calls) == 1


def test_record_query_resets_counter_after_check():
    """触发检查后计数器归零，下一轮重新累积。"""
    calls = []

    def fake_count():
        calls.append(1)
        return {"total": 200000000, "spare": 199000000}

    monitor = QuotaMonitor(check_interval=2, query_count_fn=fake_count)
    monitor.record_query()
    assert monitor.record_query() is not None  # 第 2 次触发
    assert monitor.record_query() is None       # 计数器归零后第 1 次
    assert monitor.record_query() is not None   # 第 2 次再触发
    assert len(calls) == 2
```

- [ ] **Step 2: 运行测试确认失败**

```bash
cd "E:/量化平台_V1.4.0/src"
python -m pytest tests/quant_v2/jq_fetcher/test_quota.py -v
```

Expected: FAIL，报 `ModuleNotFoundError: No module named 'quant_v2.jq_fetcher.quota'`

- [ ] **Step 3: 实现 quota.py**

`src/quant_v2/jq_fetcher/quota.py`：

```python
# -*- coding: utf-8 -*-
"""聚宽配额监控。

定期调用 jqdatasdk.get_query_count() 检查剩余配额，低于阈值告警。
正式版配额 2 亿次/日，全量拉取预估 300-400 万次（占 0.2%）。
"""
from __future__ import annotations

from typing import Callable


class QuotaMonitor:
    """配额监控器，注入 query_count_fn 实现可测试性。"""

    def __init__(
        self,
        check_interval: int = 500,
        warn_threshold: int = 1_000_000,
        query_count_fn: Callable[[], dict] | None = None,
    ):
        self._check_interval = check_interval
        self._warn_threshold = warn_threshold
        self._query_count_fn = query_count_fn
        self._since_last_check = 0

    def _resolve_fn(self) -> Callable[[], dict]:
        """延迟导入 jqdatasdk，避免无凭证时构造失败。"""
        if self._query_count_fn is not None:
            return self._query_count_fn

        def _real_count() -> dict:
            from jqdatasdk import get_query_count
            return get_query_count()

        return _real_count

    def record_query(self) -> dict | None:
        """每次查询后调用，达 check_interval 时触发检查。

        返回配额状态 dict（触发检查时）或 None（未触发）。
        """
        self._since_last_check += 1
        if self._since_last_check < self._check_interval:
            return None
        return self._do_check()

    def get_status(self) -> dict | None:
        """强制立即检查配额，不受计数影响。"""
        return self._do_check()

    def _do_check(self) -> dict | None:
        """执行实际配额查询并重置计数器。"""
        self._since_last_check = 0
        try:
            raw = self._resolve_fn()()
        except Exception:
            return None
        total = raw.get("total", 0)
        spare = raw.get("spare", 0)
        used_pct = round((total - spare) / total * 100, 2) if total > 0 else 0.0
        return {
            "total": total,
            "spare": spare,
            "used_pct": used_pct,
            "should_warn": spare < self._warn_threshold,
        }
```

- [ ] **Step 4: 运行测试确认通过**

```bash
cd "E:/量化平台_V1.4.0/src"
python -m pytest tests/quant_v2/jq_fetcher/test_quota.py -v
```

Expected: PASS（5 个测试全通过）

- [ ] **Step 5: 提交**

```bash
cd "E:/量化平台_V1.4.0"
git add src/quant_v2/jq_fetcher/quota.py src/tests/quant_v2/jq_fetcher/test_quota.py
git commit -m "feat(jq_fetcher): 添加QuotaMonitor配额监控(Task 3)

- 定期调用get_query_count检查剩余配额
- 注入query_count_fn实现可测试性
- 低于阈值时should_warn标记"
```

---

## Task 4: JqFetcher 拉取核心

整合认证、重试、速率控制、断点续传、配额监控，实现通用拉取循环 `fetch_panel` 和常用方法 `fetch_price`。交付物：JqFetcher 类可拉取数据（测试用 FakeApiClient 注入，不依赖真实 jqdatasdk）。

**Files:**
- Create: `E:\量化平台_V1.4.0\src\quant_v2\jq_fetcher\core.py`
- Create: `E:\量化平台_V1.4.0\src\tests\quant_v2\jq_fetcher\test_fetcher.py`
- Modify: `E:\量化平台_V1.4.0\src\quant_v2\jq_fetcher\__init__.py`（填充 re-export）

**Interfaces:**
- Consumes: `JqCredentials`（Task 1）、`Checkpoint`（Task 2）、`QuotaMonitor`（Task 3）
- Produces: `JqFetcher` 类（`core.py`），签名：
  - `JqFetcher(credentials: JqCredentials | None = None, api_client: Any | None = None, max_workers: int = 4, retry_max: int = 3, retry_backoff: float = 2.0, checkpoint_dir: str | Path = "tmp/jq_checkpoint", quota_check_interval: int = 500, quota_warn_threshold: int = 1_000_000)` —— 构造
  - `JqFetcher.authenticate() -> None` —— 调用 jqdatasdk.auth（用凭证认证）
  - `JqFetcher.fetch_panel(items: list[str], fetch_fn: Callable, *, task_name: str, **fetch_kwargs) -> pd.DataFrame` —— 通用拉取循环
  - `JqFetcher.fetch_price(security_list: list[str], start_date: str, end_date: str, frequency: str = "daily", fields: list[str] | None = None, fq: str = "pre", task_name: str | None = None) -> pd.DataFrame` —— 日线/分钟线拉取便捷方法
- 供 Task 5 消费：`authenticate()` / `fetch_price()` / `fetch_panel()`

- [ ] **Step 1: 写失败测试 test_fetcher.py**

`src/tests/quant_v2/jq_fetcher/test_fetcher.py`：

```python
# -*- coding: utf-8 -*-
"""JqFetcher 拉取核心测试。"""
from __future__ import annotations

import pandas as pd
import pytest

from quant_v2.jq_fetcher.core import JqFetcher
from quant_v2.jq_fetcher.credentials import JqCredentials


class FakeApiClient:
    """模拟 jqdatasdk，可控制返回值和异常。"""

    def __init__(self):
        self.price_calls: list[tuple] = []
        self.auth_called = False
        self._fail_items: set[str] = set()  # 这些标的首次调用抛异常
        self._already_failed: set[str] = set()  # 已失败过的（重试时不再现）

    def auth(self, username, password):
        self.auth_called = True
        self.username = username

    def get_price(self, security, start_date, end_date, frequency="daily",
                  fields=None, fq="pre", panel=False):
        self.price_calls.append((security, start_date, end_date, frequency))
        if security in self._fail_items and security not in self._already_failed:
            self._already_failed.add(security)
            raise ConnectionError("simulated network error")
        # 返回单标的单行 DataFrame
        return pd.DataFrame([{
            "code": security, "time": pd.Timestamp(start_date),
            "open": 10.0, "close": 10.5, "high": 10.8, "low": 9.9,
            "volume": 1000000, "money": 10500000.0,
        }])


def _make_fetcher(api_client, tmp_path, **kwargs):
    """构造测试用 JqFetcher（注入 fake api，不触发真实 auth）。"""
    creds = JqCredentials("test_user", "test_pw")
    defaults = dict(
        credentials=creds, api_client=api_client,
        max_workers=1, retry_max=3, retry_backoff=0.01,
        checkpoint_dir=str(tmp_path), quota_check_interval=10000,
    )
    defaults.update(kwargs)
    return JqFetcher(**defaults)


def test_fetch_price_basic(tmp_path):
    """单标的拉取返回非空 DataFrame。"""
    api = FakeApiClient()
    fetcher = _make_fetcher(api, tmp_path)
    df = fetcher.fetch_price(
        ["000001.XSHE"], start_date="2024-01-01", end_date="2024-01-05"
    )
    assert len(df) == 1
    assert "open" in df.columns
    assert api.price_calls[0][0] == "000001.XSHE"


def test_fetch_price_multiple_securities(tmp_path):
    """多标的合并返回。"""
    api = FakeApiClient()
    fetcher = _make_fetcher(api, tmp_path)
    df = fetcher.fetch_price(
        ["000001.XSHE", "000002.XSHE"], start_date="2024-01-01", end_date="2024-01-05"
    )
    assert len(df) == 2
    codes = set(df["code"].unique()) if "code" in df.columns else set()
    # 合并后应含两只标的的数据
    assert api.price_calls[0][0] == "000001.XSHE"
    assert api.price_calls[1][0] == "000002.XSHE"


def test_fetch_price_retries_on_error(tmp_path):
    """网络错误自动重试，重试成功后返回数据。"""
    api = FakeApiClient()
    api._fail_items.add("000001.XSHE")  # 首次失败，重试成功
    fetcher = _make_fetcher(api, tmp_path, retry_max=3, retry_backoff=0.01)
    df = fetcher.fetch_price(
        ["000001.XSHE"], start_date="2024-01-01", end_date="2024-01-05"
    )
    assert len(df) == 1  # 重试后成功


def test_fetch_price_persistent_failure_marks_failed(tmp_path):
    """持续失败的标的标记到 checkpoint.failed_items，不中断整体。"""
    api = FakeApiClient()
    # 让 000002 永远失败（重置 _already_failed）
    class AlwaysFailApi(FakeApiClient):
        def get_price(self, *args, **kwargs):
            sec = args[0] if args else kwargs.get("security")
            if sec == "000002.XSHE":
                raise ConnectionError("persistent error")
            return super().get_price(*args, **kwargs)
    api = AlwaysFailApi()
    fetcher = _make_fetcher(api, tmp_path, retry_max=2, retry_backoff=0.01)
    df = fetcher.fetch_price(
        ["000001.XSHE", "000002.XSHE"], start_date="2024-01-01", end_date="2024-01-05",
        task_name="test_fail",
    )
    # 000001 成功，000002 失败被跳过，返回只含 000001
    assert len(df) == 1
    from quant_v2.jq_fetcher.checkpoint import Checkpoint
    cp = Checkpoint("test_fail", str(tmp_path))
    assert cp.is_completed("000001.XSHE") is True
    assert cp.summary()["failed"] == 1


def test_checkpoint_skips_completed_on_resume(tmp_path):
    """断点续传：已完成的标的在重新拉取时被跳过。"""
    api = FakeApiClient()
    fetcher = _make_fetcher(api, tmp_path)
    # 第一次拉取两只
    fetcher.fetch_price(
        ["000001.XSHE", "000002.XSHE"], start_date="2024-01-01", end_date="2024-01-05",
        task_name="resume_task",
    )
    first_call_count = len(api.price_calls)
    # 第二次拉取（同 task_name），应跳过已完成的
    fetcher.fetch_price(
        ["000001.XSHE", "000002.XSHE"], start_date="2024-01-01", end_date="2024-01-05",
        task_name="resume_task",
    )
    # 不应有新的 price 调用（全部跳过）
    assert len(api.price_calls) == first_call_count


def test_authenticate_calls_jqdatasdk_auth(tmp_path):
    """authenticate() 调用 api_client.auth()。"""
    api = FakeApiClient()
    creds = JqCredentials("my_user", "my_pw")
    fetcher = JqFetcher(
        credentials=creds, api_client=api, max_workers=1,
        checkpoint_dir=str(tmp_path),
    )
    fetcher.authenticate()
    assert api.auth_called is True
    assert api.username == "my_user"
```

- [ ] **Step 2: 运行测试确认失败**

```bash
cd "E:/量化平台_V1.4.0/src"
python -m pytest tests/quant_v2/jq_fetcher/test_fetcher.py -v
```

Expected: FAIL，报 `ModuleNotFoundError: No module named 'quant_v2.jq_fetcher.core'`

- [ ] **Step 3: 实现 core.py**

`src/quant_v2/jq_fetcher/core.py`：

```python
# -*- coding: utf-8 -*-
"""JqFetcher 聚宽数据拉取核心。

整合认证、重试、速率控制、断点续传、配额监控，提供通用拉取循环
fetch_panel 和便捷方法 fetch_price。对 jqdatasdk 的依赖通过构造函数
注入 api_client 实现可测试性——测试注入 FakeApiClient，生产用动态
import jqdatasdk。
"""
from __future__ import annotations

import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path
from typing import Any, Callable

import pandas as pd
from tqdm import tqdm

from quant_v2.jq_fetcher.checkpoint import Checkpoint
from quant_v2.jq_fetcher.credentials import JqCredentials
from quant_v2.jq_fetcher.quota import QuotaMonitor


_DEFAULT_PRICE_FIELDS = [
    "open", "close", "high", "low", "volume", "money",
    "pre_close", "high_limit", "low_limit", "paused", "factor",
]


class JqFetcher:
    """聚宽数据拉取器。"""

    def __init__(
        self,
        credentials: JqCredentials | None = None,
        api_client: Any | None = None,
        max_workers: int = 4,
        retry_max: int = 3,
        retry_backoff: float = 2.0,
        checkpoint_dir: str | Path = "tmp/jq_checkpoint",
        quota_check_interval: int = 500,
        quota_warn_threshold: int = 1_000_000,
    ):
        self._credentials = credentials
        self._api = api_client
        self._max_workers = max_workers
        self._retry_max = retry_max
        self._retry_backoff = retry_backoff
        self._checkpoint_dir = Path(checkpoint_dir)
        self._quota = QuotaMonitor(
            check_interval=quota_check_interval,
            warn_threshold=quota_warn_threshold,
        )

    def _get_api(self) -> Any:
        """延迟创建真实 jqdatasdk client（首次调用时）。"""
        if self._api is not None:
            return self._api
        import jqdatasdk
        self._api = jqdatasdk
        return self._api

    def authenticate(self) -> None:
        """用凭证调用 jqdatasdk.auth()。"""
        if self._credentials is None or not self._credentials.is_loaded():
            from quant_v2.jq_fetcher.credentials import CredentialNotFoundError
            raise CredentialNotFoundError("认证需要已加载的凭证")
        api = self._get_api()
        api.auth(self._credentials.username, self._credentials.password)

    def fetch_panel(
        self,
        items: list[str],
        fetch_fn: Callable[..., pd.DataFrame],
        *,
        task_name: str,
        **fetch_kwargs,
    ) -> pd.DataFrame:
        """通用拉取循环。

        对 items 逐个调用 fetch_fn(item, **fetch_kwargs)，合并结果。
        自动断点续传（跳过 checkpoint 已完成项）、自动重试（指数退避）、
        自动配额监控、并发拉取（ThreadPoolExecutor）。

        Args:
            items: 拉取项列表（通常是标的代码列表）
            fetch_fn: 单次拉取函数，签名 fetch_fn(item, **kwargs) -> DataFrame
            task_name: checkpoint 任务名（用于断点续传）
            **fetch_kwargs: 传给 fetch_fn 的额外参数

        Returns:
            合并后的 DataFrame（失败的项被跳过）
        """
        cp = Checkpoint(task_name, self._checkpoint_dir)
        cp.set_total(len(items))

        pending = [it for it in items if not cp.is_completed(it)]
        if not pending:
            tqdm.write(f"[{task_name}] 全部 {len(items)} 项已完成（断点续传跳过）")
            return pd.DataFrame()

        tqdm.write(
            f"[{task_name}] 共 {len(items)} 项，已完成 {len(items) - len(pending)}，"
            f"待拉取 {len(pending)}"
        )

        results: list[pd.DataFrame] = []
        failed_count = 0

        with ThreadPoolExecutor(max_workers=self._max_workers) as pool:
            future_map = {
                pool.submit(self._fetch_with_retry, fetch_fn, it, fetch_kwargs, task_name): it
                for it in pending
            }
            with tqdm(total=len(pending), desc=task_name, unit="项") as pbar:
                for future in as_completed(future_map):
                    item = future_map[future]
                    try:
                        df, ok = future.result()
                    except Exception as e:
                        tqdm.write(f"[{task_name}] {item} 未预期异常: {e}")
                        cp.mark_failed(item, str(e)[:200])
                        failed_count += 1
                        pbar.update(1)
                        continue
                    if ok and df is not None and len(df) > 0:
                        results.append(df)
                        cp.mark_completed(item)
                    elif not ok:
                        cp.mark_failed(item, "max retries exceeded")
                        failed_count += 1
                    # 每 100 项落盘一次 checkpoint + 打印进度
                    if pbar.n % 100 == 0:
                        cp.save()
                        self._log_progress(task_name, cp, pbar.n, len(pending))
                    pbar.update(1)

        cp.save()
        self._log_progress(task_name, cp, len(pending), len(pending), final=True)

        if failed_count > 0:
            tqdm.write(f"[{task_name}] 警告：{failed_count} 项失败，见 checkpoint")

        if not results:
            return pd.DataFrame()
        return pd.concat(results, ignore_index=True)

    def _fetch_with_retry(
        self,
        fetch_fn: Callable[..., pd.DataFrame],
        item: str,
        fetch_kwargs: dict,
        task_name: str,
    ) -> tuple[pd.DataFrame | None, bool]:
        """单次拉取 + 重试。返回 (df, success)。"""
        last_err: Exception | None = None
        for attempt in range(1, self._retry_max + 1):
            try:
                df = fetch_fn(item, **fetch_kwargs)
                self._quota.record_query()
                return df, True
            except Exception as e:
                last_err = e
                if attempt < self._retry_max:
                    wait = self._retry_backoff ** attempt
                    time.sleep(wait)
        tqdm.write(f"[{task_name}] {item} 重试 {self._retry_max} 次后失败: {last_err}")
        return None, False

    def _log_progress(
        self,
        task_name: str,
        cp: Checkpoint,
        done: int,
        total_pending: int,
        final: bool = False,
    ) -> None:
        """记录进度和配额。"""
        s = cp.summary()
        tag = "完成" if final else "进度"
        tqdm.write(
            f"[{task_name}] {tag}: {s['completed']}/{s['total']} "
            f"({s['last_progress_pct']}%), 失败 {s['failed']}"
        )
        if final or done % 500 == 0:
            q = self._quota.get_status()
            if q is not None:
                tqdm.write(
                    f"[{task_name}] 配额: 剩余 {q['spare']:,} / {q['total']:,} "
                    f"(已用 {q['used_pct']}%)"
                    + (" [警告:低于阈值]" if q["should_warn"] else "")
                )

    def fetch_price(
        self,
        security_list: list[str],
        start_date: str,
        end_date: str,
        frequency: str = "daily",
        fields: list[str] | None = None,
        fq: str = "pre",
        task_name: str | None = None,
    ) -> pd.DataFrame:
        """日线/分钟线拉取便捷方法。

        Args:
            security_list: 标的代码列表（聚宽格式，如 '000001.XSHE'）
            start_date: 起始日期 'YYYY-MM-DD'
            end_date: 结束日期 'YYYY-MM-DD'
            frequency: 'daily' 或 'minute'
            fields: 返回字段，默认全部行情字段
            fq: 复权方式 'pre'(前复权)/'none'/None
            task_name: checkpoint 任务名，默认自动生成

        Returns:
            合并后的长表 DataFrame（panel=False 格式）
        """
        if fields is None:
            fields = list(_DEFAULT_PRICE_FIELDS)
        tn = task_name or f"price_{frequency}_{start_date}_{end_date}"

        api = self._get_api()

        def fetch_one(security: str, **_kw) -> pd.DataFrame:
            return api.get_price(
                security,
                start_date=start_date,
                end_date=end_date,
                frequency=frequency,
                fields=fields,
                fq=fq,
                panel=False,
            )

        return self.fetch_panel(security_list, fetch_one, task_name=tn)
```

- [ ] **Step 4: 运行测试确认通过**

```bash
cd "E:/量化平台_V1.4.0/src"
python -m pytest tests/quant_v2/jq_fetcher/test_fetcher.py -v
```

Expected: PASS（6 个测试全通过）

- [ ] **Step 5: 填充 __init__.py re-export**

修改 `src/quant_v2/jq_fetcher/__init__.py`：

```python
# -*- coding: utf-8 -*-
"""聚宽数据拉取框架（jq_fetcher）。

提供认证管理、配额监控、速率控制、断点续传、错误重试，供阶段 1-4 的
全量数据拉取共用。详见 docs/superpowers/specs/2026-07-08-jq-database-overhaul-design.md §2。
"""
from quant_v2.jq_fetcher.credentials import JqCredentials, CredentialNotFoundError
from quant_v2.jq_fetcher.checkpoint import Checkpoint
from quant_v2.jq_fetcher.quota import QuotaMonitor
from quant_v2.jq_fetcher.core import JqFetcher

__all__ = [
    "JqCredentials",
    "CredentialNotFoundError",
    "Checkpoint",
    "QuotaMonitor",
    "JqFetcher",
]
```

- [ ] **Step 6: 运行全部 jq_fetcher 测试确认通过**

```bash
cd "E:/量化平台_V1.4.0/src"
python -m pytest tests/quant_v2/jq_fetcher/ -v
```

Expected: PASS（credentials 7 + checkpoint 6 + quota 5 + fetcher 6 = 24 个测试全通过）

- [ ] **Step 7: 提交**

```bash
cd "E:/量化平台_V1.4.0"
git add src/quant_v2/jq_fetcher/core.py src/quant_v2/jq_fetcher/__init__.py src/tests/quant_v2/jq_fetcher/test_fetcher.py
git commit -m "feat(jq_fetcher): 添加JqFetcher拉取核心(Task 4)

- 整合认证/重试/速率/断点续传/配额监控
- fetch_panel通用拉取循环(注入api_client可测试)
- fetch_price日线/分钟线便捷方法
- ThreadPoolExecutor并发, tqdm进度, 每100项落盘checkpoint
- __init__.py re-export全部公开API"
```

---

## Task 5: 速率实测脚本（阶段 0 验收）

编写速率实测脚本，拉取 50 只标的日线 + 50 只标的 1 个月分钟线，实测 jqdatasdk 速率，产出阶段 0 验收报告。交付物：速率实测脚本 + 实测报告（含全量工期估算）。

**Files:**
- Create: `E:\量化平台_V1.4.0\scripts\jq_fetcher\jq_speed_benchmark.py`
- Create: `E:\量化平台_V1.4.0\scripts\jq_fetcher\__init__.py`（空）

**Interfaces:**
- Consumes: `JqFetcher`（Task 4）、`JqCredentials`（Task 1）
- Produces: 速率实测报告（打印到 stdout + 写入 `tmp/jq_speed_benchmark_report.txt`）

- [ ] **Step 1: 创建 scripts/jq_fetcher 包**

`scripts/jq_fetcher/__init__.py`（空文件）：

```python
```

- [ ] **Step 2: 编写速率实测脚本**

`scripts/jq_fetcher/jq_speed_benchmark.py`：

```python
# -*- coding: utf-8 -*-
"""jqdatasdk 速率实测脚本（阶段 0 验收）。

测量指标：
- 单次日线查询延迟（50 只标的各拉 11 年日线）
- 单次分钟线查询延迟（50 只标的各拉 1 个月分钟线）
- 并发 4 线程加速比（串行 50 只 vs 并发 4 线程 50 只）
- 全量工期估算（按 7047 标的 × 132 月外推）

运行方式（Windows .venv，需先设置凭证）：
    set JQ_USERNAME=手机号
    set JQ_PASSWORD=密码
    cd E:/量化平台_V1.4.0
    .venv/Scripts/python scripts/jq_fetcher/jq_speed_benchmark.py

输出：打印到 stdout + 写入 tmp/jq_speed_benchmark_report.txt
"""
from __future__ import annotations

import sys
import time
from pathlib import Path

# 让脚本能 import src 下的包
_PLATFORM_ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(_PLATFORM_ROOT / "src"))

import jqdatasdk
import pandas as pd

from quant_v2.jq_fetcher import JqCredentials


SAMPLE_SECURITIES_FILE = _PLATFORM_ROOT / "scripts" / "jq_fetcher" / "benchmark_samples.txt"
REPORT_FILE = _PLATFORM_ROOT / "tmp" / "jq_speed_benchmark_report.txt"

# 若无样本文件，用这 50 只默认标的（沪深各 25 只 ETF + 股票）
DEFAULT_SAMPLES = [
    "510300.XSHG", "510050.XSHG", "510500.XSHG", "588000.XSHG", "512000.XSHG",
    "512010.XSHG", "512100.XSHG", "512660.XSHG", "512800.XSHG", "512880.XSHG",
    "515790.XSHG", "516160.XSHG", "518880.XSHG", "513050.XSHG", "513100.XSHG",
    "601318.XSHG", "600519.XSHG", "600036.XSHG", "601166.XSHG", "600276.XSHG",
    "600030.XSHG", "601398.XSHG", "600000.XSHG", "601628.XSHG", "601857.XSHG",
    "159915.XSHE", "159901.XSHE", "159949.XSHE", "159919.XSHE", "159937.XSHE",
    "159902.XSHE", "159938.XSHE", "159995.XSHE", "159981.XSHE", "159967.XSHE",
    "000001.XSHE", "000002.XSHE", "000333.XSHE", "000651.XSHE", "000858.XSHE",
    "002594.XSHE", "002475.XSHE", "002241.XSHE", "002415.XSHE", "002230.XSHE",
    "300750.XSHE", "300059.XSHE", "300015.XSHE", "300760.XSHE", "300999.XSHE",
]

DAILY_FIELDS = ["open", "close", "high", "low", "volume", "money", "factor"]
MINUTE_FIELDS = ["open", "close", "high", "low", "volume", "money"]


def load_samples() -> list[str]:
    if SAMPLE_SECURITIES_FILE.exists():
        lines = SAMPLE_SECURITIES_FILE.read_text(encoding="utf-8").strip().splitlines()
        return [ln.strip() for ln in lines if ln.strip() and not ln.startswith("#")]
    return DEFAULT_SAMPLES


def measure_single_daily(api, securities, start, end):
    """串行拉取日线，测每只标的延迟。"""
    latencies = []
    for sec in securities:
        t0 = time.time()
        api.get_price(sec, start_date=start, end_date=end,
                      frequency="daily", fields=DAILY_FIELDS, fq="pre", panel=False)
        latencies.append(time.time() - t0)
    return latencies


def measure_single_minute(api, securities, start, end):
    """串行拉取分钟线，测每只标的延迟。"""
    latencies = []
    for sec in securities:
        t0 = time.time()
        api.get_price(sec, start_date=start, end_date=end,
                      frequency="minute", fields=MINUTE_FIELDS, fq="pre", panel=False)
        latencies.append(time.time() - t0)
    return latencies


def measure_concurrent_4(fetcher, securities, start, end):
    """并发 4 线程拉取日线，测加速比。"""
    t0 = time.time()
    fetcher.fetch_price(
        securities, start_date=start, end_date=end,
        frequency="daily", task_name="benchmark_concurrent",
    )
    return time.time() - t0


def main():
    report_lines = []
    def log(msg):
        print(msg)
        report_lines.append(msg)

    log("=" * 60)
    log("jqdatasdk 速率实测（阶段 0 验收）")
    log("=" * 60)

    # 认证
    creds = JqCredentials.load()
    jqdatasdk.auth(creds.username, creds.password)
    qc = jqdatasdk.get_query_count()
    log(f"\n认证成功。配额: 总 {qc.get('total'):,}，剩余 {qc.get('spare'):,}")

    samples = load_samples()
    log(f"\n样本标的: {len(samples)} 只")

    api = jqdatasdk

    # 1. 日线延迟（11 年）
    log("\n--- 1. 日线查询延迟（11 年全历史）---")
    daily_lats = measure_single_daily(api, samples, "2014-01-01", "2024-12-31")
    avg_daily = sum(daily_lats) / len(daily_lats)
    log(f"单次日线平均延迟: {avg_daily:.3f} 秒")
    log(f"单次日线最大延迟: {max(daily_lats):.3f} 秒")
    log(f"单次日线最小延迟: {min(daily_lats):.3f} 秒")
    log(f"门槛 < 2 秒: {'通过' if avg_daily < 2.0 else '未达标'}")

    # 2. 分钟线延迟（1 个月）
    log("\n--- 2. 分钟线查询延迟（1 个月）---")
    minute_lats = measure_single_minute(api, samples[:20], "2024-11-01", "2024-11-30")
    avg_minute = sum(minute_lats) / len(minute_lats)
    log(f"单次分钟线平均延迟: {avg_minute:.3f} 秒")
    log(f"单次分钟线最大延迟: {max(minute_lats):.3f} 秒")
    log(f"门槛 < 3 秒: {'通过' if avg_minute < 3.0 else '未达标'}")

    # 3. 并发加速比
    log("\n--- 3. 并发 4 线程加速比 ---")
    from quant_v2.jq_fetcher import JqFetcher
    fetcher = JqFetcher(
        credentials=creds, api_client=api, max_workers=4,
        retry_max=2, retry_backoff=1.0,
    )
    # 串行基准（用前 20 只）
    serial_t0 = time.time()
    for sec in samples[:20]:
        api.get_price(sec, start_date="2024-01-01", end_date="2024-01-31",
                      frequency="daily", fields=DAILY_FIELDS, fq="pre", panel=False)
    serial_time = time.time() - serial_t0
    # 并发 4 线程（同 20 只）
    concurrent_time = measure_concurrent_4(fetcher, samples[:20], "2024-01-01", "2024-01-31")
    speedup = serial_time / concurrent_time if concurrent_time > 0 else 0
    log(f"串行 20 只: {serial_time:.2f} 秒")
    log(f"并发 4 线程 20 只: {concurrent_time:.2f} 秒")
    log(f"加速比: {speedup:.2f}x")
    log(f"门槛 >= 3.0x: {'通过' if speedup >= 3.0 else '未达标'}")

    # 4. 全量工期估算
    log("\n--- 4. 全量工期估算 ---")
    total_stocks = 7047
    total_months = 132  # 11 年
    # 分钟线总查询数
    total_minute_queries = total_stocks * total_months
    # 按并发 4 线程 + 实测延迟估算
    effective_latency = avg_minute / max(speedup, 1.0)
    total_seconds = total_minute_queries * effective_latency
    total_days = total_seconds / 86400
    log(f"全标的数: {total_stocks}")
    log(f"分钟线总查询数: {total_minute_queries:,}")
    log(f"并发 {4} 线程有效延迟: {effective_latency:.3f} 秒/次")
    log(f"分钟线全量拉取预估: {total_days:.1f} 天 ({total_days/7:.1f} 周)")
    log(f"门槛 <= 7 天: {'通过' if total_days <= 7 else '未达标(需主控决策)'}")

    # 5. 配额消耗估算
    log("\n--- 5. 配额消耗估算 ---")
    total_estimated_queries = total_minute_queries + total_stocks * 2  # 日线+估值等
    quota_pct = total_estimated_queries / qc.get("total", 1) * 100
    log(f"全量预估查询数: {total_estimated_queries:,}")
    log(f"占配额比: {quota_pct:.2f}%")

    # 写报告
    log("\n" + "=" * 60)
    log("实测完成。报告已写入: " + str(REPORT_FILE))
    REPORT_FILE.parent.mkdir(parents=True, exist_ok=True)
    REPORT_FILE.write_text("\n".join(report_lines), encoding="utf-8")


if __name__ == "__main__":
    main()
```

- [ ] **Step 3: 验证脚本能编译**

```bash
cd "E:/量化平台_V1.4.0"
.venv/Scripts/python -m py_compile scripts/jq_fetcher/jq_speed_benchmark.py
```

Expected: 无输出（编译成功）

- [ ] **Step 4: 运行速率实测（需凭证）**

设置凭证环境变量后运行（凭证由执行者提供，不入库）：

```bash
cd "E:/量化平台_V1.4.0"
# Windows CMD:
set JQ_USERNAME=<手机号>
set JQ_PASSWORD=<密码>
.venv/Scripts/python scripts/jq_fetcher/jq_speed_benchmark.py
```

Expected: 输出 5 个测量段的实测数值，报告写入 `tmp/jq_speed_benchmark_report.txt`。

**验收判断**：检查报告中的门槛是否达标：
- 日线延迟 < 2 秒
- 分钟线延迟 < 3 秒
- 并发加速比 >= 3.0x
- 全量分钟线工期 <= 7 天

若"全量工期 <= 7 天"未达标，在实验记录中标记风险并提请主控决策（用户已选"分钟线也纯 API 拉取"，故为风险记录而非方案变更）。

- [ ] **Step 5: 提交**

```bash
cd "E:/量化平台_V1.4.0"
git add scripts/jq_fetcher/__init__.py scripts/jq_fetcher/jq_speed_benchmark.py
git commit -m "feat(jq_fetcher): 添加速率实测脚本(Task 5, 阶段0验收)

- 测量日线/分钟线延迟、并发加速比、全量工期估算
- 50只样本标的, 11年日线+1月分钟线
- 报告写入tmp/jq_speed_benchmark_report.txt
- 阶段0验收硬门槛的实证依据"
```

- [ ] **Step 6: 记录阶段 0 验收结论**

将速率实测报告的关键结论（5 个门槛是否达标、全量工期天数、配额占比）记录到研究库实验记录 `EX-JQDB-S0`（阶段 0 验收实验，按规格 §5.1 用 `New-ResearchItem.ps1` 创建）。若 6 项验收门槛（规格 §2.8）全部通过，阶段 0 标记完成，进入阶段 1 实现计划。

---

## 阶段 0 验收门槛对照（规格 §2.8）

| # | 门槛 | 对应任务 | 验证方式 |
| --- | --- | --- | --- |
| 1 | jqdatasdk 成功安装并 auth() 通过 | Task 1 Step 11 + Task 5 Step 4 | `import jqdatasdk` 无异常，get_query_count() 返回剩余配额 |
| 2 | JqFetcher 能拉取日线/分钟线各 1 只标的 1 段数据 | Task 4 测试 + Task 5 实测 | test_fetcher.py 通过 + benchmark 实际拉到数据 |
| 3 | checkpoint 断点续传工作 | Task 2 + Task 4 `test_checkpoint_skips_completed_on_resume` | 测试通过 |
| 4 | 配额监控触发 | Task 3 + Task 4 `_log_progress` | test_quota.py 通过 + benchmark 输出配额 |
| 5 | 速率实测报告产出 | Task 5 | tmp/jq_speed_benchmark_report.txt 含全部 5 段指标 |
| 6 | 凭证不入库 | Task 1 Step 10 | git check-ignore 覆盖测试通过 |

---

## 实施顺序总结

```
Task 1（依赖接入+凭证管理+gitignore）
  → Task 2（Checkpoint 断点续传）
  → Task 3（QuotaMonitor 配额监控）
  → Task 4（JqFetcher 拉取核心，整合 1-3）
  → Task 5（速率实测脚本，阶段 0 验收）
```

Task 1-4 可由子代理并行/串行执行（有依赖：4 依赖 1-3）。Task 5 必须在 1-4 完成后执行（需要真实凭证）。
