---
type: 实验记录
ex_id: EX-20260619T042345Z-main-8WGC
rd_id: RD-20260605T133318Z-main-H6V3
status: completed
stage: windows_dry_run_blocked_miniqmt_connect_failed_no_json
owner: main
created_at: 2026-06-19T04:23:45Z
updated_at: 2026-06-19T12:30:00+08:00
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 核心轮动风控诊断模块
decision_ids: []
lit_ids: []
idea_ids:
  - MECH-20260619T025934Z-main-DQUM
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths:
  - configs/v2_portfolio_smallcap_etf_dual_pool_50_50.json
  - scripts/research/analyze_8sh4_hard5_repair_dry_run_observation_gate.py
result_paths:
  - results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T042345Z-main-8WGC/
  - results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T042345Z-main-8WGC/run_8wgc_windows_dry_run_once.log
  - results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T042345Z-main-8WGC/run_8wgc_windows_connect_check.log
  - results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T042345Z-main-8WGC/run_8wgc_windows_check_only.log
summary_paths:
  - results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T042345Z-main-8WGC/summary.json
quality_gate: check_only_passed_connect_failed_no_json_not_strategy_validation
subagent_call_ids:
  - SUB-EXEMPT-20260619T042400Z-main-8WGC-DRYRUN
subagent_exemption: 当前可用多代理工具要求用户明确要求子代理才可 spawn；本轮主控执行并登记豁免。
tags: [双池轮动, hard5, 反弹修复, QMT, dry-run, 真实观察]
---

# hard5修复误杀真实dry-run采集归因

## 关联链接

- 研究方向：[[02_研究方向/RD-20260605T133318Z-main-H6V3_双池轮动score过热拥挤机制模块|双池轮动 score 过热拥挤机制模块]]
- 机制框架：[[07_因子数据灵感/03_机制/MECH-20260619T025934Z-main-DQUM_hard5过热概率与反弹修复状态框架|hard5 过热概率与反弹修复状态框架]]
- 前置门禁：[[04_实验记录/EX-20260619T040913Z-main-8SH4_hard5修复误杀dry-run观察门禁|8SH4 hard5 修复误杀 dry-run 观察门禁]]
- 前置检查：[[04_实验记录/EX-20260619T020248Z-main-3F8Q_QMT dry-run真实采集前置检查|3F8Q QMT dry-run 真实采集前置检查]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：当前 Windows 环境是否能真的生成一份 QMT dry-run JSON，并用 8SH4 判断它是否包含 hard5 修复误杀相关订单。  
我们原本预计：PowerShell 侧已经有 `C:\Python311\python.exe`，且 `E:\xtquant\国金QMT交易端模拟\userdata_mini` 存在，因此至少应能尝试运行 `--dry-run-once`；但是否能连接 MiniQMT、是否有订单、是否匹配 `held_repair` 都未知。  
实际看到：Windows Python 3.11 和 QMT userdata 路径均存在，`--check-only` 配置校验通过；但 `--connect-check` 和 `--dry-run-once` 都在 MiniQMT 连接层失败，返回码为 `-1`，没有生成 `live_dry_run_once.json`。  
这说明：当前机器具备运行脚本和读取配置的条件，但没有进入策略订单生成阶段，原因是 MiniQMT 客户端连接不可用；本轮不能用 8SH4 做真实 JSON 归因，也不能说明 hard5 修复机制有效或无效。  
但还不能说明：即使采集成功，也只能作为真实观察流证据，不能直接改变 hard5 默认逻辑。  
下一步要做：先启动并登录国金 QMT 模拟客户端，确认账号与 `userdata_mini` 可连接，再用同一条命令重跑 dry-run once；拿到 JSON 后才运行 8SH4。

## 2. 研究背景

96SF 证明历史 hard5 路径中的 `held_repair` 样本太少且为负；8SH4 补齐了“拿到 dry-run JSON 后如何归因”的工程门禁。现在需要推进到真实观察流：运行一次不提交委托的 dry-run，看看当前组合模拟配置是否能产出可审计 JSON。

## 3. 实验前假设

如果当前 Windows 侧 MiniQMT 模拟环境可用，那么 `src/run_v2_live.py --dry-run-once --force-events --output-json` 应能生成一份 JSON。该 JSON 经 8SH4 解析后，至少能被判定为以下三种状态之一：

- `repair_observation_match_ready`：有订单匹配 hard5 修复状态；
- `no_repair_order_match`：有订单但不匹配 hard5 修复状态；
- `json_observation_only` 或采集失败：没有完整订单意图或 MiniQMT 采集失败。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：`live_dry_run_once.json` 存在且为 UTF-8 JSON。
- JSON 门禁：至少 schema gate 通过；若有订单，应有 order intent。
- 归因门禁：8SH4 能读取 JSON 与 96SF 状态源，并输出 `summary.json`。
- 交易行为：没有 `--confirm-live-orders`，因此不会提交真实委托。
- 风险表现：若没有订单或没有匹配，不得解释为策略失败或成功，只能登记观察不足。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| 组合模拟配置 | dry-run 采集入口 | `configs/v2_portfolio_smallcap_etf_dual_pool_50_50.json` |
| 8SH4 门禁 | JSON 到 hard5 修复状态归因 | `scripts/research/analyze_8sh4_hard5_repair_dry_run_observation_gate.py` |
| 96SF 状态源 | hard5 修复状态真实格式 | `results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T035511Z-main-96SF/hard5_truepath_repair_index/truepath_event_panel.csv` |
| 3F8Q 命令 | 前置 dry-run 命令来源 | `results/v2/research/RD-20260618T105950Z-main-7FY3/EX-20260619T020248Z-main-3F8Q/readiness_summary.json` |

## 6. 竞争性解释

即使 dry-run 成功，也可能只是：

- 当前没有触发交易事件，所以 JSON 没有订单；
- QMT 连接正常但策略候选与 hard5 修复状态无关；
- 组合模拟配置中 ETF 双池组件没有生成 hard5 相关订单；
- 当前日期没有对应 96SF 历史状态源，导致 8SH4 不匹配；
- dry-run 只代表一次当下观察，不能替代历史样本外验证。

## 7. 证伪条件

出现以下情况，本轮不能作为真实观察证据：

- Windows dry-run 命令失败且未生成 JSON；
- JSON 生成但 G7S8 schema gate 失败；
- 8SH4 不能读取 JSON 或状态源；
- 日志显示需要 `--confirm-live-orders` 或真实委托确认才继续，本轮必须停止；
- 结果被误写成策略有效性或默认 hard5 修改依据。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 待检查 | dry-run JSON 生成后检查 `current_dt` 与订单时间 |
| 信号生成和成交价格不存在同 bar 泄漏 | 不适用 | 本轮不做收益计算，只采集观察 JSON |
| 股票池或 ETF 池不存在未来成分泄漏 | 不适用 | 不做历史回测或收益判断 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 不读取财务、宏观或估值数据做结论 |
| Shadow 或观察信号未被当成默认交易信号 | 预期通过 | 命令不带 `--confirm-live-orders`，只做 dry-run |

负控或错位检查：

- 若 JSON 与 96SF 状态源没有同日同标的匹配，8SH4 应输出 `match_count=0`，不得强行解释。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | 只运行 1 个固定 dry-run 配置和 1 个固定 8SH4 归因 |
| 样本内、验证集、样本外划分清楚 | 不适用 | 真实观察采集，不做收益估计 |
| 邻近参数敏感性合理 | 不适用 | 不调参数 |
| 成本、滑点或换手扰动已检查 | 不适用 | 本轮不做绩效评估 |
| 已做消融或负控 | 待检查 | 8SH4 无匹配时作为负控记录 |
| 未只报告最优结果 | 通过 | 单次采集，无优化 |

证据等级：`L1_real_observation_gate`，最多只能作为真实观察流入口。

## 10. 子代理调用记录

适配判断：`适合调用，但当前工具规则不允许`

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：当前可用多代理工具要求用户明确要求子代理才可 spawn，本轮没有该授权；主控：Codex；时间：2026-06-19T04:24:00Z
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-EXEMPT-20260619T042400Z-main-8WGC-DRYRUN | 无 | SUBTASK-HARD5-REPAIR-LIVE-DRYRUN | 无 | 2026-06-19T04:24:00Z | 3F8Q、8SH4、组合模拟配置、readiness_summary | 本实验、summary.json、三份 run log | Windows dry-run、connect-check、check-only | 只判断 dry-run 采集和连接阻塞，不判断策略有效 | MiniQMT 返回 `-1` 且无 JSON | 主控已复核 | 不改变 hard5 |

台账行：已在本轮同步。

## 11. 执行记录

### 平台配置

```text
configs/v2_portfolio_smallcap_etf_dual_pool_50_50.json
```

### 计划运行命令

```powershell
New-Item -ItemType Directory -Force -Path 'results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T042345Z-main-8WGC' | Out-Null
& 'C:\Python311\python.exe' src/run_v2_live.py --config 'configs/v2_portfolio_smallcap_etf_dual_pool_50_50.json' --dry-run-once --force-events --output-json 'results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T042345Z-main-8WGC/live_dry_run_once.json' 2>&1 | Tee-Object -FilePath 'results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T042345Z-main-8WGC/run_8wgc_windows_dry_run_once.log'
```

若 JSON 生成，再运行：

```bash
wsl -- bash -lc "cd '/mnt/e/量化平台_V1.4.0' && PYTHONPATH=src PYTHONUNBUFFERED=1 python3 scripts/research/analyze_8sh4_hard5_repair_dry_run_observation_gate.py --input-json results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T042345Z-main-8WGC/live_dry_run_once.json --state-csv results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T035511Z-main-96SF/hard5_truepath_repair_index/truepath_event_panel.csv --output-dir results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T042345Z-main-8WGC/8sh4_after_live_json --require-state 2>&1 | tee results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T042345Z-main-8WGC/run_8wgc_8sh4_after_live_json.log"
```

### 可见进度与日志

- 是否过程可见：计划是。
- 日志路径：`results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T042345Z-main-8WGC/run_8wgc_windows_dry_run_once.log`
- 查看进度命令：`Get-Content -Tail 100 -Wait results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T042345Z-main-8WGC/run_8wgc_windows_dry_run_once.log`
- 后台回测豁免：无，计划前台运行。

### 实际运行结果

```text
results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T042345Z-main-8WGC/summary.json
results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T042345Z-main-8WGC/run_8wgc_windows_dry_run_once.log
results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T042345Z-main-8WGC/run_8wgc_windows_connect_check.log
results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T042345Z-main-8WGC/run_8wgc_windows_check_only.log
```

## 12. 实际观察

| 检查项 | 结果 |
| --- | --- |
| `C:\Python311\python.exe` | 存在，版本 `Python 3.11.9` |
| `E:\xtquant\国金QMT交易端模拟\userdata_mini` | 存在 |
| `--check-only` | 退出码 `0`，配置校验通过 |
| `--connect-check` | 退出码 `1`，MiniQMT 连接失败 |
| `--dry-run-once --force-events --output-json` | 退出码 `1`，MiniQMT 连接失败 |
| MiniQMT 返回码 | `-1` |
| QMT 相关进程 | 未发现 |
| `live_dry_run_once.json` | 未生成 |
| 8SH4 真实 JSON 归因 | 未执行，因为没有 JSON |

## 13. 支持证据

- `summary.json` 记录 `windows_python_exists=true`、`qmt_userdata_path_exists=true`、`check_only_exit_code=0`。
- `run_8wgc_windows_check_only.log` 显示 live 配置、组合组件和 QMT 路径校验通过。
- `run_8wgc_windows_connect_check.log` 显示 MiniQMT 连接检查失败，返回码为 `-1`。
- `run_8wgc_windows_dry_run_once.log` 的 traceback 显示失败发生在 `XtQuantAdapter.connect()` / `xttrader.connect()`，早于策略输出 JSON。

## 14. 反对证据

- 没有生成 `live_dry_run_once.json`，因此没有真实订单意图、成交、records 或 portfolio 可供 8SH4 归因。
- 没有进入 hard5 修复状态匹配阶段，不能比较 `held_repair`、`rebuy_repair`、`new_buy_repair` 或 `chase_hot` 的真实 dry-run 行为。
- 当前阻塞是工程连接问题，不是策略表现问题，不能据此证明 hard5 机械或不机械。

## 15. 偏差诊断

本轮证据链被 MiniQMT 连接阻断。与 3F8Q 相比，Windows 侧已经满足 Python 3.11 与 userdata 路径两个硬条件；新增失败点是 QMT 客户端连接层。  
最可能解释是：国金 QMT 模拟客户端未启动、未登录、账号连接不可用，或 `userdata_mini` 与当前客户端会话不匹配。由于没有 `--confirm-live-orders`，本轮不会提交真实委托。

## 16. 研究判断

建议状态：`completed / blocked_by_miniqmt_connect_failed_no_json`。

理由：8WGC 已完成预注册和一次真实 Windows dry-run 尝试；配置层通过，但连接层失败，未生成 JSON。它只能作为“真实观察采集被阻塞”的工程证据，不能作为 hard5 修复机制的收益或风险证据。当前不支持修改 hard5、不支持 hold-only 续持例外、不支持 cap30 修复预算。

## 17. 下一步

启动并登录国金 QMT 模拟客户端后，重跑同一条 `--dry-run-once --force-events --output-json` 命令。若 `live_dry_run_once.json` 生成，再运行 8SH4 归因；若仍返回 `-1`，应先定位 MiniQMT 账号、客户端会话和 `userdata_mini` 路径配置，而不是继续研究 hard5 阈值。
