# Project Customization Evidence

由 Meta_Kim 2026-06-21 创建的 ai-study 项目治理 agent。基于 `projectAgentBlueprintPacket` + Type B 管线设计。

| Agent | 责任类别 | 创建原因 | 验证方法 | 回滚路径 |
|-------|---------|---------|---------|---------|
| `ai-study-content-reviewer` | 内容质量审查 | 项目有 23 篇文章、21 个 Mermaid 图、195 个双向链接，Quartz 渲染对 Mermaid 兼容性敏感，没有自动化的内容质量检查 | `Agent("ai-study-content-reviewer")` 触发后检查输出是否为结构化 findings | 删除 `.claude/agents/ai-study-content-reviewer.md` |
| `ai-study-deploy-guard` | 部署守门 | deploy.sh 137 行，涉及 Vault→Quartz sync→Git push→gh-pages 4 步，过去出现过 "Meta_Kim 不被 sync" 和 "GitHub push 超时" 两类问题，没有部署前置检查 | `Agent("ai-study-deploy-guard")` 触发后检查输出是否为 go/no-go 判定 | 删除 `.claude/agents/ai-study-deploy-guard.md` |
| `ai-study-graph-sync` | 图谱维护 | Graphify 已生成 132 节点/124 边/12 社区，新文章频繁入库（已从 11→12 CC + 0→8 Meta_Kim），没有自动提醒图谱过期的机制 | `Agent("ai-study-graph-sync")` 触发后检查输出是否含新鲜度 + 新文章列表 | 删除 `.claude/agents/ai-study-graph-sync.md` |

## 与全局能力的关系

创建前已验证：
- `meta-prism` (全局) 可以做通用代码审查，但不懂 Obsidian/Mermaid/Quartz 的特殊兼容问题 → **不可直接复用**
- `meta-scout` (全局) 可以搜索外部能力，但不维护项目图谱 → **不可直接复用**
- 全局的 `planning-with-files` skill 可以做任务规划，但不检查部署 → **不可直接复用**

因此创建 3 个**项目专用** agent，满足 Meta_Kim `projectCustomizationPacket` 要求的条件：
- `globalCandidateChecked`: ✅ meta-prism/meta-scout/planning-with-files 均不覆盖
- `projectNeed`: ✅ Obsidian+Quartz 站点特有的 Mermaid 渲染兼容、部署编排、图谱维护需求
- `mergePolicy`: `create_project_local_capability` (不覆盖全局，新增项目本地的)
