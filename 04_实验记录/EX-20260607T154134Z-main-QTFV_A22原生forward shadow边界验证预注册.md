---
type: 实验记录
ex_id: EX-20260607T154134Z-main-QTFV
rd_id: RD-20260605T133318Z-main-H6V3
status: active
stage: preregistered_ready_for_engineering_and_formal
owner: main
created_at: 2026-06-07T15:41:34Z
updated_at: 2026-06-07T15:41:34Z
strategy_id:
module_type: 核心轮动风控诊断模块
decision_ids: [DEC-20260607T151252Z-main-A22N]
lit_ids: []
idea_ids: []
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths:
  - configs/research/R010-A22/native_forward_shadow/EX-20260607T154134Z-main-QTFV/formal/
  - scripts/research/generate_qtfv_a22_native_forward_shadow_configs.py
  - scripts/research/run_qtfv_a22_native_forward_shadow.sh
  - scripts/research/summarize_qtfv_a22_native_forward_shadow.py
result_paths:
  - results/v2/research/R010-A22/native_forward_shadow/EX-20260607T154134Z-main-QTFV/formal/
  - results/v2/research/R010-A22/native_forward_shadow/EX-20260607T154134Z-main-QTFV/logs/formal/
  - results/v2/research/R010-A22/native_forward_shadow/EX-20260607T154134Z-main-QTFV/summary/formal/
summary_paths:
  - results/v2/research/R010-A22/native_forward_shadow/EX-20260607T154134Z-main-QTFV/summary/formal/summary.json
quality_gate: L1_engineering_shadow_boundary_preregistered
subagent_call_ids: [SUB-20260607T154000Z-main-A22FS-ENTRY]
subagent_exemption:
tags: [双池轮动, score过热, A22, 原生字段, forward边界, shadow边界, 默认关闭观察]
---

# A22原生forward shadow边界验证预注册

## 关联链接

- 研究方向：[[02_研究方向/RD-20260605T133318Z-main-H6V3_双池轮动score过热拥挤机制模块|双池轮动 score 过热拥挤机制模块]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 上游字段审计：[[04_实验记录/EX-20260607T131336Z-main-QXSS_A22原生字段与未来函数审计预注册|QXSS A22 原生字段审计]]
- 上游等价 formal：[[04_实验记录/EX-20260607T131209Z-main-A22N_A22原生字段等价审计预注册|A22N 原生等价 formal]]
- 上游日志/日期审计：[[04_实验记录/EX-20260607T152511Z-main-EKZ8_A22原生字段日志与未来函数二次审计|EKZ8 日志/日期审计]]
- 产生的决策：待定
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：A22 已经能用原生字段复现结果后，能不能安全进入默认关闭观察和 forward/shadow 边界验证。

我们原本预计：native A22 live 组应复现 A22N 的 native 结果；shadow_on/off 组应只多写 A22 shadow 日志，不改变交易产物；所有配置必须显式互斥 A13/A22。

实际看到：待执行。

这说明：待补。

但还不能说明：即使通过，也只说明工程边界和日志隔离通过，不等于 A22 可以实盘或替代 hard5。

下一步要做：实现默认关闭 A22 shadow 日志、生成配对配置、可见运行四段 formal，并做 strict 汇总。

## 2. 研究背景

这个实验属于 `RD-20260605T133318Z-main-H6V3`。K3AC 已把 score-cap 主线切回 A22 cap70；QXSS 发现旧 A22 实际复用了 A13 字段；A22N 证明 legacy A13 字段表达和 native A22 flat cap70 完全等价；EKZ8 又补齐日志语义和可见日期顺序审计。

剩余阻塞是工程边界：A22 native 不能直接进入生产，需要先证明两件事：

- live 配置能用原生 A22 字段可见复现 A22N 结果。
- shadow 配置在默认关闭观察状态下只写日志，不改变 orders/trades/equity/positions。

本实验不寻找新收益，只做 A22 native 的 forward/shadow 边界验证。

## 3. 实验前假设

在四个固定分段中，A22 native live 可复现 A22N native 行为；A22 shadow_on/off 可证明默认关闭观察不改变交易产物，并且日志、manifest 和可见日期顺序满足 strict gate。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：live 组四段 final/MDD/trades/fee 与 A22N native 对应分段完全一致；shadow_on/off 四段关键交易产物 hash 完全一致。
- 交易行为：shadow_on 比 shadow_off 只多 `R010-A22 SHADOW` 日志，orders/trades/equity/positions/subportfolio_equity 不变；live 组只出现 A22 live 指纹，不出现 A13 live 指纹。
- 风险表现：本实验不新增收益优势判断；只复核工程边界。2025_20260519 若与 A22N 不一致则失败。
- 分段表现：2020_2021、2022_2023、2025_20260519 应出现 A22 触发或 shadow 触发记录；2024 可作为零触发负控。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| A22N `native_a22_cap70` | live 复现基准 | `${QUANT_PLATFORM_ROOT}/results/v2/research/R010-A22/native_hot_score_budget/EX-20260607T131209Z-main-A22N/formal/native_a22_cap70/` |
| `native_a22_live` | 原生 A22 live 可见复现组 | `${QUANT_PLATFORM_ROOT}/configs/research/R010-A22/native_forward_shadow/EX-20260607T154134Z-main-QTFV/formal/native_a22_live/` |
| `a20_unbudgeted_shadow_off` | shadow 隔离对照，A20 放行但不启用 A22 live/shadow | `${QUANT_PLATFORM_ROOT}/configs/research/R010-A22/native_forward_shadow/EX-20260607T154134Z-main-QTFV/formal/a20_unbudgeted_shadow_off/` |
| `a20_unbudgeted_shadow_on` | 默认关闭 A22 shadow 观察组，不改变交易 | `${QUANT_PLATFORM_ROOT}/configs/research/R010-A22/native_forward_shadow/EX-20260607T154134Z-main-QTFV/formal/a20_unbudgeted_shadow_on/` |
| `double_on_guard` | 静态负控，仅检查 A13/A22 双开会被 strict 拒绝 | 不作为 formal 回测组 |

## 6. 竞争性解释

即使结果符合预期，也可能是：

- shadow_on/off 完全一致，可能只是 A22 shadow 没有触发或日志没有覆盖关键字段，而不是隔离证明充分。
- live 复现 A22N，可能只是再次跑同一历史样本，不能替代真正 forward 样本。
- A20 unbudgeted shadow 基线不是 hard5 真实生产路径；它只用于观察 A22 预算建议，不代表 hard5 已可安全启用 A22 shadow。
- 双开 A13/A22 若没有被静态 gate 拦住，可能出现 legacy 先应用、native 后覆盖的顺序干扰。

## 7. 证伪条件

出现以下情况，本假设不通过：

- 任一 formal 配置没有显式互斥 A13/A22。
- `native_a22_live` 四段 final/MDD/trades/fee 或关键 hash 与 A22N native 不一致且不能归因于日志外非策略差异。
- `a20_unbudgeted_shadow_on` 与 `a20_unbudgeted_shadow_off` 任一分段 orders/trades/equity/positions/subportfolio_equity 归一化 hash 不一致。
- shadow_on 没有输出 `R010-A22 SHADOW` 日志，或 shadow 日志缺少 `observe_date/signal_date/trigger/suggested_cap/orders_changed_by_shadow` 等核心字段。
- 任一可解析日志出现 `signal_date > trade_date` 或 `signal_date > observe_date`。
- run log 缺失、`exit_status` 非 0、manifest 缺少 config sha 或出现 `Traceback/ERROR/SystemError`。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 待检查 | 审计 `R010-A STATE`、`R010-B ACTION`、`R010-A22 SHADOW` 的 `signal_date/trade_date/observe_date` |
| 信号生成和成交价格不存在同 bar 泄漏 | 待检查 | 本实验只检查可见日期边界；成交模型继承平台 |
| 股票池或 ETF 池不存在未来成分泄漏 | 继承上游 | 不改 ETF 池 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | A22 不引入财务、宏观或估值字段 |
| Shadow 或观察信号未被当成默认交易信号 | 待检查 | shadow_on/off 交易产物 hash 必须一致 |

负控或错位检查：

- 2024 零触发负控：允许正确指纹为 0，但错误指纹必须为 0，shadow_on/off 产物必须一致。
- `double_on_guard` 静态负控：双开 A13/A22 不作为 formal 组，strict 必须能识别并拒绝。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | 不调参；只跑三组四段加一个静态双开负控 |
| 样本内、验证集、样本外划分清楚 | 部分 | 固定四段；2025_20260519 作为近端 forward-like 边界，不声明真实样本外 |
| 邻近参数敏感性合理 | 不适用 | 工程边界验证，不做阈值邻域 |
| 成本、滑点或换手扰动已检查 | 继承 K3AC/A22N | 本实验看交易产物隔离，不看收益优势 |
| 已做消融或负控 | 待检查 | shadow_on/off 和 double_on_guard |
| 未只报告最优结果 | 待检查 | 全部 12 个 formal 回测和 1 个静态负控都必须汇总 |

证据等级预期：`L1_engineering_shadow_boundary`。即使通过，也只支持默认关闭观察和下一步更严格 forward/shadow 研究，不支持生产 promote。

## 10. 子代理调用记录

适配判断：`适合调用`

调用状态：`called_running`

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-20260607T154000Z-main-A22FS-ENTRY | Archimedes | SUBTASK-20260607T154000Z-main-A22FS_子查_A22_native_forward_shadow脚本边界 | gpt-5.3-codex-spark | 2026-06-07T15:40:00Z | 平台 forward/shadow/observe 脚本、A22/A22N 脚本和策略源码 | 无 | 只读检索 | 运行中，未形成最终脚本边界清单 | 子代理不得判断无未来函数、promote 或默认切换 | 待主控复核 | 用于补充脚本复用和风险清单 |

台账行：待完成后同步 `01_台账/子代理调用台账.csv`。

## 11. 执行记录

### 平台配置

```text
${QUANT_PLATFORM_ROOT}/configs/research/R010-A22/native_forward_shadow/EX-20260607T154134Z-main-QTFV/formal/
${QUANT_PLATFORM_ROOT}/scripts/research/generate_qtfv_a22_native_forward_shadow_configs.py
${QUANT_PLATFORM_ROOT}/scripts/research/run_qtfv_a22_native_forward_shadow.sh
${QUANT_PLATFORM_ROOT}/scripts/research/summarize_qtfv_a22_native_forward_shadow.py
```

### 运行命令

```bash
cd /mnt/e/qp_v1_4_0
PYTHONIOENCODING=utf-8 python3 -m py_compile scripts/research/generate_qtfv_a22_native_forward_shadow_configs.py scripts/research/summarize_qtfv_a22_native_forward_shadow.py
PYTHONIOENCODING=utf-8 python3 scripts/research/generate_qtfv_a22_native_forward_shadow_configs.py
PYTHONUNBUFFERED=1 bash scripts/research/run_qtfv_a22_native_forward_shadow.sh
PYTHONIOENCODING=utf-8 python3 scripts/research/summarize_qtfv_a22_native_forward_shadow.py --strict
```

### 可见进度与日志

- 是否过程可见：是，run 脚本必须 `PYTHONUNBUFFERED=1` 并用 `tee` 写每个配置的 run log。
- 日志路径：`${QUANT_PLATFORM_ROOT}/results/v2/research/R010-A22/native_forward_shadow/EX-20260607T154134Z-main-QTFV/logs/formal/`
- 查看进度命令：`Get-ChildItem ${QUANT_PLATFORM_ROOT}/results/v2/research/R010-A22/native_forward_shadow/EX-20260607T154134Z-main-QTFV/logs/formal/ -Recurse`
- 异常判断：任一 run log 无 `exit_status=0`、任一 summary 缺失、strict gate 失败则本实验失败。
- 后台回测豁免：不后台运行。

```text
如后台或静默运行，必须写：
后台回测豁免：<原因>
进程标识：<pid或任务名>
日志路径：<path>
查看进度：<command>
停止方式：<command>
预计耗时：<duration>
```

### 结果路径

```text
${QUANT_PLATFORM_ROOT}/results/v2/research/R010-A22/native_forward_shadow/EX-20260607T154134Z-main-QTFV/formal/
${QUANT_PLATFORM_ROOT}/results/v2/research/R010-A22/native_forward_shadow/EX-20260607T154134Z-main-QTFV/logs/formal/
${QUANT_PLATFORM_ROOT}/results/v2/research/R010-A22/native_forward_shadow/EX-20260607T154134Z-main-QTFV/summary/formal/summary.json
```

## 12. 实际观察

待执行后补齐。

## 13. 支持证据

待执行后补齐。

## 14. 反对证据

待执行后补齐。

## 15. 偏差诊断

待执行后补齐。

## 16. 研究判断

建议状态：待执行后判断。预注册上限为 `observe` 或 `engineering_pass`，不得直接写 `promote`。

理由：待执行后补齐。

## 17. 下一步

若通过：进入 A22 native 默认关闭观察或更完整 forward/shadow 样本验证。若失败：先修复 shadow 日志、配置互斥或日期边界，不得推进观察候选。
