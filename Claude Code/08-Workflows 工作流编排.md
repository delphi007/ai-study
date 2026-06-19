---
tags: [claude-code, workflows, 工作流, 编排]
创建时间: 2026-06-19
专题: Claude Code 基本使用
序号: 08
---

# Workflows 工作流编排

## 📖 概念

> Workflows 是 Claude Code 的**多代理编排引擎**。它将多个子代理（Agent）组织为一个确定性的管道（Pipeline），通过脚本定义依赖关系、并行策略和结果合并规则。如果 Agents 是"团队成员"，Workflows 就是"项目执行计划书"——它决定了谁在什么时候做什么，以及各个结果如何汇总。

Workflows 解决的是**复杂多步骤任务的系统性执行**问题。单个 Agent 可以处理一个子任务，但当一个任务需要跨多个维度（安全审查 + 性能审查 + 架构审查）、跨多个文件、跨多个阶段（发现 → 设计 → 实现 → 验证）时，需要 Workflows 来编排整个过程。

### Workflows vs Agent vs Skills

| 机制 | 描述 | 编排粒度 | 执行模式 |
|------|------|---------|---------|
| **Skills** | 单个领域的知识 + 工具编排 | 工具级（6-10 个工具调用） | AI 自主决策 |
| **Agent** | 单个子任务的独立执行 | 文件级（1-20 个文件） | 独立上下文 |
| **Workflows** | 多 Agent 的确定性脚本编排 | 项目级（10-100+ 文件） | 脚本控制（确定性） |

## 🔧 工作原理

> Workflows 通过 JavaScript 脚本定义执行图（DAG）。脚本中声明阶段（phase）、并发（parallel）、管道（pipeline）和代理调用（agent），运行时按依赖关系调度。

### 核心调度原语

```mermaid
graph TD
    subgraph "Workflow 脚本"
        Script[export const meta = {...}]
        Script --> Phase1[phase&#40;'Discover'&#41;]
        Script --> Phase2[phase&#40;'Analyze'&#41;]
        Script --> Phase3[phase&#40;'Verify'&#41;]
    end
    
    subgraph "阶段一：Discover"
        A1[agent&#40;'find patterns'&#41;]
        A2[agent&#40;'scan deps'&#41;]
        A3[agent&#40;'list files'&#41;]
    end
    
    subgraph "阶段二：Analyze"
        B1[agent&#40;'review A'&#41;]
        B2[agent&#40;'review B'&#41;]
        B3[agent&#40;'review C'&#41;]
    end
    
    subgraph "阶段三：Verify"
        C1[agent&#40;'synthesize'&#41;]
    end
    
    Phase1 --> A1
    Phase1 --> A2
    Phase1 --> A3
    A1 --> B1
    A2 --> B2
    A3 --> B3
    B1 --> C1
    B2 --> C1
    B3 --> C1
```

### 三种调度模式

```javascript
// 模式一：parallel() — 全并发，等待所有完成
// 适用：完全独立的子任务
const results = await parallel([
  () => agent("审查前端代码"),
  () => agent("审查后端代码"),
  () => agent("审查数据库 Schema"),
]);
// 总耗时 = max(审查1, 审查2, 审查3)

// 模式二：pipeline() — 流水线，无阶段间屏障
// 适用：多阶段处理，上一阶段的结果尽早流入下一阶段
const bugs = await pipeline(
  FILES,                          // 输入：文件列表
  f => agent(`审查 ${f}`),       // 阶段1：逐个审查
  r => agent(`验证 ${r.title}`)   // 阶段2：逐个验证（不等其它文件审查完）
);
// 文件A审查完立即开始验证A，同时文件B、C还在审查中

// 模式三：串行 phase() — 显式阶段屏障
// 适用：后阶段必须完全依赖前阶段的汇总结果
phase('Discover');
const items = await agent("发现所有需要迁移的文件");
phase('Migrate');
await parallel(items.map(f => () => agent(`迁移 ${f}`)));
phase('Verify');
await agent("验证迁移完整性");
```

### Workflow 脚本结构

```javascript
// 每个 Workflow 脚本必须以 meta 导出开头
export const meta = {
  name: 'code-health-check',
  description: '全方位代码健康检查：安全 + 性能 + 架构',
  phases: [
    { title: 'Scan', detail: '并行扫描三个维度' },
    { title: 'Verify', detail: '交叉验证发现的问题' },
  ],
};

// 阶段一：并行扫描
phase('Scan');
const findings = await parallel([
  () => agent('扫描安全漏洞', {
    schema: FINDING_SCHEMA,
    label: 'security'
  }),
  () => agent('扫描性能问题', {
    schema: FINDING_SCHEMA,
    label: 'performance'
  }),
  () => agent('扫描架构问题', {
    schema: FINDING_SCHEMA,
    label: 'architecture'
  }),
]);

// 合并所有发现
const allFindings = findings.filter(Boolean).flatMap(r => r.findings);

// 阶段二：交叉验证
phase('Verify');
const verified = await parallel(
  allFindings.map(f => () =>
    agent(`验证这个发现是否真实：${f.title}`, {
      schema: VERDICT_SCHEMA,
      label: `verify:${f.file}`
    })
  )
);

return { findings: verified.filter(Boolean) };
```

## 📂 目录树位置

> Workflows 目前主要通过 `Workflow()` 工具内联脚本执行。独立的 Workflow 脚本文件存储在 `~/.claude/workflows/` 下。

```
项目根目录/
└── .claude/
    └── workflows/                  ← 项目 Workflow 脚本（计划中）
        └── <workflow-name>.js      ← 单个 Workflow 定义

用户全局目录 (~/.claude/)：
~/.claude/
└── workflows/                      ← 全局 Workflow 脚本（所有项目可用）
    └── <workflow-name>.js
```

| 文件/位置 | 作用 | 调用方式 |
|----------|------|---------|
| `~/.claude/workflows/<name>.js` | 全局可复用的 Workflow | `Workflow({scriptPath: "~/.claude/workflows/<name>.js"})` |
| 内联脚本 | 单次 Workflow（不持久化） | `Workflow({script: "..."})` |
| `Workflow()` 工具 | 调度器入口 | 主代理通过 Workflow 工具调用 |

**与 Agents 的目录关系**：
```
.claude/
├── agents/                  ← Agent 定义（Markdown）
│   └── <agent>.md           ←   单个代理的身份和指令
└── workflows/               ← Workflow 脚本（JavaScript）
    └── <workflow>.js        ←   编排多个 Agent 的执行图
```

## 💡 为什么重要

- **确定性执行**：Workflows 是脚本控制，非 AI 自主规划，执行路径可预测
- **规模处理**：单个 Workflow 可协调 100+ 个 Agent，处理远超单次对话容量的任务
- **质量保证**：内置模式（adversarial verify、loop-until-dry）确保输出质量
- **可复用性**：Workflow 脚本一次编写、存储、跨项目复用

## 🎯 实战示例

### 示例 1：全代码库质量审计

**场景**：你接手了一个遗留项目（200+ 文件），想做一次全面的代码审计：安全漏洞、性能瓶颈、架构异味、测试覆盖缺口。手动不可能完成，单个 Agent 的上下文也装不下全量分析。

**操作步骤**：

```bash
"用 Workflow 对当前代码库做全方位质量审计：
1. 并行启动 4 个维度扫描器
2. 每个发现用 3 个不同视角的验证器交叉验证
3. 汇总存活发现，按严重度排序输出审计报告"
```

**Workflow 脚本**：

```javascript
export const meta = {
  name: 'full-code-audit',
  description: '全方位代码审计：安全 + 性能 + 架构 + 测试',
  phases: [
    { title: 'Scan', detail: '四维度并行扫描' },
    { title: 'Verify', detail: '三维度交叉验证' },
    { title: 'Report', detail: '汇总并生成审计报告' },
  ],
};

// 阶段一：四维度并行扫描
phase('Scan');
const scanResults = await parallel([
  () => agent(
    '全面扫描安全问题：SQL注入、XSS、CSRF、硬编码密钥、不安全依赖',
    { label: 'security-scan', schema: { type: 'object', properties: { findings: { type: 'array' } } } }
  ),
  () => agent(
    '全面扫描性能问题：N+1查询、不必要的重渲染、大文件、缺失缓存、同步阻塞',
    { label: 'perf-scan', schema: { type: 'object', properties: { findings: { type: 'array' } } } }
  ),
  () => agent(
    '全面扫描架构问题：循环依赖、层级泄漏、接口不一致、过度耦合、God Class',
    { label: 'arch-scan', schema: { type: 'object', properties: { findings: { type: 'array' } } } }
  ),
  () => agent(
    '全面扫描测试缺口：未覆盖的关键路径、缺失边界测试、flaky test、零断言的测试',
    { label: 'test-scan', schema: { type: 'object', properties: { findings: { type: 'array' } } } }
  ),
]);

const allFindings = scanResults
  .filter(Boolean)
  .flatMap(r => r.findings)
  .map(f => ({ ...f, id: `${f.file}:${f.line}:${f.title}` }));

// 去重
const seen = new Set();
const unique = allFindings.filter(f => {
  const k = f.id;
  if (seen.has(k)) return false;
  seen.add(k);
  return true;
});

// 阶段二：三维度交叉验证（每个发现 3 票）
phase('Verify');
const verified = await pipeline(
  unique,
  f => parallel([
    () => agent(`从正确性角度验证：${f.title}（文件：${f.file}:${f.line}）。这是真实问题还是误报？`,
      { label: `verify-correctness:${f.file}`, schema: VERDICT_SCHEMA }),
    () => agent(`从安全影响角度验证：${f.title}。如果是真实问题，利用难度和危害多大？`,
      { label: `verify-security:${f.file}`, schema: VERDICT_SCHEMA }),
    () => agent(`从修复成本角度评估：${f.title}。修复需要改多少文件？有多大风险？`,
      { label: `verify-cost:${f.file}`, schema: VERDICT_SCHEMA }),
  ]).then(votes => ({ ...f, votes }))
);

// 只保留多数票确认的发现
const confirmed = verified
  .filter(Boolean)
  .filter(f => f.votes.filter(v => v?.isReal).length >= 2);

// 阶段三：生成报告
phase('Report');
const report = confirmed
  .sort((a, b) => {
    const sev = { CRITICAL: 4, HIGH: 3, MEDIUM: 2, LOW: 1 };
    return (sev[b.severity] || 0) - (sev[a.severity] || 0);
  });

return { total: report.length, report };
```

**结果**：

```markdown
# 代码审计报告

## 总览
- 扫描: 247 个文件
- 发现: 83 个初步问题
- 确认: 31 个真实问题（去重 + 交叉验证后）
  - 🔴 CRITICAL: 2
  - 🟠 HIGH: 11
  - 🟡 MEDIUM: 14
  - 🟢 LOW: 4
```

**原理分析**：4 个扫描 Agent 并行运行（总耗时 ≈ 最慢的一个），然后每个发现被 3 个不同视角的验证 Agent 交叉检查（adversarial verify 模式），只有 ≥2/3 票的发现才进入最终报告。这比单个 Agent 的全量分析可靠得多——误报率从约 40% 降到 <10%。

### 示例 2：大规模依赖升级——分治 + 汇总

**场景**：Monorepo 有 12 个子包，需要对所有包升级 TypeScript 5.0 → 5.8，逐个包适配 breaking changes，最后验证整体一致性。

**操作步骤**：

```bash
"用 Workflow 分批升级所有子包的 TypeScript 版本：
先扫描所有包的现状，然后并行升级，最后一致性验证"
```

**Workflow 脚本**：

```javascript
export const meta = {
  name: 'ts-upgrade',
  description: 'Monorepo TypeScript 批量升级',
  phases: [
    { title: 'Discover', detail: '扫描所有子包' },
    { title: 'Upgrade', detail: '并行升级各子包' },
    { title: 'Verify', detail: '一致性验证和修复' },
  ],
};

// 阶段一：发现
phase('Discover');
const packages = await agent(
  '列出 packages/ 下所有子包，以及每个包的 tsconfig.json 和 TypeScript 相关配置',
  { schema: { type: 'object', properties: { packages: { type: 'array', items: { type: 'object', properties: { name: { type: 'string' }, path: { type: 'string' }, hasTsConfig: { type: 'boolean' } } } } } } }
);
log(`发现 ${packages.packages.length} 个子包`);

// 阶段二：并行升级（分 2 波，每波 6 个，避免资源争抢）
phase('Upgrade');
const BATCH_SIZE = 6;
const results = [];
for (let i = 0; i < packages.packages.length; i += BATCH_SIZE) {
  const batch = packages.packages.slice(i, i + BATCH_SIZE);
  const batchResults = await parallel(
    batch.map(pkg => () => agent(
      `升级 ${pkg.name}（${pkg.path}）的 TypeScript 从 5.0 到 5.8：
      1. 更新 package.json 中的 typescript 版本
      2. 运行 tsc --noEmit 查看错误
      3. 逐个修复 breaking changes
      4. 确保编译通过`,
      { label: `upgrade:${pkg.name}`, isolation: 'worktree' }
    ))
  );
  results.push(...batchResults);
  log(`完成第 ${Math.floor(i / BATCH_SIZE) + 1} 波（${batch.length} 个包）`);
}

// 阶段三：验证
phase('Verify');
await agent(
  '运行全量测试，检查所有子包的交叉依赖是否正确，
   确认没有版本冲突，生成 CHANGELOG 条目',
  { label: 'verify-all' }
);

return { upgraded: packages.packages.length, status: 'done' };
```

**结果**：12 个子包分 2 波并行升级，每个子包在自己的 worktree 中独立处理。总耗时约为主串行的 1/6。最后的验证 Agent 确保跨包依赖一致。

**原理分析**：`isolation: 'worktree'` 让每个子包升级在独立的工作副本中进行，互不干扰。分波机制（BATCH_SIZE=6）控制并发度，避免 12 个 Agent 同时写文件造成资源争抢。这体现了 Workflows 的**资源管理**能力——不只是"全部并行"，而是根据实际情况控制调度粒度。

### 示例 3：方案选型 PK —— 多路线并行设计 + 裁判评分

**场景**：需要为一个即时通讯功能选择技术方案。候选方案：WebSocket 直连、Socket.IO、SSE + HTTP/2。你希望每条路线有独立的 Agent 设计方案，再由独立的裁判 Agent 统一维度打分。

**操作步骤**：

```bash
"用 Workflow 做技术选型 PK：三条路线并行设计，独立裁判评分，输出对比报告"
```

**Workflow 脚本**：

```javascript
export const meta = {
  name: 'tech-selection-pk',
  description: '技术选型：多路线并行设计 + 独立评分',
  phases: [
    { title: 'Design', detail: '三条路线并行设计' },
    { title: 'Judge', detail: '独立裁判五维度评分' },
    { title: 'Synthesize', detail: '综合推荐' },
  ],
};

const REQUIREMENT = `
为即时通讯功能设计技术方案：
- 需求：实时消息、在线状态、消息已读、历史消息
- 环境：React 前端 + Node.js 后端
- 指标：延迟 < 100ms、支持 10k 并发、实现周期 < 4 周
`;

const ROUTES = [
  { key: 'ws', name: 'WebSocket 直连', prompt: `设计基于原生 WebSocket (ws 库) 的方案` },
  { key: 'sio', name: 'Socket.IO', prompt: `设计基于 Socket.IO 的方案` },
  { key: 'sse', name: 'SSE + HTTP/2', prompt: `设计基于 Server-Sent Events + HTTP/2 Push 的方案` },
];

// 阶段一：三条路线并行设计
phase('Design');
const designs = await parallel(
  ROUTES.map(route => () => agent(
    `${REQUIREMENT}\n\n${route.prompt}\n\n输出：架构图描述、数据结构、通信流程、实现步骤、优缺点`,
    { label: `design:${route.key}`, schema: DESIGN_SCHEMA }
  ))
);

// 阶段二：独立裁判评分
phase('Judge');
const DIMENSIONS = ['实现复杂度', '性能', '可维护性', '生态成熟度', '扩展性'];
const scored = await parallel(
  designs.filter(Boolean).map((design, i) => () =>
    agent(
      `从以下 5 个维度对方案 "${ROUTES[i].name}" 评分（每维 1-5 分）：
      ${DIMENSIONS.join('、')}
      
      方案内容：${JSON.stringify(design)}
      
      给出每维得分和一句话理由`,
      { label: `judge:${ROUTES[i].key}`, schema: SCORE_SCHEMA }
    )
  )
);

// 阶段三：综合推荐
phase('Synthesize');
const recommendation = await agent(
  `以下是三条技术路线及其评分：
  ${scored.filter(Boolean).map((s, i) => `${ROUTES[i].name}: ${JSON.stringify(s)}`).join('\n')}
  
  请给出：推荐方案、推荐理由、主要风险、如果推荐方案失败的最佳备选`,
  { label: 'synthesize' }
);

return { designs, scores: scored, recommendation };
```

**结果**：三条路线并行设计，总设计时间 = 最慢的一个（约 60s）。独立裁判给每维打分，综合推荐清晰有据。

```
┌────────────────────┬──────┬──────┬──────┬──────┬──────┬─────┐
│ 方案               │ 复杂度│ 性能 │ 可维护│ 生态 │ 扩展 │ 总分│
├────────────────────┼──────┼──────┼──────┼──────┼──────┼─────┤
│ WebSocket 直连     │  3   │  5   │  3   │  4   │  4   │ 19  │
│ Socket.IO          │  4   │  4   │  4   │  5   │  4   │ 21  │
│ SSE + HTTP/2       │  3   │  3   │  4   │  3   │  3   │ 16  │
└────────────────────┴──────┴──────┴──────┴──────┴──────┴─────┘

推荐：Socket.IO（成熟度高、团队学习成本低、社区支持好）
备选：WebSocket 直连（性能最优，如果 Socket.IO 遇到性能瓶颈）
```

**原理分析**：这展示了 Workflows 在**项目管理决策**中的价值——"设计方案"和"评分"分离。设计者不被评分标准影响（聚焦方案设计），裁判不被设计过程影响（只看最终方案）。这种"分离关注点"的编排模式只有 Workflows 能做到，单个 Agent 的串行对话无法实现这种独立性。

## ✅ 最佳实践

1. **DO**：先用单个 Agent 探索问题空间，确认 Workflow 确实需要后再编排
2. **DO**：使用 `schema` 约束 Agent 的返回格式——Workflow 脚本是 JS，需要可预测的数据结构
3. **DO**：大型 Workflow 分阶段执行，每个阶段完成后检查中间结果再继续
4. **DON'T**：为简单任务创建 Workflow（<3 个 Agent 或 <5 个文件）——单个 Agent 更高效
5. **DON'T**：忽略 `isolation: 'worktree'`——并行文件修改任务必须使用隔离，否则 Agent 互相覆盖
6. **TIP**：`budget.remaining()` 控制 Agent 数量——根据用户设定的 token 预算动态调整并行度

## ⚠️ 常见陷阱

| 陷阱 | 表现 | 解决方案 |
|------|------|---------|
| 过度并行 | 简单任务也用 Workflow，开销大于收益 | 评估：<3 个独立维度或 <10 个文件用单 Agent |
| Schema 不兼容 | Agent 返回格式与下一个阶段期望不匹配 | 使用 `schema` 参数强制验证返回格式 |
| 资源耗尽 | 100 个 Agent 同时运行导致系统卡死 | 分波执行，用 `BATCH_SIZE` 控制并发度 |
| 汇总丢失 | 大量 Agent 结果被稀疏呈现 | 最后阶段专用一个 Agent 汇总和结构化输出 |

## 🔗 关联概念

- [[Claude Code/04-Agents 代理系统\|Agents 代理系统]] — Workflows 是 Agent 的编排层
- [[Claude Code/01-Skills 技能系统\|Skills 技能系统]] — Workflows + Skills：给 Workflow 中的 Agent 装备专业技能
- [[Claude Code/10-Plan Mode 规划模式\|Plan Mode 规划模式]] — Plan Mode 做方案设计，Workflows 做方案执行

## 📚 扩展阅读

- 官方文档：[Claude Code Workflows](https://docs.anthropic.com/en/docs/claude-code/workflows)
- Agent Teams Playbook：`agent-teams-playbook` Skill

---

> **下一步**：阅读 [[Claude Code/09-Slash Commands 斜杠命令\|Slash Commands 斜杠命令]] 了解内置的快捷命令系统。
