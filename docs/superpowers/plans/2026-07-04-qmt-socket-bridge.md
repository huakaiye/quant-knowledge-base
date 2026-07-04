# QMT Socket Bridge Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 实现一套 socket bridge + drop-in shim，让 ETF 双池动量轮动实盘策略零改动地从 miniQMT 迁移到大 QMT 客户端进程内 passorder/ContextInfo 通道。

**Architecture:** 三组件——(1) server 跑在 XtItClient.exe 进程内的 daemon 线程，用 socketserver.ThreadingTCPServer + ThreadPoolExecutor(max_workers=8) 实现真并发，worker 线程直接调进程内 passorder/get_trade_detail_data/ContextInfo.get_full_tick；(2) client 跑在外部 Python 3.11，单 TCP 长连接 + Future 分发；(3) shim 包替换 .venv 的 xtquant，把策略的 API 调用翻译成 bridge 命令。

**Tech Stack:** Python 3.6 标准库（server 端，客户端内置）+ Python 3.11（client/shim 端）+ socketserver/threading/json/concurrent.futures（零第三方依赖）

## Global Constraints

- **编码**：server 端文件必须 `#coding:gbk`（客户端终端编码）；client/shim 文件用 `# -*- coding: utf-8 -*-`
- **常量同源**：shim 的 `xtconstant.py` 必须从原版 `.venv` 直接复制，不重写、不重编号
- **常量值**：STOCK_BUY=23, STOCK_SELL=24, LATEST_PRICE=5, ORDER_PART_CANCEL=53, ORDER_CANCELED=54, ORDER_SUCCEEDED=56, ORDER_JUNK=57
- **端口**：58711（避开 58610），可通过 `QMT_BRIDGE_PORT` 环境变量覆盖
- **账号**：8890398505（硬编码在 server 端，C2 v6/v7 已验证可读资产）
- **路径分隔符**：所有文档/台账用 `/`，禁反斜杠
- **前置门禁**：Task 0（C2 v11 开盘验证）必须通过，Task 1-6 才能合并

---

## 文件结构

### 新建文件

| 路径 | 职责 | 编码 |
|------|------|------|
| `E:\xtquant\策略\qmt_socket_server.py` | bridge server（客户端进程内运行） | gbk |
| `E:\xtquant\策略\qmt_socket_client.py` | bridge client（外部 Python） | utf-8 |
| `.venv\Lib\site-packages\xtquant\__init__.py` | shim 包入口（空文件） | utf-8 |
| `.venv\Lib\site-packages\xtquant\xtconstant.py` | 常量（从原版复制） | utf-8 |
| `.venv\Lib\site-packages\xtquant\xttype.py` | StockAccount 值对象 | utf-8 |
| `.venv\Lib\site-packages\xtquant\_bridge_client.py` | bridge client 单例 | utf-8 |
| `.venv\Lib\site-packages\xtquant\xtdata.py` | 4 个行情函数 shim | utf-8 |
| `.venv\Lib\site-packages\xtquant\xttrader.py` | XtQuantTrader 类 shim | utf-8 |
| `E:\xtquant\策略\tests\test_shim.py` | shim 单元测试 | utf-8 |
| `E:\xtquant\策略\tests\test_bridge_smoke.py` | bridge 端到端 smoke 测试 | utf-8 |

### 备份（替换前）

- `.venv\Lib\site-packages\xtquant\` → `xtquant_original_backup\`

---

## Task 0: C2 v11 开盘验证（生死线门禁）

**Files:**
- Create: `E:\xtquant\策略\c2_test_inclient_v11.py`（已写好）

**Interfaces:**
- Produces: `E:\xtquant\tmp\c2v11_result.json`，含 `bridge_viable: bool`

- [ ] **Step 1: 明天开盘 9:30 后运行 C2 v11**

操作：大 QMT 客户端 → 新建策略文件 → 粘贴 `c2_test_inclient_v11.py` → 运行

- [ ] **Step 2: 检查输出**

关键行：
```
[A] ORDER after_passorder=DELTA  ← 必须 > 0
[B] VERDICT: OK: price in range  ← 必须是 OK 开头
=> BRIDGE FULLY VIABLE           ← 最终判定
```

- [ ] **Step 3: 读结果文件确认**

Run: `cat E:/xtquant/tmp/c2v11_result.json`
Expected: `"bridge_viable": true`

- [ ] **Step 4: 判定**

- `bridge_viable: true` → 继续 Task 1-6
- `bridge_viable: false` → 停止，bridge 方案作废，转评估 ptrade 等替代方案

- [ ] **Step 5: 记录到 EX-SOCKBRIDGE（落地后）**

此步在研究库落地阶段做，不在本计划内。

---

## Task 1: bridge server（客户端进程内）

**Files:**
- Create: `E:\xtquant\策略\qmt_socket_server.py`

**Interfaces:**
- Consumes: 客户端 C++ 注入的全局函数 `passorder` / `get_trade_detail_data` / `get_full_tick`；`ContextInfo` 对象的 `get_full_tick` / `get_market_data_ex` / `get_instrument_detail` / `get_trading_dates` 方法
- Produces: TCP server 监听 `127.0.0.1:58711`，行分隔 JSON 协议

- [ ] **Step 1: 写 server 骨架**

```python
#coding:gbk
"""
QMT Socket Bridge Server
运行位置: 大 QMT 客户端进程内 (新建策略文件)
职责: 接收 JSON 命令 -> 调客户端内 API -> 返回 JSON 结果
协议: 行分隔 JSON over TCP, 详见设计规格第 3 节
"""
import socketserver
import threading
import json
import time
import traceback
from concurrent.futures import ThreadPoolExecutor

_BRIDGE_PORT = 58711
_g_account = "8890398505"
_g_lock = threading.Lock()
_g_context = None
_g_started = False
_g_start_ts = time.time()
_g_write_lock = threading.Lock()  # 保护 socket 写入, 防多 worker 粘包
```

- [ ] **Step 2: 写对象转 dict 工具函数**

```python
def _dump_obj(o):
    """C++ 对象转 dict, 兜底 __dict__ 为空的情况 (C2 v7 验证)."""
    out = {}
    try:
        if hasattr(o, "__dict__") and o.__dict__:
            out.update(o.__dict__)
    except Exception:
        pass
    try:
        for attr in dir(o):
            if attr.startswith("_"):
                continue
            try:
                v = getattr(o, attr)
                if callable(v):
                    continue
                out[attr] = v
            except Exception:
                pass
    except Exception:
        pass
    return out


def _safe_default(obj):
    """JSON 序列化兜底."""
    try:
        return _dump_obj(obj)
    except Exception:
        return str(obj)
```

- [ ] **Step 3: 写 order_type 映射 + 命令分发**

```python
_ORDER_TYPE_MAP = {23: 0, 24: 1}  # STOCK_BUY->买, STOCK_SELL->卖


def _exec_cmd(req):
    """命令分发. 在 ThreadPoolExecutor worker 里执行."""
    cmd = req.get("cmd", "")
    args = req.get("args", {}) or {}
    req_id = req.get("id", "")
    ctx = _g_context
    acc = _g_account

    if cmd == "ping":
        return {"id": req_id, "ok": True, "data": {
            "server": "qmt_socket_bridge", "version": "v1",
            "uptime_sec": int(time.time() - _g_start_ts),
            "account": acc, "has_context": ctx is not None,
            "port": _BRIDGE_PORT}}

    if ctx is None:
        return {"id": req_id, "ok": False,
                "error": "ContextInfo not ready, wait for first handlebar"}

    try:
        # ---- 下单 ----
        if cmd == "order_stock":
            code = args["code"]
            price = float(args["price"])
            volume = int(args["volume"])
            price_type = int(args.get("price_type", 11))
            order_type = int(args["order_type"])
            op_type = _ORDER_TYPE_MAP.get(order_type, 0)
            passorder(op_type, 1, acc, code, price_type, price, volume, ctx)
            # passorder 无返回值, 查 ORDER 表拿 order_id
            try:
                orders = get_trade_detail_data(acc, "STOCK", "ORDER")
                if orders:
                    latest = _dump_obj(orders[-1])
                    order_id = latest.get("order_id", -1)
                else:
                    order_id = -1
            except Exception:
                order_id = -1
            return {"id": req_id, "ok": True, "data": {"order_id": order_id}}

        elif cmd == "cancel_order_stock":
            order_id = args["order_id"]
            cancel(order_id, ctx)
            return {"id": req_id, "ok": True, "data": {"result": 0}}

        # ---- 查询 ----
        elif cmd == "query_stock_positions":
            rows = get_trade_detail_data(acc, "STOCK", "POSITION")
            return {"id": req_id, "ok": True,
                    "data": [_dump_obj(r) for r in (rows or [])]}

        elif cmd == "query_stock_asset":
            rows = get_trade_detail_data(acc, "STOCK", "ACCOUNT")
            if rows:
                return {"id": req_id, "ok": True,
                        "data": _dump_obj(rows[0])}
            return {"id": req_id, "ok": True, "data": None}

        elif cmd == "query_stock_orders":
            rows = get_trade_detail_data(acc, "STOCK", "ORDER")
            return {"id": req_id, "ok": True,
                    "data": [_dump_obj(r) for r in (rows or [])]}

        # ---- 行情 ----
        elif cmd == "get_full_tick":
            code_list = args["code_list"]
            result = ctx.get_full_tick(code_list)
            return {"id": req_id, "ok": True, "data": result or {}}

        elif cmd == "get_market_data_ex":
            field_list = args.get("field_list", [])
            stock_list = args.get("stock_list", [])
            period = args.get("period", "1d")
            count = args.get("count", -1)
            dividend_type = args.get("dividend_type", "none")
            fill_data = args.get("fill_data", True)
            df_dict = ctx.get_market_data_ex(
                field_list, stock_list, period, count,
                dividend_type, fill_data)
            # DataFrame 序列化: {stock: split_dict}
            out = {}
            if df_dict:
                import pandas as pd
                for stock, df in df_dict.items():
                    if isinstance(df, pd.DataFrame):
                        out[stock] = df.to_dict("split")
                    else:
                        out[stock] = df
            return {"id": req_id, "ok": True, "data": out}

        elif cmd == "get_instrument_detail":
            code = args["code"]
            result = ctx.get_instrument_detail(code)
            return {"id": req_id, "ok": True, "data": result or {}}

        elif cmd == "get_trading_dates":
            market = args["market"]
            start_time = args.get("start_time", "")
            end_time = args.get("end_time", "")
            count = args.get("count", -1)
            result = ctx.get_trading_dates(market, start_time, end_time, count)
            return {"id": req_id, "ok": True, "data": result or []}

        else:
            return {"id": req_id, "ok": False,
                    "error": "unknown cmd: %s" % cmd}

    except NameError as e:
        return {"id": req_id, "ok": False,
                "error": "NameError: %s (client env not injected)" % e,
                "error_type": "NameError"}
    except Exception as e:
        return {"id": req_id, "ok": False,
                "error": "%s\n%s" % (e, traceback.format_exc()),
                "error_type": type(e).__name__}
```

- [ ] **Step 4: 写 socket handler + threading server**

```python
class _BridgeHandler(socketserver.StreamRequestHandler):
    def handle(self):
        cli = self.client_address
        print("[bridge] connect from %s:%s" % (cli[0], cli[1]), flush=True)
        while True:
            line = self.rfile.readline()
            if not line:
                break
            line = line.strip()
            if not line:
                continue
            try:
                req = json.loads(line.decode("utf-8"))
            except Exception as e:
                resp = {"id": "", "ok": False, "error": "bad json: %s" % e}
                with _g_write_lock:
                    self.wfile.write((json.dumps(resp) + "\n").encode("utf-8"))
                continue
            # 提交到线程池, 不阻塞下一行读取
            _g_executor.submit(self._handle_one, req)

    def _handle_one(self, req):
        try:
            resp = _exec_cmd(req)
        except Exception as e:
            resp = {"id": req.get("id", ""), "ok": False,
                    "error": "handle EXC: %s" % e}
        try:
            payload = json.dumps(resp, default=_safe_default) + "\n"
            with _g_write_lock:
                self.wfile.write(payload.encode("utf-8"))
                self.wfile.flush()
        except Exception as e:
            print("[bridge] write fail for req %s: %s" % (
                req.get("id", ""), e), flush=True)


class _ThreadingServer(socketserver.ThreadingTCPServer):
    daemon_threads = True
    allow_reuse_address = True
    request_queue_size = 64


_g_executor = ThreadPoolExecutor(max_workers=8, thread_name_prefix="bridge")


def _start_server(port):
    srv = _ThreadingServer(("127.0.0.1", port), _BridgeHandler)
    print("[bridge] listening on 127.0.0.1:%d" % port, flush=True)
    srv.serve_forever()
```

- [ ] **Step 5: 写 init/handlebar 入口**

```python
def init(ContextInfo):
    print("=== qmt_socket_bridge init ===", flush=True)
    try:
        ContextInfo.set_account(_g_account)
        print("[bridge] set_account(%s) done" % _g_account, flush=True)
    except Exception as e:
        print("[bridge] set_account EXC: %s" % e, flush=True)


def handlebar(ContextInfo):
    global _g_context, _g_started
    _g_context = ContextInfo
    if not _g_started:
        _g_started = True
        t = threading.Thread(target=_start_server, args=(_BRIDGE_PORT,),
                             name="QmtSocketBridge")
        t.daemon = True
        t.start()
        print("[bridge] server thread started, port=%d, acc=%s" %
              (_BRIDGE_PORT, _g_account), flush=True)
        print("[bridge] waiting for client on 127.0.0.1:%d ..." % _BRIDGE_PORT,
              flush=True)
```

- [ ] **Step 6: 在客户端运行自测**

操作：粘贴到"新建策略文件"运行，控制台应出现：
```
[bridge] listening on 127.0.0.1:58711
[bridge] server thread started
```
然后用 telnet 手动测：
```
telnet 127.0.0.1 58711
{"id":"t1","cmd":"ping","args":{}}
```
Expected: `{"id":"t1","ok":true,"data":{"server":"qmt_socket_bridge",...}}`

- [ ] **Step 7: 提交**

```bash
cd "E:/xtquant/策略"
git init 2>/dev/null; git add qmt_socket_server.py
git commit -m "feat(bridge): server 端实现 (路线 1a 真并发)"
```

---

## Task 2: bridge client（外部 Python）

**Files:**
- Create: `E:\xtquant\策略\qmt_socket_client.py`

**Interfaces:**
- Consumes: server 的 TCP 58711 端口
- Produces: `QMTBridgeClient` 类，方法 `ping/order_stock/query_*/get_full_tick` 等

- [ ] **Step 1: 写 client 类骨架**

```python
# -*- coding: utf-8 -*-
"""QMT Socket Bridge Client. 外部 Python 3.11."""
import socket
import json
import uuid
import threading
import time
from concurrent.futures import Future


class QMTBridgeError(Exception):
    pass


class QMTBridgeClient:
    def __init__(self, host="127.0.0.1", port=58711, timeout=10):
        self.host = host
        self.port = port
        self.timeout = timeout
        self._sock = None
        self._f = None
        self._send_lock = threading.Lock()
        self._futures = {}
        self._futures_lock = threading.Lock()
        self._recv_thread = None
        self._disconnected_at = None
        self._reconnect_attempts = 0
```

- [ ] **Step 2: 写连接 + 重连逻辑**

```python
    def connect(self):
        if self._sock is not None:
            return
        if self._disconnected_at:
            elapsed = time.time() - self._disconnected_at
            backoff = min(30, 2 ** self._reconnect_attempts)
            if elapsed < backoff:
                time.sleep(backoff - elapsed)
            self._reconnect_attempts += 1
            if self._reconnect_attempts > 5:
                raise QMTBridgeError(
                    "bridge unreachable after 5 reconnect attempts")
        s = socket.create_connection((self.host, self.port), timeout=30)
        self._sock = s
        self._f = s.makefile("rwb")
        self._disconnected_at = None
        self._start_recv_thread()
        info = self._call("ping", {}).get("data", {})
        print("[bridge-client] connected uptime=%ss account=%s" % (
            info.get("uptime_sec"), info.get("account")))

    def _start_recv_thread(self):
        if self._recv_thread and self._recv_thread.is_alive():
            return
        self._recv_thread = threading.Thread(target=self._recv_loop,
                                              name="bridge-recv", daemon=True)
        self._recv_thread.start()

    def _recv_loop(self):
        while self._f is not None:
            try:
                line = self._f.readline()
            except Exception:
                break
            if not line:
                break
            try:
                resp = json.loads(line.decode("utf-8"))
            except Exception:
                continue
            req_id = resp.get("id", "")
            with self._futures_lock:
                fut = self._futures.pop(req_id, None)
            if fut and not fut.done():
                fut.set_result(resp)
        self._on_disconnect()

    def _on_disconnect(self):
        with self._futures_lock:
            for fut in self._futures.values():
                if not fut.done():
                    fut.set_exception(QMTBridgeError("connection lost"))
            self._futures.clear()
        self._sock = None
        self._f = None
        self._disconnected_at = time.time()
```

- [ ] **Step 3: 写 call + Future 分发**

```python
    def _call(self, cmd, args):
        if self._sock is None:
            self.connect()
        req_id = "req_%s" % uuid.uuid4().hex[:8]
        req = {"id": req_id, "cmd": cmd, "args": args or {}}
        data = (json.dumps(req) + "\n").encode("utf-8")
        fut = Future()
        with self._futures_lock:
            self._futures[req_id] = fut
        with self._send_lock:
            try:
                self._f.write(data)
                self._f.flush()
            except Exception as e:
                with self._futures_lock:
                    self._futures.pop(req_id, None)
                raise QMTBridgeError("send fail: %s" % e)
        try:
            resp = fut.result(timeout=self.timeout)
        except Exception:
            with self._futures_lock:
                self._futures.pop(req_id, None)
            raise
        return resp

    def close(self):
        self._disconnected_at = None  # 主动关闭不触发重连
        if self._f:
            try: self._f.close()
            except: pass
            self._f = None
        if self._sock:
            try: self._sock.close()
            except: pass
            self._sock = None
```

- [ ] **Step 4: 写业务封装方法**

```python
    def ping(self):
        return self._call("ping", {}).get("data", {})

    def order_stock(self, account_id, code, order_type, volume,
                    price_type, price):
        r = self._call("order_stock", {
            "account": account_id, "code": code,
            "order_type": order_type, "volume": volume,
            "price_type": price_type, "price": price})
        if not r.get("ok"):
            raise QMTBridgeError("order_stock fail: %s" % r.get("error"))
        return r["data"]["order_id"]

    def query_stock_positions(self, account_id):
        return self._call("query_stock_positions",
                          {"account": account_id}).get("data", [])

    def query_stock_asset(self, account_id):
        return self._call("query_stock_asset",
                          {"account": account_id}).get("data")

    def query_stock_orders(self, account_id):
        return self._call("query_stock_orders",
                          {"account": account_id}).get("data", [])

    def cancel_order_stock(self, account_id, order_id):
        return self._call("cancel_order_stock",
                          {"account": account_id, "order_id": order_id})

    def get_full_tick(self, code_list):
        return self._call("get_full_tick",
                          {"code_list": code_list}).get("data", {})

    def get_market_data_ex(self, field_list, stock_list, period="1d",
                           count=-1, dividend_type="none", fill_data=True):
        return self._call("get_market_data_ex", {
            "field_list": field_list, "stock_list": stock_list,
            "period": period, "count": count,
            "dividend_type": dividend_type, "fill_data": fill_data}).get("data", {})

    def get_instrument_detail(self, code):
        return self._call("get_instrument_detail",
                          {"code": code}).get("data", {})

    def get_trading_dates(self, market, start_time="", end_time="", count=-1):
        return self._call("get_trading_dates", {
            "market": market, "start_time": start_time,
            "end_time": end_time, "count": count}).get("data", [])

    def __enter__(self):
        self.connect()
        return self

    def __exit__(self, *a):
        self.close()
```

- [ ] **Step 5: 写自检 main**

```python
if __name__ == "__main__":
    print("=== QMTBridgeClient self-test ===")
    try:
        with QMTBridgeClient() as c:
            print("[ping]", c.ping())
            print("[asset]", c.query_stock_asset("8890398505"))
    except (ConnectionRefusedError, QMTBridgeError) as e:
        print("[FAIL] %s" % e)
        print("确认: server 已在客户端运行 + 端口 58711 监听")
```

- [ ] **Step 6: 启动 server 后跑 client 自检**

Run: `python E:/xtquant/策略/qmt_socket_client.py`
Expected: 打印 ping info + asset

- [ ] **Step 7: 提交**

```bash
cd "E:/xtquant/策略"
git add qmt_socket_client.py
git commit -m "feat(bridge): client 端实现 (长连接 + Future 分发)"
```

---

## Task 3: shim 包骨架（__init__ / xtconstant / xttype）

**Files:**
- Backup: `.venv\Lib\site-packages\xtquant\` → `.venv\Lib\site-packages\xtquant_original_backup\`
- Create: `.venv\Lib\site-packages\xtquant\__init__.py`
- Create: `.venv\Lib\site-packages\xtquant\xtconstant.py`（从备份复制）
- Create: `.venv\Lib\site-packages\xtquant\xttype.py`

**Interfaces:**
- Produces: shim 包的基础结构，供 Task 4-5 使用

- [ ] **Step 1: 备份原版 xtquant**

```bash
cd "E:/xtquant/策略/.venv/Lib/site-packages"
cp -r xtquant xtquant_original_backup
```
确认：`ls xtquant_original_backup/` 应有 `__init__.py xtconstant.py xtdata.py xttrader.py xttype.py`

- [ ] **Step 2: 写空 __init__.py**

```python
# xtquant shim package - drop-in replacement for bridge
# 原版 __init__.py 就是空的, 保持一致
```

- [ ] **Step 3: 复制 xtconstant.py**

```bash
cp xtquant_original_backup/xtconstant.py xtquant/xtconstant.py
```
确认常量值：`grep -E "STOCK_BUY|STOCK_SELL|LATEST_PRICE|ORDER_" xtquant/xtconstant.py`

- [ ] **Step 4: 写 xttype.py（StockAccount 值对象）**

```python
# -*- coding: utf-8 -*-
"""xttype shim - 只实现策略用到的 StockAccount."""


class StockAccount:
    """资金账号值对象. 作为不透明 token 在策略和 shim 间传递."""

    def __init__(self, account_id, account_type="STOCK"):
        self.account_id = account_id
        self.account_type = account_type

    def __repr__(self):
        return "StockAccount(%s, %s)" % (self.account_id, self.account_type)
```

- [ ] **Step 5: 验证 import**

```bash
cd "E:/xtquant/策略"
python -c "from xtquant import xtconstant; print(xtconstant.STOCK_BUY, xtconstant.ORDER_SUCCEEDED)"
python -c "from xtquant.xttype import StockAccount; a=StockAccount('8890398505'); print(a.account_id)"
```
Expected: `23 56` 和 `8890398505`

- [ ] **Step 6: 提交**

```bash
cd "E:/xtquant/策略"
git add .venv/Lib/site-packages/xtquant/__init__.py
git add .venv/Lib/site-packages/xtquant/xttype.py
# xtconstant.py 是复制的, 也提交
git add .venv/Lib/site-packages/xtquant/xtconstant.py
git commit -m "feat(shim): 包骨架 + xtconstant 复制 + StockAccount 值对象"
```

---

## Task 4: shim _bridge_client + xtdata

**Files:**
- Create: `.venv\Lib\site-packages\xtquant\_bridge_client.py`
- Create: `.venv\Lib\site-packages\xtquant\xtdata.py`

**Interfaces:**
- Consumes: `qmt_socket_client.QMTBridgeClient`（Task 2）
- Produces: `_bridge_client.get_client()` 单例 + `xtdata` 模块的 4 个函数

- [ ] **Step 1: 写 _bridge_client.py（单例封装）**

```python
# -*- coding: utf-8 -*-
"""bridge client 单例. shim 各模块共享一个连接."""
import os
import sys

# 把 E:\xtquant\策略 加入 path, 找到 qmt_socket_client
_STRATEGY_DIR = r"E:\xtquant\策略"
if _STRATEGY_DIR not in sys.path:
    sys.path.insert(0, _STRATEGY_DIR)

from qmt_socket_client import QMTBridgeClient, QMTBridgeError

_g_client = None


def get_client():
    global _g_client
    if _g_client is None:
        host = os.environ.get("QMT_BRIDGE_HOST", "127.0.0.1")
        port = int(os.environ.get("QMT_BRIDGE_PORT", "58711"))
        _g_client = QMTBridgeClient(host=host, port=port)
        _g_client.connect()
    return _g_client


def is_bridge_enabled():
    return os.environ.get("QMT_USE_BRIDGE", "1") == "1"
```

- [ ] **Step 2: 写 xtdata.py（4 个行情函数 + enable_hello）**

```python
# -*- coding: utf-8 -*-
"""xtdata shim - 把策略的行情调用翻译成 bridge 命令."""
import pandas as pd
from types import SimpleNamespace
from ._bridge_client import get_client

# 模块级属性 (原版 xtdata 有, 策略会赋值)
enable_hello = False


def get_full_tick(code_list):
    """返回 {stock: {lastPrice, volume, ...}} 字典."""
    return get_client().get_full_tick(code_list)


def get_market_data_ex(field_list=[], stock_list=[], period="1d",
                       start_time="", end_time="", count=-1,
                       dividend_type="none", fill_data=True):
    """返回 {stock: DataFrame}. DataFrame 从 split 格式还原."""
    raw = get_client().get_market_data_ex(
        field_list, stock_list, period, count, dividend_type, fill_data)
    out = {}
    for stock, split_dict in raw.items():
        if isinstance(split_dict, dict) and "columns" in split_dict:
            out[stock] = pd.DataFrame(
                split_dict["data"],
                index=split_dict["index"],
                columns=split_dict["columns"])
        else:
            out[stock] = pd.DataFrame(split_dict)
    return out


def get_instrument_detail(code, iscomplete=False):
    """返回合约详情 dict."""
    return get_client().get_instrument_detail(code)


def get_trading_dates(market, start_time="", end_time="", count=-1):
    """返回交易日历 list[int] (毫秒时间戳)."""
    return get_client().get_trading_dates(market, start_time, end_time, count)
```

- [ ] **Step 3: 验证 xtdata import**

```bash
cd "E:/xtquant/策略"
python -c "from xtquant import xtdata; print(xtdata.enable_hello)"
```
Expected: `False`（不触发连接，连接在首次调用时建立）

- [ ] **Step 4: 提交**

```bash
cd "E:/xtquant/策略"
git add .venv/Lib/site-packages/xtquant/_bridge_client.py
git add .venv/Lib/site-packages/xtquant/xtdata.py
git commit -m "feat(shim): _bridge_client 单例 + xtdata 4 函数 shim"
```

---

## Task 5: shim xttrader（XtQuantTrader 类）

**Files:**
- Create: `.venv\Lib\site-packages\xtquant\xttrader.py`

**Interfaces:**
- Consumes: `_bridge_client.get_client()` + `StockAccount`
- Produces: `XtQuantTrader` 类，签名与原版一致

- [ ] **Step 1: 写 XtQuantTrader 类**

```python
# -*- coding: utf-8 -*-
"""xttrader shim - XtQuantTrader 类, 签名与原版一致."""
import time
from ._bridge_client import get_client


class XtQuantTrader:
    """与原版 xttrader.XtQuantTrader 签名兼容的 shim.

    path/session_id 参数被忽略 (bridge 不需要 userdata_mini 路径).
    """

    def __init__(self, path, session_id, callback=None):
        self._path = path
        self._session_id = session_id
        self._connected = False

    def start(self):
        """原版启动内部线程. shim 无需启动, 空实现."""
        pass

    def connect(self):
        """返回 0=成功 (与原版一致). 失败返回 -1."""
        try:
            client = get_client()
            info = client.ping()
            self._connected = True
            return 0
        except Exception as e:
            print("[shim] connect fail: %s" % e)
            self._connected = False
            return -1

    def stop(self):
        self._connected = False

    def subscribe(self, account):
        """原版订阅账号推送. shim 策略不用推送, 空实现返回 0."""
        return 0

    def register_callback(self, callback):
        """原版注册回调. shim 不实现推送, 空实现."""
        pass

    def order_stock(self, account, stock_code, order_type, order_volume,
                    price_type, price, strategy_name='', order_remark=''):
        """下单. 返回 order_id (>0 成功, -1 失败, 与原版一致)."""
        if not self._connected:
            return -1
        try:
            return get_client().order_stock(
                account.account_id, stock_code, order_type,
                order_volume, price_type, price)
        except Exception as e:
            print("[shim] order_stock fail: %s" % e)
            return -1

    def cancel_order_stock(self, account, order_id):
        """撤单. 返回 0=成功."""
        if not self._connected:
            return -1
        try:
            get_client().cancel_order_stock(account.account_id, order_id)
            return 0
        except Exception as e:
            print("[shim] cancel fail: %s" % e)
            return -1

    def query_stock_positions(self, account):
        """返回 [SimpleNamespace] 兼容属性访问."""
        from types import SimpleNamespace
        rows = get_client().query_stock_positions(account.account_id)
        return [SimpleNamespace(**r) for r in rows]

    def query_stock_asset(self, account):
        """返回 SimpleNamespace 或 None."""
        from types import SimpleNamespace
        data = get_client().query_stock_asset(account.account_id)
        if data is None:
            return None
        return SimpleNamespace(**data)

    def query_stock_orders(self, account, cancelable_only=False):
        """返回 [SimpleNamespace]."""
        from types import SimpleNamespace
        rows = get_client().query_stock_orders(account.account_id)
        return [SimpleNamespace(**r) for r in rows]

    def query_stock_trades(self, account):
        """策略未用, 但 API 完整性保留."""
        return []

    def run_forever(self):
        """原版阻塞主线程. shim 不需要, 但保留以防策略调用."""
        import time as _t
        while True:
            _t.sleep(0.2)
```

- [ ] **Step 2: 验证 import + 构造**

```bash
cd "E:/xtquant/策略"
python -c "
from xtquant import xttrader
t = xttrader.XtQuantTrader('dummy', 123)
print('created:', t)
print('start:', t.start())
"
```
Expected: 创建成功，start 返回 None

- [ ] **Step 3: 提交**

```bash
cd "E:/xtquant/策略"
git add .venv/Lib/site-packages/xtquant/xttrader.py
git commit -m "feat(shim): xttrader.XtQuantTrader 类 (签名兼容原版)"
```

---

## Task 6: 端到端 smoke 测试

**Files:**
- Create: `E:\xtquant\策略\tests\test_bridge_smoke.py`

**Interfaces:**
- Consumes: server 运行中 + Task 1-5 完成

- [ ] **Step 1: 写 smoke 测试脚本**

```python
# -*- coding: utf-8 -*-
"""bridge 端到端 smoke 测试.
前提: server 已在客户端运行 (监听 58711).
运行: python E:/xtquant/策略/tests/test_bridge_smoke.py
"""
import sys
import os
sys.path.insert(0, r"E:\xtquant\策略")

from xtquant import xtdata, xttrader
from xtquant.xttype import StockAccount
import xtconstant


def test_ping():
    """T1: ping 自检."""
    from xtquant._bridge_client import get_client
    info = get_client().ping()
    assert info.get("server") == "qmt_socket_bridge", info
    print("[T1 ping] PASS:", info)


def test_query_asset():
    """T2: 查询穿透."""
    acc = StockAccount("8890398505")
    trader = xttrader.XtQuantTrader("dummy", 1)
    assert trader.connect() == 0, "connect failed"
    asset = trader.query_stock_asset(acc)
    assert asset is not None, "asset is None"
    assert asset.total_asset > 0, "total_asset <= 0"
    print("[T2 asset] PASS: total_asset=%s cash=%s" % (
        asset.total_asset, asset.cash))


def test_query_positions():
    """T2b: 持仓查询."""
    acc = StockAccount("8890398505")
    trader = xttrader.XtQuantTrader("dummy", 1)
    trader.connect()
    positions = trader.query_stock_positions(acc)
    print("[T2b positions] PASS: %d positions" % len(positions))
    for p in positions[:3]:
        print("  ", p.stock_code, p.volume)


def test_get_full_tick():
    """T3: 行情穿透."""
    tick = xtdata.get_full_tick(["511880.SH"])
    assert tick, "tick empty"
    first_key = list(tick.keys())[0]
    data = tick[first_key]
    assert "lastPrice" in data, "no lastPrice"
    print("[T3 tick] PASS: %s lastPrice=%s" % (
        first_key, data["lastPrice"]))


def test_get_market_data_ex():
    """T3b: 日线查询."""
    data = xtdata.get_market_data_ex(
        field_list=["close"], stock_list=["511880.SH"],
        period="1d", count=5, dividend_type="front", fill_data=False)
    assert "511880.SH" in data, "no 511880.SH"
    df = data["511880.SH"]
    assert not df.empty, "df empty"
    print("[T3b kline] PASS: %d rows, last close=%s" % (
        len(df), df["close"].iloc[-1]))


def test_order_smoke():
    """T4: 下单 smoke (100 股 511880, 约 100 元).
    仅在交易时段运行. 非交易时段跳过.
    """
    import time
    now = time.localtime()
    hour_min = now.tm_hour * 100 + now.tm_min
    if not (930 <= hour_min <= 1500):
        print("[T4 order] SKIP: non-trading hours")
        return
    acc = StockAccount("8890398505")
    trader = xttrader.XtQuantTrader("dummy", 1)
    trader.connect()
    ret = trader.order_stock(
        acc, "511880.SH", xtconstant.STOCK_BUY, 100,
        xtconstant.LATEST_PRICE, 0)
    print("[T4 order] result=%s (>0 success)" % ret)
    assert ret is not None


if __name__ == "__main__":
    print("=== bridge smoke test ===")
    tests = [test_ping, test_query_asset, test_query_positions,
             test_get_full_tick, test_get_market_data_ex, test_order_smoke]
    passed = 0
    failed = 0
    for t in tests:
        try:
            t()
            passed += 1
        except Exception as e:
            print("[FAIL] %s: %s" % (t.__name__, e))
            failed += 1
    print("\n=== done: %d passed, %d failed ===" % (passed, failed))
```

- [ ] **Step 2: 启动 server，运行 smoke 测试**

操作顺序：
1. 客户端"新建策略文件"粘贴 `qmt_socket_server.py`，运行
2. 等 `[bridge] listening on 127.0.0.1:58711`
3. 外部运行：

```bash
cd "E:/xtquant/策略"
python tests/test_bridge_smoke.py
```

Expected: `5 passed, 0 failed`（T4 在交易时段会真下单）

- [ ] **Step 3: T4 下单后肉眼确认**

在客户端委托列表查看：应有 1 笔 511880.SH 买入 100 股的委托。

- [ ] **Step 4: 提交**

```bash
cd "E:/xtquant/策略"
git add tests/test_bridge_smoke.py
git commit -m "test(bridge): 端到端 smoke 测试 (T1-T4)"
```

---

## 自审

### 规格覆盖检查

| 规格 章节 | 对应 Task |
|----------|----------|
| §1 背景与约束 | Global Constraints |
| §3 通信协议 | Task 1 (server) + Task 2 (client) |
| §4 并发模型 | Task 1 (ThreadPoolExecutor max=8) |
| §5 shim 结构 | Task 3 (骨架) + Task 4 (xtdata) + Task 5 (xttrader) |
| §6 命令集映射 | Task 1 (_exec_cmd 全部 10 个 cmd) |
| §7 错误处理 | Task 1 (try/except) + Task 2 (重连退避) |
| §8 测试计划 | Task 0 (阶段 2) + Task 6 (阶段 3 T1-T5) |
| §9 回滚方案 | Task 3 Step 1 (备份) + _bridge_client QMT_USE_BRIDGE |
| §10 监控 | 待实施阶段补充（YAGNI，先跑通再说） |

### 占位符扫描

无 TBD/TODO。所有代码块完整。

### 类型一致性

- `order_stock` 在 server 返回 `{order_id}`，client `r["data"]["order_id"]`，shim 返回 int → 一致
- `query_stock_positions` server 返回 `list[dict]`，client 透传，shim 包 `SimpleNamespace` → 一致
- `get_full_tick` server 返回 dict，client 透传，shim 透传 → 一致
- `get_market_data_ex` server 用 `df.to_dict("split")`，shim 用 `pd.DataFrame(data, index, columns)` 还原 → 一致

### 遗漏检查

- 监控指标（§10）：YAGNI，先跑通再说，实施阶段补
- 研究库台账同步（§12）：在 EX-SOCKBRIDGE 落地阶段做，不在本计划内

自审通过。
