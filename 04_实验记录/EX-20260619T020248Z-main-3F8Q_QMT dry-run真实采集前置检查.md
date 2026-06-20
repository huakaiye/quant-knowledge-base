---
type: 实验记录
ex_id: EX-20260619T020248Z-main-3F8Q
rd_id: RD-20260618T105950Z-main-7FY3
status: completed
stage: live_dry_run_readiness_failed_actionable
owner: main
created_at: 2026-06-19T02:02:48Z
updated_at: 2026-06-19T02:07:43Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 执行与换仓模块
decision_ids: [DEC-20260618T110703Z-main-FF3K]
lit_ids: []
idea_ids: []
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths:
  - scripts/research/check_7fy3_live_dry_run_readiness.py
  - src/tests/scripts/test_check_7fy3_live_dry_run_readiness.py
  - configs/v2_portfolio_smallcap_etf_dual_pool_50_50.json
result_paths:
  - results/v2/research/RD-20260618T105950Z-main-7FY3/EX-20260619T020248Z-main-3F8Q/
summary_paths:
  - results/v2/research/RD-20260618T105950Z-main-7FY3/EX-20260619T020248Z-main-3F8Q/readiness_summary.json
quality_gate: pytest 3 passed; py_compile passed; readiness_pass=false with 3 required failures
subagent_call_ids: []
subagent_exemption: 子代理豁免：当前多代理工具只有在用户显式要求子代理/委派/并行 agent 时才允许 spawn，本轮没有该授权；主控：main；时间：2026-06-19T02:02:48Z
tags: [双池轮动, 低滞后, QMT, dry-run, 前置检查, 实盘边界]
---

# QMT dry-run真实采集前置检查

## 关联链接

- 研究方向：[[02_研究方向/RD-20260618T105950Z-main-7FY3_双池轮动真实交易微观数据低滞后研究|7FY3 真实交易微观数据低滞后研究]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 前置链路：[[04_实验记录/EX-20260619T014937Z-main-96B8_B5JS G7S8 48VR端到端链路预检|96B8 B5JS-G7S8-48VR 端到端链路预检]]
- 当前决策：[[05_研究决策/DEC-20260618T110703Z-main-FF3K_微观数据缺口确认后暂停低滞后执行实验|FF3K 微观数据缺口确认后暂停低滞后执行实验]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：当前机器离“采集真实 QMT dry-run JSON”还差什么。  
我们原本预计：平台配置和 96B8 链路应能找到，但当前运行环境大概率不是 Windows MiniQMT 环境，因此不能直接采集真实 dry-run。  
实际看到：`readiness_pass=false`，硬失败 3 项：`qmt_path_exists`、`current_os_is_windows`、`current_python_is_311`。配置文件、live CLI、96B8 链路脚本、策略组件、A22 7Z32 信号源和 KFSQ 2XKW 信号源都存在。  
这说明：研究没有卡在“不知道怎么做”，而是卡在明确的运行环境上；换到 Windows + Python 3.11 + 可见 QMT userdata 路径后，就可以按脚本生成的命令采集 JSON。  
但还不能说明：真实 dry-run 会有订单、订单会被 A22/KFSQ 解释，或低滞后方案有效。  
下一步要做：在 Windows QMT 环境执行 `readiness_summary.json` 里的 `windows_dry_run_once` 命令，生成 JSON 后回到 96B8 链路。

## 2. 研究背景

96B8 已经把 B5JS、G7S8 和 48VR 串成可重复链路，但它仍只用合成 JSON。要真正推进 7FY3，需要一份来自 MiniQMT dry-run runner 的真实 JSON。3F8Q 不运行 dry-run，而是做采集前的只读检查：当前机器、配置、QMT 路径、策略组件、候选信号源和输出命令是否已经就绪。

## 3. 实验前假设

如果当前机器不具备真实 QMT dry-run 采集条件，那么前置检查器应能明确指出缺口，同时保留已经就绪的配置和后续命令，避免继续停留在“需要真实数据”的泛化描述。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：`readiness_pass=false`，且失败原因可枚举。
- 环境：当前 WSL/Linux 不是 Windows；Python 是 3.10，不是 MiniQMT 要求的 3.11。
- 配置：`configs/v2_portfolio_smallcap_etf_dual_pool_50_50.json` 能解析，策略组件路径存在。
- 链路：A22 7Z32 与 KFSQ 2XKW 信号源存在，并生成 dry-run 命令和 96B8 链路命令。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| V2 MiniQMT CLI | dry-run 采集入口 | `src/run_v2_live.py` |
| 组合模拟配置 | 当前最接近真实双池/组合的 dry-run 配置 | `configs/v2_portfolio_smallcap_etf_dual_pool_50_50.json` |
| 96B8 链路脚本 | JSON 生成后的外部观察链路 | `scripts/research/run_7fy3_dry_run_evidence_chain.py` |
| A22 7Z32 信号源 | 真实格式候选信号源 | `results/v2/research/R010-A22/trigger_event_search/EX-20260618T074745Z-main-7Z32/event_rows.csv` |
| KFSQ 2XKW 信号源 | 真实格式候选信号源 | `results/v2/research/RD-20260614T115209Z-main-MCYG/EX-20260618T143708Z-main-2XKW/scored_oos_panel.csv` |

## 6. 竞争性解释

即使前置检查失败，也可能是：

- 在 Windows 终端运行时 QMT 路径存在，WSL 下 `Path.exists()` 看不到 Windows 路径。
- 当前配置含模拟账号和路径，但真实可连接性仍需 `--connect-check` 或 QMT 客户端运行状态确认。
- 策略组件存在只说明文件可读，不代表策略运行时不会因为数据、行情或调度事件失败。
- 信号源存在只说明后续可归因，不说明信号有效。

## 7. 证伪条件

出现以下情况，本检查器不合格：

- 不能解析 live 配置。
- 找不到 live CLI 或 96B8 链路脚本。
- 不能生成 `readiness_summary.json` 和 `readiness_checks.csv`。
- 输出不能区分 required failure 和 warning。
- 不能给出后续 dry-run 和 chain 命令。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 不适用，采集前置检查 | 不读取行情、不生成信号 |
| 信号生成和成交价格不存在同 bar 泄漏 | 不适用 | 不运行策略、不撮合成交 |
| 股票池或 ETF 池不存在未来成分泄漏 | 不适用 | 只检查配置和文件路径 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 未访问财务、宏观或估值数据 |
| Shadow 或观察信号未被当成默认交易信号 | 通过 | 脚本不连接 QMT、不下单，只生成命令 |

负控或错位检查：

- 本轮不做收益或错位负控；它是采集前置检查，不是策略实验。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | 固定检查当前组合模拟配置、A22 7Z32、KFSQ 2XKW |
| 样本内、验证集、样本外划分清楚 | 不适用 | 不评估收益 |
| 邻近参数敏感性合理 | 不适用 | 不做参数网格 |
| 成本、滑点或换手扰动已检查 | 不适用 | 尚未进入真实成交层 |
| 已做消融或负控 | 不适用 | 本轮目标是环境可采集性 |
| 未只报告最优结果 | 通过 | 报告通过项、失败项和 warning |

证据等级：`L1_engineering_readiness`。它只证明当前采集条件是否就绪。

## 10. 子代理调用记录

适配判断：适合委派路径核对和配置审计，但本轮涉及实盘边界，且当前工具没有显式子代理授权。

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：当前多代理工具只有在用户显式要求子代理/委派/并行 agent 时才允许 spawn，本轮没有该授权；主控：main；时间：2026-06-19T02:02:48Z
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-EXEMPT-20260619T020600Z-main-LIVEREADY | 无 | SUBTASK-7FY3-LIVE-DRYRUN-READINESS | 无 | 2026-06-19T02:02:48Z | live CLI、MiniQMT 说明、96B8 链路、live 配置 | 本实验、前置检查脚本和测试 | pytest、py_compile、readiness check | 只判断采集条件，不判断策略有效 | 当前机器非 Windows/QMT 环境 | 主控复核 summary 与 checks | 支持把下一步限定为 Windows QMT 采集 |

台账行：已同步 `01_台账/子代理调用台账.csv`。

## 11. 执行记录

### 平台配置

```text
scripts/research/check_7fy3_live_dry_run_readiness.py
src/tests/scripts/test_check_7fy3_live_dry_run_readiness.py
configs/v2_portfolio_smallcap_etf_dual_pool_50_50.json
```

### 运行命令

```bash
cd /mnt/e/量化平台_V1.4.0
PYTHONPATH=src python3 -m pytest src/tests/scripts/test_check_7fy3_live_dry_run_readiness.py -q
PYTHONPATH=src python3 -m py_compile scripts/research/check_7fy3_live_dry_run_readiness.py src/tests/scripts/test_check_7fy3_live_dry_run_readiness.py
PYTHONPATH=src python3 scripts/research/check_7fy3_live_dry_run_readiness.py --output-dir results/v2/research/RD-20260618T105950Z-main-7FY3/EX-20260619T020248Z-main-3F8Q
```

### 可见进度与日志

- 是否过程可见：是。
- 日志路径：`results/v2/research/RD-20260618T105950Z-main-7FY3/EX-20260619T020248Z-main-3F8Q/run_3f8q_readiness.log`
- 查看进度命令：`cat results/v2/research/RD-20260618T105950Z-main-7FY3/EX-20260619T020248Z-main-3F8Q/run_3f8q_readiness.log`
- 异常判断：脚本返回非 0 且 `readiness_summary.json` 显示 required failures；这是本轮预期结果，不是脚本崩溃。
- 后台回测豁免：无，未后台运行。

### 结果路径

```text
results/v2/research/RD-20260618T105950Z-main-7FY3/EX-20260619T020248Z-main-3F8Q/readiness_summary.json
results/v2/research/RD-20260618T105950Z-main-7FY3/EX-20260619T020248Z-main-3F8Q/readiness_checks.csv
results/v2/research/RD-20260618T105950Z-main-7FY3/EX-20260619T020248Z-main-3F8Q/run_3f8q_readiness.log
```

## 12. 实际观察

| 指标 | 基准 | 本次 | 变化 | 解释 |
| --- | --- | --- | --- | --- |
| 单元测试 | 新脚本应可测试 | 3 passed | 通过 | 检查器核心逻辑可复用 |
| 编译检查 | 无语法错误 | 通过 | 通过 | 平台入口可加载 |
| `readiness_pass` | 预期当前机器不通过 | false | 符合 | 当前不是 Windows QMT 采集环境 |
| required failure count | 预期可枚举 | 3 | 符合 | 缺口具体化 |
| 配置解析 | 预期通过 | pass | 符合 | 组合模拟配置可解析 |
| 策略组件 | 预期存在 | pass | 符合 | 小市值与 ETF 双池组件文件存在 |
| 候选信号源 | 预期存在 | pass | 符合 | A22 7Z32 与 KFSQ 2XKW 可接链路 |

## 13. 支持证据

- `readiness_summary.json`：`readiness_pass=false`，`required_failure_count=3`。
- required failures：`qmt_path_exists`、`current_os_is_windows`、`current_python_is_311`。
- 当前环境：`current_os=Linux`，`current_python=3.10`。
- live job：`strategy_name=V2_组合_小市值_ETF双池_50_50`，`strategy_type=portfolio`，`qmt_mode=sim_qmt`，`component_count=2`。
- 通过项包括：`live_config_exists`、`live_cli_exists`、`chain_script_exists`、`live_config_parse_without_account`、`live_config_has_account_and_qmt_path`、`strategy_assets_exist`、两个 `signal_source_exists`。
- `readiness_summary.json` 已生成 `windows_dry_run_once` 和 `wsl_chain_after_json` 两条命令。

## 14. 反对证据

- 当前机器不能直接生成真实 dry-run JSON。
- WSL 下看不到 `E:\xtquant\国金QMT交易端模拟\userdata_mini`，不能证明 Windows 端也缺路径。
- 还没有执行 `--connect-check`，不能证明 QMT 客户端已登录或账户可查询。
- 还没有生成 `live_dry_run_once.json`，因此 96B8 的真实链路尚未运行。

## 15. 偏差诊断

主要偏差是：配置里的账号和 QMT 路径已经存在，但 WSL 侧仍判定 `qmt_path_exists=false`。这是预期边界：MiniQMT dry-run 必须在 Windows + Python 3.11 下运行，WSL 只能做链路和结果解析。

## 16. 研究判断

建议状态：`observe`

理由：3F8Q 没有推进策略结论，但显著降低了下一步执行不确定性。现在已知道当前环境不能采集真实 dry-run，且已有可复制命令。7FY3 仍 `park`，不能 production promote、shadow 或 observe 实盘。

## 17. 下一步

在 Windows QMT 环境中先执行：

```powershell
& 'C:\Python311\python.exe' src/run_v2_live.py --config 'configs/v2_portfolio_smallcap_etf_dual_pool_50_50.json' --dry-run-once --force-events --output-json 'results/v2/research/RD-20260618T105950Z-main-7FY3/EX-20260619T020248Z-main-3F8Q/live_dry_run_once.json'
```

生成 JSON 后，在 WSL 中执行 `readiness_summary.json` 的 `wsl_chain_after_json` 命令。若 JSON 有订单但 48VR 无匹配，应登记未解释订单；若有匹配，也只能进入外部观察归因，不能直接改默认策略。
