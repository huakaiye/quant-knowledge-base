---
type: 实验记录
ex_id: EX-20260619T073040Z-main-E8H6
rd_id: RD-20260605T133318Z-main-H6V3
status: active
stage: windows_client_launch_connect_check_preregistered
owner: main
created_at: 2026-06-19T07:30:40Z
updated_at: 2026-06-19T15:33:00+08:00
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 核心轮动真实订单层证据诊断
decision_ids: []
lit_ids: []
idea_ids:
  - MECH-20260619T025934Z-main-DQUM
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths:
  - configs/v2_portfolio_smallcap_etf_dual_pool_50_50.json
  - src/run_v2_live.py
  - scripts/research/diagnose_7x8f_qmt_connection.py
result_paths:
  - results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T073040Z-main-E8H6/
summary_paths: []
quality_gate: preregistered_no_connect_result_yet
subagent_call_ids:
  - SUB-EXEMPT-20260619T073500Z-main-E8H6-QMT-RETRY
subagent_exemption: 当前可用子代理工具规则要求用户明确授权才可启动；本轮涉及 QMT 客户端启动、登录可见性和真实订单层证据边界，主控执行并登记豁免。
tags: [双池轮动, hard5, QMT, dry-run, connect-check, 真实订单层, 只读诊断]
---

# hard5 QMT客户端启动后connect-check重跑诊断

## 关联链接

- 研究方向：[[02_研究方向/RD-20260605T133318Z-main-H6V3_双池轮动score过热拥挤机制模块|H6V3 双池轮动 score 过热拥挤机制模块]]
- 前置实验：[[04_实验记录/EX-20260619T071136Z-main-7X8F_hard5真实订单层QMT连接失败诊断只读面板|7X8F hard5 真实订单层 QMT 连接失败诊断]]
- 前置实验：[[04_实验记录/EX-20260619T042345Z-main-8WGC_hard5修复误杀真实dry-run采集归因|8WGC hard5 修复误杀真实 dry-run 采集归因]]
- 观察门禁：[[04_实验记录/EX-20260619T040913Z-main-8SH4_hard5修复误杀dry-run观察门禁|8SH4 hard5 修复误杀 dry-run 观察门禁]]
- 机制框架：[[07_因子数据灵感/03_机制/MECH-20260619T025934Z-main-DQUM_hard5过热概率与反弹修复状态框架|hard5 过热概率与反弹修复状态框架]]
- 相关执行方向：[[02_研究方向/RD-20260618T105950Z-main-7FY3_双池轮动真实交易微观数据低滞后研究|7FY3 真实交易微观数据低滞后研究]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：7X8F 已经把 8WGC 的 `connect=-1` 收窄为“QMT 客户端进程不可见”。E8H6 不再研究 hard5 阈值，而是尝试启动国金 QMT 模拟客户端，并在客户端进程可见后重跑 `--connect-check`。如果 connect-check 通过，才允许下一步生成真实 dry-run JSON。

我们原本预计：若 7X8F 的唯一硬阻塞确实只是客户端未启动，那么启动 `XtMiniQmt.exe` 后应能看到 `XtMiniQmt/minibroker/miniquote/BrokerProxy` 等候选进程，7X8F 诊断的 `qmt_process_found` 应从 `false` 变为 `true`。若账号未登录或交易模块未激活，`--connect-check` 仍可能失败，但失败应从“进程不可见”推进到“登录或会话层阻塞”。

实际看到：待执行。

这说明：待执行。

但还不能说明：即使 connect-check 通过，也不能说明 hard5 修复机制有效，不能改 hard5，不能提交真实委托；它只说明真实订单层观察 JSON 的前置连接条件更接近可用。

下一步要做：先启动客户端并确认进程；再跑 connect-check；若通过，再单独采集 dry-run JSON 并用 8SH4 归因。

## 2. 研究背景

QS5G 已经暂停当前日频和 13:09 前分钟路径阈值路线。7X8F 显示配置、账号目录、`MiniConfig.xml`、userdata 新鲜度和 Python 3.11 `xtquant` 模块均通过，唯一 required failure 是 `qmt_process_found`。因此下一步最小不确定性已经不是“怎么调 hard5”，而是“启动并登录 QMT 模拟客户端后，连接门禁是否能从进程层推进到会话层，甚至生成真实 dry-run JSON”。

## 3. 实验前假设

如果 7X8F 的阻塞主要来自 QMT 模拟客户端未启动，那么启动 `E:\xtquant\国金QMT交易端模拟\bin.x64\XtMiniQmt.exe` 后，进程检查应至少能看到 QMT/MiniQMT 相关进程；若账号已经自动恢复会话，`src/run_v2_live.py --connect-check` 应有机会通过。

## 4. 实验前预测

如果假设为真，应该看到：

- 进程：启动后 `qmt_process_found=true`，候选进程数大于 0。
- 诊断：重跑 7X8F 诊断时不再出现 `required_failures=["qmt_process_found"]`。
- 连接：`--connect-check` 若成功，退出码为 0；若失败，应提供比 8WGC 更具体的登录、session 或交易模块错误。
- 安全边界：不使用 `--confirm-live-orders`，不提交真实委托，不把 dry-run 订单当成策略收益。
- 若生成 JSON：只落盘到 E8H6 结果目录，并作为后续 8SH4 归因输入。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| 8WGC | 连接失败基准，`connect=-1` 且无 JSON | `results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T042345Z-main-8WGC/summary.json` |
| 7X8F | 启动前诊断基准，唯一硬失败为 `qmt_process_found` | `results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T071136Z-main-7X8F/qmt_connection_diagnostic_summary.json` |
| QMT 客户端入口 | 本轮启动对象 | `E:\xtquant\国金QMT交易端模拟\bin.x64\XtMiniQmt.exe` |
| live CLI | 本轮 connect-check 入口 | `src/run_v2_live.py` |

## 6. 竞争性解释

即使启动后仍失败，也可能是：

- 客户端启动了，但必须人工输入密码、验证码或确认交易模块；
- 客户端进程名不在当前关键词里，导致扫描漏报；
- `XtMiniQmt.exe` 不是正确启动入口，实际应通过桌面快捷方式、券商启动器或升级器启动；
- 进程可见但账号会话未登录，`xttrader.connect()` 仍返回 `-1`；
- QMT 与 Python 端使用的 session_id、账号或 userdata 目录不匹配。

## 7. 证伪条件

出现以下情况，本假设不通过：

- `XtMiniQmt.exe` 无法启动，且没有任何候选进程出现；
- 客户端启动后 7X8F 诊断仍只显示 `qmt_process_found=false`；
- `--connect-check` 失败且错误仍停留在进程不可见，不能推进到会话层；
- 实验中误用了 `--confirm-live-orders` 或提交真实委托；
- 把 connect-check 结果写成 hard5 交易有效性证据。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 不适用 | 本轮不读取收益标签 |
| 信号生成和成交价格不存在同 bar 泄漏 | 不适用 | 本轮不做回测、不评估 H5/H10 |
| 股票池或 ETF 池不存在未来成分泄漏 | 不适用 | 本轮只检查连接前置条件 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 不读取财务、宏观或估值 |
| Shadow 或观察信号未被当成默认交易信号 | 通过预期 | 不改配置，不下单，不启用 shadow/observe |

负控或错位检查：

- 同时输出进程检查、7X8F 重诊断和 connect-check 退出码，避免把“客户端窗口打开”误解为“可连接”。
- 输出 `strategy_validation=false` 或等价边界，避免被误用为 hard5 规则证据。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过预期 | 固定一个客户端入口、一个配置、一条 connect-check |
| 样本内、验证集、样本外划分清楚 | 不适用 | 工程连接诊断 |
| 邻近参数敏感性合理 | 不适用 | 不调策略参数 |
| 成本、滑点或换手扰动已检查 | 不适用 | 尚未进入成交层 |
| 已做消融或负控 | 通过预期 | 以 7X8F 启动前失败为对照 |
| 未只报告最优结果 | 通过预期 | 记录启动、进程、诊断和 connect-check 全路径 |

证据等级：`L1_engineering_diagnostic`。它只能证明真实订单层采集前置条件是否推进，不是策略有效性证据。

## 10. 子代理调用记录

适配判断：`适合调用，但当前未获用户明确授权启动并行子代理`

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：当前可用子代理工具规则要求用户明确授权才可启动，且本轮涉及 QMT 客户端启动、登录可见性和真实订单层证据边界；主控：Codex；时间：2026-06-19T07:35:00Z
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-EXEMPT-20260619T073500Z-main-E8H6-QMT-RETRY | 无 | SUBTASK-HARD5-QMT-CLIENT-RETRY | 无 | 2026-06-19T07:35:00Z | 7X8F、8WGC、run_v2_live、QMT 目录 | 本实验 | 待执行 | 只判断客户端启动和连接门禁，不判断策略收益 | 可能需要人工登录 | 待复核 | 待执行 |

台账行：待同步。

## 11. 执行记录

### 平台配置

```text
configs/v2_portfolio_smallcap_etf_dual_pool_50_50.json
src/run_v2_live.py
scripts/research/diagnose_7x8f_qmt_connection.py
```

### 计划运行命令

```powershell
$out='results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T073040Z-main-E8H6'
New-Item -ItemType Directory -Force -Path $out | Out-Null
Start-Process -FilePath 'E:\xtquant\国金QMT交易端模拟\bin.x64\XtMiniQmt.exe' -WorkingDirectory 'E:\xtquant\国金QMT交易端模拟\bin.x64'
Start-Sleep -Seconds 20
Get-Process | Where-Object { $_.ProcessName -match 'qmt|mini|xt|BrokerProxy|quote' } | Select-Object Id,ProcessName,Path | Tee-Object -FilePath "$out/qmt_process_after_launch.txt"
& 'C:\Python311\python.exe' scripts/research/diagnose_7x8f_qmt_connection.py --config configs/v2_portfolio_smallcap_etf_dual_pool_50_50.json --previous-summary results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T042345Z-main-8WGC/summary.json --output-dir "$out/diagnose_after_launch" 2>&1 | Tee-Object -FilePath "$out/run_e8h6_diagnose_after_launch.log"
& 'C:\Python311\python.exe' src/run_v2_live.py --config configs/v2_portfolio_smallcap_etf_dual_pool_50_50.json --connect-check 2>&1 | Tee-Object -FilePath "$out/run_e8h6_connect_check.log"
```

若 `--connect-check` 成功，下一条命令才允许执行：

```powershell
& 'C:\Python311\python.exe' src/run_v2_live.py --config configs/v2_portfolio_smallcap_etf_dual_pool_50_50.json --dry-run-once --force-events --output-json "$out/live_dry_run_once.json" 2>&1 | Tee-Object -FilePath "$out/run_e8h6_dry_run_once.log"
```

### 可见进度与日志

- 是否过程可见：是。
- 日志路径：`results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T073040Z-main-E8H6/`
- 查看进度命令：`Get-Content -Tail 100 -Wait ${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T073040Z-main-E8H6/run_e8h6_connect_check.log`
- 异常判断：客户端启动后无进程为启动失败；进程存在但 connect-check 失败为会话或登录阻塞；connect-check 通过才进入 dry-run JSON。
- 后台回测豁免：无。客户端为需要用户可见登录的交互程序；connect-check 前台运行并记录日志。

### 结果路径

```text
results/v2/research/RD-20260605T133318Z-main-H6V3/EX-20260619T073040Z-main-E8H6/
```

## 12. 实际观察

待执行。

## 13. 支持证据

待执行。

## 14. 反对证据

待执行。

## 15. 偏差诊断

待执行。

## 16. 研究判断

建议状态：待执行。

理由：待执行。

## 17. 下一步

若进程和 connect-check 都通过，生成真实 dry-run JSON 并进入 8SH4 归因；若进程可见但 connect-check 失败，把阻塞收窄为登录、session 或交易模块层；若进程仍不可见，转为启动入口排查或人工登录说明。
