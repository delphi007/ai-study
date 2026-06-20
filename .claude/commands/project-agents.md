---
description: 列出当前项目的所有专属 agent 及其职责和触发方式
---

读取 `.claude/agents/` 目录下除 PROJECT_CUSTOMIZATION.md 外的所有 agent 定义文件。对每个 agent，提取 name、description、own、do_not_touch、trigger 字段。然后输出汇总表：

## 项目 Agent 清单

| Agent | 职责 | 触发方式 |
|-------|------|---------|
| [按实际文件列出] | [own 字段内容] | [trigger 字段内容] |

然后附带一段说明：这些 agent 也可以用 `Agent("name")` 显式调用。全局 Meta_Kim agent 需要用其他方式查看，不在本项目 agent 目录中。
