---
type: 研究决策
dec_id: DEC-20260704T153323Z-main-ELB2
rd_ids: [RD-20260703T081815Z-main-LMIG]
ex_ids: [EX-20260703T081815Z-main-XTCN, EX-20260704T153310Z-main-ZVJH]
decision: promote_candidate
owner: main
created_at: 2026-07-04T15:33:23Z
updated_at: 2026-07-04T23:30:00Z
impact: direction
subagent_call_ids:
  - SUB-20260704T-CASELOOKUP
subagent_exemption: 子代理豁免：已有调用记录未在当前子代理台账中找到，路线判断由主控完成；主控：main；时间：2026-07-04T15:33:23Z
tags: [实盘平台, miniQMT清退, 路线修订, socket桥接, tornado, promote_candidate]
---

# 大QMT直连证伪转socket桥接路线

## 关联链接

- 受影响方向：[[02_研究方向/RD-20260703T081815Z-main-LMIG_miniQMT清退后实盘平台迁移|RD-LMIG miniQMT清退后实盘平台迁移]]
- 关键实验（前序，已作废）：[[04_实验记录/EX-20260703T081815Z-main-XTCN_大QMT内置xtquant连通性smoke|EX-XTCN 大QMT内置xtquant连通性smoke]]
- 关键实验（本次）：[[04_实验记录/EX-20260704T153310Z-main-ZVJH_QMTsocket桥接连通性与并发验证|EX-ZVJH QMTsocket桥接连通性与并发验证]]
- 上一张决策：无（LMIG 方向首张 DEC）
- 后续实验：实盘下单 smoke（周一开盘后跑）
- 设计规格：[[docs/superpowers/specs/2026-07-04-qmt-socket-bridge-design|QMT Socket Bridge 设计规格]]
- 研究驾驶舱：[[00_入口/研究驾驶舱|研究驾驶舱]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 决策结论

`promote_candidate`（待周一开盘 DELTA 验证后升级 `promote`）

**两条路线的复合决策**：
1. **kill** 原"大QMT 内置 xtquant 直连"路线（EX-XTCN 已证伪）
2. **promote_candidate** 新"socket 桥接（tornado HTTP）"路线（EX-ZVJH 6/6 验证通过，待下单确认）

## 这个节点是什么

miniQMT 清退后，实盘策略需要新的承载方案。本决策处理"选哪条技术路线"：

- **原路线（已 kill）**：外部 Python 用大 QMT 内置的 xtquant 直连 → EX-XTCN 证实 connect=-1，XtItClient 不提供 58610 服务
- **新路线（promote_candidate）**：在大 QMT 客户端进程内起 tornado HTTP server，外部 Python 通过 HTTP 调用客户端内 passorder/ContextInfo → EX-ZVJH 验证全链路可用

## 相比上一个节点改变了什么

- **kill** RD-LMIG 原"直连"假设（frontmatter current_best_ex_id 从 EX-XTCN 改为 EX-ZVJH）
- **新增** tornado HTTP 桥接作为主路线（bridge server + client + shim 包已实现并验证）
- **保留** ptrade 作为长期备选（子代理 ALT-PTRADE 确认可行性最高，但用户拒绝云端运行模式）
- **修订** RD-LMIG 正文"核心假设"/"下一步"/"边界声明"章节（原表述基于已证伪的直连假设）

## 子代理依据来源

适配判断：`适合调用`（社区成功案例调研，决定性影响架构方向）

调用状态：`called`

子代理豁免：无

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-20260704T-CASELOOKUP | general-purpose | SUBTASK-CASELOOKUP | sonnet | 2026-07-04 | 社区博客/论坛/GitHub | 无 | 无 | 找到流光 tid=63 tornado 方案 | 无 | 是 | 决定性（扭转架构方向） |

台账行：见 `01_台账/子代理调用台账.csv`

## 支持证据

- **EX-ZVJH 6/6 验证通过**：ping/asset/positions/tick/连接/字段映射全部正确
- **C4 v1 崩溃测试**：156 次 passorder 跨线程并发零崩溃
- **C2 v11 行情验证**：ContextInfo.get_full_tick 返回实时 tick，绕开 58610
- **迅投官方论坛 tid=63**：流光的 tornado 方案是公开验证过的先例
- **迅投官方文档**：明确 QMT 单线程限制，解释了 daemon 线程方案的失败根因
- **客户端自带 tornado 6.0.2**：无需额外安装，ipykernel 也用它，相对稳定

## 反对证据

- **实盘 DELTA 未验证**：非交易时段/模拟模式下 DELTA=0，但已排除是 bridge 通道问题（替代解释：柜台不接收/模拟账本不写）。需周一开盘确认。
- **客户端升级风险**：tornado 6.0.2 是 2019 年版本，QMT 升级可能影响（但 ipykernel 依赖它，被移除概率低）

## 边界

这个决策**不能**说明：

- passorder 在交易时段真的能生成委托（DELTA>0 未验证）
- bridge 长期稳定性（只测了单次连接，未测长时间运行/重连/并发压力）
- 策略切换到 bridge 后的业务正确性（需 shadow 模式对账）

仍然不确定的：

- 周一开盘 DELTA 是否真的 >0（极可能，但未实测）
- 客户端升级后 ContextInfo 行为是否变化

## 后续动作

- [ ] 周一（2026-07-07）开盘后跑 T4 下单 smoke，确认 DELTA>0
- [ ] DELTA>0 则本 DEC 升级为 `promote`，EX-ZVJH 升级为 `promote`
- [ ] 策略 shadow 模式跑 1 天（dry_run 对账）
- [ ] 小资金实盘跑 1 周
- [ ] 全量切换（停掉 miniQMT）

## 需要同步更新

- [x] 研究方向页（RD-LMIG 正文修正）
- [ ] 研究驾驶舱（重建时自动更新）
- [x] 实验台账（EX-ZVJH 新增行）
- [x] 决策台账（DEC-ELB2 新增行）
- [x] 子代理调用台账（12 个 SUB 补登）
- [x] 研究方向台账（RD-LMIG current_best_ex_id 改为 EX-ZVJH）
- [ ] 研究图谱（重建）
- [ ] 研究进展板（重建）
- [ ] 术语库（新增 tornado 桥接/IOLoop 等术语）
