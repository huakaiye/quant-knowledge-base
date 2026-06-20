# Frontmatter 规范

本规范是研究库所有 Markdown 资产 YAML frontmatter 字段的**单一事实源**。`tools/Invoke-RepoAudit.ps1` 按本页校验，`10_模板/*.md` 按本页生成。

## 设计原则

1. **字段名稳定**：一旦定义，不在历史文件里做破坏性重命名。`rd_id`（单数，用于 RD/EX）与 `rd_ids`（复数，用于 DEC 的一对多）是不同语义，不是笔误。
2. **枚举有弹性**：`status` 和 `decision` 提供推荐枚举，但允许带语义的细分值（如 `promote_candidate`、`continue_negative_control`、`promote_engineering`），校验只拦截明显错误的自由值（如中文 `只读标记`、`live`、`waiting`）。
3. **迁移文件宽容**：`*-mig-*` 文件允许字段不齐全，但必须保留 `migration_status` 和 `evidence_level`，标识其未复核状态。
4. **路径可移植**：平台路径统一用 `${QUANT_PLATFORM_ROOT}` / `${LIVE_TRADING_ROOT}` 逻辑根或平台内相对路径，禁止写死个人绝对路径。

## 通用字段（所有资产）

| 字段 | 必填 | 说明 |
| --- | --- | --- |
| `type` | 是 | 资产类型，见下表 |
| `<资产>_id` | 是 | 主 ID，与文件名前缀对齐 |
| `owner` | 是 | 创建者标识，如 `main`、`mig`、`zicha001` |
| `created_at` | 是 | UTC ISO8601-Z，如 `2026-06-05T11:56:51Z` |
| `updated_at` | 是 | UTC ISO8601-Z |
| `tags` | 否 | YAML 列表 |

## 各资产字段 schema

### RD 研究方向（`02_研究方向/`）

| 字段 | 必填 | 规则 |
| --- | --- | --- |
| `type` | 是 | `研究方向` |
| `rd_id` | 是 | 与文件名一致 |
| `parent_rd_id` | 模块级必填 | `scope: 模块` 时必须指向策略级 RD；`scope: 策略` 时留空 |
| `scope` | 是 | `策略` / `模块` / `旧库迁移` |
| `module_type` | 模块必填 | 模块类型说明，如 `防御模块` |
| `status` | 是 | 见 status 枚举 |
| `priority` | 是 | `P0` / `P1` / `P2` / `P3` |
| `strategy_id` | 否 | 关联策略档案 |
| `current_decision_id` | 否 | 当前决策 |
| `current_best_ex_id` | 否 | 当前最佳实验 |

### EX 实验记录（`04_实验记录/`）

| 字段 | 必填 | 规则 |
| --- | --- | --- |
| `type` | 是 | `实验记录` |
| `ex_id` | 是 | 与文件名一致 |
| `rd_id` | 是 | 必须在 RD 台账存在（mig 文件查 `legacy_to_rd_map.csv` 补全） |
| `status` | 是 | 见 status 枚举 |
| `stage` | 是 | 实验阶段，自由文本但推荐用结构化值，如 `preregistered` / `smoke_passed` / `formal_completed` / `legacy_raw`（迁移专用） |
| `strategy_id` | 否 | |
| `module_type` | 否 | |
| `decision_ids` | 否 | YAML 列表 |
| `lit_ids` | 否 | YAML 列表 |
| `idea_ids` | 否 | YAML 列表 |
| `platform_project` | 否 | 默认 `${QUANT_PLATFORM_ROOT}` |
| `config_paths` | 否 | YAML 列表，平台相对路径 |
| `result_paths` | 否 | YAML 列表 |
| `summary_paths` | 否 | YAML 列表 |
| `quality_gate` | 否 | 证据等级门禁结论 |
| `migration_status` | mig 必填 | `migrated_unverified` / `migrated_verified` / `archived` |
| `evidence_level` | mig 必填 | `legacy_raw` / `legacy_reviewed` |
| `legacy_id` | mig 选填 | 旧库编号 |
| `source_old_path` | mig 选填 | 旧库绝对路径（迁移证据，允许保留） |

### DEC 研究决策（`05_研究决策/`）

| 字段 | 必填 | 规则 |
| --- | --- | --- |
| `type` | 是 | `研究决策` |
| `dec_id` | 是 | 与文件名一致 |
| `rd_ids` | 是 | **复数**，YAML 列表；禁止用单数 `rd_id` |
| `ex_ids` | 否 | **复数**，YAML 列表；禁止用单数 `ex_id` |
| `decision` | 是 | 见 decision 枚举（允许细分值） |
| `impact` | 否 | `direction` / `module` / `process` |
| `migration_status` | mig 必填 | 同 EX |
| `evidence_level` | mig 必填 | 同 EX |

### LIT 文献（`06_文献资料/`）

| 字段 | 必填 | 规则 |
| --- | --- | --- |
| `type` | 是 | `文献` |
| `lit_id` | 是 | 与文件名一致 |
| `status` | 是 | `待处理` / `已归档` / `已转化` |
| `source` | 否 | 期刊或出处 |
| `authors` | 否 | |
| `year` | 否 | |

### STRAT 策略档案（`03_策略档案/`）

| 字段 | 必填 | 规则 |
| --- | --- | --- |
| `type` | 是 | `策略档案` |
| `strategy_id` | 是 | 与文件名一致 |
| `name` | 是 | 策略名 |
| `status` | 是 | 见 status 枚举 |
| `rd_id` | 否 | 关联策略级 RD |
| `platform_project` | 否 | 默认 `${QUANT_PLATFORM_ROOT}` |

### IDEA / FAC / DATA / MECH 灵感（`07_因子数据灵感/`）

| 字段 | 必填 | 规则 |
| --- | --- | --- |
| `type` | 是 | `灵感` / `因子` / `数据` / `机制` |
| `idea_id` | 是 | 与文件名一致（IDEA/FAC/DATA/MECH 统一用 `idea_id`） |
| `status` | 是 | `draft` / `active` / `park` / `converted` |

### TERM 术语（`09_术语库/`）

| 字段 | 必填 | 规则 |
| --- | --- | --- |
| `type` | 是 | `术语` |
| `term_id` | 是 | 与文件名一致 |
| `term` | 是 | 术语名 |

### MIG 迁移卡（`11_迁移暂存/`）

| 字段 | 必填 | 规则 |
| --- | --- | --- |
| `type` | 是 | `迁移卡` |
| `mig_id` | 是 | 与文件名一致 |
| `status` | 是 | `todo` / `mapped` / `migrated` / `verified` / `discarded` / `migrated_unverified` |
| `source_old_path` | 否 | 旧库路径 |

## status 枚举

用于 RD/EX/DEC/STRAT/IDEA 的 `status` 字段。校验时，以下值为**合法**：

| 值 | 含义 |
| --- | --- |
| `draft` | 草稿，未启动 |
| `active` | 正在推进 |
| `completed` | 已完成（多用于 EX） |
| `promote` | 已升级 |
| `promote_candidate` | 候选升级 |
| `revise` | 需修订重做 |
| `park` | 暂停保留证据 |
| `kill` | 否定归档 |
| `observe` | 只观察不改默认 |
| `migrated_unverified` | 迁移未复核（mig 专用） |
| `migrated_verified` | 迁移已复核（mig 专用） |
| `reviewed_readonly_baseline_skeleton` | 已复核只读骨架（mig 专用） |
| `archived` | 已归档 |
| `待处理` / `已归档` / `已转化` | LIT 专用 |

**非法值**（校验直接拦截）：`live`、`waiting`、`只读标记`、`只读标签`、`观察中`、`暂不采纳`、空字符串。

## decision 枚举

用于 DEC 的 `decision` 字段。允许**推荐枚举 + 带语义的细分值**：

推荐枚举：`accept` / `promote` / `promote_candidate` / `promote_engineering` / `revise` / `park` / `kill` / `observe` / `continue_negative_control` / `draft`

细分值规则：必须是小写英文+下划线，且能从语义归入上述某一类（如 `continue_negative_control` 属 `observe` 范畴）。校验拦截：中文值（`暂不采纳`、`采纳`、`观察中`）、`live`、空字符串。

## 台账 CSV 规范

| 规则 | 要求 |
| --- | --- |
| 编码 | UTF-8 无 BOM（与 `研究方向台账.csv` 一致） |
| 路径分隔符 | `file` 列统一用正斜杠 `/`，禁止反斜杠 `\` |
| 时间格式 | `*_at_utc` 列必须 ISO8601-Z，禁 `+08:00` 偏移 |
| 多值分隔 | `rd_ids`/`ex_ids`/`decision_ids` 用分号 `;` 分隔 |
| 尾部 | 不留空行 |

## 校验工具联动

`tools/Invoke-RepoAudit.ps1` 严格按本页执行。本页修改即视为 schema 变更，需同步更新 `10_模板/*.md` 并跑一次全库校验。
