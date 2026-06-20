#!/bin/bash
# =============================================================================
# Quartz Deploy Script — AI 学习知识库
#
# 用途：将 Obsidian Vault 构建为 Quartz 静态站并部署到 GitHub Pages
# 使用：bash deploy.sh
#
# 前置条件：
#   - Node.js 22+
#   - gh CLI 已认证（gh auth status）
#   - Git 仓库已关联 GitHub（origin: delphi007/ai-study）
# =============================================================================

set -euo pipefail

# ─── 配置 ────────────────────────────────────────────────
VAULT_ROOT="/Users/delphi/work/ai-study"
QUARTZ_DIR="$VAULT_ROOT/.quartz"
CONTENT_DIR="$QUARTZ_DIR/content"
PUBLIC_DIR="$VAULT_ROOT/public"
DEPLOY_TMP="/tmp/ai-study-deploy"
GITHUB_REMOTE="https://github.com/delphi007/ai-study.git"

# ─── 颜色 ────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

step() { echo -e "${GREEN}[$(date +%H:%M:%S)]${NC} $1"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
err()  { echo -e "${RED}❌ $1${NC}"; exit 1; }

# ─── Step 1: 同步 Vault 内容到 Quartz ───────────────────
step "1/5 同步 Vault 文章到 Quartz content..."

# 清除旧内容
rm -rf "$CONTENT_DIR/00-总览"    2>/dev/null
rm -rf "$CONTENT_DIR/Claude Code" 2>/dev/null
rm -rf "$CONTENT_DIR/Meta_Kim"    2>/dev/null
rm -rf "$CONTENT_DIR/模板"         2>/dev/null

# 确保必要目录存在
mkdir -p "$CONTENT_DIR/00-总览"
mkdir -p "$CONTENT_DIR/Claude Code"
mkdir -p "$CONTENT_DIR/Meta_Kim"
mkdir -p "$CONTENT_DIR/模板"

# 复制 00-总览
cp "$VAULT_ROOT/00-总览"/*.md "$CONTENT_DIR/00-总览/"

# 复制 Claude Code（排除 AGENTS.md / CLAUDE.md 等非文章）
cp "$VAULT_ROOT/Claude Code/0"*.md "$CONTENT_DIR/Claude Code/" 2>/dev/null || true
cp "$VAULT_ROOT/Claude Code/1"*.md "$CONTENT_DIR/Claude Code/" 2>/dev/null || true
rm -f "$CONTENT_DIR/Claude Code/AGENTS.md"
rm -f "$CONTENT_DIR/Claude Code/CLAUDE.md"

# 复制 Meta_Kim
cp "$VAULT_ROOT/Meta_Kim/"*.md "$CONTENT_DIR/Meta_Kim/"

# 复制模板
cp "$VAULT_ROOT/模板/"*.md "$CONTENT_DIR/模板/" 2>/dev/null || true

# 确保首页存在
if [ ! -f "$CONTENT_DIR/index.md" ]; then
  warn "index.md 不存在，使用默认首页"
  cp /dev/null "$CONTENT_DIR/index.md"  # Quartz 会生成默认内容
fi

claude_count=$(find "$CONTENT_DIR/Claude Code" -name "*.md" | wc -l | tr -d ' ')
meta_kim_count=$(find "$CONTENT_DIR/Meta_Kim" -name "*.md" | wc -l | tr -d ' ')
echo "   ✅ 已同步 Claude Code ${claude_count} 篇 + Meta_Kim ${meta_kim_count} 篇"

# ─── Step 1.5: 内容质量校验 ─────────────────────────────
step "1.5/5 内容质量校验..."

bash "$VAULT_ROOT/scripts/validate.sh" || err "内容校验失败，部署中止。请修复问题后重试。"

echo "   ✅ 校验通过"

# ─── Step 2: Quartz 构建 ────────────────────────────────
step "2/5 Quartz 构建静态站..."

cd "$QUARTZ_DIR"

if [ ! -f "node_modules/.package-lock.json" ] && [ ! -d "node_modules" ]; then
  warn "依赖未安装，正在 npm install..."
  npm install
fi

node quartz/bootstrap-cli.mjs build --output "$PUBLIC_DIR" 2>&1 | \
  grep -E "Found|Emitted|Done|Error" || true

# 验证构建产物
if [ ! -f "$PUBLIC_DIR/index.html" ]; then
  err "构建失败：public/index.html 不存在"
fi

echo "   ✅ 构建完成"

# ─── Step 3: 修复 404 路由 ───────────────────────────────
step "3/5 修复 404 页面路由..."

bash scripts/patch-404.sh "$PUBLIC_DIR" || err "404 补丁失败"

echo "   ✅ 404 路由已修复"

# ─── Step 4: 提交 Vault 源码（master 分支） ──────────────
step "4/5 提交 Vault 源码..."

cd "$VAULT_ROOT"

if git diff --quiet && git diff --cached --quiet; then
  echo "   ℹ️  无变更，跳过提交"
else
  git add -A
  git commit -q -m "chore: sync vault content $(date +%Y-%m-%d)" 2>/dev/null || true
  git push origin master 2>&1 | tail -1
  echo "   ✅ 源码已推送"
fi

# ─── Step 5: 部署到 GitHub Pages ─────────────────────────
step "5/5 部署到 GitHub Pages..."

rm -rf "$DEPLOY_TMP"
cp -r "$PUBLIC_DIR" "$DEPLOY_TMP"

cd "$DEPLOY_TMP"
touch .nojekyll
git init -q
git checkout -b gh-pages -q
git add -A
git commit -q -m "Deploy $(date +%Y-%m-%dT%H:%M:%S)" 2>/dev/null
git remote add origin "$GITHUB_REMOTE" 2>/dev/null
git push -u origin gh-pages --force 2>&1 | tail -1

rm -rf "$DEPLOY_TMP"

# ─── 完成 ────────────────────────────────────────────────
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  ✅ 部署完成！${NC}"
echo -e "${GREEN}  🌐 https://delphi007.github.io/ai-study/${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
