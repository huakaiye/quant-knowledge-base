---
type: 研究方向
rd_id: RD-20260703T081815Z-main-LMIG
parent_rd_id: RD-20260605T115651Z-main-EXE0
scope: 模块
module_type: 实盘平台工程模块
status: active
priority: P0
owner: main
created_at: 2026-07-03T08:18:15Z
updated_at: 2026-07-04T23:30:00Z
strategy_id: STRAT-20260605T115651Z-main-DP00
current_decision_id: DEC-20260704T153323Z-main-ELB2
current_best_ex_id: EX-20260704T153310Z-main-ZVJH
tags: [实盘平台, miniQMT清退, 大QMT, socket桥接, tornado, passorder, 平台迁移, 工程]
---

# miniQMT 清退后实盘平台迁移

## 关联链接

- 父方向：[[02_研究方向/RD-20260605T115651Z-main-EXE0_双池轮动执行与换仓模块|双池轮动执行与换仓模块]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 首个连通性验证（已作废）：[[04_实验记录/EX-20260703T081815Z-main-XTCN_大QMT内置xtquant连通性smoke|EX-XTCN 大QMT 内置 xtquant 连通性 smoke]]
- socket 桥接验证（当前主路线）：[[04_实验记录/EX-20260704T153310Z-main-ZVJH_QMTsocket桥接连通性与并发验证|EX-ZVJH QMTsocket桥接连通性与并发验证]]
- 路线决策：[[05_研究决策/DEC-20260704T153323Z-main-ELB2_大QMT直连证伪转socket桥接路线|DEC-ELB2 大QMT直连证伪转socket桥接路线]]
- 设计规格：[[docs/superpowers/specs/2026-07-04-qmt-socket-bridge-design|QMT Socket Bridge 设计规格]]
- 实现计划：[[docs/superpowers/plans/2026-07-04-qmt-socket-bridge|QMT Socket Bridge Implementation Plan]]
- 平台协作规范：[[08_方法论/平台协作规范|平台协作规范]]
- 命名与编号规范：[[08_方法论/命名与编号规范|命名与编号规范]]

## 一句话说明

券商通知 miniQMT（XtMiniQmt.exe 极简后台）将被清退，且外部 pip 装的 xtquant 会随之失效。本方向验证并落地 **socket 桥接方案**——在大 QMT 客户端进程内起 tornado HTTP server，外部 Python 通过 HTTP 调用客户端内 passorder/ContextInfo，使策略代码零改动完成迁移。

## 背景（2026-07-03 用户通知）

- 用户接到券商通知：miniQMT 将清退，存量用户暂时可用，后续逐步停用。
- 用户的明确澄清：**xtquant 是 miniQMT 的一部分，会随 miniQMT 一并清退**（指 pip 安装的外部 xtquant + XtMiniQmt.exe 后台组合）。
- 研究库此前从未记录任何 miniQMT 清退、迁移或替代讨论（SUBTASK-MINIQMT-ASSESS 全库盘点零命中"清退/大QMT/迁移"）。
- 本机 miniQMT 实盘主文件：`E:\xtquant\策略\ETF双池动量轮动_MiniQMT.py`（3434 行，v19）。
- 当前实盘版本：A2-slope004 + B3-gate-tiered-v2 默认启用，hard5 默认硬过滤，shadow 灰度机制已落地。

## 被清退范围（用户明确）

| 项 | 是否清退 | 说明 |
| --- | --- | --- |
| XtMiniQmt.exe（极简后台） | 是 | 券商通知明确 |
| 外部 pip 安装的 xtquant | 是 | 依赖 XtMiniQmt.exe 提供服务，会一并失效 |
| 大QMT 客户端（XtItClient.exe） | 否 | 保留 |
| 大QMT 内置 xtquant（`bin.x64\Lib\site-packages\xtquant` + `XtQuantServer_qmt.dll`） | 否 | 客户端内部组件，独立于 miniQMT |

## 迁移核心假设（已证伪 → 转桥接）

### ❌ 原假设（EX-XTCN 证伪，2026-07-03）

**外部 Python 3.11 + 大QMT 内置 xtquant + 大QMT userdata_mini** 可以替代 **外部 Python 3.11 + pip xtquant + miniQMT userdata**。

证伪证据：mini 进程全关 + 58610 端口无监听时，`connect()` 返回 -1。XtItClient.exe **不提供** xtquant 服务后端（58610 由 miniquote/minibroker 提供）。详见 EX-XTCN 第 12 章事实核查。

### ✅ 新假设（EX-ZVJH 验证中，2026-07-04）

**在大 QMT 客户端进程内起 tornado HTTP server + 外部 Python 用 shim 包劫持 xtquant import**，可以替代 miniQMT，且策略代码零改动。

依据：
1. 迅投官方论坛 tid=63（流光）验证过 tornado-in-init 模式可行。
2. QMT 客户端 Python 是单线程的（官方明确"无法使用多线程"），tornado IOLoop 单线程事件循环完美绕开此限制。
3. C4 v1 实测 passorder 跨线程并发 156 次零崩溃。
4. C2 v11 实测 ContextInfo.get_full_tick 返回实时 tick（绕开 58610）。
5. EX-ZVJH 端到端测试 6/6 通过（ping/asset/positions/tick/连接/字段映射）。

## 运行约束（修订）

- **大QMT 客户端 XtItClient.exe 必须启动并保持登录态**——server 跑在客户端进程内，客户端关闭则 bridge 死。
- **tornado server 监听 127.0.0.1:58711**（避开已清退的 58610），外部 Python 通过 HTTP 调用。
- **下单/委托确认受交易时段约束**：非交易时段 passorder 调用不报错但委托不进 ORDER 表（柜台不接收）。
- **tornado 版本随客户端升级**：客户端自带 tornado 6.0.2（ipykernel 依赖），升级可能影响，需回归测试。

## 子代理计划

子代理计划：调用；调用ID SUB-20260703T081815Z-main-MINIQMT-ASSESS；任务代号 SUBTASK-MINIQMT-ASSESS；平台昵称（自动 Hooke）；模型 sonnet；交付物 研究库 miniQMT/实盘/大QMT 现状盘点；无豁免。已完成。

## 边界声明

- 本方向只解决"实盘平台从 miniQMT 迁移到 socket 桥接"，不修改任何策略业务逻辑、不复活任何已 park 的研究方向、不改变 hard5/A2-slope004/B3-gate-tiered-v2 实盘默认开关。
- 不把 smoke 结果直接升级为实盘交易依据；真实下单 smoke（T4）通过前不改实盘默认配置。
- **socket 桥接是当前主路线**（EX-ZVJH 验证 6/6 通过）；ptrade 作为长期备选保留（用户拒绝云端运行模式，但工具链已就绪）。

## 下一步

1. **周一（2026-07-07）开盘后跑 T4 下单 smoke**：511880.SH 买 100 股 @ 废单价，确认 DELTA>0。
2. DELTA>0 则 EX-ZVJH 升级 `promote`，DEC-ELB2 升级 `promote`，bridge 投产。
3. 策略 shadow 模式跑 1 天（dry_run 对账信号一致性）。
4. 小资金实盘跑 1 周（对账委托/成交）。
5. 全量切换（停掉 miniQMT，纯 bridge 运行）。

## 当前实验

- [[04_实验记录/EX-20260704T153310Z-main-ZVJH_QMTsocket桥接连通性与并发验证|EX-ZVJH QMTsocket桥接连通性与并发验证]]（**当前主路线**，6/6 验证通过，待开盘 DELTA 确认）
- [[04_实验记录/EX-20260703T081815Z-main-XTCN_大QMT内置xtquant连通性smoke|EX-XTCN 大QMT 内置 xtquant 连通性 smoke]]（已作废前序实验）
