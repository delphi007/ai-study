---
tags: [claude-code, commands, 命令, 斜杠命令]
创建时间: 2026-06-19
专题: Claude Code 基本使用
序号: 09
---

# Slash Commands 斜杠命令系统

## 📖 概念

> Slash Commands（斜杠命令）是 Claude Code 的**快捷指令系统**。以 `/` 开头输入的命令会触发预定义的操作——从代码审查（`/review`）到会话压缩（`/compact`）到项目初始化（`/init`）。Slash Commands 是"高频操作的快捷键"——不需要用自然语言描述，一个 `/` 加几个字母就能触发复杂的预定义工作流。

Slash Commands 不是自然语言对话的替代，而是**高频操作的加速器**。你可以想象它像 Photoshop 的快捷键——熟练用户用 `Ctrl+Z` 撤销而不是去菜单找，同样，熟练的 Claude Code 用户用 `/review` 审查代码而不是说"帮我审查当前的变更"。

### 命令的类别

| 类别 | 命令 | 说明 |
|------|------|------|
| **代码审查** | `/review`, `/code-review`, `/security-review`, `/simplify` | 审查和优化代码 |
| **会话管理** | `/goal`, `/compact`, `/clear`, `/context` | 管理会话目标、上下文和状态 |
| **项目管理** | `/init`, `/memory`, `/tasks`, `/loop`, `/save-progress` | 管理项目配置、记忆和进度 |
| **配置** | `/config`, `/keybindings`, `/permissions`, `/hooks` | 配置 Claude Code |
| **执行** | `/run`, `/verify`, `/test`, `/workflows` | 运行和验证 |
| **信息** | `/help`, `/status`, `/doctor`, `/version` | 查看信息和诊断 |
| **自定义** | `.claude/commands/<name>.md` | 用户自定义命令 |

## 🔧 工作原理

> Slash Commands 通过**命令注册表 + 参数解析 + 上下文注入**三层机制工作。内置命令编译在 CLI 中；自定义命令从 `.claude/commands/` 或 `~/.claude/commands/` 加载。

### 命令执行流程

```mermaid
sequenceDiagram
    participant User as 用户输入 "/review"
    participant CLI as CLI 入口
    participant Registry as 命令注册表
    participant Command as 匹配的命令
    participant Session as 当前会话
    
    User->>CLI: /review
    CLI->>Registry: 解析 "/review"
    Registry-->>CLI: 返回命令定义 + 参数模板
    CLI->>Command: 加载命令逻辑
    Command-->>CLI: 生成执行提示词
    CLI->>Session: 注入提示词作为新对话轮次
    Session-->>User: 执行命令结果
```

### 命令解析规则

```
输入：/review --comment --fix
  │         │        │
  │         │        └── 标志：同时应用修复
  │         └── 标志：发布为 PR 评论
  └── 命令名：review

输入：/loop 5m /verify
  │       │    │
  │       │    └── 参数：要循环的命令
  │       └── 参数：间隔 5 分钟
  └── 命令名：loop
```

### 自定义命令定义

自定义命令是一个 Markdown 文件，内容是在触发时注入给 AI 的提示词：

```markdown
# .claude/commands/deploy.md

## Description
部署当前分支到 Staging 环境。
触发词：/deploy

## Instructions
当用户使用 /deploy 命令时，执行以下部署流程：

1. 检查当前分支是否干净（git status）
2. 运行完整测试套件（npm test）
3. 构建生产版本（npm run build）
4. 如果全部通过，触发 Staging 部署
5. 输出部署结果和访问 URL

## 参数
- --force：跳过测试直接部署（危险，需二次确认）
- --dry-run：预览部署计划但不执行
```

## 📂 目录树位置

> 内置命令编译在 CLI 内（无文件）。自定义命令存储为 Markdown 文件。

```
项目根目录/
└── .claude/
    └── commands/                   ← 项目自定义命令
        ├── deploy.md               ←   /deploy 命令
        ├── review-all.md           ←   /review-all 命令
        └── new-feature.md          ←   /new-feature 命令

用户全局目录 (~/.claude/)：
~/.claude/
└── commands/                       ← 全局自定义命令（所有项目可用）
    ├── daily-standup.md             ←   /daily-standup 命令
    └── format-all.md                ←   /format-all 命令
```

| 文件/位置 | 作用 | 触发方式 |
|----------|------|---------|
| 内置命令 | CLI 编译的功能（60+ 个） | `/命令名` |
| `.claude/commands/<name>.md` | 项目自定义命令（团队共享） | `/<name>` |
| `~/.claude/commands/<name>.md` | 全局自定义命令（个人） | `/<name>` |

**命令优先级**：项目自定义 > 全局自定义 > 内置命令。同名命令按此顺序覆盖。

**与 Skills、Hooks、Workflows 的目录关系**：
```
.claude/
├── commands/                ← 自定义命令（手动 / 触发）
├── skills/                  ← 自定义技能（自然语言触发）
├── hooks/                   ← Hook 脚本（事件自动触发）
└── workflows/               ← Workflow 脚本（Workflow() 工具触发）
```

触发机制对比：
- Commands：用户显式输入 `/命令名`
- Skills：用户自然语言匹配触发词
- Hooks：生命周期事件自动触发
- Workflows：通过 `Workflow()` 工具在对话中调用

## 💡 为什么重要

- **效率提升**：`/review` 比"帮我审查当前代码变更"快 10 倍输入
- **标准化操作**：团队用统一的 `/deploy` 而不是各自描述部署流程
- **可组合**：`/loop 5m /verify` 组合命令创造新行为
- **学习曲线平滑**：新成员用 `/help` 发现所有可用命令

## 🎯 实战示例

### 示例 1：用自定义命令标准化团队工作流

**场景**：团队有固定的功能开发流程——从分支创建到 PR 创建的标准化步骤。你希望一条命令自动执行整个流程。

**操作步骤**：

创建 `.claude/commands/new-feature.md`：

```markdown
# /new-feature

## Description
创建新功能分支并完成初始设置。
触发：/new-feature --feature <功能名> [--from <基线分支>]

## Instructions
当用户触发 /new-feature 时，执行：

1. **拉取最新代码**：
   ```bash
   git fetch origin
   git checkout <基线分支或main>
   git pull origin <基线分支>
   ```

2. **创建功能分支**：
   ```bash
   git checkout -b feature/<功能名>
   ```

3. **生成任务计划**：
   在 `docs/features/<功能名>/` 下创建：
   - `task_plan.md` — 分解为文件级别的实现任务
   - `findings.md` — 记录实现过程中的发现和决策

4. **更新 CLAUDE.md**：
   在 CLAUDE.md 中添加此功能的关键上下文（模块名、关键文件、约束）。

5. **输出摘要**：
   - 分支名：feature/<功能名>
   - 基线提交：<commit hash>
   - 任务计划路径：docs/features/<功能名>/task_plan.md
   - 下一步：开始实现第一个任务
```

**使用**：

```bash
/new-feature --feature user-avatar-upload
```

**结果**：

```
✅ feature/user-avatar-upload 分支已从 main (a3f2c1e) 创建
📋 任务计划：docs/features/user-avatar-upload/task_plan.md
   - 5 个子任务已分解
📝 CLAUDE.md 已更新，添加本功能的上下文
💡 下一步：开始实现 Task 1 — 创建文件上传组件
```

**原理分析**：自定义命令将团队**隐性流程**（"创建功能分支后要写 task_plan、更新 CLAUDE.md"）转化为**显式脚本**。新成员用 `/new-feature` 时自动遵循流程，不会遗漏步骤。这是"团队标准化"的典型应用。

### 示例 2：组合命令实现持续验证循环

**场景**：你正在进行大规模重构，希望在开发过程中持续自动验证，一旦测试失败立即知道。

**操作步骤**：

```bash
/loop 2m /verify
```

**结果**：Claude Code 每 2 分钟自动运行一次验证（检查 lint、类型、测试），结果呈现在对话中。

```bash
# 等价于手动执行：
while true; do
  sleep 120
  # 触发 /verify：运行类型检查 + lint + 相关测试
done
```

**组合变体**：

```bash
# 每次代码变更后自动审查
/loop 5m /code-review --effort low

# 每 30 分钟检查一次依赖安全
/loop 30m "检查所有依赖的安全漏洞"

# 监控 CI 状态
/loop 3m "检查当前分支的最新 CI 运行状态"
```

**原理分析**：`/loop` 是元命令——它接收另一个命令作为参数并周期性执行。这种**命令组合**能力让简单命令产生复杂行为：`/loop` + `/verify` = 持续集成代理，`/loop` + `/code-review` = 持续代码审查。不需要 Workflow 脚本就能实现持续监控。

### 示例 3：用命令管理项目知识——多命令协作

**场景**：项目初期，你希望快速初始化项目结构、配置 Claude Code、建立知识基线。三条命令接力完成。

**操作步骤**：

```bash
# 第一步：初始化项目 Claude Code 配置
/init
# → 分析项目结构，自动生成 CLAUDE.md

# 第二步：记录关键决策
/memory "记录项目技术选型：
- 前端：React 18 + TypeScript + Vite + Tailwind CSS
- 后端：Node.js + Express + Prisma + PostgreSQL
- 测试：Vitest（前端）+ Jest（后端）
- CI/CD：GitHub Actions，部署到 Vercel（前端）+ Railway（后端）
- 禁止使用 any 类型，禁止硬编码配置值"

# 第三步：保存初始进度
/save-progress
# → 写入 .claude/project-task-state.json

# 第四步：查看当前状态
/status
# → 显示：项目、会话、Memory、配置摘要
```

**结果**：四条命令接力，5 分钟内完成项目知识初始化。后续所有协作中，AI 自动理解项目技术栈、遵循约定、记住上下文。

**原理分析**：`/init`、`/memory`、`/save-progress`、`/status` 构成项目知识管理的命令链。每条命令专注一件事，组合使用时产生系统性效果。这是 Slash Commands 的最佳实践——不是一条命令包揽一切，而是小而专注的命令可组合。

---

## 🎯 /goal 命令详解

> `/goal` 是 Claude Code 的**会话目标设定命令**。它让用户在会话开始时（或任务切换时）用一句话锁定当前会话要达成的核心目标。这不是一个"执行命令"——它不触发任何代码生成或文件操作，而是向 AI 注入高优先级的意图锚点，影响整个会话的行为方向。

### 为什么需要 /goal

Claude Code 的普通对话是**逐轮反应式**的——AI 每轮根据上下文决定下一步。这在简单任务中足够，但在复杂长任务中容易**偏离方向**：AI 可能在实现细节中迷失，忘记了最初是要做什么。

`/goal` 通过在系统提示词中显式注入目标，形成**持续的意图约束**。AI 在做每一步决策时都会参照这个目标，判断"当前动作是否在朝目标前进"。

### /goal 与 普通对话、Plan Mode 的区别

| 机制 | 介入时机 | 约束强度 | 产出物 |
|------|---------|:--:|------|
| **普通对话** | 逐轮 | 弱 | 即时回复 |
| **/goal** | 会话级 | 中 | 无（意图注入） |
| **Plan Mode** | 任务级 | 强 | plan.md 文件 |
| **CLAUDE.md** | 项目级 | 强 | 持久化指令 |

### /goal 的生效机制

```
用户输入：/goal 完成优惠券服务的单元测试覆盖到 85%
         │
         ▼
    CLI 解析命令 → 生成意图注入提示词
         │
         ▼
    注入到当前会话系统提示词（高优先级）
         │
         ▼
    AI 后续每轮的决策都参照此目标
    - 偏离目标时自我纠正
    - 完成目标后主动告知用户
```

### 如何用得好

**1. 目标要具体，可验证**

```
❌ /goal 做好测试                     ← 无法验证
❌ /goal 提高代码质量                  ← 太模糊
✅ /goal 将订单模块的单元测试覆盖率从 45% 提升到 85%
✅ /goal 修复 src/api/ 下所有 TypeScript strict mode 错误
```

好的目标包含**范围**（订单模块）+ **指标**（覆盖率 45%→85%）。AI 和你在事后都能清楚判断"目标达成了没"。

**2. 聚焦单一目标**

```
❌ /goal 重构支付模块、添加日志、修复 ESLint 警告、升级依赖
   → 这不是一个目标，是四个任务的混杂。AI 会无法判断优先级。

✅ 一个会话 /goal 一个目标，完成后 /goal 切换下一个
```

**3. 含成功标准**

```
/目标                            成功标准
──────────────────────────────────────────────────
/goal 迁移所有 API 端点           → 32 个端点全部从 REST 迁到 GraphQL，旧端点移除
/goal 性能优化                   → P99 延迟从 2s 降到 500ms 以下
/goal 文档补充                   → 所有 public API 函数都有 JSDoc，覆盖率 100%
```

**4. 会话中途可以用 /goal 重新定向**

```bash
# 会话开始
/goal 完成用户注册功能

# ... 工作进行中 ...

# 发现注册功能依赖邮箱服务，切换目标
/goal 先完成邮箱验证服务的封装，验证通过后再继续注册功能
```

**5. 结合其它命令形成工作流**

```bash
/goal 将订单模块覆盖率提升到 85%
/test                         # → 先看当前覆盖率基线
/verify                       # → 运行当前测试看看哪些没覆盖
# ... 写测试代码 ...
/verify                       # → 检查覆盖率是否达标
# 达标 → /goal 完成 ✓
```

### ⚠️ 注意事项

| 注意点 | 说明 |
|--------|------|
| **不是执行命令** | `/goal` 不触发任何代码生成，它只是设定方向。设定后你仍然需要继续对话来推进工作 |
| **不替代 Plan Mode** | 复杂多步骤任务（5+ 文件变更）仍应使用 Plan Mode 生成结构化计划。`/goal` 适合中等复杂度的聚焦任务 |
| **目标丢失** | 上下文压缩（`/compact`）后目标仍在，但压缩如果裁掉了关键上下文可能影响 AI 对目标的理解。可重新 `/goal` 一次 |
| **跨会话不持久** | `/goal` 只在当前会话有效。新会话需要重新设定。持久化项目级目标应写入 `CLAUDE.md` |
| **不要过度约束** | 目标太窄可能限制 AI 的创造力。例如 `/goal 用 for 循环优化查询` 不如 `/goal 将查询延迟降到 50ms 以下`（后者允许 AI 选择更好的方案） |

### 🎯 使用案例

#### 案例 1：Bug 修复聚焦

**场景**：用户反馈登录页在 Safari 上白屏，Chrome 正常。你需要在复杂的前端项目中定位并修复这个浏览器兼容问题。

```bash
/goal 修复 Safari 浏览器上登录页白屏的兼容性 Bug，Chrome/Firefox/Safari 三端验证通过
```

**AI 收到目标后**：

1. 自动聚焦于 `login` 相关文件和 Safari 兼容性问题
2. 检查是否使用了 Safari 不支持的 CSS 属性（如 `:has()` 旧版）或 JS API
3. 不会趁机"顺便重构一下登录页的样式"（目标约束）
4. 修完后会在 Chrome/Firefox/Safari 三端验证

**为什么这个目标好**：
- 范围明确：登录页 + Safari
- 可验证：三端都通过才算完成
- 避免范围蔓延：不会趁机重构整个前端

#### 案例 2：渐进式重构

**场景**：`src/services/` 目录下有 50+ 个文件，你打算分批重构。先做第一批：把 5 个最常用的工具函数迁移到 TypeScript strict mode。

```bash
/goal 将 src/utils/ 下 5 个核心工具函数（date, string, array, object, http）
迁移为 TypeScript strict 模式，零 any，所有函数显式标注入参和返回类型
```

**AI 的工作方式**：

```bash
# 1. 先扫描现状
"列出 src/utils/ 下所有文件的 TypeScript 严格程度"

# 2. 逐个迁移
"从 date.ts 开始，改为 strict 模式，修复所有类型错误"

# 3. 每完成一个检查目标
"✅ date.ts 已迁移，0 个 any，所有类型显式标注。继续 string.ts？"

# 4. 全部完成后
"5 个文件全部迁移完成。src/utils/ 目录 strict 覆盖率：5/5 ✅"
```

**为什么这个目标好**：
- 可量化：5 个文件，完成后即达成
- 质量标准明确：零 any、显式类型
- 范围有界：只做 utils/，不动 services/

#### 案例 3：会话中途重新定向——处理意外发现

**场景**：你正在开发新功能，AI 在分析代码时发现了一个 SQL 注入漏洞。你决定暂停原任务，先修漏洞。

```bash
# 原始目标
/goal 添加批量用户导入功能（CSV 上传 + 校验 + 入库）

# AI 发现漏洞后：
"⚠️ 在 src/routes/admin/users.ts:45 发现 SQL 拼接，
用户输入直接拼入查询语句，存在注入风险。要继续原任务还是先修复？"

# 重新定向
/goal 先修复 src/routes/admin/users.ts:45 的 SQL 注入漏洞，
将其改为参数化查询，添加输入校验，写测试验证修复
```

**修复完成后**：

```bash
# 回到原目标
/goal 继续添加批量用户导入功能（CSV 上传 + 校验 + 入库）
```

**为什么这个模式好**：
- `/goal` 支持会话中途灵活切换
- 新目标同样具体可验证
- 做完后回到原目标，不会忘记之前做到哪了

#### 案例 4：与其它命令配合——目标驱动工作流

**场景**：你需要完成一个 API 端点从 JavaScript 到 TypeScript 的迁移。

```bash
# 1. 设定目标
/goal 将 GET /api/users/:id 端点从 JS 迁移到 TS strict 模式，
包含完整的请求/响应类型、Zod 校验和错误处理

# 2. 了解现状
"分析 src/routes/users.js 的当前逻辑和依赖"

# 3. 实现（AI 在目标约束下工作）
"开始迁移，先创建类型定义，再改路由"

# 4. 持续验证
/verify                     # 运行类型检查 + 相关测试

# 5. 验收
"检查这次迁移是否满足目标：strict mode、完整类型、Zod 校验、错误处理"

# AI 自我检查：
"✅ strict mode：tsconfig 覆盖，零隐式 any
 ✅ 类型定义：IUser、IUserResponse、IErrorResponse 已定义
 ✅ Zod 校验：params.id 和 响应结构已校验
 ✅ 错误处理：404/400/500 已覆盖
 🎯 /goal 完成"
```

---

## ✅ 最佳实践

1. **DO**：为团队高频操作创建自定义命令（`/deploy`、`/new-feature`、`/review-all`）
2. **DO**：自定义命令文件写清楚 Description、Instructions、参数说明
3. **DO**：使用 `/help` 发现可用命令——新版本可能添加了新命令
4. **DON'T**：把复杂的多步骤逻辑塞进一条命令——复杂编排用 Workflows
5. **DON'T**：自定义命令覆盖内置命令的同名——可能让团队成员困惑
6. **TIP**：`/loop` + 任意命令 = 持续自动化，是最高效的命令组合模式

## ⚠️ 常见陷阱

| 陷阱 | 表现 | 解决方案 |
|------|------|---------|
| 命令不存在 | 输入 `/xxx` 无反应 | `/help` 查看可用命令列表；检查自定义命令文件格式 |
| 自定义命令未生效 | `.claude/commands/deploy.md` 存在但 `/deploy` 无反应 | 检查文件位置和扩展名（必须 `.md`），重启 Claude Code |
| 命令覆盖冲突 | 项目命令和全局命令同名，行为不符合预期 | 理解优先级：项目 > 全局 > 内置 |
| `/loop` 过频 | 短间隔触发过多会话，消耗 tokens | 根据任务的实际变化速度设置间隔（CI 状态 3min，依赖检查 30min） |

## 🔗 关联概念

- [[Claude Code/07-配置与项目管理\|配置与项目管理]] — 命令存储在 `.claude/commands/` 下
- [[Claude Code/08-Workflows 工作流编排\|Workflows 工作流编排]] — 复杂编排用 Workflows，简单操作用 Commands
- [[Claude Code/01-Skills 技能系统\|Skills 技能系统]] — Commands 手动触发，Skills 自然语言触发
- [[Claude Code/05-Memory 记忆系统\|Memory 记忆系统]] — `/memory` 命令管理记忆

## 📚 扩展阅读

- 官方文档：[Claude Code Slash Commands](https://docs.anthropic.com/en/docs/claude-code/slash-commands)
- `/help` 命令：查看所有可用命令

---

> **下一步**：阅读 [[Claude Code/10-Plan Mode 规划模式\|Plan Mode 规划模式]] 了解结构化项目规划机制。
