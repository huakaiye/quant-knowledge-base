# Obsidian Git 自动同步配置

本页记录本研究库推荐的 Obsidian Git 插件配置。插件私密配置文件 `.obsidian/plugins/obsidian-git/data.json` 不提交到 GitHub，但本地应按本页设置。

## 当前本地设置

| 设置 | 推荐值 | 说明 |
| --- | ---: | --- |
| `autoSaveInterval` | 5 | 每 5 分钟自动备份一次 |
| `autoPushInterval` | 5 | 每 5 分钟自动推送一次 |
| `autoPullInterval` | 5 | 每 5 分钟自动拉取一次 |
| `autoPullOnBoot` | true | Obsidian 启动时自动拉取 |
| `pullBeforePush` | true | 推送前先拉取，减少冲突 |
| `disablePush` | false | 允许推送 |
| `autoBackupAfterFileChange` | true | 文件变化后自动备份 |
| `syncMethod` | merge | 默认用 merge 同步 |

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
4. 在 Obsidian Git 设置中按“当前本地设置”填写自动备份、自动拉取和自动推送。
5. 确认 Git 凭据在本机可用后，再启用自动推送。

## 冲突处理

自动同步不等于自动解决研究冲突。若 Obsidian Git 提示冲突：

1. 停止继续编辑冲突文件。
2. 先打开 Git 差异，确认冲突来自哪一份实验、决策或台账。
3. 优先保留两边的研究事实，人工合并结论。
4. 合并后运行：

```powershell
powershell -ExecutionPolicy Bypass -File tools/Test-ResearchRepo.ps1
```
