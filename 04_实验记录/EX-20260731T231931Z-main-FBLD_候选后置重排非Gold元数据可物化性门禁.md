---
type: 实验记录
ex_id: EX-20260731T231931Z-main-FBLD
rd_id: RD-20260731T090245Z-main-KLCN
status: completed
stage: development_smoke
owner: main
created_at: 2026-07-31T23:19:31Z
updated_at: 2026-07-31T23:35:12Z
strategy_id:
module_type:
decision_ids:
  - DEC-20260731T224543Z-main-7835
  - DEC-20260731T233700Z-main-ART8
lit_ids: []
idea_ids: []
platform_project: ${THINKTANK_PROJECT_ROOT}
config_paths:
  - ${THINKTANK_PROJECT_ROOT}/src/thinktank/memory/rerank_dev_gate.py
  - ${THINKTANK_PROJECT_ROOT}/config/schemas/rerank_dev_coverage.schema.json
  - ${THINKTANK_PROJECT_ROOT}/tests/test_rerank_dev_gate.py
result_paths:
  - hot://runs/EX-20260731T231931Z-main-FBLD/coverage_gate_v1/
summary_paths:
  - ${THINKTANK_PROJECT_ROOT}/docs/架构/候选长期记忆.md
quality_gate: stopped_pre_score_insufficient_coverage
subagent_call_ids:
  - SUB-20260731T231300Z-main-HSP35
  - SUB-20260731T231300Z-main-HSP36
  - SUB-20260731T231300Z-main-HSP37
subagent_exemption:
tags: [个人智库, 长期记忆, 非Gold元数据, 覆盖门禁, 候选重排, 开发实验]
---

# 候选后置重排非Gold元数据可物化性门禁

## 关联链接

- 研究方向：[[02_研究方向/RD-20260731T090245Z-main-KLCN_个人智库消息面结构化与长期记忆系统|个人智库消息面结构化与长期记忆系统]]
- 前序实验：[[04_实验记录/EX-20260731T225634Z-main-4PT7_候选记忆信息单元去重与实体消歧重排开发预注册|候选记忆信息单元去重与实体消歧L1工程合同]]
- 触发决策：[[05_研究决策/DEC-20260731T224543Z-main-7835_BM25保留候选召回但不得直接作为最终排序|BM25保留候选召回但不得直接作为最终排序]]
- 产生决策：[[05_研究决策/DEC-20260731T233700Z-main-ART8_候选重排V1因真实元数据覆盖不足停止评分|候选重排v1停止评分并先修数据合同]]
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

L1已经证明“可信元数据后处理”在代码层能安全工作，但真实新闻里未必已经有足够多可信标签。本实验先回答更基础的问题：不用qrels、事件族或封存错误答案，仅从检索文档、查询、内容哈希和公开来源谱系，究竟能生成多少可用的去重、产品和设施标签。

本轮只建可重复覆盖报告，不看重排后的Recall、MRR或nDCG。任何核心机制覆盖不足，都必须在加载Gold前停止评分。此前只读可行性审计已看见初步字段计数，因此本记录不把覆盖数量冒充未知预测；它预注册的是实现合同、精确复算点、失败门槛和停止动作。

## 2. 研究背景

EX-4PT7的合成夹具全部通过，但其`product_ids`、`facility_ids`和`information_unit_key`需要独立sidecar。若直接从开发集qrels、`event_nodes`或策展字段复制，得到的高分只是答案泄漏；若凭标题猜标签，又会把模型猜测伪装成确定事实。因此在任何真实评分前，必须先把非Gold可物化性做成独立门禁。

## 3. 实验前假设

一个字段白名单严格、时间与payload绑定完整的确定性投影器，可以在完全不读取Gold的进程中复算非Gold元数据覆盖；预计它只足以支持精确内容副本去重，尚不足以支持产品、设施或语义信息单元重排，因而应按预注册规则停止评分而不是补标签调参。

## 4. 实验前预测

下列数量来自实验创建前的只读可行性审计，属于待工程复算的固定点，不是盲预测：

| 检查项 | 固定复算点 |
| --- | ---: |
| 开发索引/查询 | 81篇 / 30问 |
| 内容哈希与查询源文档连接 | 81/81、30/30 |
| 完全相同内容组 | 2组、4篇 |
| 候选/查询存在可解析父链接 | 43/81、23/30 |
| 应带父链接的repost/derived_summary/correction完整率 | 8/11，72.7% |
| 安全规范`product_ids` | 0/81、0/30 |
| 安全规范`facility_ids` | 0/81、0/30 |
| Gold等价语义信息单元 | 0/81、0/30，禁止物化 |

工程点预测：

1. 白名单投影、sidecar、查询上下文和覆盖报告重复运行字节级一致。
2. 输出不得出现`event_family_id`、`chain_id`、`information_unit_id`、`relation_to_previous`、`risk_tags`、`selection_rationale`、qrels或相关等级。
3. `normalized_content_sha256`只允许折叠完全相同内容；`repost`父链可统计但不自动等同语义信息单元，`derived_summary/correction/official_publication/original`均不得硬合并。
4. 原始BM25固定取Top-20计算覆盖，输出目标仍为Top-10；候选sidecar连接、payload绑定和`feature_known_at`覆盖必须100%。
5. 去重、产品、设施每个机制必须至少覆盖8个可比较查询、12个成对案例和3个独立来源域；预计三项至少一项不达标，因此最终状态应为`insufficient_coverage`且qrels加载次数为0。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| 冻结开发索引与查询 | 唯一文本和时间输入 | `${THINKTANK_PROJECT_ROOT}/benchmarks/memory_recall_cn_v0/index_documents.jsonl`、`queries.jsonl` |
| 白名单来源投影 | 只提供URL、内容哈希、来源谱系和可得时间 | 由`source_manifest.jsonl`单向投影，运行时不接触原清单 |
| 净化包内BM25重建 | 覆盖进程只用导出后的索引、查询与配置重建Top-20，不复用旧Gold同进程run | `coverage_gate_v1/report/bm25_top20_run.json` |
| EX-4PT7 Schema | 约束sidecar与查询上下文 | `candidate_rerank_metadata.schema.json`、`candidate_rerank_query.schema.json` |

本轮不运行`A0-A5`消融和`N1-N4`负控评分。只有覆盖门禁全部通过，才允许在同一冻结包上一次性评分；预计不会到达该阶段。

进程边界在实现前固定为两段：`export`只允许读取`benchmark_manifest.json`中的安全文件绑定、`index_documents.jsonl`、`queries.jsonl`、`benchmark_config.json`和`source_manifest.jsonl`的白名单字段，输出严格净化packet；`analyze`只接收该packet目录，在包内以retrieval-only loader重建BM25 Top-20，工作目录中不得出现qrels、`event_nodes`、curation、旧run或评分报告。两段不能合并为一个同时看原基准目录和覆盖结论的便捷进程。本实验无论覆盖是否通过都不挂载qrels；若通过，评分仍须另行冻结并启动新命令。

## 6. 竞争性解释

- 现有开发集设计目标是BM25召回，不是实体注册表覆盖；产品/设施为零可能反映数据合同缺失，而不是这种重排机制无效。
- 精确哈希只有两个重复组，可能低估真实采集中的转载重复率。
- 来源父链72.7%可能来自早期清单建模不足，而非官方页面本身无法追溯。
- 即使连接率100%，常量`jurisdiction=CN`也没有消歧力，不能用它粉饰结构化覆盖。

## 7. 证伪条件

出现任一情况，本次门禁实现失败：

- 投影器或覆盖器读取qrels、`event_nodes`、curation或EX-AHS7任何正式排名/错误明细。
- 禁用字段进入投影、sidecar、日志或覆盖报告。
- 用标题、机构、域名或平面实体字符串自动猜产品、设施、细粒度辖区或语义信息单元。
- 把更正、修订、阶段更新、官方刊载或派生摘要自动折叠为父文档。
- payload、查询哈希、时间、注册表或验证产物绑定不是100%，仍继续评分。
- 覆盖不足后加载qrels、查看排序指标或补标签重跑。
- 相同输入两次报告不同，或输出候选不再是冻结BM25 Top-20的子集。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 只使用`query_as_of`前已公开且已进入BM25输入的候选 | 待检查 | 覆盖器只消费冻结run与索引 |
| `feature_known_at <= query_as_of` | 待检查 | sidecar逐条时间校验 |
| 查询自身和未来候选不被恢复 | 待检查 | 输出子集与时间负控 |
| 评分进程与Gold物理隔离 | 待检查 | 本轮预期qrels加载0次 |
| 正式holdout保持只读 | 待检查 | 根seal复验与无排名命令 |

负控：禁用字段注入、payload错配、未来`feature_known_at`、缺失父链接、同哈希不同文档、不同哈希父子文档、重复执行字节一致性。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| Top-K与通过线已预注册 | 是 | 原始K=20、输出K=10；8问/12对/3域 |
| 字段白名单已冻结 | 是 | 只含ID、URL、哈希、来源谱系与时间 |
| 不从Gold反推别名或类型 | 待检查 | 禁用文件与字段负控 |
| 覆盖不足即停止 | 待检查 | 报告状态与qrels加载计数 |
| 未只报告最优结果 | 待检查 | 单次完整覆盖报告 |

证据等级上限：`L1数据合同门禁`。即使通过，也不构成L2排序效果、事实批准或生产采用。

## 10. 子代理调用记录

适配判断：`适合调用`

调用状态：`called`

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `SUB-20260731T231300Z-main-HSP35` | Copernicus | `SUBTASK-L2-NONGOLD-SIDECAR-COVERAGE-AUDIT` | inherited | 2026-07-31T23:13:00Z | dev非Gold索引、查询、来源投影与候选Schema | 无 | 只读解析 | 给出可物化字段、覆盖点和最低门槛 | 不读Gold与正式排名 | 已复核 | 固定预评分覆盖点，预计只允许精确副本去重 |
| `SUB-20260731T231300Z-main-HSP36` | Descartes | `SUBTASK-L2-EVAL-LEAKAGE-CONTRACT-AUDIT` | inherited | 2026-07-31T23:13:00Z | dev基准、scorer与rerank接口 | 无 | 只读解析 | 要求导出与覆盖分进程、净化包内重建Top-20、覆盖通过并冻结运行后才可由第三进程挂Gold | 不读EX-AHS7正式排名 | 已复核 | 禁止复用旧Gold同进程BM25 run，并补验证产物真实存在门禁 |
| `SUB-20260731T231300Z-main-HSP37` | Boole | `SUBTASK-L2-ABLATION-STOP-RULE-AUDIT` | inherited | 2026-07-31T23:13:00Z | L1合同与预注册草案 | 无 | 只读审计 | 固定6消融、4负控和覆盖停止条件 | 已接触旧封存材料，不得参与新holdout | 已复核 | 覆盖不足必须在评分前停止 |

台账行：完成后同步`01_台账/子代理调用台账.csv`。

## 11. 执行记录

### 平台配置

```text
${THINKTANK_PROJECT_ROOT}=E:/智库
开发集=benchmarks/memory_recall_cn_v0
正式holdout=禁止读取与运行
```

### 计划命令

```powershell
$env:PYTHONPATH = (Resolve-Path 'src').Path
python -m thinktank.memory.rerank_dev_gate export --benchmark-dir benchmarks/memory_recall_cn_v0 --created-at 2026-07-31T23:19:31Z --output .runtime/hot/runs/EX-20260731T231931Z-main-FBLD/coverage_gate_v1/packet
python -m thinktank.memory.rerank_dev_gate analyze --packet .runtime/hot/runs/EX-20260731T231931Z-main-FBLD/coverage_gate_v1/packet --output .runtime/hot/runs/EX-20260731T231931Z-main-FBLD/coverage_gate_v1/report
python -m thinktank.memory.rerank_dev_gate validate --packet .runtime/hot/runs/EX-20260731T231931Z-main-FBLD/coverage_gate_v1/packet --report .runtime/hot/runs/EX-20260731T231931Z-main-FBLD/coverage_gate_v1/report/coverage_report.json
python -m pytest -q tests/test_rerank_dev_gate.py
```

### 可见进度与日志

- 是否过程可见：是，预计一分钟内前台完成。
- 日志路径：`hot://runs/EX-20260731T231931Z-main-FBLD/coverage_gate_v1/`。
- 异常判断：任何禁用字段、哈希漂移、时间倒灌或非确定性立即失败。
- 后台回测豁免：本任务不是回测，不启动后台进程。

### 结果路径

```text
hot://runs/EX-20260731T231931Z-main-FBLD/coverage_gate_v1/
```

## 12. 实际观察

1. 已实现`rerank_dev_gate.py`、覆盖报告Schema和8项门禁测试。导出进程只读取冻结manifest的安全绑定、索引、查询、BM25配置和来源清单白名单；覆盖进程只读取12个净化packet文件，并在其中以retrieval-only loader重建Top-20，没有复用旧Gold同进程run。
2. packet含81篇文档、30个查询、81份候选sidecar和30份查询上下文。候选连接、查询连接、Top-20 sidecar、payload、查询payload、`feature_known_at`和验证产物绑定率全部为`1.0`；禁用字段发现数为0。
3. 净化包内BM25实际产生596条Top-20候选行。精确内容键影响13个查询、13个配对和3个来源域，达到`8问/12对/3域`机制覆盖门槛；全库只有2个相同内容组、共4篇，因此这里只能解释为“精确副本去重可测”，不能解释为语义信息单元已解决。
4. `product_ids`与`facility_ids`在候选侧和查询侧均为0，两个机制的可比较查询、配对和来源域均为0，明确不达门槛。
5. `repost/derived_summary/correction`共11篇，只有8篇有且能解析父链接，完整率与解析率均为`0.727272727`，低于1.0门槛。普通父链继续只作谱系，不自动硬合并。
6. 覆盖报告状态为`insufficient_coverage`、`scoring_authorized=false`、`gold_loaded=false`、`qrels_load_count=0`。主控按预注册停止，没有运行A0-A5、没有查看Recall/MRR/nDCG、没有补标签重跑。
7. 定向测试8项+2项子测试、全量157项测试+153项子测试、`compileall`和项目门禁全部通过；门禁检查199个UTF-8文本与60个JSON。正式holdout根seal复验`ok=true`，哈希仍为`sha256:79733fd35e4c491d577f217ddccbdd4dc14d1d59b6f747c45c099dc9984c985e`。

## 13. 支持证据

- 覆盖报告：`hot://runs/EX-20260731T231931Z-main-FBLD/coverage_gate_v1/report/coverage_report.json`，SHA-256为`sha256:5f3bd9e05415210bed15c43e7e63ea250ab0bc75cf446ddf33ebfd22958d917c`。
- 净化packet manifest：`hot://runs/EX-20260731T231931Z-main-FBLD/coverage_gate_v1/packet/retrieval_manifest.json`，SHA-256为`sha256:9c8742b978b853ebf07ed62231e79a38642ed73230c9c797ee6dd0b521b68c8e`。
- 净化包内Top-20 run：`hot://runs/EX-20260731T231931Z-main-FBLD/coverage_gate_v1/report/bm25_top20_run.json`，SHA-256为`sha256:7f2fdfd96ff2294f807eb0f1eac1aa9b7a5490bcca65b65d66104668388559af`。
- 实现与负控：`${THINKTANK_PROJECT_ROOT}/src/thinktank/memory/rerank_dev_gate.py`、`config/schemas/rerank_dev_coverage.schema.json`、`tests/test_rerank_dev_gate.py`。
- 禁用字段突变不改变安全投影；父链接不同哈希不共享信息单元键；注入qrels或篡改验证产物均被拒绝；相同创建时间的两套packet与报告逐文件字节一致。

## 14. 反对证据

- 产品与设施规范ID覆盖为0，当前v1实体消歧没有真实输入，不能评分更不能采用。
- 父链完整率只有72.7%，且`original`、`official_publication`、`derived_summary`与`correction`都可能包含新信息；来源关系不能替代信息单元裁决。
- 精确哈希去重只覆盖完全相同内容，不能识别改写、摘要、同一发布会不同载体或同事件不同阶段。
- 这是已见开发集上的数据合同门禁，不是L2排序效果，也不能外推到人物、部门、跨机构新闻或生产流量。

## 15. 偏差诊断

初步审计的81/30、2组4篇、43/81、23/30、8/11和产品/设施为0均被确定性复算。预注册只预计“至少一项机制不足”，实际精确内容键在Top-20中达到13问、13对、3域，比仅看全库两个重复组更广，因为同一镜像会在多个查询中重复出现；这支持继续研究精确副本去重，但不改变完整v1门禁失败。停止规则得到忠实执行，未产生排序指标。

## 16. 研究判断

建议状态：`revise`

EX-4PT7的代码合同继续保留，精确`normalized_content_sha256`副本去重可以进入独立后续验证；但`verified_metadata_priority_v1`整体不得评分、不得接默认召回，也不得用0覆盖的产品/设施字段宣称实体消歧。当前路线应从“立即评估v1重排”修订为“先建设独立类型注册表、角色化实体与可验证来源关系数据合同”。

## 17. 下一步

新增路线决策卡，固定“v1停止评分、精确副本去重单独保留、类型消歧先补数据合同”。下一实验不得在当前开发集上人工补产品/设施答案；应先定义独立实体注册表Schema、实体类型与角色、别名证据、注册表版本、人工复核抽样和至少90%查询/80%候选/95%精度门槛，再用未参与注册表设计的开发材料做覆盖门禁。关系层另行建模，不能把`source_parent_url`直接当相关性或因果边。
