# Graph Report - Claude Code  (2026-06-19)

## Corpus Check
- 20 files · ~13,733 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 485 nodes · 465 edges · 22 communities (18 shown, 4 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]
- [[_COMMUNITY_Community 8|Community 8]]
- [[_COMMUNITY_Community 9|Community 9]]
- [[_COMMUNITY_Community 10|Community 10]]
- [[_COMMUNITY_Community 11|Community 11]]
- [[_COMMUNITY_Community 12|Community 12]]
- [[_COMMUNITY_Community 13|Community 13]]
- [[_COMMUNITY_Community 14|Community 14]]
- [[_COMMUNITY_Community 15|Community 15]]
- [[_COMMUNITY_Community 16|Community 16]]
- [[_COMMUNITY_Community 17|Community 17]]
- [[_COMMUNITY_Community 18|Community 18]]
- [[_COMMUNITY_Community 19|Community 19]]
- [[_COMMUNITY_Community 20|Community 20]]
- [[_COMMUNITY_Community 21|Community 21]]

## God Nodes (most connected - your core abstractions)
1. `Tools 工具系统` - 11 edges
2. `Skills 技能系统` - 10 edges
3. `Hooks 钩子系统` - 10 edges
4. `Agents 代理系统` - 10 edges
5. `Claude Code 入门概览` - 10 edges
6. `Slash Commands 斜杠命令系统` - 10 edges
7. `Workflows 工作流编排` - 10 edges
8. `Memory 记忆系统` - 10 edges
9. `Plan Mode 规划模式` - 10 edges
10. `MCP 模型上下文协议` - 10 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Communities (22 total, 4 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.06
Nodes (34): CLAUDE.md 的最佳结构, code:block1 (全局配置 (~/.claude/settings.json)), code:json ({), code:markdown (## 前端项目约定), code:json ({), code:markdown (## 数据管道项目约定), code:json ({), code:bash (#!/bin/bash) (+26 more)

### Community 1 - "Community 1"
Cohesion: 0.06
Nodes (32): code:block1 (~/.claude/projects/<project-hash>/memory/), code:bash (# 新会话中：), code:bash ("帮我建立决策追踪记忆体系。今天做一个决策：), code:markdown (// memory/adr-cursor-pagination.md), code:bash (# 几周后：), code:markdown (---), code:mermaid (sequenceDiagram), code:block4 (用户全局目录 (~/.claude/)：) (+24 more)

### Community 2 - "Community 2"
Cohesion: 0.06
Nodes (32): active, choiceSurfaceState, controlState, criticalFetchLoopCount, criticalFetchLoopMax, currentStage, dispatchChain, dispatchedAgents (+24 more)

### Community 3 - "Community 3"
Cohesion: 0.06
Nodes (31): code:mermaid (graph TD), code:python (#!/usr/bin/env python3), code:json ({), code:bash (#!/bin/bash), code:json ({), code:json (// .claude/settings.json), code:json ({), code:json ({) (+23 more)

### Community 4 - "Community 4"
Cohesion: 0.06
Nodes (31): code:mermaid (sequenceDiagram), code:block10 (✅ feature/user-avatar-upload 分支已从 main (a3f2c1e) 创建), code:bash (/loop 2m /verify), code:bash (# 等价于手动执行：), code:bash (# 每次代码变更后自动审查), code:bash (# 第一步：初始化项目 Claude Code 配置), code:block2 (输入：/review --comment --fix), code:markdown (# .claude/commands/deploy.md) (+23 more)

### Community 5 - "Community 5"
Cohesion: 0.06
Nodes (30): code:mermaid (graph TD), code:javascript (export const meta = {), code:bash ("用 Workflow 做技术选型 PK：三条路线并行设计，独立裁判评分，输出对比报告"), code:javascript (export const meta = {), code:block13 (┌────────────────────┬──────┬──────┬──────┬──────┬──────┬───), code:javascript (// 模式一：parallel() — 全并发，等待所有完成), code:javascript (// 每个 Workflow 脚本必须以 meta 导出开头), code:block4 (项目根目录/) (+22 more)

### Community 6 - "Community 6"
Cohesion: 0.07
Nodes (29): code:mermaid (sequenceDiagram), code:json (// settings.json), code:bash ("查看当前 Sprint 的进度，把剩余的 P0 任务分配给有空闲的工程师"), code:block2 (MCP Server), code:json ({), code:block4 (项目根目录/), code:json (// .claude/settings.json), code:bash ("用 GitHub MCP 帮我：) (+21 more)

### Community 7 - "Community 7"
Cohesion: 0.07
Nodes (29): code:mermaid (sequenceDiagram), code:block2 (项目根目录/), code:mermaid (graph TD), code:json (// .claude/settings.json), code:block5 (mcp__jira__search_issues    — 按 JQL 搜索 Issue), code:json ({), code:block7 (Skill "代码审查" 内部编排逻辑：), code:typescript (// custom-mcp-server/src/index.ts) (+21 more)

### Community 8 - "Community 8"
Cohesion: 0.07
Nodes (29): Agents 代理系统, code:block1 (Main Agent（主代理 - 你在对话中交互的对象）), code:bash ("为'多人实时协作编辑文档'功能设计技术方案。), code:block11 (并行设计阶段：), code:mermaid (sequenceDiagram), code:block3 (串行执行（依赖关系）：), code:block4 (项目根目录/), code:bash ("全面审查我当前的变更，用三个并行的子代理：) (+21 more)

### Community 9 - "Community 9"
Cohesion: 0.07
Nodes (28): active, blockedOn, completed, currentStage, currentStageKey, languageResolution, language, source (+20 more)

### Community 10 - "Community 10"
Cohesion: 0.07
Nodes (28): active, blockedOn, completed, currentStage, currentStageKey, languageResolution, language, source (+20 more)

### Community 11 - "Community 11"
Cohesion: 0.07
Nodes (27): code:mermaid (sequenceDiagram), code:markdown (# Plan: 缓存策略选型与实现), code:markdown (# Plan: <功能名称>), code:block3 (项目根目录/), code:block4 (.claude/), code:bash ("为电商平台设计优惠券系统。包括：优惠券类型（满减/折扣）、), code:markdown (# Plan: 优惠券系统), code:bash ("当前 services/ 目录过于庞大（50+ 文件）。我想将核心业务逻辑) (+19 more)

### Community 12 - "Community 12"
Cohesion: 0.07
Nodes (26): code:mermaid (sequenceDiagram), code:block2 (.claude/skills/my-skill/), code:block3 (项目根目录/), code:markdown (# API Generator Skill), code:block5 (4. **Response Format**:), code:block6 (5. Always include: input validation, error handling, TypeScr), code:bash ("create API endpoint for user registration with email/passwo), code:bash (# 首先安装需要的 Skills（一次性）) (+18 more)

### Community 13 - "Community 13"
Cohesion: 0.08
Nodes (25): completedAt, status, completedAt, status, completedAt, status, completedAt, status (+17 more)

### Community 14 - "Community 14"
Cohesion: 0.09
Nodes (21): Claude Code 入门概览, code:mermaid (graph TD), code:block2 (项目根目录/), code:bash (# 在终端中进入空目录，然后对 Claude Code 说：), code:bash (# 在项目根目录下：), code:bash ("为这个 monorepo 搭建 GitHub Actions CI：), 💡 为什么重要, 🔗 关联概念 (+13 more)

### Community 15 - "Community 15"
Cohesion: 0.12
Nodes (16): code:bash ("将项目从 moment.js 迁移到 date-fns：), code:block11 (Grep("moment")                    → 发现 34 个文件), code:bash ("审计所有子项目的依赖：), code:block13 (Glob("**/package.json")                    → 发现 5 个 package.), code:markdown (# 依赖健康报告 - 2026-06-19), code:bash ("为 user 表添加 avatar_url (TEXT) 和 bio (TEXT) 字段：), code:block16 (Read(prisma/schema.prisma)                 → 理解当前 Schema), code:typescript (// mcp-servers/internal-tools/src/index.ts) (+8 more)

### Community 16 - "Community 16"
Cohesion: 0.29
Nodes (6): created_at, project, project_dir, sessions, updated_at, version

### Community 17 - "Community 17"
Cohesion: 0.33
Nodes (5): mode, scriptMtimeMs, startedAt, status, updatedAt

## Knowledge Gaps
- **327 isolated node(s):** `PreToolUse`, `version`, `created_at`, `updated_at`, `sessions` (+322 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **4 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `stages` connect `Community 13` to `Community 2`?**
  _High betweenness centrality (0.009) - this node is a cross-community bridge._
- **Why does `Tools 工具系统` connect `Community 7` to `Community 15`?**
  _High betweenness centrality (0.007) - this node is a cross-community bridge._
- **Why does `🎯 实战示例` connect `Community 15` to `Community 7`?**
  _High betweenness centrality (0.005) - this node is a cross-community bridge._
- **What connects `PreToolUse`, `version`, `created_at` to the rest of the system?**
  _327 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.06 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.06 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.06 - nodes in this community are weakly interconnected._