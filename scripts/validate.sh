#!/bin/bash
# =============================================================================
# ai-study Content Validator
#
# 在 deploy.sh 的 Step 1（内容同步）之后、Step 2（Quartz 构建）之前运行。
# 检查 4 个维度：Mermaid 渲染风险、Frontmatter 完整性、死链、必需章节。
# 校验失败 → 非零退出码 + findings 摘要 → deploy.sh 中止。
# =============================================================================
set -euo pipefail

VAULT_ROOT="${VAULT_ROOT:-/Users/delphi/work/ai-study}"
CHECK_DIRS=("$VAULT_ROOT/Claude Code" "$VAULT_ROOT/Meta_Kim")
TEMPLATE="$VAULT_ROOT/模板/专题文章模板.md"

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

FINDINGS=0
FILES_CHECKED=0

# ── Helper ──────────────────────────────────────────────────
finding() {
  local severity="$1" file="$2" line="$3" msg="$4"
  echo -e "  ${RED}[${severity}]${NC} ${file}:${line} — ${msg}"
  ((FINDINGS++))
}

# ── Dimension 1: Mermaid block integrity ────────────────────
check_mermaid() {
  local file="$1"
  local in_mermaid=0 mermaid_line=0

  # Check open/close balance
  local opens=$(grep -c '```mermaid' "$file" 2>/dev/null || echo 0)
  local closes=$(grep -c '^```$' "$file" 2>/dev/null || echo 0)

  # Count total fenced blocks (open + close) to verify pairing
  local all_opens=$(grep -c '```' "$file" 2>/dev/null || echo 0)
  if (( all_opens % 2 != 0 )); then
    finding "CRITICAL" "$(basename "$file")" "?" "fenced block 开关数量不匹配（奇数个 \`\`\`）"
  fi

  # Check for numbered nodes inside mermaid blocks
  while IFS= read -r line; do
    local lineno="${line%%:*}"
    local content="${line#*:}"

    if [[ "$content" == *'```mermaid'* ]]; then
      in_mermaid=1
      mermaid_line=$lineno
    elif [[ "$in_mermaid" -eq 1 && "$content" == '```' ]]; then
      in_mermaid=0
    elif [[ "$in_mermaid" -eq 1 ]]; then
      # Check for "1. " "2. " patterns inside mermaid node labels
      # macOS grep: use awk for Perl-like regex
      if echo "$content" | awk '/["\[][0-9]+\. /' | grep -q .; then
        finding "CRITICAL" "$(basename "$file")" "$lineno" "mermaid 节点含数字编号（Markdown 可能误解析为有序列表）"
      fi
    fi
  done < <(grep -n '' "$file")
}

# ── Dimension 2: Frontmatter completeness ──────────────────
check_frontmatter() {
  local file="$1"
  local in_fm=0 fm_end=0

  # Check frontmatter exists
  head -1 "$file" | grep -q '^---$' || {
    finding "HIGH" "$(basename "$file")" "1" "缺少 frontmatter 起始 ---"
    return
  }

  # Count frontmatter delimiters
  local fm_count=$(grep -c '^---$' "$file" 2>/dev/null || echo 0)
  if (( fm_count < 2 )); then
    finding "HIGH" "$(basename "$file")" "1" "frontmatter 未闭合（缺第二个 ---）"
    return
  fi

  # Extract frontmatter section (macOS sed compatible)
  local fm_text=$(sed -n '/^---$/,/^---$/p' "$file" | sed '$d' | sed '1d')

  # Required fields
  for field in "tags:" "创建时间:" "专题:" "序号:"; do
    echo "$fm_text" | grep -q "$field" || {
      finding "MEDIUM" "$(basename "$file")" "2" "frontmatter 缺字段: $field"
    }
  done
}

# ── Dimension 3: Dead links ─────────────────────────────────
check_dead_links() {
  local file="$1"
  local in_code=0

  while IFS= read -r line; do
    # Track fenced code block state
    if [[ "$line" == '```'* ]]; then
      ((in_code ^= 1))
      continue
    fi
    [[ "$in_code" -eq 1 ]] && continue

    # Skip inline code (backtick-wrapped) — links there are examples, not navigable
    local visible_text=$(echo "$line" | sed 's/`[^`]*`//g')

    # Extract [[...]] links from this line
    local raw_links=$(echo "$visible_text" | grep -o '\[\[[^]]*\]\]' 2>/dev/null | sed 's/^\[\[//;s/\]\]$//' || true)

    while IFS= read -r link; do
      [[ -z "$link" ]] && continue
      local target="${link%%|*}"

      # Skip absolute URLs
      [[ "$target" == http* ]] && continue
      [[ "$target" == "Claude Code/"* ]] && continue
      [[ "$target" == "Meta_Kim/"* ]] && continue
      [[ "$target" == "00-总览/"* ]] && continue
      [[ "$target" == "模板/"* ]] && continue

      # Convert to expected .md filename
      local target_fn="${target}.md"
      local found=""
      found=$(find "$VAULT_ROOT" -name "$(basename "$target_fn")" 2>/dev/null | head -1)

      if [[ -z "$found" ]]; then
        if [[ ! -f "$VAULT_ROOT/$target_fn" ]]; then
          finding "HIGH" "$(basename "$file")" "?" "死链: [[${target}]]"
        fi
      fi
    done <<< "$raw_links"
  done < "$file"
}

# ── Dimension 4: Required template sections ─────────────────
check_sections() {
  local file="$1"
  local required=("## ✅" "## ⚠️")

  # Only check articles (00-07.md pattern), skip index files
  [[ "$(basename "$file")" =~ ^[0-9]+-.*\.md$ ]] || return

  for section in "${required[@]}"; do
    grep -q "$section" "$file" || {
      finding "MEDIUM" "$(basename "$file")" "—" "缺模板章节: $section"
    }
  done
}

# ── Main ────────────────────────────────────────────────────
echo -e "${GREEN}[validate]${NC} 开始内容质量校验..."
echo ""

for dir in "${CHECK_DIRS[@]}"; do
  [[ -d "$dir" ]] || continue

  for file in "$dir"/*.md; do
    [[ -f "$file" ]] || continue
    # Skip AGENTS.md / CLAUDE.md
    [[ "$(basename "$file")" == "AGENTS.md" ]] && continue
    [[ "$(basename "$file")" == "CLAUDE.md" ]] && continue

    ((FILES_CHECKED++))

    check_mermaid "$file"
    check_frontmatter "$file"
    check_dead_links "$file"
    check_sections "$file"
  done
done

echo ""
echo "──────────────────────────────────────────"
echo -e " 校验文件: ${FILES_CHECKED} 篇"
echo -e " 发现问题: ${FINDINGS} 个"
echo "──────────────────────────────────────────"

if (( FINDINGS > 0 )); then
  echo ""
  echo -e "${RED}❌ 校验未通过 — 请修复以上问题后重新部署${NC}"
  exit 1
else
  echo -e "${GREEN}✅ 校验通过${NC}"
  exit 0
fi
