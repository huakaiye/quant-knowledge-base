# Obsidian 使用规范

本研究库计划上传到 GitHub，但人类研究者仍以 Obsidian 作为主要阅读和编辑界面。

## 已复用旧库配置

新库已从旧研究库复制 Obsidian 外观、核心插件配置、社区插件启用列表、社区插件代码、snippets 和 themes。

旧库路径：

```text
E:\【笔记库】\量化研究库\.obsidian
```

## 未复制或不提交的内容

以下内容属于本地状态或可能包含私密信息，不进入 GitHub：

- `.obsidian/workspace*.json`
- `.obsidian/cache/`
- `.obsidian/todoist-token`
- `.obsidian/plugins/*/data.json`
- `.obsidian/plugins/obsidian-git/obsidian_askpass.sh`

## 可以提交的内容

- `.obsidian/app.json`
- `.obsidian/appearance.json`
- `.obsidian/canvas.json`
- `.obsidian/community-plugins.json`
- `.obsidian/core-plugins*.json`
- `.obsidian/graph.json`
- `.obsidian/hotkeys.json`
- `.obsidian/plugins/*/manifest.json`
- `.obsidian/plugins/*/main.js`
- `.obsidian/plugins/*/styles.css`
- `.obsidian/snippets/`
- `.obsidian/themes/`

## 推荐使用方式

1. 用 Obsidian 打开 `E:\【笔记库】\量化研究库_V2.0.0`。
2. 从 `00_入口/研究驾驶舱.md` 开始阅读。
3. 使用 Dataview、表格编辑、Kanban、Canvas、Excalidraw 等插件辅助浏览。
4. 如果某插件首次打开需要重新授权或重新配置，优先在本地填写，不提交 `data.json`。

## 与 GitHub 的关系

Obsidian 负责人类阅读体验，GitHub 负责版本协作和审查。不要为了 Obsidian 便利牺牲 GitHub 安全边界。

如果某个插件配置对团队协作确实重要，应把可公开配置写进研究库文档，而不是提交含私密字段的 `data.json`。
