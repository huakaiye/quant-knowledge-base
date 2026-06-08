# Obsidian Git 自动同步配置

本页记录本研究库推荐的 Obsidian Git 插件配置。插件私密配置文件 `.obsidian/plugins/obsidian-git/data.json` 不提交到 GitHub，但本地应按本页设置。

## 团队默认原则

多人共同编辑本库时，不推荐让 Obsidian Git 插件高频自动 pull/push。`00_入口/` 和 `01_台账/` 是高频共享文件，5 分钟自动推送会把半成品入口摘要、台账更新和同事的并行更新直接撞到一起。

团队默认做法：

- Obsidian 负责阅读和编辑。
- Obsidian Git 插件最多负责本地手动备份。
- 跨设备、跨 Agent 或 GitHub 远端同步统一使用 `tools/Sync-ResearchRepo.ps1`。
- 台账 CSV 的结构化冲突由 `tools/Merge-LedgerCsv.ps1` 辅助合并。
- 入口文档和研究判断冲突必须人工或主控 Agent 合成，不自动猜结论。

## 推荐本地设置

| 设置 | 推荐值 | 说明 |
| --- | ---: | --- |
| `autoSaveInterval` | 0 | 关闭定时自动备份，完成一个原子修改后再手动备份或运行同步脚本 |
| `autoPushInterval` | 0 | 禁止插件定时推送，避免未检查内容进入 GitHub |
| `autoPullInterval` | 0 | 禁止编辑过程中定时拉取，避免正在写文件时被远端更新打断 |
| `autoPullOnBoot` | false | 启动时不自动拉取，先由同步脚本检查状态 |
| `pullBeforePush` | false | 插件不负责推送时无需启用 |
| `disablePush` | true | 禁止插件推送，统一走安全同步脚本 |
| `autoBackupAfterFileChange` | false | 关闭文件变化后立刻备份，避免频繁提交零散草稿 |
| `syncMethod` | merge | 保留默认值；实际跨端同步使用脚本 |

如果只想用插件保留本地检查点，可以临时打开 `autoSaveInterval`，但仍必须保持自动 pull、自动 push 和插件 push 关闭。

## 安全同步脚本

日常需要同步到 GitHub 时，在仓库根目录运行：

```powershell
powershell -ExecutionPolicy Bypass -File tools/Sync-ResearchRepo.ps1
```

脚本会执行：

1. 检查是否已有未完成 merge/rebase。
2. 删除 Obsidian Git 生成的临时冲突提示文件 `conflict-files-obsidian-git.md`。
3. 如本地有改动，先创建同步前备份，再自动提交本地 Obsidian 改动。
4. `git fetch --prune origin`。
5. 合并 `origin/main`。
6. 对 `01_台账/*.csv` 冲突按第一列 ID 自动合并去重。
7. 遇到 `00_入口/当前状态.md`、`00_入口/研究驾驶舱.md` 等语义冲突时停止，不自动猜结论。
8. 运行 `git diff --check` 和 `tools/Test-ResearchRepo.ps1`。
9. 通过全部检查后才推送到 GitHub `main`。

只想测试合并和检查、不推送时：

```powershell
powershell -ExecutionPolicy Bypass -File tools/Sync-ResearchRepo.ps1 -NoPush
```

如果需要交给 Windows 计划任务，建议 10 到 15 分钟一次，不要 1 到 5 分钟高频运行。计划任务里的脚本路径使用本机研究库真实路径，不写入共享文档。

自动同步的边界是：脚本可以合并结构化台账事实，但不能自动合并研究判断。若脚本停在语义冲突，必须由人工或 Agent 读取双方内容后合成。

## 安全边界

以下内容仍然不提交：

- `.obsidian/plugins/obsidian-git/data.json`
- `.obsidian/plugins/obsidian-git/obsidian_askpass.sh`
- `.obsidian/workspace*.json`
- `conflict-files-obsidian-git.md`
- 任何 token、账号、私密远端配置或本机状态。

## 新设备复现步骤

1. 克隆 `https://github.com/huakaiye/quant-knowledge-base.git`。
2. 用 Obsidian 打开仓库目录。
3. 确认社区插件 `Git` 已启用。
4. 在 Obsidian Git 设置中按“推荐本地设置”填写参数，关闭插件自动拉取和自动推送。
5. 确认 Git 凭据在本机可用后，运行 `tools/Sync-ResearchRepo.ps1 -NoPush` 做第一次安全检查。
6. 检查通过后，再运行 `tools/Sync-ResearchRepo.ps1` 做正式同步。

## 每次编辑前后流程

开始编辑前：

```powershell
git status --short --branch
powershell -ExecutionPolicy Bypass -File tools/Sync-ResearchRepo.ps1 -NoPush
```

如果 `git status` 显示未提交修改，先确认这些修改是不是自己上一轮留下的。不要在未解决冲突或未整理本地修改时继续用 Obsidian Git 自动同步。

编辑时：

- 新实验、新决策、新文献和新灵感优先新建独立文件，并使用唯一 ID，避免多人抢同一个文件名。
- `00_入口/研究驾驶舱.md`、`00_入口/当前状态.md` 和 `01_台账/*.csv` 只在一轮工作结束时集中更新。
- 不把入口文件当草稿区；草稿先写到具体实验、决策或临时本地笔记，收口后再同步入口摘要。

完成编辑后：

```powershell
rg -n "^(<<<<<<<|=======|>>>>>>>)" .
powershell -ExecutionPolicy Bypass -File tools/Test-ResearchRepo.ps1
git status --short
```

确认无冲突标记、健康检查通过后，再运行安全同步脚本提交并推送。

## 冲突处理

若 Obsidian Git 或安全同步脚本提示冲突：

1. 停止继续编辑冲突文件。
2. 先运行安全同步脚本，让它自动处理可结构化合并的台账冲突：

```powershell
powershell -ExecutionPolicy Bypass -File tools/Sync-ResearchRepo.ps1 -NoPush
```

3. 若脚本仍停止，打开 Git 差异，确认冲突来自哪一份实验、决策或台账。
4. 对 Markdown 冲突，优先保留两边的研究事实，人工合并成一段新的当前事实，不简单选择 `HEAD` 或 `origin/main`。
5. 对台账 CSV 冲突，按主键合并记录：实验用 `ex_id`，决策用 `dec_id`，方向用 `rd_id`，子代理调用用 `call_id`；同一个 ID 的多侧修改必须人工看 `updated_at_utc` 或 `timestamp_utc` 后决定。
6. 合并后运行：

```powershell
rg -n "^(<<<<<<<|=======|>>>>>>>)" .
powershell -ExecutionPolicy Bypass -File tools/Test-ResearchRepo.ps1
```

确认通过后再执行：

```powershell
git add <已解决文件>
git commit
git push
```

不要提交 `conflict-files-obsidian-git.md`。该文件是插件生成的冲突提示，已在 `.gitignore` 中排除。

## 本地 Git 建议

每台机器建议启用以下本地配置；这些配置写入 `.git/config`，不提交到共享仓库：

```powershell
git config rerere.enabled true
git config merge.conflictStyle zdiff3
git config pull.rebase false
git config core.autocrlf false
```

含义：

- `rerere.enabled` 记录已解决过的冲突，后续相似冲突可自动套用解决方案。
- `merge.conflictStyle zdiff3` 在冲突中显示共同祖先，便于判断双方各改了什么。
- `pull.rebase false` 与本库 merge 同步方式保持一致。
- `core.autocrlf false` 交给 `.gitattributes` 管控换行，避免 CSV/Markdown 被反复改行尾。
