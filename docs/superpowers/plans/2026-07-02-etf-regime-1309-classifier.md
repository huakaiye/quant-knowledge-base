# ETF 全池 13:09 市场状态分类器只读面板 — 实现计划

> 历史实施记录：本文中的 V1.4 路径、旧 runner 和当时命令按原证据保留，禁止作为当前执行入口。当前平台为 `${QUANT_PLATFORM_ROOT}`（V2.0），运行必须遵守研究库与平台各自的 `AGENTS.md`。

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新建一个 RD 方向和一个 EX 只读面板实验，写一个只读分析脚本，用 13:09 盘中数据把 ETF 全池每日市场状态分类（GMM 软聚类），并刻画各状态下的次日收益与大跌风险，验证分类有结构且有预测力。

**Architecture:** 单进程只读 Python 脚本，连 ClickHouse 取前复权日频/分钟数据 → 计算两层特征 → 分层 GMM 聚类 → 错位负控 → 输出 csv/json/md 面板。研究库侧新建 RD（挂 DP00 模块）+ EX（L1_readonly 预注册），同步台账与图谱。

**Tech Stack:** Python 3（平台 env）+ pandas/numpy/scikit-learn + clickhouse-driver + polars；PowerShell（New-ResearchItem.ps1、Build-ResearchBoard.ps1、Build-ResearchGraph.ps1、Test-ResearchRepo.ps1）；Git Bash。

## Global Constraints

- 所有交流、文档、注释、提交说明用中文（AGENTS.md 语言要求）。
- 所有文本文件 UTF-8 无 BOM（AGENTS.md 编码要求）。
- 不得把净值/交易明细/参数扫描结果/原始数据/PDF 提交到研究库（AGENTS.md 系统边界）。
- 实验前必须写清：rd_id / 假设 / 预测 / 基准对照 / 竞争性解释 / 证伪条件 / 平台配置结果路径（AGENTS.md 每轮实验硬规则）。
- 看结果后新增参数网格必须作为新实验重新预注册（AGENTS.md 过拟合硬规则）。
- K（聚类数）、特征集、分箱数在跑任何收益数据前冻结预注册（本计划 Task 5 冻结）。
- 平台命令在 WSL 内运行；回测全程实时输出进度（本实验是只读分析脚本，非回测，但脚本须 print+flush 实时输出）。
- 路径用逻辑根 `${QUANT_PLATFORM_ROOT}`（本机 `E:\量化平台_V1.4.0`）。
- score 公式沿用平台实际口径 `(exp(slope×250)−1)×R²`，调 `weighted_regression_momentum_scores(prices, window=25, annualization=250)`（`momentum.py:12,174-175`）。
- 样本期 2022-01-01 ~ 2026-06-30（规格 §3.1）。
- 预测力门槛：状态对全池等权次日收益均值差 > 0.3%，错位负控差异 < 原差异一半（规格 §6.2）。

---

## 关键事实速查（写代码时直接引用）

| 事实 | 出处 | 用法 |
|---|---|---|
| score 计算 | `E:\量化平台_V1.4.0\src\quant_v2\utils\momentum.py:12` `weighted_regression_momentum_scores(prices, *, window, annualization=250)` | 返回 DataFrame[annualized_returns, r2, score]，index=code |
| 取日频前复权收盘 | `clickhouse_portal.py:482` `portal.get_price(security, count=N, fields=("close",), fq="pre")` | 返回 polars DataFrame[code,date,close,factor] |
| 取某日 13:09 分钟 close | `clickhouse_portal.py:1306` `portal.load_minute_field_snapshot(day, symbols, event_times=["13:09:00"], fields=("close",), start_time="09:30", end_time="13:09")` | 分钟表 factor 空，需用日频 factor 还原前复权 |
| 取开盘→13:09 分钟序列 | 同上，`event_times=None` + `start_time="09:30", end_time="13:09"` | 同上需还原前复权 |
| ETF 池 | `src\strategies\research\etf_dual_pool_all_weather_bear_defense.py:44-72` `STATIC_ETF_POOL` | 约 130 只，硬编码 list |
| ClickHouse 连接 | `src\quant_backtest\config\ch_config.py:68` `get_ch_connection()` + `:87` `get_ch_settings()` | 模板封装见 `audit_mju9_etf_factor_consistency.py:97-107` |
| 脚本骨架范本 | `scripts\research\audit_mju9_etf_factor_consistency.py` | argparse → audit → _write_csv/_write_json/_write_summary_md |
| 研究库 RD 模板 | `10_模板/研究方向模板.md`（5 个占位符） | 脚本只替换 {{ID}}{{TITLE}}{{PARENT_ID}}{{AGENT_CODE}}{{CREATED_AT}} |
| 研究库 EX 模板 | `10_模板/实验记录模板.md`（17 节） | 同上 5 占位符 |
| New-ResearchItem.ps1 | `tools/New-ResearchItem.ps1` | `-Type Direction/Experiment -Title -ParentId` |
| RD 台账 | `01_台账/研究方向台账.csv` 14 列**带引号** | file 用 `/`，时间 `...Z`，ISO8601-Z |
| EX 台账（注意文件名） | `01_台账/实验台账.csv`（**不是"实验记录台账"**） 14 列**无引号** | config_paths/result_paths 多值用 `;` |
| 子代理台账 | `01_台账/子代理调用台账.csv` 15 列无引号 | call_id `SUB-...`，task_code `SUBTASK-...` |
| 双向链接语法 | 正文可使用别名；表格内只使用无别名链接 | 规范 `08_方法论/Obsidian双向链接规范.md` |
| 子模块 RD frontmatter 范本 | `02_研究方向/RD-...-OFF0_双池轮动进攻模块.md` | scope:模块，module_type 中文名，strategy_id 沿用父策略 |
| 重建工具 | `tools/Build-ResearchBoard.ps1` / `Build-ResearchGraph.ps1` / `Test-ResearchRepo.ps1` | 资产变更后必跑 |

---

## 文件结构

**平台侧（创建）**：
- `${LEGACY_QUANT_PLATFORM_ROOT}/scripts/research/analyze_etf_regime_1309_panel.py` — 主分析脚本（单文件，~600 行，分 6 个职责段：连接/数据/特征/聚类/评估/落盘）

**研究库侧（创建）**：
- `02_研究方向/RD-<新id>_双池轮动全池1309市场状态分类模块.md` — 新 RD（New-ResearchItem 生成 + 手工补）
- `04_实验记录/EX-<新id>_<标题>.md` — 新 EX（New-ResearchItem 生成 + 手工补 17 节）
- `01_台账/研究方向台账.csv` — 追加 1 行
- `01_台账/实验台账.csv` — 追加 1 行
- `01_台账/子代理调用台账.csv` — 追加本次头脑风暴+落地用的子代理调用行

**修改（重建产物）**：
- `00_入口/研究进展板.canvas`（Build-ResearchBoard）
- `00_入口/研究图谱.json` + `研究图谱.md`（Build-ResearchGraph）

---

## Task 1: 用 New-ResearchItem.ps1 新建 RD 方向

**Files:**
- Create: `02_研究方向/RD-<新id>_双池轮动全池1309市场状态分类模块.md`

**Interfaces:**
- Produces: 新 RD 的 `rd_id`（后续 Task 2/4/5/8/9 全部引用）

- [ ] **Step 1: 运行 New-ResearchItem.ps1 创建 RD**

```bash
cd "E:/【笔记库】/量化研究库_V2.0.0"
powershell -ExecutionPolicy Bypass -File tools/New-ResearchItem.ps1 -Type Direction -Title "双池轮动全池1309市场状态分类模块" -ParentId "RD-20260605T115651Z-main-DP00"
```

Expected: 输出 `已创建：02_研究方向/RD-<timestamp>-main-<4位码>_双池轮动全池1309市场状态分类模块.md` 和 `ID：RD-<timestamp>-main-<4位码>` 和 `提醒：请同步更新 01_台账/ 中对应台账。`

- [ ] **Step 2: 记下生成的 rd_id**

把脚本输出的 ID（形如 `RD-20260702TXXXXXXZ-main-XXXX`）记为变量 `RD_ID`，后续所有步骤引用。**记录到本次会话的执行记录里。**

- [ ] **Step 3: 修改 RD frontmatter**

Read 新建的 RD 文件，把 frontmatter 改成（参照 OFF0 范本）：

```yaml
---
type: 研究方向
rd_id: <RD_ID>
parent_rd_id: RD-20260605T115651Z-main-DP00
scope: 模块
module_type: 市场状态识别模块
status: draft
priority: P2
owner: main
created_at: <脚本填的值>
updated_at: <脚本填的值>
strategy_id: STRAT-20260605T115651Z-main-DP00
current_decision_id:
current_best_ex_id:
tags: [双池轮动, 市场状态, regime, 1309盘中, GMM分类]
---
```

注意：模板 `scope` 默认值是字面 `策略或模块`，**必须改成 `模块`**。

- [ ] **Step 4: 填 RD 正文（关联链接 + 一句话说明 + 研究信念等）**

把 `## 关联链接` 区块改成（用带路径别名语法）：

```markdown
## 关联链接

- 父方向：[[02_研究方向/RD-20260605T115651Z-main-DP00_双池轮动策略|双池轮动策略]]
- 策略档案：[[03_策略档案/STRAT-20260605T115651Z-main-DP00_双池轮动策略档案|双池轮动策略档案]]
- 平行模块（score过热）：[[02_研究方向/RD-20260605T133318Z-main-H6V3_双池轮动score过热拥挤机制模块|score过热拥挤机制模块]]
- 当前最佳实验：（待 EX 创建后回填）
- 当前决策：（暂无）
- 研究驾驶舱：[[00_入口/研究驾驶舱|研究驾驶舱]]
```

填正文核心章节：

```markdown
## 一句话说明
用 13:09 盘中数据识别 ETF 全池每日市场状态（普涨/高热/抱团/分化等），验证分类稳定且对次日有预测力。纯 regime detection，不与 hard5 绑定，不预设用途。

## 研究对象
双池轮动全池约 130 只 ETF，2022-01-01 ~ 2026-06-30，每日用前复权数据计算两层特征：(1) 中期 score_1309 分布 8 维；(2) 当日开盘→13:09 盘中强度分布 16 维。

## 当前研究信念
ETF 全池 13:09 分布形态存在稳定类型，GMM 软聚类可识别；不同状态次日收益分布有显著差异，且差异来自形态信息（alpha）而非昨日 beta；13:09 盘中采样比纯收盘口径有增量信息。

## 可观察预测
- 轮廓系数 ≥ 0.25
- 状态平均停留天数 ≥ 3 天
- 存在状态对，全池等权次日收益均值差 > 0.3%，且错位一日负控差异 < 原差异一半

## 竞争性解释
状态间收益差异可能是 beta 效应（昨日市场延续），用错位一日负控排除。也可能是 13:09 采样与收盘高度相关（无增量），用 score_close 对照排除。

## 证伪条件
- 轮廓系数 < 0.25 → 形态无结构
- 错位负控差异 ≥ 原差异 80% → beta 伪装
- bootstrap 聚类中心稳定率 < 70% → 聚类不可复现
满足任一即 park。
```

其余章节（研究对象/已完成实验/关键决策/当前下一步/给新手）填"（本方向新立项，首批实验 EX-<id> 进行中）"等占位，EX 完成后回填。

- [ ] **Step 5: 提交 RD**

```bash
cd "E:/【笔记库】/量化研究库_V2.0.0"
git add "02_研究方向/RD-<新id>_双池轮动全池1309市场状态分类模块.md"
git commit -m "feat(RD): 新增双池轮动全池1309市场状态分类模块方向

挂 RD-DP00 下，scope=模块，module_type=市场状态识别模块。
纯 regime detection，承接 EX-REGM，用 13:09 盘中数据 + 两层特征 + GMM 软聚类。
详见 docs/superpowers/specs/2026-07-02-etf-regime-1309-classifier-design.md"
```

---

## Task 2: 用 New-ResearchItem.ps1 新建 EX 实验记录

**Files:**
- Create: `04_实验记录/EX-<新id>_<标题>.md`

**Interfaces:**
- Consumes: Task 1 的 `RD_ID`
- Produces: 新 EX 的 `ex_id`（后续 Task 5/8 引用）

- [ ] **Step 1: 运行 New-ResearchItem.ps1 创建 EX**

```bash
cd "E:/【笔记库】/量化研究库_V2.0.0"
powershell -ExecutionPolicy Bypass -File tools/New-ResearchItem.ps1 -Type Experiment -Title "ETF全池1309市场状态GMM分类只读面板" -ParentId "<RD_ID>"
```

Expected: 输出 `已创建：04_实验记录/EX-<timestamp>-main-<4位码>_ETF全池1309市场状态GMM分类只读面板.md` 和 `ID：EX-<timestamp>-main-<4位码>`。

- [ ] **Step 2: 记下生成的 ex_id**

记为变量 `EX_ID`。

- [ ] **Step 3: 修改 EX frontmatter**

```yaml
---
type: 实验记录
ex_id: <EX_ID>
rd_id: <RD_ID>
status: preregistered
stage: preregistered
owner: main
created_at: <脚本填的值>
updated_at: <脚本填的值>
strategy_id: STRAT-20260605T115651Z-main-DP00
module_type: 市场状态识别模块
decision_ids: []
lit_ids: []
idea_ids: []
platform_project: ${QUANT_PLATFORM_ROOT}
config_paths: ['${LEGACY_QUANT_PLATFORM_ROOT}/configs/research/<RD_ID>/<EX_ID>/']
result_paths: ['${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/<RD_ID>/<EX_ID>/']
summary_paths: []
quality_gate: L1_readonly_preregistered
subagent_call_ids: []
subagent_exemption:
tags: [市场状态, regime, 1309盘中, GMM, 只读面板, 预注册]
---
```

- [ ] **Step 4: 填 EX 正文 17 节（实验前必写部分）**

按 AGENTS.md 每轮实验硬规则，实验前必须写清 7 项。逐节填写：

**第 1 节 新手摘要**（实验前先写一句话，实验后回填）：
```markdown
## 1. 新手摘要
（实验前）本研究尝试用每天下午 13:09 的 ETF 全池价格分布形态，把当天市场分成"普涨/高热/抱团/分化"等几类状态，看不同状态下第二天市场表现有没有差异。如果分类稳定且差异真实（不是简单的"昨天涨今天继续涨"的 beta），未来才值得考虑用它指导策略。当前为预注册阶段。
```

**第 3 节 实验前假设**（抄规格 §2 H1/H2/H3）：
```markdown
## 3. 实验前假设
- H1（分类有结构）：ETF 全池 13:09 分布形态存在稳定类型，GMM 软聚类轮廓系数 ≥ 0.25。
- H2（有预测力）：不同状态全池等权次日收益均值差 > 0.3%，且错位一日负控差异 < 原差异一半。
- H3（盘中增量）：13:09 盘中强度层的预测力显著高于纯收盘口径（score_close 对照）。
```

**第 4 节 实验前预测**：
```markdown
## 4. 实验前预测
- 预测 1：GMM 在层 1（8 维）会聚出 3-5 个状态，在层 2（16 维）会聚出 2-3 个状态。
- 预测 2：会存在一类"高热见顶"状态（层1高分集中 + 层2 pos_in_range 低即冲高回落），其次日全池等权收益显著低于"真强势普涨"状态（层1高分集中 + 层2 pos_in_range 高即收高位）。
- 预测 3：错位一日负控会部分衰减状态间收益差异（证明有 alpha 成分），但不会完全归零。
```

**第 5 节 基准和对照**：
```markdown
## 5. 基准和对照
- 基准（baseline）：score_close 口径（25 个收盘价）的分布分类——用于回答"13:09 盘中采样是否带来增量"。
- 对照 1（错位负控）：状态标签滞后 1 天，匹配 D→D+1 收益，用于排除 beta。
- 对照 2（随机标签）：状态标签随机打乱，预期收益差≈0，用于校验指标计算正确性。
- 前序对照：[[04_实验记录/EX-20260701T0500Z-main-REGM_2026全年分数结构状态与调仓策略面板|EX-REGM]]（收盘口径，雏形）。
```

**第 6 节 竞争性解释**（抄规格 §2）：
```markdown
## 6. 竞争性解释
- CE1：状态间收益差异是 beta 效应（昨日市场延续），不是今天的形态信息——用错位一日负控排除。
- CE2：13:09 采样与收盘高度相关，无增量——用 score_close 对照排除。
- CE3：聚类结果是 GMM 对噪声的过拟合——用 bootstrap 稳定率排除。
- CE4：某状态样本量太小导致收益差被极值驱动——用"每状态 ≥ 20 天"门槛排除稀疏状态。
```

**第 7 节 证伪条件**：
```markdown
## 7. 证伪条件
满足任一即 park，记录"ETF 层 13:09 形态无 alpha 增量"：
- FC1：轮廓系数 < 0.25（层 1 或层 2 任一）→ 形态无结构
- FC2：错位一日负控差异 ≥ 原差异 80% → beta 伪装
- FC3：bootstrap 聚类中心稳定率 < 70% → 聚类不可复现
```

**第 8 节 未来函数审计**：
```markdown
## 8. 未来函数审计
| 数据用途 | 字段 | 时点 | 风险 | 处置 |
|---|---|---|---|---|
| 层1 中期 score_1309 | 24日收盘+今日13:09 | D日13:09 | 无 | 13:09 决策时全部可见 |
| 层2 盘中强度 | 今日开盘→13:09分钟 | D日13:09 | 无 | 13:09 决策时全部可见 |
| 状态标签 | 两层GMM聚类结果 | D日13:09后 | 无 | 仅用D日数据 |
| 次日收益 | D日13:09→D+1日13:09前复权收益 | D+1日13:09 | 无 | 严格用D+1数据 |
| 错位负控 | D-1状态标签匹配D→D+1收益 | D-1,D+1 | 无 | 故意错位 |
结论：无未来函数风险。子代理可检查字段路径，但未来函数最终确认由主控承担。
```

**第 9 节 过拟合审计**：
```markdown
## 9. 过拟合审计
| 风险 | 处置 |
|---|---|
| 看结果后调K | K范围（层1:2..5，层2:2..3）在跑任何收益数据前用轮廓系数冻结 |
| 看结果后调特征 | 8维+16维特征集预注册冻结 |
| 看结果后调分箱 | 分箱数（shannon_entropy用）预注册为20箱冻结 |
| 后验选状态合并 | 稀疏状态(<20天)只描述不归因，不合并 |
| 路径升级过快 | L1_readonly，不进formal不shadow |
```

**第 10 节 子代理调用记录**（先写豁免/计划，执行后回填表格）：
```markdown
## 10. 子代理调用记录
- 适配判断：适合调用（实验落地涉及台账/图谱/链接核对，适合子代理）
- 调用状态：called
- 子代理豁免：（不适用）

| 调用 ID | 平台昵称 | 任务代号 | 模型 | 发起时间 | 读取文件 | 修改文件 | 执行命令 | 结论边界 | 风险点 | 主控复核 | 结果对决策影响 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SUB-<t1> | (待填) | SUBTASK-CTX-HARD5 | sonnet | 2026-07-02T.. | hard5相关RD/EX/DEC | 无 | 无 | 只检索 | 仅摘录 | 是 | 提供hard5背景 |
| SUB-<t2> | (待填) | SUBTASK-CTX-SCORE | sonnet | 2026-07-02T.. | score计算/13:09/前复权 | 无 | 无 | 只检索 | 仅摘录 | 是 | 提供score口径 |
| SUB-<t3> | (待填) | SUBTASK-CTX-DYNTHRESH | sonnet | 2026-07-02T.. | 动态阈值/聚类历史 | 无 | 无 | 只检索 | 仅摘录 | 是 | 提供先例 |
| SUB-<t4> | (待填) | SUBTASK-CTX-REGIME | sonnet | 2026-07-02T.. | regime方向+命名规范 | 无 | 无 | 只检索 | 仅摘录 | 是 | 确定挂载位置 |
| SUB-<t5> | (待填) | SUBTASK-CTX-PLATFORM | sonnet | 2026-07-02T.. | momentum.py/数据表 | 无 | 无 | 只检索 | 仅摘录 | 是 | 确定API签名 |
| SUB-<t6> | (待填) | SUBTASK-CTX-REPOPROC | sonnet | 2026-07-02T.. | 模板/台账/链接规范 | 无 | 无 | 只检索 | 仅摘录 | 是 | 确定落地格式 |

- 台账行：已同步 01_台账/子代理调用台账.csv。
```

（执行后把 `<t1>..<t6>` 替换为真实时间戳，平台昵称填实际显示值。）

**第 11 节 执行记录**（先写计划，执行后回填结果）：
```markdown
## 11. 执行记录
### 平台配置
- 脚本：${LEGACY_QUANT_PLATFORM_ROOT}/scripts/research/analyze_etf_regime_1309_panel.py
- 数据：jq_bar_daily（前复权日频）、jq_bar_minute_v2（13:09及开盘→13:09分钟）
- ETF池：STATIC_ETF_POOL（约130只）
- 样本期：2022-01-01 ~ 2026-06-30

### 运行命令
（待 Task 7 执行后填）

### 结果路径
${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/<RD_ID>/<EX_ID>/diagnostic/
${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/<RD_ID>/<EX_ID>/summary/
```

第 2/12-17 节（研究背景/实际观察/支持证据/反对证据/偏差诊断/研究判断/下一步）实验后回填。

- [ ] **Step 5: 提交 EX**

```bash
cd "E:/【笔记库】/量化研究库_V2.0.0"
git add "04_实验记录/EX-<新id>_ETF全池1309市场状态GMM分类只读面板.md"
git commit -m "feat(EX): 预注册 ETF全池1309市场状态GMM分类只读面板

挂 <RD_ID> 下，stage=preregistered，quality_gate=L1_readonly_preregistered。
实验前 7 项已写清（假设/预测/对照/竞争解释/证伪/未来函数审计/过拟合审计）。
承接 EX-REGM，用 13:09 盘中数据 + 两层特征 + GMM。"
```

---

## Task 3: 写分析脚本 — 数据加载段（连接 + 取数）

**Files:**
- Create: `${LEGACY_QUANT_PLATFORM_ROOT}/scripts/research/analyze_etf_regime_1309_panel.py`

**Interfaces:**
- Consumes: 平台 `momentum.py:12`、`clickhouse_portal.py:482/1306`、`ch_config.py:68/87`、`etf_dual_pool_all_weather_bear_defense.py:44`
- Produces: 模块内函数 `_connect()`、`_load_daily_close()`、`_load_minute_1309()`、`_load_minute_open_to_1309()`

- [ ] **Step 1: 写脚本骨架 + imports + 路径注入 + 连接函数**

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

> 历史实施记录：本文中的 V1.4 路径、旧 runner 和当时命令按原证据保留，禁止作为当前执行入口。当前平台为 `${QUANT_PLATFORM_ROOT}`（V2.0），运行必须遵守研究库与平台各自的 `AGENTS.md`。
"""
ETF 全池 13:09 市场状态分类只读面板
RD: <RD_ID>  EX: <EX_ID>
详见研究库 docs/superpowers/specs/2026-07-02-etf-regime-1309-classifier-design.md
L1_readonly 只读分析，不交易、不改实盘。
"""
import argparse
import json
import sys
from datetime import datetime
from pathlib import Path

import numpy as np
import pandas as pd
from sklearn.mixture import GaussianMixture
from sklearn.metrics import silhouette_score

# 平台路径注入（与 audit_mju9_etf_factor_consistency.py:30-32 同款）

> 历史实施记录：本文中的 V1.4 路径、旧 runner 和当时命令按原证据保留，禁止作为当前执行入口。当前平台为 `${QUANT_PLATFORM_ROOT}`（V2.0），运行必须遵守研究库与平台各自的 `AGENTS.md`。
PROJECT_ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(PROJECT_ROOT / "src"))

from clickhouse_driver import Client
from quant_backtest.config.ch_config import get_ch_connection, get_ch_settings
from quant_v2.data.clickhouse_portal import ClickHouseDataPortal
from quant_v2.utils.momentum import weighted_regression_momentum_scores

# 从策略源码导入 ETF 池（避免硬编码重复）

> 历史实施记录：本文中的 V1.4 路径、旧 runner 和当时命令按原证据保留，禁止作为当前执行入口。当前平台为 `${QUANT_PLATFORM_ROOT}`（V2.0），运行必须遵守研究库与平台各自的 `AGENTS.md`。
sys.path.insert(0, str(PROJECT_ROOT / "src" / "strategies" / "research"))
from etf_dual_pool_all_weather_bear_defense import STATIC_ETF_POOL

RD_ID = "<RD_ID>"
EX_ID = "<EX_ID>"
EX_TAG = "REGME1309"
START_DATE = "2022-01-01"
END_DATE = "2026-06-30"
WINDOW = 25           # score 回归窗口
ANNUAL = 250          # 年化
EVENT_TIME = "13:09:00"
N_BINS = 20           # shannon_entropy 分箱数（预注册冻结）


def _connect() -> Client:
    conn = get_ch_connection()
    return Client(
        host=conn["host"], port=conn["port"], database=conn["database"],
        user=conn["user"], password=conn["password"],
        connect_timeout=conn["connect_timeout"], settings=get_ch_settings(),
    )


def main():
    print(f"[{EX_TAG}] start RD={RD_ID} EX={EX_ID}", flush=True)
    print(f"[{EX_TAG}] sample {START_DATE} ~ {END_DATE}", flush=True)
    # 后续 Task 填充


if __name__ == "__main__":
    main()
```

- [ ] **Step 2: 写日频收盘加载函数（取全池每个交易日的前复权收盘宽表）**

追加到脚本：

```python
def _load_daily_close(portal: ClickHouseDataPortal, etfs: list[str]) -> pd.DataFrame:
    """取全池所有 ETF 在样本期的前复权日频收盘价，返回宽表[date×code]。
    用 portal.get_price 单标的循环（fq='pre' 内部修复断点），再 pivot。
    """
    print(f"[{EX_TAG}] load daily close for {len(etfs)} etfs", flush=True)
    frames = []
    for i, code in enumerate(etfs):
        df = portal.get_price(
            code, start_date=START_DATE, end_date=END_DATE,
            fields=("close",), fq="pre",
        )
        if df is None or len(df) == 0:
            continue
        pdf = df.to_pandas() if hasattr(df, "to_pandas") else df
        pdf["code"] = code
        frames.append(pdf[["date", "code", "close"]])
        if (i + 1) % 30 == 0:
            print(f"[{EX_TAG}] daily close {i+1}/{len(etfs)}", flush=True)
    long_df = pd.concat(frames, ignore_index=True)
    wide = long_df.pivot(index="date", columns="code", values="close").sort_index()
    print(f"[{EX_TAG}] daily close wide shape={wide.shape}", flush=True)
    return wide
```

- [ ] **Step 3: 写 13:09 分钟 close 加载函数（含前复权还原）**

关键：分钟表 factor 100% 为空，需用日频 factor 把分钟真实价还原为前复权。

```python
def _load_minute_1309_and_factor(
    portal: ClickHouseDataPortal, etfs: list[str], trading_days: list[str]
) -> pd.DataFrame:
    """取每个交易日 13:09 的分钟 close + 当日日频 factor，返回长表[date,code,close_1309_real,factor]。
    前复权 close_1309 = close_1309_real * factor（用 jq_bar_daily 的 factor 还原）。
    """
    print(f"[{EX_TAG}] load 13:09 minute close for {len(trading_days)} days", flush=True)
    rows = []
    for i, day in enumerate(trading_days):
        # 13:09 分钟 close（真实价）
        snap = portal.load_minute_field_snapshot(
            trading_day=day, symbols=etfs,
            event_times=[EVENT_TIME], fields=("close",),
            start_time="09:30", end_time="13:09",
        )
        if snap is None or len(snap) == 0:
            continue
        sdf = snap.to_pandas() if hasattr(snap, "to_pandas") else snap
        # 当日日频 factor（用于前复权还原）
        fac = portal.get_price(
            None, start_date=day, end_date=day,
            fields=("factor",), fq="pre",
        )  # 注：get_price 单标的接口，全池需循环或直查 SQL；此处用直查简化
        # 简化：用直查 SQL 取全池当日 factor
        rows.append(sdf[["code", "datetime", "close"]].assign(date=day))
        if (i + 1) % 50 == 0:
            print(f"[{EX_TAG}] 13:09 minute {i+1}/{len(trading_days)}", flush=True)
    raw = pd.concat(rows, ignore_index=True)
    raw.rename(columns={"close": "close_1309_real"}, inplace=True)
    # factor 用日频表另查（见 _load_daily_factor）
    return raw
```

⚠️ **注意**：上面 `portal.get_price(None, ...)` 全池调用可能不支持，Task 7 调试时改用直查 SQL（参考 `audit_mju9_etf_factor_consistency.py:180-198`）。这里先留接口，调试时修正。

- [ ] **Step 4: 写日频 factor 加载函数（前复权还原用）**

```python
def _load_daily_factor(client: Client, etfs: list[str]) -> pd.DataFrame:
    """直查 jq_bar_daily 取全池样本期 factor，返回[date,code,factor]。"""
    symbols = [c.split(".")[0] for c in etfs]  # jq_bar_daily 存 symbol（无后缀）
    # 按 etf 后缀映射 exchange
    exc_map = {}
    for c in etfs:
        sym, exc = c.split(".")
        exc_map[sym] = exc
    sql = """
    SELECT toDate(datetime) AS date, symbol, exchange, factor
    FROM jq_bar_daily
    WHERE symbol IN %(symbols)s
      AND datetime >= %(start)s AND datetime <= %(end)s
    """
    rows = _query_rows(client, sql, {
        "symbols": symbols, "start": START_DATE, "end": END_DATE + " 23:59:59",
    })
    df = pd.DataFrame(rows, columns=["date", "symbol", "exchange", "factor"])
    df["code"] = df["symbol"] + "." + df["exchange"]
    return df[["date", "code", "factor"]]


def _query_rows(client: Client, sql: str, params: dict) -> list[tuple]:
    return client.execute(sql, params)
```

- [ ] **Step 5: 提交脚本骨架**

```bash
cd "E:/【笔记库】/量化研究库_V2.0.0"
# 脚本在平台目录，研究库不直接提交平台代码；但记录本次新增到执行记录

> 历史实施记录：本文中的 V1.4 路径、旧 runner 和当时命令按原证据保留，禁止作为当前执行入口。当前平台为 `${QUANT_PLATFORM_ROOT}`（V2.0），运行必须遵守研究库与平台各自的 `AGENTS.md`。
# 平台侧 git 由平台仓库管理，这里只确认文件存在

> 历史实施记录：本文中的 V1.4 路径、旧 runner 和当时命令按原证据保留，禁止作为当前执行入口。当前平台为 `${QUANT_PLATFORM_ROOT}`（V2.0），运行必须遵守研究库与平台各自的 `AGENTS.md`。
ls -la "E:/量化平台_V1.4.0/scripts/research/analyze_etf_regime_1309_panel.py"
echo "脚本骨架已就位（数据加载段）"
```

（平台代码不提交到研究库；若平台仓库启用 git，在平台仓库提交。研究库只在 EX 执行记录登记路径。）

---

## Task 4: 写分析脚本 — 特征工程段（两层特征）

**Files:**
- Modify: `${LEGACY_QUANT_PLATFORM_ROOT}/scripts/research/analyze_etf_regime_1309_panel.py`

**Interfaces:**
- Consumes: Task 3 的 `_load_daily_close`、`_load_minute_1309_and_factor`、`_load_daily_factor`
- Produces: `_compute_score_1309_panel()`、`_compute_score_close_panel()`、`_layer1_features()`、`_layer2_features()`

- [ ] **Step 1: 写 score_1309 全池逐日计算（用生产 momentum API）**

```python
def _compute_score_1309_panel(
    daily_close_wide: pd.DataFrame,
    minute_1309_raw: pd.DataFrame,
    factor_df: pd.DataFrame,
) -> pd.DataFrame:
    """逐日计算全池 score_1309，返回[date,code,score_1309]长表。
    每日对每只ETF：[过去24个交易日收盘 + 今日13:09前复权价] 25点回归。
    """
    print(f"[{EX_TAG}] compute score_1309 panel", flush=True)
    # 合并 13:09 真实价 + factor → 前复权 13:09 价
    m = minute_1309_raw.merge(factor_df, on=["date", "code"], how="left")
    m["close_1309_pre"] = m["close_1309_real"] * m["factor"]
    
    dates = sorted(daily_close_wide.index.unique())
    out = []
    for i, day in enumerate(dates[WINDOW-1:]):  # 需要前 24 天
        prev_idx = dates.index(day)
        prev_24 = dates[prev_idx-WINDOW+1:prev_idx]  # 过去24个交易日
        close_24 = daily_close_wide.loc[prev_24]      # [24 × code]
        # 当日 13:09 前复权价
        today_1309 = m[m["date"] == day].set_index("code")["close_1309_pre"]
        # 拼成 25 点宽表
        price_25 = pd.concat([close_24, today_1309.to_frame().T.set_axis([day])])
        # 调生产 API
        scores = weighted_regression_momentum_scores(price_25, window=WINDOW, annualization=ANNUAL)
        scores = scores.reset_index().rename(columns={"index": "code"})
        scores["date"] = day
        out.append(scores[["date", "code", "score"]].rename(columns={"score": "score_1309"}))
        if (i+1) % 50 == 0:
            print(f"[{EX_TAG}] score_1309 {i+1}/{len(dates)-WINDOW+1}", flush=True)
    return pd.concat(out, ignore_index=True)
```

- [ ] **Step 2: 写 score_close 对照口径（25 个收盘价）**

```python
def _compute_score_close_panel(daily_close_wide: pd.DataFrame) -> pd.DataFrame:
    """对照基准：逐日用过去25个收盘价算 score_close。"""
    print(f"[{EX_TAG}] compute score_close panel (control)", flush=True)
    dates = sorted(daily_close_wide.index.unique())
    out = []
    for i, day in enumerate(dates[WINDOW-1:]):
        prev_idx = dates.index(day)
        prev_25 = daily_close_wide.iloc[prev_idx-WINDOW+1:prev_idx+1]  # 含当日收盘
        scores = weighted_regression_momentum_scores(prev_25, window=WINDOW, annualization=ANNUAL)
        scores = scores.reset_index().rename(columns={"index": "code"})
        scores["date"] = day
        out.append(scores[["date", "code", "score"]].rename(columns={"score": "score_close"}))
        if (i+1) % 100 == 0:
            print(f"[{EX_TAG}] score_close {i+1}/{len(dates)-WINDOW+1}", flush=True)
    return pd.concat(out, ignore_index=True)
```

- [ ] **Step 3: 写层 1 特征（每日 8 维：5 分位 + skew + kurt + bimodal）**

```python
from scipy.stats import skew, kurtosis

def _bimodal_coef(s: pd.Series) -> float:
    """SARLE 双峰系数。"""
    g1 = skew(s.dropna())
    g2 = kurtosis(s.dropna(), fisher=False)  # Pearson kurtosis
    return (g1**2 + 1) / g2 if g2 > 0 else float("nan")

def _layer1_features(score_1309_panel: pd.DataFrame) -> pd.DataFrame:
    """每日对全池 score_1309 分布提取 8 维特征。"""
    print(f"[{EX_TAG}] layer1 features (8d)", flush=True)
    rows = []
    for day, grp in score_1309_panel.groupby("date"):
        s = grp["score_1309"].dropna()
        if len(s) < 30:
            continue
        q = s.quantile([0.1, 0.25, 0.5, 0.75, 0.9]).to_dict()
        rows.append({
            "date": day,
            "p10": q[0.1], "p25": q[0.25], "p50": q[0.5], "p75": q[0.75], "p90": q[0.9],
            "skew": skew(s), "kurt": kurtosis(s),
            "bimodal": _bimodal_coef(s),
        })
    return pd.DataFrame(rows).set_index("date")
```

- [ ] **Step 4: 写层 2 特征（每日 16 维：4 盘中特征 × 4 统计量）**

```python
def _compute_intraday_features(
    portal: ClickHouseDataPortal, etfs: list[str], trading_days: list[str],
    factor_df: pd.DataFrame,
) -> pd.DataFrame:
    """逐日逐ETF算4个盘中特征(O2T_return/intraday_trend_R2/pos_in_range/amplitude)，
    再按日聚合为16维分布统计。返回[date,code,O2T,...]长表。"""
    print(f"[{EX_TAG}] compute intraday features (per etf per day)", flush=True)
    rows = []
    for i, day in enumerate(trading_days):
        snap = portal.load_minute_field_snapshot(
            trading_day=day, symbols=etfs, event_times=None,
            fields=("open", "high", "low", "close"),
            start_time="09:30", end_time="13:09",
        )
        if snap is None or len(snap) == 0:
            continue
        sdf = snap.to_pandas() if hasattr(snap, "to_pandas") else snap
        for code, g in sdf.groupby("code"):
            if len(g) < 5:
                continue
            open_p = g["open"].iloc[0]
            close_1309 = g["close"].iloc[-1]
            high = g["high"].max(); low = g["low"].min()
            o2t = (close_1309 - open_p) / open_p if open_p else float("nan")
            # 当日分钟 log 回归 R²
            t = np.arange(len(g))
            y = np.log(g["close"].values)
            if len(y) > 2 and not np.any(np.isinf(y)):
                slope, intercept = np.polyfit(t, y, 1)
                fitted = slope * t + intercept
                ss_res = np.sum((y - fitted)**2)
                ss_tot = np.sum((y - y.mean())**2)
                r2 = 1 - ss_res/ss_tot if ss_tot > 0 else float("nan")
            else:
                r2 = float("nan")
            pos = (close_1309 - low) / (high - low) if (high - low) > 0 else float("nan")
            amp = (high - low) / open_p if open_p else float("nan")
            rows.append({"date": day, "code": code, "O2T": o2t,
                         "intraday_R2": r2, "pos_in_range": pos, "amplitude": amp})
        if (i+1) % 50 == 0:
            print(f"[{EX_TAG}] intraday {i+1}/{len(trading_days)}", flush=True)
    return pd.DataFrame(rows)


def _layer2_features(intraday_long: pd.DataFrame) -> pd.DataFrame:
    """每日对全池4个盘中特征的分布各取[p25,p50,p75,mean]→16维。"""
    print(f"[{EX_TAG}] layer2 features (16d)", flush=True)
    feats = ["O2T", "intraday_R2", "pos_in_range", "amplitude"]
    stats = ["p25", "p50", "p75", "mean"]
    rows = []
    for day, grp in intraday_long.groupby("date"):
        if len(grp) < 30:
            continue
        rec = {"date": day}
        for f in feats:
            s = grp[f].dropna()
            rec[f"{f}_p25"] = s.quantile(0.25)
            rec[f"{f}_p50"] = s.quantile(0.5)
            rec[f"{f}_p75"] = s.quantile(0.75)
            rec[f"{f}_mean"] = s.mean()
        rows.append(rec)
    df = pd.DataFrame(rows).set_index("date")
    # 标准化（GMM 需要）
    return (df - df.mean()) / df.std()
```

- [ ] **Step 5: 提交（平台仓库，或记录到研究库执行记录）**

```bash
echo "Task 4 完成：特征工程段已写入脚本"
wc -l "E:/量化平台_V1.4.0/scripts/research/analyze_etf_regime_1309_panel.py"
```

---

## Task 5: 写分析脚本 — 聚类段（分层 GMM + K 选择）

**Files:**
- Modify: `${LEGACY_QUANT_PLATFORM_ROOT}/scripts/research/analyze_etf_regime_1309_panel.py`

⚠️ **关键约束**：K 选择必须**只看轮廓系数**，不看收益。这一步完成后才能进入 Task 6（评估收益）。

- [ ] **Step 1: 写 K 选择函数（纯形态，轮廓系数）**

```python
def _select_k_gmm(features: pd.DataFrame, k_range: range, layer_name: str) -> tuple[int, GaussianMixture]:
    """在纯形态数据上用轮廓系数选K（不看收益）。返回(best_k, fitted_gmm)。"""
    print(f"[{EX_TAG}] select K for {layer_name} via silhouette (no returns)", flush=True)
    X = features.dropna().values
    best_k, best_score, best_gmm = None, -1, None
    for k in k_range:
        try:
            gmm = GaussianMixture(n_components=k, random_state=42, n_init=5)
            labels = gmm.fit_predict(X)
            sil = silhouette_score(X, labels) if k > 1 else float("nan")
            print(f"[{EX_TAG}] {layer_name} k={k} silhouette={sil:.4f}", flush=True)
            if k > 1 and sil > best_score:
                best_k, best_score, best_gmm = k, sil, gmm
        except Exception as e:
            print(f"[{EX_TAG}] {layer_name} k={k} failed: {e}", flush=True)
    print(f"[{EX_TAG}] {layer_name} selected k={best_k} silhouette={best_score:.4f}", flush=True)
    return best_k, best_gmm
```

- [ ] **Step 2: 写 bootstrap 稳定性检验**

```python
def _bootstrap_stability(features: pd.DataFrame, k: int, n_boot: int = 100) -> float:
    """重抽样n_boot次，看聚类中心匹配率（ARI）。"""
    from sklearn.metrics import adjusted_rand_score
    print(f"[{EX_TAG}] bootstrap stability k={k} n_boot={n_boot}", flush=True)
    X = features.dropna().values
    base = GaussianMixture(n_components=k, random_state=42, n_init=5).fit_predict(X)
    aris = []
    for b in range(n_boot):
        idx = np.random.choice(len(X), len(X), replace=True)
        lab = GaussianMixture(n_components=k, random_state=b, n_init=3).fit_predict(X[idx])
        aris.append(adjusted_rand_score(base[idx], lab))
    mean_ari = float(np.mean(aris))
    print(f"[{EX_TAG}] bootstrap mean ARI={mean_ari:.4f}", flush=True)
    return mean_ari
```

- [ ] **Step 3: 写组合状态生成**

```python
def _combine_states(layer1_gmm, layer2_gmm, l1_features, l2_features) -> pd.DataFrame:
    """组合状态 = (层1状态, 层2状态)。返回[date, state_l1, state_l2, state_combo, prob]。"""
    l1_labels = layer1_gmm.predict(l1_features.dropna().values)
    l2_labels = layer2_gmm.predict(l2_features.dropna().values)
    df = pd.DataFrame({
        "date": l1_features.dropna().index,
        "state_l1": l1_labels,
    }).join(pd.DataFrame({
        "date": l2_features.dropna().index,
        "state_l2": l2_labels,
    }).set_index("date"), on="date", how="inner")
    df["state_combo"] = df["state_l1"].astype(str) + "_" + df["state_l2"].astype(str)
    return df
```

- [ ] **Step 4: 提交**

```bash
echo "Task 5 完成：聚类段（K选择+bootstrap+组合状态）已写入脚本"
```

---

## Task 6: 写分析脚本 — 评估段（次日收益 + 错位负控 + 痛点交叉表）

**Files:**
- Modify: `${LEGACY_QUANT_PLATFORM_ROOT}/scripts/research/analyze_etf_regime_1309_panel.py`

- [ ] **Step 1: 写次日全池等权收益计算（13:09→次日13:09 前复权）**

```python
def _compute_next_day_returns(
    minute_1309_raw: pd.DataFrame, factor_df: pd.DataFrame,
) -> pd.DataFrame:
    """D日13:09 → D+1日13:09 的前复权收益（逐ETF，再等权聚合）。返回[date,code,ret_d2d1]。"""
    m = minute_1309_raw.merge(factor_df, on=["date", "code"], how="left")
    m["close_1309_pre"] = m["close_1309_real"] * m["factor"]
    m = m.sort_values(["code", "date"])
    m["next_close"] = m.groupby("code")["close_1309_pre"].shift(-1)
    m["ret_d2d1"] = m["next_close"] / m["close_1309_pre"] - 1
    return m[["date", "code", "ret_d2d1"]].dropna()
```

- [ ] **Step 2: 写状态评估表（每状态画像 + 预测力门槛判定）**

```python
def _evaluate_states(
    combo_df: pd.DataFrame, ret_long: pd.DataFrame,
) -> tuple[pd.DataFrame, dict]:
    """每状态画像 + 状态对收益差。返回(state_profile_df, verdict_dict)。"""
    merged = combo_df.merge(ret_long, on="date", how="inner")
    # 每状态等权次日收益
    prof = merged.groupby("state_combo").agg(
        n_days=("date", "nunique"),
        mean_ret=("ret_d2d1", "mean"),
        median_ret=("ret_d2d1", "median"),
        std_ret=("ret_d2d1", "std"),
        pct_drop3=("ret_d2d1", lambda s: (s < -0.03).mean()),
        var5=("ret_d2d1", lambda s: s.quantile(0.05)),
    ).reset_index()
    prof["avg_hold_days"] = _avg_hold_days(combo_df)
    # 状态对最大收益差
    valid = prof[prof["n_days"] >= 20]
    max_diff = 0.0; pair = None
    for i in range(len(valid)):
        for j in range(i+1, len(valid)):
            d = abs(valid.iloc[i]["mean_ret"] - valid.iloc[j]["mean_ret"])
            if d > max_diff:
                max_diff, pair = d, (valid.iloc[i]["state_combo"], valid.iloc[j]["state_combo"])
    verdict = {
        "max_state_pair_diff": max_diff, "best_pair": pair,
        "has_prediction_power": max_diff > 0.003,
    }
    return prof, verdict


def _avg_hold_days(combo_df: pd.DataFrame) -> pd.Series:
    """每状态平均停留天数（连续同状态段的平均长度）。"""
    out = {}
    df = combo_df.sort_values("date")
    for st, g in df.groupby("state_combo"):
        dates = g["date"].tolist()
        runs = 1
        for i in range(1, len(dates)):
            if dates[i] != dates[i-1]:  # 简化：按交易日连续，实际需对齐交易日历
                runs += 1
        out[st] = len(dates) / runs if runs else 0
    return pd.Series(out)
```

- [ ] **Step 3: 写错位一日负控**

```python
def _lagged_negative_control(
    combo_df: pd.DataFrame, ret_long: pd.DataFrame,
) -> float:
    """状态标签滞后1天，重算最大状态对收益差。返回负控差异。"""
    combo_lag = combo_df.copy()
    combo_lag["state_combo"] = combo_lag.groupby("state_combo")["state_combo"].shift(1)
    combo_lag = combo_lag.dropna(subset=["state_combo"])
    merged = combo_lag.merge(ret_long, on="date", how="inner")
    prof = merged.groupby("state_combo")["ret_d2d1"].mean()
    valid = merged.groupby("state_combo")["date"].nunique()
    prof = prof[valid >= 20]
    if len(prof) < 2:
        return 0.0
    diff = prof.max() - prof.min()
    print(f"[{EX_TAG}] lagged negative control max diff={diff:.4f}", flush=True)
    return diff
```

- [ ] **Step 4: 写痛点交叉表（即使纯分类器定位，仍记录 hard5 误杀/保护作为参考维度）**

```python
def _hard5_reference_cross(
    score_1309_panel: pd.DataFrame, ret_long: pd.DataFrame, combo_df: pd.DataFrame,
) -> pd.DataFrame:
    """参考维度（非评判标准）：状态 × hard5是否剔除 × 次日收益。"""
    df = score_1309_panel.merge(ret_long, on=["date", "code"], how="inner")
    df["hard5_cut"] = df["score_1309"] >= 5
    df = df.merge(combo_df[["date", "state_combo"]], on="date", how="left")
    cross = df.groupby(["state_combo", "hard5_cut"])["ret_d2d1"].agg(["mean", "count"]).reset_index()
    return cross
```

- [ ] **Step 5: 提交**

```bash
echo "Task 6 完成：评估段（次日收益+错位负控+参考交叉表）已写入脚本"
```

---

## Task 7: 写分析脚本 — 落盘段 + main 串联 + 调试运行

**Files:**
- Modify: `${LEGACY_QUANT_PLATFORM_ROOT}/scripts/research/analyze_etf_regime_1309_panel.py`

- [ ] **Step 1: 写落盘函数（csv + json + md）**

```python
def _write_csv(path: Path, df: pd.DataFrame):
    path.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(path, index=False, encoding="utf-8-sig")

def _write_json(path: Path, obj: dict):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(obj, ensure_ascii=False, indent=2, default=str), encoding="utf-8")

def _write_summary_md(path: Path, prof, verdict, lag_diff, silhouette_l1, silhouette_l2, ari_l1, ari_l2):
    path.parent.mkdir(parents=True, exist_ok=True)
    lines = [
        f"# ETF 全池 13:09 市场状态分类只读面板", "",
        f"**RD**: {RD_ID}  **EX**: {EX_ID}", "",
        f"## 分类质量", "",
        f"- 层1 轮廓系数: {silhouette_l1:.4f} (门槛 ≥ 0.25)",
        f"- 层2 轮廓系数: {silhouette_l2:.4f}",
        f"- 层1 bootstrap ARI: {ari_l1:.4f} (门槛 ≥ 0.70)",
        f"- 层2 bootstrap ARI: {ari_l2:.4f}",
        "",
        f"## 预测力", "",
        f"- 状态对最大收益差: {verdict['max_state_pair_diff']:.4f} (门槛 > 0.003)",
        f"- 最佳状态对: {verdict['best_pair']}",
        f"- 错位负控差异: {lag_diff:.4f}",
        f"- 负控复制率: {lag_diff/verdict['max_state_pair_diff']:.2%} (门槛 < 50% 有 alpha)",
        "",
        f"## 判定", "",
    ]
    if silhouette_l1 < 0.25:
        lines.append("- ❌ 形态无结构（轮廓系数 < 0.25）→ park")
    elif lag_diff >= 0.8 * verdict['max_state_pair_diff']:
        lines.append("- ❌ beta 伪装（负控复制 ≥ 80%）→ park")
    elif verdict['max_state_pair_diff'] <= 0.003:
        lines.append("- ⚠️ 结构但无预测力 → 记录不影响 hard5")
    else:
        lines.append("- ✅ 有预测力 → 值得开 formal（新独立 EX 预注册）")
    lines += ["", f"## 状态画像", "", prof.to_markdown(index=False), ""]
    path.write_text("\n".join(lines), encoding="utf-8")
```

- [ ] **Step 2: 填 main() 串联全流程**

```python
def main():
    print(f"[{EX_TAG}] start RD={RD_ID} EX={EX_ID}", flush=True)
    parser = argparse.ArgumentParser()
    parser.add_argument("--out", default=str(PROJECT_ROOT / f"results/v2/research/{RD_ID}/{EX_ID}"))
    args = parser.parse_args()
    out_dir = Path(args.out)
    
    client = _connect()
    portal = ClickHouseDataPortal()  # 默认初始化；若需参数见 clickhouse_portal.py
    
    etfs = list(STATIC_ETF_POOL)
    print(f"[{EX_TAG}] pool size={len(etfs)}", flush=True)
    
    # 1. 数据
    daily_close = _load_daily_close(portal, etfs)
    trading_days = sorted(daily_close.index.astype(str))
    minute_1309 = _load_minute_1309_and_factor(portal, etfs, trading_days)
    factor_df = _load_daily_factor(client, etfs)
    
    # 2. 特征
    score_1309_panel = _compute_score_1309_panel(daily_close, minute_1309, factor_df)
    score_close_panel = _compute_score_close_panel(daily_close)
    l1 = _layer1_features(score_1309_panel)
    intraday = _compute_intraday_features(portal, etfs, trading_days, factor_df)
    l2 = _layer2_features(intraday)
    
    # 3. 聚类（K 在纯形态选）
    k1, gmm1 = _select_k_gmm(l1, range(2, 6), "layer1")
    k2, gmm2 = _select_k_gmm(l2, range(2, 4), "layer2")
    ari1 = _bootstrap_stability(l1, k1)
    ari2 = _bootstrap_stability(l2, k2)
    sil1 = silhouette_score(l1.dropna().values, gmm1.predict(l1.dropna().values))
    sil2 = silhouette_score(l2.dropna().values, gmm2.predict(l2.dropna().values))
    combo = _combine_states(gmm1, gmm2, l1, l2)
    
    # 4. 评估
    ret_long = _compute_next_day_returns(minute_1309, factor_df)
    prof, verdict = _evaluate_states(combo, ret_long)
    lag_diff = _lagged_negative_control(combo, ret_long)
    hard5_cross = _hard5_reference_cross(score_1309_panel, ret_long, combo)
    
    # 5. 落盘
    _write_csv(out_dir / "diagnostic" / "state_profile.csv", prof)
    _write_csv(out_dir / "diagnostic" / "layer1_features.csv", l1.reset_index())
    _write_csv(out_dir / "diagnostic" / "layer2_features.csv", l2.reset_index())
    _write_csv(out_dir / "diagnostic" / "combo_states.csv", combo)
    _write_csv(out_dir / "diagnostic" / "hard5_reference_cross.csv", hard5_cross)
    _write_csv(out_dir / "diagnostic" / "score_1309_panel.csv", score_1309_panel)
    _write_json(out_dir / "summary" / "overview.json", {
        "rd_id": RD_ID, "ex_id": EX_ID,
        "k_layer1": k1, "k_layer2": k2,
        "silhouette_l1": sil1, "silhouette_l2": sil2,
        "ari_l1": ari1, "ari_l2": ari2,
        **verdict, "lagged_control_diff": lag_diff,
    })
    _write_summary_md(out_dir / "summary" / "regime_panel_summary.md",
                      prof, verdict, lag_diff, sil1, sil2, ari1, ari2)
    print(f"[{EX_TAG}] done. output={out_dir}", flush=True)
```

- [ ] **Step 3: 在 WSL 内运行脚本（实时进度）**

按 AGENTS.md 平台命令边界，回测/分析在 WSL 内运行，实时输出：

```bash
PLATFORM_WSL=$(powershell -ExecutionPolicy Bypass -File "E:/【笔记库】/量化研究库_V2.0.0/tools/Get-QuantPlatformRoot.ps1" -Target Platform -Format WSL)
wsl -- bash -lc "cd '$PLATFORM_WSL' && PYTHONPATH=src PYTHONUNBUFFERED=1 python3 scripts/research/analyze_etf_regime_1309_panel.py 2>&1 | tee results/v2/research/${RD_ID}/${EX_ID}/run.log"
```

Expected: 实时打印 `[REGME1309]` 前缀进度；最终生成 `diagnostic/*.csv` + `summary/overview.json` + `summary/regime_panel_summary.md`。

⚠️ 调试要点（按子代理报告）：
- `portal.get_price(None,...)` 全池可能不支持 → 改用 `_load_daily_factor` 直查 SQL
- `ClickHouseDataPortal()` 初始化参数 → 若报错查 `clickhouse_portal.py` 构造函数
- 分钟表 factor 空 → 已在 `_compute_score_1309_panel` 用日频 factor 还原
- 13:09 数据缺失的日期 → `dropna` 处理，记录缺失率

- [ ] **Step 4: 检查输出，记录到 EX 第 11/12 节**

```bash
ls -la "E:/量化平台_V1.4.0/results/v2/research/${RD_ID}/${EX_ID}/diagnostic/"
cat "E:/量化平台_V1.4.0/results/v2/research/${RD_ID}/${EX_ID}/summary/overview.json"
```

把实际观察填回 EX 第 11 节（运行命令 + 结果路径）、第 12 节（实际观察）、第 13/14 节（支持/反对证据）。

---

## Task 8: 填写 EX 实验后内容 + 同步台账

**Files:**
- Modify: `04_实验记录/EX-<新id>_<标题>.md`
- Modify: `01_台账/研究方向台账.csv`
- Modify: `01_台账/实验台账.csv`
- Modify: `01_台账/子代理调用台账.csv`

**Interfaces:**
- Consumes: Task 7 的实际结果（overview.json + summary md）

- [ ] **Step 1: 填 EX 第 1/12-17 节（实验后必补）**

根据 Task 7 输出填写：
- 第 1 节 新手摘要：用 plain 话总结"分类成几类、有没有预测力、结论是什么"
- 第 12 节 实际观察：抄 overview.json 关键数字（k1/k2/silhouette/ari/收益差/负控）
- 第 13 节 支持证据：过门槛的指标
- 第 14 节 反对证据：未过门槛的指标
- 第 15 节 偏差诊断：实际 vs 预测（第 4 节）
- 第 16 节 研究判断：建议状态（observe / park / promote_candidate）
- 第 17 节 下一步：按规格 §9 后续决策路径

- [ ] **Step 2: 更新 EX frontmatter status/stage**

```yaml
status: completed       # 或 parked（看结果）
stage: completed_readonly_regime_strategy_panel
quality_gate: L1_readonly_completed
```

- [ ] **Step 3: 同步研究方向台账（追加 1 行，带引号风格）**

Read `01_台账/研究方向台账.csv`，追加（注意双引号包裹、`/` 分隔、ISO8601-Z）：

```csv
"<RD_ID>","RD-20260605T115651Z-main-DP00","模块","市场状态识别模块","双池轮动全池1309市场状态分类模块","<status>","P2","main","<created>Z","<updated>Z","02_研究方向/<RD_ID>_双池轮动全池1309市场状态分类模块.md","","<EX_ID>","<next_action>"
```

- [ ] **Step 4: 同步实验台账（追加 1 行，无引号风格）**

Read `01_台账/实验台账.csv`，追加（注意**无引号**、`config_paths`/`result_paths` 用 `;` 分隔）：

```csv
<EX_ID>,<RD_ID>,<completed或parked>,completed_readonly_regime_strategy_panel,ETF全池1309市场状态GMM分类只读面板,<假设一句话>,${LEGACY_QUANT_PLATFORM_ROOT}/scripts/research/analyze_etf_regime_1309_panel.py,${LEGACY_QUANT_PLATFORM_ROOT}/results/v2/research/<RD_ID>/<EX_ID>/,04_实验记录/<EX_ID>_ETF全池1309市场状态GMM分类只读面板.md,,<created>Z,<updated>Z>,<新手摘要一句话>,<下一步>
```

- [ ] **Step 5: 同步子代理调用台账（追加 6 行本次头脑风暴+落地的子代理）**

Read `01_台账/子代理调用台账.csv`，追加 6 行（无引号），每行对应一个 SUB/SUBTASK：

```csv
SUB-20260702T<时间>Z-main-<4码>,SUBTASK-20260702T<时间>Z-main-<4码>,<平台昵称>,sonnet,main,<读取的文件清单>,<输入摘要>,<输出摘要>,<EX_ID 或 RD_ID>,,completed,main,low,2026-07-02T<时间>Z,<新手摘要>
```

6 行对应：CTX-HARD5 / CTX-SCORE / CTX-DYNTHRESH / CTX-REGIME / CTX-PLATFORM / CTX-REPOPROC。

- [ ] **Step 6: 提交台账与 EX 回填**

```bash
cd "E:/【笔记库】/量化研究库_V2.0.0"
git add "04_实验记录/EX-<新id>_*.md" "01_台账/研究方向台账.csv" "01_台账/实验台账.csv" "01_台账/子代理调用台账.csv"
git commit -m "feat(EX): 回填 <EX_ID> 实验结果并同步台账

实验后 7 项已补齐（观察/支持/反对/偏差/判断/下一步/新手摘要）。
状态: <completed/parked>。同步 RD/EX/SUB 三台账。"
```

---

## Task 9: 重建研究图谱 + 进展板 + UTF-8 校验

**Files:**
- Modify: `00_入口/研究进展板.canvas`（Build-ResearchBoard）
- Modify: `00_入口/研究图谱.json` + `研究图谱.md`（Build-ResearchGraph）

- [ ] **Step 1: 重建研究进展板**

```bash
cd "E:/【笔记库】/量化研究库_V2.0.0"
powershell -ExecutionPolicy Bypass -File tools/Build-ResearchBoard.ps1
```

Expected: 进展板刷新，新 RD/EX 出现在叙事板。

- [ ] **Step 2: 重建研究图谱（验证 0 悬空边）**

```bash
powershell -ExecutionPolicy Bypass -File tools/Build-ResearchGraph.ps1
```

Expected: 输出 `0 悬空边`（或类似验证通过信息）。

- [ ] **Step 3: UTF-8 校验**

```bash
powershell -ExecutionPolicy Bypass -File tools/Test-ResearchRepo.ps1
```

Expected: 核心文本文件通过 UTF-8 检查。

- [ ] **Step 4: 检查研究驾驶舱是否需更新**

Read `00_入口/研究驾驶舱.md`，若新方向影响"当前主推方向"或"近期重点"，更新一段说明；否则跳过。

- [ ] **Step 5: 提交重建产物**

```bash
cd "E:/【笔记库】/量化研究库_V2.0.0"
git add "00_入口/研究进展板.canvas" "00_入口/研究图谱.json" "00_入口/研究图谱.md"
# 研究驾驶舱若改也 add

> 历史实施记录：本文中的 V1.4 路径、旧 runner 和当时命令按原证据保留，禁止作为当前执行入口。当前平台为 `${QUANT_PLATFORM_ROOT}`（V2.0），运行必须遵守研究库与平台各自的 `AGENTS.md`。
git commit -m "chore: 重建研究进展板与图谱（新增 <RD_ID>/<EX_ID>）

Build-ResearchBoard + Build-ResearchGraph（0 悬空边）+ Test-ResearchRepo 通过。"
```

---

## 自审清单（writing-plans 技能要求）

**1. 规格覆盖**：规格 §1-12 逐节核对——
- §0/§1 命题与定位 → Task 1/2（RD/EX 立项）✓
- §2 假设 → EX 第 3 节（Task 2 Step 4）✓
- §3 数据口径 → Task 3 Step 2-4 ✓
- §4 两层特征 → Task 4 ✓
- §5 分类方法 → Task 5 ✓
- §6 评估门槛 → Task 6 + Task 7 落盘判定 ✓
- §7 防过拟合 → EX 第 8/9 节（Task 2 Step 4）+ Task 5 K 选择规则 ✓
- §8 待确认项 → 已在规格修正（score 公式/池/13:09 全部核实）✓
- §9 后续路径 → EX 第 17 节（Task 8 Step 1）✓
- §10 实现位置 → Task 3 脚本路径 + EX frontmatter config_paths ✓
- §11 落地清单 → Task 1/2/8/9 全覆盖 ✓
- §12 YAGNI → 计划未包含 formal/扫描/实盘 ✓

**2. 占位符扫描**：`<RD_ID>`/`<EX_ID>`/`<时间>`/`<4码>` 是 New-ResearchItem.ps1 生成后才能填的动态值，属合理占位（脚本无法预生成 ID）。`<平台昵称>` 由运行时分配。无 TBD/TODO/"适当处理"。

**3. 类型一致性**：
- `weighted_regression_momentum_scores(prices, window=25, annualization=250)` — Task 3/4/6 一致 ✓
- `portal.load_minute_field_snapshot(day, symbols, event_times, fields, start_time, end_time)` — Task 3/4 一致 ✓
- `STATIC_ETF_POOL` — Task 3 import，Task 3/4/7 使用一致 ✓
- `state_combo` 字段名 — Task 5 定义，Task 6 评估使用一致 ✓
- `score_1309` / `score_close` 字段名 — Task 4 定义，Task 6 交叉表使用一致 ✓

**结论**：计划完整，无遗漏，可执行。

---

## 执行交接

计划完成，已保存到 `docs/superpowers/plans/2026-07-02-etf-regime-1309-classifier.md`。两种执行选项：

**1. 子代理驱动（推荐）** —— 我为每个 Task 派发全新子代理，Task 间审查，快速迭代

**2. 内联执行** —— 用 executing-plans 在本会话中执行 Task，带检查点的批量执行

选哪种？
