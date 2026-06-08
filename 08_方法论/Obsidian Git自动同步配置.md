# Obsidian Git 自动同步配置

本页记录本研究库推荐的 Obsidian Git 插件配置。插件私密配置文件 `.obsidian/plugins/obsidian-git/data.json` 不提交到 GitHub，但本地应按本页设置。

## 推荐本地设置

本库不再推荐让 Obsidian Git 插件高频自动 pull/push。插件适合做本地保存和本地自动提交；跨设备、跨 Agent 或 GitHub 远端合并，应交给 `tools/Sync-ResearchRepo.ps1` 安全同步脚本。

| 设置 | 推荐值 | 说明 |
| --- | ---: | --- |
| `autoSaveInterval` | 5 | 每 5 分钟自动备份一次 |
| `autoPushInterval` | 0 | 不由插件自动推送，交给安全同步脚本 |
| `autoPullInterval` | 0 | 不由插件自动拉取，交给安全同步脚本 |
| `autoPullOnBoot` | false | 启动时不自动拉取，避免开库即进入冲突 |
| `pullBeforePush` | false | 插件不负责推送时无需启用 |
| `disablePush` | true | 禁止插件推送，避免未检查内容进入 GitHub |
| `autoBackupAfterFileChange` | true | 文件变化后自动备份 |
| `syncMethod` | merge | 保留默认值；实际跨端同步使用脚本 |

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

如果需要把脚本交给 Windows 计划任务，建议 10 到 15 分钟一次，不要 1 到 5 分钟高频运行：

```powershell
schtasks /Create /TN "ResearchRepoSafeSync" /SC MINUTE /MO 15 /TR "powershell -NoProfile -ExecutionPolicy Bypass -File \"D:\Obsidian\量化研究库_V2\tools\Sync-ResearchRepo.ps1\"" /F
```

自动同步的边界是：脚本可以合并结构化台账事实，但不能自动合并研究判断。若脚本停在语义冲突，必须由人工或 Agent 读取双方内容后合成。

## 安全边界

以下内容仍然不提交：

- `.obsidian/plugins/obsidian-git/data.json`
- `.obsidian/plugins/obsidian-git/obsidian_askpass.sh`
- `.obsidian/workspace*.json`
- 任何 token、账号、私密远端配置或本机状态。

## 新设备复现步骤

1. 克隆 `https://github.com/huakaiye/quant-knowledge-base.git`。
2. 用 Obsidian 打开仓库目录。
3. 确认社区插件 `Git` 已启用。
4. 在 Obsidian Git 设置中按“推荐本地设置”填写自动备份，关闭插件自动拉取和自动推送。
5. 确认 Git 凭据在本机可用后，运行 `tools/Sync-ResearchRepo.ps1` 做第一次安全同步。

## 冲突处理

自动同步不等于自动解决研究冲突。若 Obsidian Git 提示冲突：

1. 停止继续编辑冲突文件。
2. 先运行安全同步脚本，让它自动处理可结构化合并的台账冲突：

```powershell
powershell -ExecutionPolicy Bypass -File tools/Sync-ResearchRepo.ps1 -NoPush
```

3. 若脚本仍停止，打开 Git 差异，确认冲突来自哪一份实验、决策或台账。
4. 优先保留两边的研究事实，人工合并结论。
5. 合并后运行：

```powershell
powershell -ExecutionPolicy Bypass -File tools/Test-ResearchRepo.ps1
```
