---
type: 实验记录
ex_id: EX-20260801T120701Z-main-ZVRG
rd_id: RD-20260731T090245Z-main-KLCN
status: completed
stage: smoke_passed
owner: main
created_at: 2026-08-01T12:07:01Z
updated_at: 2026-08-01T13:10:49Z
strategy_id:
module_type:
decision_ids: []
lit_ids: []
idea_ids: []
platform_project: '${THINKTANK_PROJECT_ROOT}'
config_paths:
  - '${THINKTANK_PROJECT_ROOT}/config/schemas/intelligence_document_batch.schema.json'
  - '${THINKTANK_PROJECT_ROOT}/config/schemas/intelligence_document_capture_receipt.schema.json'
  - '${THINKTANK_PROJECT_ROOT}/config/schemas/intelligence_watch_registry.schema.json'
  - '${THINKTANK_PROJECT_ROOT}/src/thinktank/intelligence/document_capture.py'
  - '${THINKTANK_PROJECT_ROOT}/src/thinktank/intelligence/watch_registry.py'
  - '${THINKTANK_PROJECT_ROOT}/config/entity_coverage_sources_cn_v1.json'
  - '${THINKTANK_PROJECT_ROOT}/tests/test_intelligence_document_capture.py'
result_paths:
  - 'hot://intelligence/collection_runs/v1/ICR-20260801T120024Z-2253AE16C3/'
  - 'hot://intelligence/document_batches/v2/C11-document-batch-20260801T124510Z.json'
  - 'hot://intelligence/document_runs/v2/C11-live-20260801T125233Z/'
  - 'hot://intelligence/document_runs/v2/C11-live-20260801T125233Z.verification.json'
  - 'hot://intelligence/document_objects/v1/'
summary_paths:
  - '${THINKTANK_PROJECT_ROOT}/docs/架构/候选正文采集与内容寻址.md'
quality_gate: passed_l1_seen_sample_body_capture_no_promote
subagent_call_ids: [SUB-20260801T121000Z-main-C11P, SUB-20260801T124300Z-main-C11A]
subagent_exemption:
tags:
  - 个人智库
  - 集成修订
  - 正文采集
  - Schema绑定
  - 精确主机
  - 失败关闭
---

# 真实上游Schema与精确允许主机集成修订

## 关联链接

- 研究方向：[[02_研究方向/RD-20260731T090245Z-main-KLCN_个人智库消息面结构化与长期记忆系统|个人智库消息面结构化与长期记忆系统]]
- 策略档案：
- 来源文献或灵感：[[04_实验记录/EX-20260801T104617Z-main-U95B_绑定调度器的列表复验与候选正文内容寻址|C10失败关闭证据]]
- 产生的决策：
- 研究质量审计：[[08_方法论/研究质量审计规范|研究质量审计规范]]
- 子代理调用台账：[[01_台账/子代理调用台账.csv|子代理调用台账]]

## 1. 新手摘要

这次实验想知道：修正C10对真实上游Schema和主机语义的错误假设后，能否在不重跑列表、不换样本的前提下形成严格绑定的6条正文任务，并执行首次候选正文烟测。  
我们原本预计：C8注册表应由自己的正式Schema验证，不适用的`gold_loaded`字段不应被强造；C9的`source_domain`是采集域策略，C8的`canonical_host`才是正文精确主机，二者必须分层保存。  
实际看到：C11严格重建了原6条URL和顺序，31项专项、475项全库及独立代码审计通过；唯一一次live烟测正好发出6次请求、0重试，政府网、上交所和白宫各2条全部形成候选正文，离线重放也6/6通过。  
这说明：v2已经把真实C8 Schema、C9目录域和C8正文精确主机正确分层，且能用写一次、内容寻址和固定回执形成可独立复验的候选正文资产。  
但还不能说明：这6条页面内容必然完整或真实，也不能外推持续采集SLA、未来未见样本、模型提炼质量、长期记忆或自动决策；本批URL此前已经看过，只是L1开发烟测。  
下一步要做：保留本批不重跑，等待未来新C9运行产生未见URL后另开独立确认；通过前不写事实、长期记忆、行动或交易层。

## 2. 研究背景

本实验属于个人智库消息面结构化与长期记忆系统，是C10的直接修订。C10的29项合成测试与474项全库测试虽通过，但实际batch编译发现两个跨层误建模：C8正式注册表没有`gold_loaded`，C9目录域`gov.cn`/`sse.com.cn`也不等于C8精确发布主机`www.gov.cn`/`www.sse.com.cn`。C10没有生成batch，正文网络请求为0，因此可以在保留失败证据的前提下建立新版本。

本轮复用以下已封存C9证据，不再次联网：

- 计划：`hot://intelligence/collection_runs/v1/C10-bound-run-plan-20260801T120024Z.json`，文件哈希`sha256:7275050f816cff99392940d8d4c9d942ea4a22293f9ba61e42374a60aa205cba`。
- 回执：`hot://intelligence/collection_runs/v1/ICR-20260801T120024Z-2253AE16C3/receipt.json`，语义哈希`sha256:c59c904b11fc773adeaf5dbc62cf35458c8d8ca0c56b4a169b4687dc71b98c5f`。
- 核验：`hot://intelligence/collection_runs/v1/ICR-20260801T120024Z-2253AE16C3.verification.json`，报告哈希`sha256:3f2743e982f669bcf6a83e06d01405d131f56092fa5bc110db509d40c511945f`，`verified_at=2026-08-01T12:02:29Z`。

在任何C11代码修改前冻结的任务清单如下。允许主机只取C8 `canonical_host`，不是从这些URL反推：

| 顺序 | 渠道/原数组索引 | C8精确主机 | 冻结URL |
| --- | --- | --- | --- |
| 0 | `CHANNEL-CN-GOV-POLICY / 0` | `www.gov.cn` | `https://www.gov.cn/zhengce/content/202607/content_7077199.htm` |
| 1 | `CHANNEL-CN-GOV-POLICY / 1` | `www.gov.cn` | `https://www.gov.cn/zhengce/content/202607/content_7077172.htm` |
| 2 | `CHANNEL-CN-SSE-ANNOUNCEMENTS / 0` | `www.sse.com.cn` | `https://www.sse.com.cn/disclosure/announcement/general/jjzssgg/c/c_20260731_10827449.shtml` |
| 3 | `CHANNEL-CN-SSE-ANNOUNCEMENTS / 1` | `www.sse.com.cn` | `https://www.sse.com.cn/disclosure/announcement/general/jjzssgg/c/c_20260731_10827451.shtml` |
| 4 | `CHANNEL-US-WHITEHOUSE-ACTIONS / 0` | `www.whitehouse.gov` | `https://www.whitehouse.gov/presidential-actions/2026/07/to-facilitate-positive-adjustment-to-competition-from-imports-of-quartz-surface-products/` |
| 5 | `CHANNEL-US-WHITEHOUSE-ACTIONS / 1` | `www.whitehouse.gov` | `https://www.whitehouse.gov/presidential-actions/2026/07/presidential-permit-authorizing-cameron-county-texas-to-own-operate-and-maintain-the-brownsville-and-matamoros-bridge-in-brownsville-texas/` |

对应`entries.json`文件哈希依次为国务院`sha256:3bea777d7cfebba377fbb0da9e3e4c1ea22f6e75e7ff50fefc0340f72b68002b`、上交所`sha256:2b02c8c6b750443420631376f8580e3d8f3c24e41f3dffae05a01080c7f73a4d`、白宫`sha256:f1e60a26f608f7e55f79aed8bece2b89aa5b6a8224427b601ebc1387b0fdfdea`。

代码修改前冻结的正式上游依赖：

```text
watch_registry_validator_sha256=sha256:2fc54d6f192a4e022f6ab9d3c8168dfff7a60c52e281d2e43ce05b0b180a9f35
watch_registry_schema_sha256=sha256:0f4ca2d57382b39630e4c2c2ec954df846a75e3a647dbfd3905c217c32c4bdff
source_catalog_file_sha256=sha256:c5cbcf07ce0b8e6f07439fd5728e459305589fa49702973a3eee937be581710d
```

主机规则冻结为两个不同方向的公式：

```text
上游一致性：c8_canonical_host == c9_source_domain
           or c8_canonical_host.endswith("." + c9_source_domain)
正文授权：candidate_host == requested_host == final_host == c8_canonical_host
```

所有主机先小写、移除末尾点并转为IDNA ASCII。第一条只能证明C8精确主机落在C9带点边界的目录域内，C9域本身绝不能进入正文allowlist。必须用`evilgov.cn`、`www.gov.cn.evil.com`和反向比较做负控；未来多主机只能修改C8 Schema并另开实验。

## 3. 实验前假设

若C11逐对象调用或等价重放正式Schema合同，并把C9目录域策略与C8正文精确主机分层，则同一封存C9证据可以确定性生成原6条任务；正式live抓取仍受精确C8主机、内容寻址、时间和权限门约束。

## 4. 实验前预测

如果假设为真，应该看到：

- 集成指标：必须直接调用`validate_watch_registry`，C8注册表按正式Schema与来源目录绑定通过且无需伪造`gold_loaded`；其他明确拥有该字段的对象仍必须为false，禁止人工“等价字段子集”替代。
- 主机指标：C9 `source_domain`只作为目录采集策略；它必须包含C8 `canonical_host`，而列表URL、候选URL和正文最终URL必须逐字匹配C8精确主机。
- 样本指标：batch仍恰为6条，顺序固定为国务院2条、上交所2条、白宫2条；URL与C10预览完全一致。
- 安全指标：合成运行永久不可下游；live禁止注入fetcher；回执、attempt、内容对象和成功语义可重放；模型、记忆、数据库写入均为0。
- 可用率点预测：至少5/6正文形成`succeeded`；未达到只反对可用率，不自动反对已通过的安全合同。
- 交易行为、风险表现、分段表现：不适用，本实验无交易和模型推断。

## 5. 基准和对照

| 对照 | 用途 | 路径 |
| --- | --- | --- |
| C10失败关闭 | 证明旧实现真实集成失败且正文请求为0 | `EX-20260801T104617Z-main-U95B` |
| 同一C9封存闭包 | 排除重跑列表或换样本造成的差异 | `hot://intelligence/collection_runs/v1/ICR-20260801T120024Z-2253AE16C3/` |
| C8正式注册表Schema与验证器 | 决定上游字段适用性，不允许人工等价子集 | `${THINKTANK_PROJECT_ROOT}/config/schemas/intelligence_watch_registry.schema.json`；`${THINKTANK_PROJECT_ROOT}/src/thinktank/intelligence/watch_registry.py` |
| 合成负控 | 验证缺失必填权限、伪造Gold、目录域越界、正文非精确主机、live注入和重签产物均失败 | `${THINKTANK_PROJECT_ROOT}/tests/test_intelligence_document_capture.py` |

## 6. 竞争性解释

即使结果符合预期，也可能只是：

- 已看过同一6条URL后的开发修订成功，不代表独立样本泛化。
- 三个站点当前页面恰好适配HTML抽取器，不代表PDF、JS渲染、验证码或其他官方站点。
- C8精确主机恰好覆盖当前URL；未来真正多主机渠道仍需新C8 Schema显式列出，不得由C11自动推断。
- 哈希和重放只能证明包内一致性，不能独立证明外部发布者真实性或内容没有被源站改写。

## 7. 证伪条件

出现以下任一情况，本假设不通过：

- 为让实际资产通过而给旧C8文件补写字段、重签旧C8/C9对象、重跑C9列表或更换/补抽URL。
- C8注册表没有直接调用`validate_watch_registry`并绑定正式Schema、验证器代码和来源目录完整文件哈希，或任何实际定义了`gold_loaded`的对象不是false。C8 Schema规定`additionalProperties=false`，因此registry里`gold_loaded`必须缺失，出现也应失败。
- 使用`www`剥离、后缀猜测、eTLD+1或运行后新增别名来放宽正文主机；正文最终URL不等于冻结C8 `canonical_host`。
- batch不是预注册的6条及相同顺序，或不能从C8/C9原文件在原`verified_at`精确重建。
- synthetic结果获得下游权限，live接受自定义fetcher，或重签回执/对象/attempt能伪造成功。
- 读取Gold、qrels、curation、event_nodes、formal holdout，调用模型，写记忆/PostgreSQL，或打开事实/行动/交易权限。
- 专项或全库门禁新增失败；正文运行超过6次逻辑请求或发生重试。

## 8. 未来函数审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 数据时间戳只使用当时可得信息 | 预注册通过条件 | 复用C9 `first_seen_at`与原`verified_at`；列表提示优先，正文时间仅在提示缺失时使用 |
| 信号生成和成交价格不存在同 bar 泄漏 | 不适用 | 无信号和交易 |
| 股票池或 ETF 池不存在未来成分泄漏 | 不适用 | 无股票池 |
| 财务、宏观或估值数据按可得日处理 | 不适用 | 本轮只做网页候选正文 |
| Shadow 或观察信号未被当成默认交易信号 | 是 | 输出固定candidate，行动与交易权限false |

负控或错位检查：

- 把任何发布时间改为晚于`first_seen_at`必须失败。
- 列表和正文时间相差超过36小时必须失败。
- 改变C9条目顺序、C8精确主机或任一上游哈希后，batch重建必须失败。
- `evilgov.cn`、`www.gov.cn.evil.com`、把目录域与精确主机反向比较，以及候选/最终URL只满足C9目录域但不等于C8主机，必须失败。
- 禁止读取`Gold`、`qrels`、`curation`、`event_nodes`和formal holdout；测试只用合成夹具和已封存非Gold上游元数据。

## 9. 过拟合审计

| 检查项 | 结论 | 证据 |
| --- | --- | --- |
| 参数搜索空间已预注册 | 是 | 无参数搜索；主机只取C8单一`canonical_host` |
| 样本内、验证集、样本外划分清楚 | 是 | 本轮是已见URL的开发集成复验，不宣称独立样本外证据 |
| 邻近参数敏感性合理 | 不适用 | 不调阈值；100字符与36小时沿用C10冻结值 |
| 成本、滑点或换手扰动已检查 | 不适用 | 无交易 |
| 已做消融或负控 | 待执行 | 正式Schema形状、缺失/伪造权限、目录域边界、精确主机、live/synthetic和重签重放 |
| 未只报告最优结果 | 预注册通过条件 | 6条全部保留唯一终态，不补抽、不删除失败 |

证据等级：最高`L1`开发集成与一次小样本正文烟测；因URL已见，不是独立确认或生产证据。

## 10. 子代理调用记录

适配判断：`适合调用；将新版本的跨Schema与主机边界合同交由只读子代理审计，主控保留规则、实现、联网和最终判断`

调用状态：`called / completed`

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `SUB-20260801T121000Z-main-C11P` | Anscombe | `SUBTASK-C11-INTEGRATION-PREREG-AUDIT` | inherited | 2026-08-01T12:10:00Z | 本实验预注册、C10失败证据及C8/C9只读Schema/元数据 | 无 | 无网络、无代码执行 | 只审计字段适用性、主机边界和样本冻结，不判断正文事实 | 无P0；正式C8验证器未冻结、域包含公式方向不够明确、联网后样本失败与系统失败未分流3项P1 | 已逐项复核并采纳；样本锁定无阻断 | 新增正式验证器/Schema/来源目录哈希、带点边界单向公式、恶意域负控及系统中止未启动终态 |
| `SUB-20260801T124300Z-main-C11A` | Anscombe | `SUBTASK-C11-P0P1-CODE-AUDIT` | inherited | 2026-08-01T12:43:00Z | C11两份Schema、正文实现与专项测试 | 无 | 无网络、只读静态审计 | 只判断首次6请求烟测前的P0/P1，不判断正文事实 | 未发现阻止烟测的P0/P1；确认正式C8/来源目录绑定、域公式方向、逐请求重放、系统熔断计数和整批下游关闭 | 主控逐行复核并在专项、全库和真实batch重放通过后采纳 | 允许按预注册固定6条执行唯一一次live烟测；不增加事实或行动权限 |

台账行：已同步`01_台账/子代理调用台账.csv`；两次调用均不参与正文读取、事实判断、模型或Gold。

## 11. 执行记录

### 平台配置

```text
状态=completed / smoke_passed
project=${THINKTANK_PROJECT_ROOT}
python=3.14.4
storage_profile=hybrid/provisional
c9_list_network_requests=0（复用封存运行）
c11_body_network_requests=6/6
c11_body_retries=0
gold/qrels/curation/event_nodes/formal_holdout=disabled
model_calls=0
memory/postgresql_writes=0
```

### 运行命令

```powershell
$env:PYTHONPATH = (Join-Path (Get-Location) 'src')
python -m pytest -q tests/test_intelligence_document_capture.py
python -m pytest -q
pwsh.exe -NoProfile -File scripts/Test-ThinkTankRepo.ps1
python -m thinktank.intelligence.document_capture compile <同一C8/C9闭包 + 显式来源目录；输出C11-document-batch-20260801T124510Z.json>
python -m thinktank.intelligence.document_capture run <冻结batch；输出C11-live-20260801T125233Z；live；6条；一次；零重试>
python -m thinktank.intelligence.document_capture verify-run <固定回执与batch；输出C11-live-20260801T125233Z.verification.json>
```

### 可见进度与日志

- 是否过程可见：是；正文任务逐条前台打印终态。
- 日志路径：`hot://intelligence/document_runs/v2/`写一次回执与attempt。
- 查看进度命令：前台JSON；每完成一条立即显示渠道、task、HTTP、字符数和错误阶段。
- 异常判断：代码/Schema/上游哈希漂移、样本不是冻结6条、非精确C8主机、输出碰撞、权限字段错误、请求超预算、重试或任何门禁失败均停止。
- 后台回测豁免：不适用；不是回测，不启动后台任务。

联网后的停止规则按故障所有权冻结：

- `sample_failure`：单篇HTTP/TLS、跨主机最终URL、挑战页、短正文、无发布时间或36小时时间冲突。该条记唯一失败终态，继续处理剩余冻结任务；不重试、不补抽。
- `system_boundary_failure`：下一请求前发现fetcher身份、代码、Schema、上游或batch漂移，请求预算异常，或当前任务发生内容寻址/写一次完整性冲突。立即停止后续网络；当前任务记`integrity_failed`，剩余冻结任务显式记`not_started_system_abort`，不得省略或替换。
- 收据必须同时报告`planned_task_count=6`、实际`request_count`和未启动数；成功率分母仍为预注册6条。只要存在系统中止，整批固定不可下游。
- 若存储本身已无法写出中止收据，只保留暂存目录并让进程非零退出；不存在正式发布目录就等价于不可下游，不能伪造完整回执。

### 结果路径

```text
source_catalog=${THINKTANK_PROJECT_ROOT}/config/entity_coverage_sources_cn_v1.json
c9_plan=hot://intelligence/collection_runs/v1/C10-bound-run-plan-20260801T120024Z.json
c9_receipt=hot://intelligence/collection_runs/v1/ICR-20260801T120024Z-2253AE16C3/receipt.json
c9_verification=hot://intelligence/collection_runs/v1/ICR-20260801T120024Z-2253AE16C3.verification.json
document_batch=hot://intelligence/document_batches/v2/C11-document-batch-20260801T124510Z.json
document_receipt=hot://intelligence/document_runs/v2/C11-live-20260801T125233Z/receipt.json
document_verification=hot://intelligence/document_runs/v2/C11-live-20260801T125233Z.verification.json
content_objects=hot://intelligence/document_objects/v1/{raw,normalized}/sha256/<prefix>/<full-digest>
```

## 12. 实际观察

| 指标 | 基准 | 本次 | 变化 | 解释 |
| --- | --- | --- | --- | --- |
| C8正式Schema复核 | C10因误要`gold_loaded`失败 | 通过；直接调用正式验证器，注册表该字段保持不存在 | 修复通过 | 来源目录、验证器代码和C8 Schema均进入冻结哈希闭包 |
| 主机分层 | C10把C9目录域误当C8精确主机 | 6/6任务保存两层字段；请求URL与最终URL均精确命中C8主机 | 修复通过 | `www.gov.cn in gov.cn`等只作C9一致性检查，不扩大正文allowlist |
| 主机负控 | 无真实Schema负控 | `evilgov.cn`、`www.gov.cn.evil.com`及反向比较全部拒绝 | 新增通过 | 专项共6组子用例验证带点边界方向 |
| 冻结任务 | C10预览6条 | 6条URL与顺序逐字段一致 | 无漂移 | batch `IDB-20260801T124510Z-38BB77E7D6`，语义哈希`sha256:36334f...e545` |
| C11专项测试 | C10 29/29 | 31/31通过，另6组子用例通过 | `+2`主测试 | 新增真实C8形状、域负控、逐请求漂移和系统熔断覆盖 |
| 全库门禁 | 474/474通过，1项权限跳过 | 475/475通过，1项权限跳过，186组子用例通过 | 无回归 | 耗时125.16秒；跳过仍为Windows符号链接权限边界 |
| 智库仓库总门禁 | C10时474项通过 | 476项执行、475通过、1权限跳过 | 无回归 | `Test-ThinkTankRepo.ps1`通过；Python/JSON/Schema/UTF-8全部通过 |
| 研究库门禁 | 15条既有历史资产错误 | 仍为15条；C11新增错误0 | 无新增 | 检查1197个UTF-8文件；旧错误来自2026-06-29至07-05资产，不在本轮擅自修复 |
| 正文请求/重试 | 0/0 | 6/0 | 命中上限且未超预算 | 无C9网络重跑，不补抽、不替换失败样本 |
| 正文成功数 | 未检验 | 6/6 | 超过至少5/6点预测 | 政府网2、上交所2、白宫2均HTTP 200并形成候选规范化正文 |
| 规范化字符数 | 未检验 | `7003 / 3446 / 236 / 240 / 24114 / 6040` | 全部超过100 | 两篇上交所页面很短，仍只视为候选正文，不推断完整性或事实 |
| 离线独立核验 | 未检验 | 6/6 attempt、原始对象、规范化对象和成功语义重放通过 | 新增通过 | 报告`sha256:61697b...5424`，固定回执字节一致 |
| 权限写入 | 全0 | 模型/记忆/PostgreSQL均0；事实/行动/交易均false | 无越权 | 仅`candidate`层允许后续受控导入 |

## 13. 支持证据

- C8注册表在不增加字段、不重签旧文件的情况下通过正式Schema及来源目录绑定复核；注册表文件哈希仍为`sha256:fa972c...eaa3`。
- C9计划、回执和报告在原`verified_at`精确重放；batch恰含冻结6条及相同顺序，文件哈希为`sha256:1a0f33...c6a0f`。
- 每个任务同时保存C9目录域策略和C8精确主机；6个请求URL与最终URL均只命中后者，未发生重定向越权。
- 31项专项、6组域负控、475项全库和186组全库子用例通过；独立只读代码审计未发现烟测前P0/P1。
- live回执`sha256:019599...7bfc`记录6个唯一成功终态、6次请求、0重试、0系统中止；固定回执文件哈希为`sha256:1d9e71...0d62`。
- 离线核验逐个通过attempt、原始对象、规范化对象及原文到规范文和发布时间的确定性重放，报告`ready=true`。
- 模型、记忆、数据库写入为0；所有对象继续固定为candidate，事实、行动与交易权限均为false。

## 14. 反对证据

- 本轮没有观察到安全合同反证：上游未漂移、任务未变化、请求未超预算、无重试、无越权主机、无系统熔断，专项及全库无新增失败。
- 这6条URL在C10失败关闭时已经看过，因此6/6成功仍是开发集成证据，不是未来未见样本的独立确认。
- 两篇上交所规范化文本只有236和240字符；阈值门通过不证明公告正文完整，更不能证明页面内容事实正确。
- 政府网两篇依赖列表日期作为发布时间，正文页没有独立抽出语义时间；这符合冻结优先级，但尚未验证跨日更新或列表日期错误时的表现。
- 本轮只覆盖三个精确主机、HTML正文和一次网络状态，不能外推到PDF/OCR、多主机渠道、持续采集SLA或生产并发。

## 15. 偏差诊断

预注册偏差分类：

- `upstream_schema_mismatch`：正式上游Schema或语义仍不能被v2重放。
- `host_policy_mismatch`：C9目录域、C8精确主机、列表或候选主机关系不满足冻结规则。
- `sample_drift`：任务不是预注册6条及同一顺序。
- `document_fetch_failure`：正文请求、HTTP、TLS或最终精确主机失败。
- `document_normalization_failure`：挑战页、短正文、正文提取或发布时间失败。
- `integrity_failure`：固定回执、attempt、对象、哈希、代码或Schema重放失败。
- `prediction_miss_without_contract_failure`：安全合同通过但成功数少于5/6。

任何新域名、多主机列表、解析适配器、阈值或时间容差都必须另开实验，不在本轮结果后追加。

实际诊断：未触发`upstream_schema_mismatch`、`host_policy_mismatch`、`sample_drift`、抓取/规范化失败或`integrity_failure`；正文成功数6/6，也未触发点预测失败。唯一已知偏差来源是“已见样本开发复验”，已按预注册降低证据等级，不补做同批重复运行。

## 16. 研究判断

最终状态：`completed / smoke_passed`。

执行后决策矩阵：

| 安全合同 | 正文成功数 | 最高结论 | 状态 |
| --- | --- | --- | --- |
| 通过 | `>=5/6` | L1已见样本开发集成与一次正文烟测通过；非独立确认、非事实批准 | `completed / smoke_passed` |
| 通过 | `<5/6` | v2安全链可保留，但当前正文可用率点预测失败 | `revise`或`observe` |
| 失败 | 任意 | v2不得消费；保留失败证据 | `revise`，严重边界破坏可`kill` |

无论结果如何都不得`promote`到事实层、长期记忆、Agent自动行动或交易。

主控判断：采用决策矩阵第一行，只确认C11的L1已见样本工程烟测通过。`ready_for_downstream_ingest=true`仅表示这6个候选对象通过本批技术门，不能改写为事实批准、模型采用或生产上线。本轮不改变既有研究路线，因此不新建研究决策卡。

## 17. 下一步

1. 保留本次batch、回执、verification与内容对象为写一次L1开发证据，不再重跑同一批，也不据6/6调整阈值。
2. 等未来新C9列表运行产生真正未见的新URL后，另开实验冻结样本和网络预算，做独立正文确认；旧6条不得混入独立成功率分母。
3. 独立确认前可以只开发“候选正文到结构化文档”的离线Schema和失败关闭合同，但不得把本批正文写入事实层、长期记忆或Agent行动层。
4. 机械盘迁移仍等待空的独立NTFS/ReFS目标盘和用户限时授权；当前exFAT归档只保留`provisional`。
5. 未来独立正文确认和存储边界均通过后，再为DeepSeek V4 Flash候选提炼、BM25/向量召回和高智能条件分析建立新的逐层预注册。
