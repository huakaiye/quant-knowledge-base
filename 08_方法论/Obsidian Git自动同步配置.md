# Obsidian Git 自动同步配置

本页记录本研究库推荐的 Obsidian Git 插件配置。插件私密配置文件 `.obsidian/plugins/obsidian-git/data.json` 不提交到 GitHub，但本地应按本页设置。

## 多人协作默认设置

多人共同编辑本库时，不建议开启高频自动提交和自动推送。`00_入口/` 和 `01_台账/` 是高频共享文件，5 分钟自动推送会把半成品入口摘要、台账更新和同事的并行更新直接撞到一起，形成 Obsidian Git 无法自动处理的合并冲突。

推荐把 Obsidian Git 作为“手动同步按钮”，而不是后台自动同步器：

| 设置 | 推荐值 | 说明 |
| --- | ---: | --- |
| `autoSaveInterval` | 0 | 关闭定时自动备份，改为完成一个原子修改后手动备份 |
| `autoPushInterval` | 0 | 关闭定时自动推送，避免把未整理完的入口和台账自动推到远端 |
| `autoPullInterval` | 0 | 关闭编辑过程中的定时自动拉取，避免正在写文件时被远端更新打断 |
| `autoPullOnBoot` | true | Obsidian 启动时自动拉取 |
| `pullBeforePush` | true | 推送前先拉取，减少冲突 |
| `disablePush` | false | 允许推送 |
| `autoBackupAfterFileChange` | false | 关闭文件变化后立刻备份，避免频繁提交零散草稿 |
| `syncMethod` | merge | 默认用 merge 同步 |

单人短期维护、无人并行编辑时，可以临时启用自动备份；回到多人协作前必须恢复上表设置。

## 单人自动模式

以下设置只适合单人维护或短时间无人并行编辑的窗口，不作为团队默认值：

| 设置 | 单人可用值 | 说明 |
| --- | ---: | --- |
| `autoSaveInterval` | 5 | 每 5 分钟自动备份一次 |
| `autoPushInterval` | 5 | 每 5 分钟自动推送一次 |
| `autoPullInterval` | 5 | 每 5 分钟自动拉取一次 |
| `autoBackupAfterFileChange` | true | 文件变化后自动备份 |

启用单人自动模式前，先在团队沟通中确认没人同时改 `00_入口/`、`01_台账/`、`08_方法论/` 和同一批实验/决策文件。

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
4. 在 Obsidian Git 设置中按“多人协作默认设置”填写同步参数。
5. 确认 Git 凭据在本机可用后，再启用自动推送。

## 每次编辑前后流程

开始编辑前：

```powershell
git status --short --branch
git pull --no-rebase
```

如果 `git status` 显示未提交修改，先确认这些修改是不是自己上一轮留下的。不要在未解决冲突或未整理本地修改时继续用 Obsidian Git 自动同步。

编辑时：

- 新实验、新决策、新文献和新灵感优先新建独立文件，并使用唯一 ID，避免多人抢同一个文件名。
- `00_入口/研究驾驶舱.md`、`00_入口/当前状态.md` 和 `01_台账/*.csv` 只在一轮工作结束时集中更新。
- 不把入口文件当草稿区；草稿先写到具体实验、决策或临时本地笔记，收口后再同步入口摘要。

完成编辑后：

```powershell
rg -n "<<<<<<<|=======|>>>>>>>" .
powershell -ExecutionPolicy Bypass -File tools/Test-ResearchRepo.ps1
git status --short
```

确认无冲突标记、健康检查通过后，再用 Obsidian Git 或命令行提交并推送。

## 冲突处理

自动同步不等于自动解决研究冲突。若 Obsidian Git 提示冲突：

1. 停止继续编辑冲突文件。
2. 先打开 Git 差异，确认冲突来自哪一份实验、决策或台账。
3. 对 Markdown 冲突，优先保留两边的研究事实，人工合并成一段新的当前事实，不简单选择 `HEAD` 或 `origin/main`。
4. 对台账 CSV 冲突，按主键合并记录：实验用 `ex_id`，决策用 `dec_id`，方向用 `rd_id`，子代理调用用 `call_id`；同一个 ID 的多侧修改必须人工看 `updated_at_utc` 或 `timestamp_utc` 后决定。
5. 合并后运行：

```powershell
rg -n "<<<<<<<|=======|>>>>>>>" .
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
- `pull.rebase false` 与 Obsidian Git 的 merge 同步方式保持一致。
- `core.autocrlf false` 交给 `.gitattributes` 管控换行，避免 CSV/Markdown 被反复改行尾。
