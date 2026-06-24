---
type: 实验记录
ex_id: EX-20260624T013047Z-main-GTUS
rd_id: RD-20260623T125116Z-main-DVXD
status: completed
stage: storage_design_gate_completed_no_network
owner: main
created_at: 2026-06-24T01:30:47Z
updated_at: 2026-06-24T01:34:12Z
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 进攻与核心轮动扩展模块
decision_ids: [DEC-20260624T013403Z-main-9AF6]
lit_ids: []
idea_ids: []
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths:
  - scripts/research/prepare_gtus_tushare_sw_industry_import_gate.py
  - scripts/research/test_gtus_tushare_sw_industry_import_gate.py
result_paths:
  - results/v2/research/RD-20260623T125116Z-main-DVXD/EX-20260624T013047Z-main-GTUS/
summary_paths:
  - results/v2/research/RD-20260623T125116Z-main-DVXD/EX-20260624T013047Z-main-GTUS/storage_design.json
  - results/v2/research/RD-20260623T125116Z-main-DVXD/EX-20260624T013047Z-main-GTUS/storage_design_report.md
quality_gate: storage_design_completed_no_external_fetch
subagent_call_ids: []
subagent_exemption: 当前是主控存储架构判断，且可用子代理工具要求用户显式请求；主控：main；时间：2026-06-24T01:34:12Z
tags: [双池轮动, 行业轮动, 个股增强, Tushare, 申万行业, 数据导入, schema]
---

# Tushare申万行业成分导入门禁

## 关联链接

- 研究方向：[[02_研究方向/RD-20260623T125116Z-main-DVXD_双池轮动行业状态机与个股增强模块|双池轮动行业状态机与个股增强模块]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 来源文献或灵感：[[04_实验记录/EX-20260623T234552Z-main-QKD7_历史行业成分数据源盘点门禁|QKD7 历史行业成分数据源盘点]]
- 产生的决策：[[05_研究决策/DEC-20260624T013403Z-main-9AF6_申万行业成分采用独立membership事实表|申万行业成分采用独立membership事实表]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：如果用 Tushare 补申万行业成分，数据应当怎么存，才不会给回测带来未来函数。
我们原本预计：不能直接写入 `jq_stock_info.sw_l1/sw_l2/sw_l3`，因为它没有日期维度；也不能简单塞进 `index_constituent`，因为现有读取逻辑要求完整快照。
实际看到：平台脚本生成了三张草案表：`ts_sw_industry_raw`、`sw_industry_classification`、`industry_stock_membership`；其中 `industry_stock_membership` 是推荐事实源。
这说明：行业成分应当单独建带 `in_date/out_date` 的 membership 表，回测按信号日做点位过滤。
但还不能说明：Tushare 真实字段已经完全满足门禁，因为本轮没有联网拉取真实数据。
下一步要做：用户明确允许后，运行小样本 Tushare 网络探针，确认 `index_member_all` 字段可还原 `stock + industry + in_date/out_date`。

## 2. 研究背景

QKD7 已确认本地没有可回测历史行业成分。用户说明 Tushare 账号积分充足，因此本实验先解决“拿到数据后如何存储”的问题，避免后续导入时破坏现有平台表语义。

## 3. 实验前假设

申万行业成分必须作为独立历史事实表存储，不能直接补到静态证券信息表；若要兼容现有指数成分接口，需要在门禁通过后另行生成完整快照层。

## 4. 实验前预测

如果假设为真，应该看到：

- 指标：schema 草案包含 `taxonomy/taxonomy_version/level/industry_code/stock_symbol/in_date/out_date/source/batch_id`。
- 交易行为：本实验不交易。
- 风险表现：本实验不评价收益风险。
- 分段表现：本实验不做回测。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| `jq_stock_info` | 静态证券信息表，行业字段无日期维度，不适合做历史事实源 | `${QUANT_PLATFORM_ROOT}` ClickHouse |
| `index_constituent` | 现有指数成分快照表，要求每个 `effective_date` 是完整快照 | `${QUANT_PLATFORM_ROOT}` ClickHouse |
| `QKD7` | 证明本地历史行业成分缺失 | [[04_实验记录/EX-20260623T234552Z-main-QKD7_历史行业成分数据源盘点门禁]] |

## 6. 竞争性解释

即使独立表更安全，也可能存在其他做法：

- 扩展 `index_constituent` 为行业成分快照事实源，但必须生成完整快照，不能只插入纳入/剔除事件。
- 为 `jq_stock_info` 填最新行业字段，作为展示或快速筛选，但不能用于历史回测。
- 如果 Tushare 字段不含可靠 `out_date`，需要从连续快照差分生成退出日期。

## 7. 证伪条件

出现以下情况，本假设不通过：

- schema 无法表达 `in_date/out_date`。
- 无法保留 Tushare 原始行和批次追踪。
- 同一股票同一日期一级行业多重归属无法检测。
- 兼容 `index_constituent` 时误用事件表语义，导致现有 `max(effective_date)<=date` 查询只拿到新增成员。

本轮未触发证伪条件；但尚未做 Tushare 真实字段探针。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 待后续 | 本轮只做 schema，不拉真实数据 |
| 信号生成和成交价格不存在同 bar 泄漏 | 不适用 | 未生成信号 |
| 股票池或 ETF 池不存在未来成分泄漏 | 设计通过 | 查询规则固定为 `in_date <= signal_date AND (out_date IS NULL OR out_date > signal_date)` |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 未使用 |
| Shadow 或观察信号未被当成默认交易信号 | 通过 | 未改策略配置，未写数据库 |

负控或错位检查：

- 本轮是 schema 门禁，不做收益负控。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 通过 | 无收益参数 |
| 样本内、验证集、样本外划分清楚 | 不适用 | 未回测 |
| 邻近参数敏感性合理 | 不适用 | 无参数 |
| 成本、滑点或换手扰动已检查 | 不适用 | 未交易 |
| 已做消融或负控 | 不适用 | schema 门禁 |
| 未只报告最优结果 | 通过 | 同时记录主表、原始表和兼容层限制 |

证据等级：`L1`

## 10. 子代理调用记录

适配判断：`不适合调用`

调用状态：`exempt`

子代理豁免：

```text
子代理豁免：当前是主控存储架构判断，且可用子代理工具要求用户显式请求；主控：main；时间：2026-06-24T01:34:12Z
```

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |

台账行：

```text
无；本轮未调用子代理，仅在正文记录豁免。
```

## 11. 执行记录

### 平台配置

```text
${QUANT_PLATFORM_ROOT}/scripts/research/prepare_gtus_tushare_sw_industry_import_gate.py
${QUANT_PLATFORM_ROOT}/scripts/research/test_gtus_tushare_sw_industry_import_gate.py
```

### 运行命令

```bash
cd /mnt/e/量化平台_V1.4.0
PYTHONPATH=src python3 -m py_compile scripts/research/prepare_gtus_tushare_sw_industry_import_gate.py scripts/research/test_gtus_tushare_sw_industry_import_gate.py
PYTHONPATH=src python3 -m pytest -q scripts/research/test_gtus_tushare_sw_industry_import_gate.py
PYTHONUNBUFFERED=1 PYTHONPATH=src python3 scripts/research/prepare_gtus_tushare_sw_industry_import_gate.py
```

### 可见进度与日志

- 是否过程可见：`是`
- 日志路径：终端输出；结构化结果在结果目录。
- 查看进度命令：不适用，脚本默认模式 1 秒内完成。
- 异常判断：pytest 仅有 `.pytest_cache` 权限警告，不影响 6 个单测通过。
- 后台回测豁免：未运行回测，未后台执行。

### 结果路径

```text
${QUANT_PLATFORM_ROOT}/results/v2/research/RD-20260623T125116Z-main-DVXD/EX-20260624T013047Z-main-GTUS/
```

## 12. 实际观察

| 指标 | 基准 | 本次 | 变化 | 解释 |
| --- | --- | --- | --- | --- |
| 事实源表 | 不能是静态表 | `industry_stock_membership` | 通过 | 带日期、层级、来源和批次 |
| 原始数据追溯 | 必须保留 | `ts_sw_industry_raw` | 通过 | 保留 raw_json 和 row_hash |
| 行业分类表 | 需要独立 | `sw_industry_classification` | 通过 | 存 taxonomy/version/level |
| `jq_stock_info` | 不做事实源 | 明确禁止 | 通过 | 无日期维度 |
| `index_constituent` | 只能兼容 | 需完整快照后再派生 | 通过 | 现有查询不适合纳入/剔除事件表 |
| 单测 | 通过 | 6 passed | 通过 | 仅 pytest cache 警告 |
| Tushare 网络探针 | 未执行 | 未执行 | 边界清楚 | 需用户显式允许 |

## 13. 支持证据

- `storage_design.json` 记录推荐事实源为 `industry_stock_membership`，禁止把 `jq_stock_info` 作为事实源。
- `schema_ddl.sql` 包含原始层、分类层和 membership 事实层三张表。
- 脚本明确默认模式为 `no_network_no_db_write`。
- 单测覆盖代码归一化、日期解析、L1/L2/L3 展开、重复键和同日多一级行业检测。

## 14. 反对证据

- 尚未调用 Tushare，不能确认 `index_member_all` 真实字段名和完整性。
- 尚未评估全量数据规模、写库速度和 ClickHouse 分区表现。

## 15. 偏差诊断

实验前以为可以考虑补 `index_constituent`，但检查平台现有读取逻辑后发现：现有方法按 `max(effective_date)<=date` 取同一日期全部成员，因此如果只导入 Tushare 的纳入/剔除事件，会导致查询只返回最新变动股票，而不是完整行业成分。这强化了独立 membership 事实表的必要性。

## 16. 研究判断

建议状态：`promote_candidate`

理由：存储架构门禁通过，但只限 schema 设计层。它允许进入下一步 Tushare 小样本网络探针，不允许直接全量导入或改策略。

## 17. 下一步

用户明确允许后，运行：

```bash
PYTHONUNBUFFERED=1 PYTHONPATH=src TUSHARE_TOKEN=*** python3 scripts/research/prepare_gtus_tushare_sw_industry_import_gate.py --allow-network-probe --probe-limit 200
```

探针通过后，再新开正式导入实验，执行建表、全量拉取、覆盖率审计和 QKD7 重跑。
