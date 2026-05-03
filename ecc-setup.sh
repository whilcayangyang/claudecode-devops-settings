#!/usr/bin/env bash
# =============================================================================
# ecc-setup.sh — Everything Claude Code setup for IaC/DevOps
# Usage: ./ecc-setup.sh [--install | --uninstall | --mcp | --link-settings | --help]
# =============================================================================

set -euo pipefail

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ── Config ────────────────────────────────────────────────────────────────────
ECC_REPO="https://github.com/affaan-m/everything-claude-code.git"
ECC_PLUGIN_ID="everything-claude-code@everything-claude-code"
ECC_CLONE_DIR="${HOME}/everything-claude-code"
CLAUDE_DIR="${HOME}/.claude"
ECC_RULES_DIR="${CLAUDE_DIR}/rules/ecc"
ECC_SKILLS_DIR="${CLAUDE_DIR}/skills/ecc"
AGENTS_DIR="${CLAUDE_DIR}/agents"

INFRA_SKILLS=(
  deployment-patterns
  docker-patterns
  backend-patterns
  python-patterns
  python-testing
  api-design
  database-migrations
  security-review
  verification-loop
  tdd-workflow
  search-first
  mcp-server-patterns
  autonomous-loops
)

INFRA_AGENTS=(
  python-reviewer
  security-reviewer
  code-reviewer
  architect
  planner
  build-error-resolver
)

# ── Helpers ───────────────────────────────────────────────────────────────────
log()     { echo -e "${GREEN}[✔]${RESET} $*"; }
info()    { echo -e "${BLUE}[i]${RESET} $*"; }
warn()    { echo -e "${YELLOW}[!]${RESET} $*"; }
error()   { echo -e "${RED}[✘]${RESET} $*"; }
section() { echo -e "\n${BOLD}${CYAN}══ $* ══${RESET}"; }

# ── Usage ─────────────────────────────────────────────────────────────────────
usage() {
  echo -e "
${BOLD}ecc-setup.sh${RESET} — Everything Claude Code for IaC/DevOps

${BOLD}Usage:${RESET}
  ./ecc-setup.sh ${CYAN}--install${RESET}        Clone repo, install plugin, rules, skills, agents
  ./ecc-setup.sh ${CYAN}--uninstall${RESET}      Remove ECC rules, skills, agents, env vars
  ./ecc-setup.sh ${CYAN}--mcp${RESET}            Show MCP server recommendations and status
  ./ecc-setup.sh ${CYAN}--link-settings${RESET}  Symlink settings.json and CLAUDE.md into ~/.claude/
  ./ecc-setup.sh ${CYAN}--help${RESET}           Show this help
"
}

# ── Link settings ─────────────────────────────────────────────────────────────
_link() {
  local src="${SCRIPT_DIR}/$1"
  local dst="${CLAUDE_DIR}/$2"

  if [[ ! -e "${src}" && ! -d "${src}" ]]; then
    warn "SKIP  $2 (source not found: ${src})"
    return
  fi

  if [[ -L "${dst}" && "$(readlink "${dst}")" == "${src}" ]]; then
    info "OK    $2 (already linked)"
    return
  fi

  ln -sf "${src}" "${dst}"
  log "LINKED $2 -> ${src}"
}

cmd_link_settings() {
  section "Linking settings into ${CLAUDE_DIR}"
  local SCRIPT_DIR
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  mkdir -p "${CLAUDE_DIR}"
  _link "settings.json" "settings.json"
  _link "CLAUDE.md"     "CLAUDE.md"
  log "Done."
}

# ── Install ───────────────────────────────────────────────────────────────────
cmd_install() {
  section "Installing ECC (IaC/DevOps profile)"

  # Check dependencies
  for dep in git node npm; do
    if ! command -v "$dep" &>/dev/null; then
      error "Missing dependency: ${dep}"
      exit 1
    fi
  done

  # Clone repo if needed
  if [[ ! -d "${ECC_CLONE_DIR}" ]]; then
    info "Cloning ECC repo into ${ECC_CLONE_DIR}..."
    git clone "$ECC_REPO" "${ECC_CLONE_DIR}"
  else
    warn "Repo already exists at ${ECC_CLONE_DIR}, skipping clone. Run 'git pull' inside it to update."
  fi

  cd "${ECC_CLONE_DIR}"
  npm install --silent
  log "Dependencies installed"

  # Rules
  section "Installing rules (common only)"
  mkdir -p "$ECC_RULES_DIR"
  cp -R rules/common "$ECC_RULES_DIR/"
  log "Rules installed → ${ECC_RULES_DIR}/common"
  warn "Skipped: typescript/, swift/, php/, golang/ — not relevant to IaC stack"

  # Skills
  section "Installing skills (infra subset)"
  mkdir -p "$ECC_SKILLS_DIR"
  for skill in "${INFRA_SKILLS[@]}"; do
    if [[ -d "skills/${skill}" ]]; then
      cp -R "skills/${skill}" "$ECC_SKILLS_DIR/"
      log "Skill: ${skill}"
    else
      warn "Skill not found in repo: ${skill} (may have been renamed)"
    fi
  done

  # Agents
  section "Installing agents (infra subset)"
  mkdir -p "$AGENTS_DIR"
  for agent in "${INFRA_AGENTS[@]}"; do
    if [[ -f "agents/${agent}.md" ]]; then
      cp "agents/${agent}.md" "$AGENTS_DIR/"
      log "Agent: ${agent}"
    else
      warn "Agent not found: ${agent}.md"
    fi
  done
  warn "Skipped: java-reviewer, kotlin-reviewer, pytorch-*, rust-*, typescript-reviewer"

  cd - >/dev/null

  # Plugin install instructions (must be done inside Claude Code)
  section "Plugin install (manual step required)"
  echo -e "
${YELLOW}Run these commands inside Claude Code:${RESET}

  ${CYAN}/plugin marketplace add ${ECC_REPO}${RESET}
  ${CYAN}/plugin install ${ECC_PLUGIN_ID}${RESET}

Plugin distributes skills/commands/hooks engine.
Rules/agents above are installed directly (plugin cannot distribute rules).
"

  log "Install complete."
  echo -e "\n${YELLOW}Next:${RESET} Run ${CYAN}./ecc-setup.sh --mcp${RESET} to review MCP server recommendations."
}

# ── Uninstall ─────────────────────────────────────────────────────────────────
cmd_uninstall() {
  section "Uninstalling ECC"

  # Rules
  if [[ -d "$ECC_RULES_DIR" ]]; then
    rm -rf "$ECC_RULES_DIR"
    log "Removed rules: ${ECC_RULES_DIR}"
  else
    info "Rules dir not found, skipping: ${ECC_RULES_DIR}"
  fi

  # Skills
  if [[ -d "$ECC_SKILLS_DIR" ]]; then
    rm -rf "$ECC_SKILLS_DIR"
    log "Removed skills: ${ECC_SKILLS_DIR}"
  else
    info "Skills dir not found, skipping: ${ECC_SKILLS_DIR}"
  fi

  # Agents
  if [[ -d "$AGENTS_DIR" ]]; then
    for agent in "${INFRA_AGENTS[@]}"; do
      if [[ -f "${AGENTS_DIR}/${agent}.md" ]]; then
        rm -f "${AGENTS_DIR}/${agent}.md"
        log "Removed agent: ${agent}.md"
      fi
    done
  fi

  # Script-based uninstall if repo is present
  if [[ -d "${ECC_CLONE_DIR}" ]]; then
    info "Running ECC uninstaller (dry-run first)..."
    cd "${ECC_CLONE_DIR}"
    node scripts/uninstall.js --dry-run || true
    echo ""
    read -r -p "$(echo -e "${YELLOW}Proceed with ECC uninstall script?${RESET} [y/N] ")" confirm
    if [[ "${confirm,,}" == "y" ]]; then
      node scripts/uninstall.js
      log "ECC uninstall script complete"
    else
      warn "Skipped ECC uninstall script"
    fi
    cd - >/dev/null
  fi

  echo -e "
${YELLOW}Manual step required — inside Claude Code:${RESET}

  ${CYAN}/plugin uninstall ${ECC_PLUGIN_ID}${RESET}
"
  log "Uninstall complete."
}

# ── MCP ───────────────────────────────────────────────────────────────────────
cmd_mcp() {
  section "MCP Server Recommendations for IaC/DevOps"

  echo -e "
${BOLD}Keep ENABLED:${RESET}

  ${GREEN}✔ context7${RESET}
      Docs lookup for Terraform, Kubernetes, Python, Helm, AWS providers.
      Saves you from outdated training data on rapidly-changing APIs.

  ${GREEN}✔ github${RESET}
      PR review, issue tracking, repo access from Claude Code.
      Essential for infra code review workflows.

  ${GREEN}✔ sequential-thinking${RESET}
      Multi-step reasoning for complex infra planning and architecture decisions.
      Low token overhead, high value for Terraform module design and K8s troubleshooting.

${BOLD}Disable these:${RESET}

  ${RED}✘ exa${RESET}
      Web search MCP. Redundant for infra work — context7 handles docs better.
      Each MCP tool description costs tokens. No benefit for your stack.

  ${RED}✘ memory${RESET}
      Persistent cross-session memory. Adds injection overhead every SessionStart.
      For infra work, your CLAUDE.md and skills provide better structured context.
      Use ECC_SESSION_START_CONTEXT=off instead.

  ${RED}✘ playwright${RESET}
      Browser automation. Zero relevance to Terraform/K8s/Python/Bash workflows.
      Disable immediately — pure token waste.

${BOLD}Budget rule:${RESET}

  Keep MCPs ≤ 10 active, tools ≤ 80 total.
  Too many MCPs collapse your 200k context window to ~70k.
  Current target: ${GREEN}3 active MCPs${RESET} (context7 + github + sequential-thinking).

${BOLD}How to disable in Claude Code:${RESET}

  Run ${CYAN}/mcp${RESET} inside Claude Code → navigate to each server → disable.
  Claude Code writes choices to ~/.claude.json (not settings.json).

${BOLD}Verify your MCP tool count:${RESET}

  ${CYAN}/mcp${RESET} → check total tool count shown at bottom of list.
"
}

# ── Main ──────────────────────────────────────────────────────────────────────
[[ $# -eq 0 ]] && usage && exit 0

case "${1}" in
  --install)        cmd_install        ;;
  --uninstall)      cmd_uninstall      ;;
  --mcp)            cmd_mcp            ;;
  --link-settings)  cmd_link_settings  ;;
  --help|-h)   usage         ;;
  *)
    error "Unknown option: ${1}"
    usage
    exit 1
    ;;
esac
