# claudecode-devops-settings

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-compatible-5A32FB)](https://github.com/anthropics/claude-code)
[![Model](https://img.shields.io/badge/model-claude--sonnet--5-orange)](settings.json)
[![ECC Plugin](https://img.shields.io/badge/ECC-everything--claude--code-1f6feb)](https://github.com/affaan-m/everything-claude-code)

Claude Code configuration tuned for senior infrastructure engineers managing production and Homelab environments. Pairs a battle-tested `settings.json` with a curated [Everything Claude Code (ECC)](https://github.com/affaan-m/everything-claude-code) plugin subset to keep the assistant direct, safe, and token-efficient on IaC workflows.

---

## What's in This Repo

| File / Dir | Purpose |
|---|---|
| `settings.json` | Project-level Claude Code config — model, permissions, hooks, env vars, ECC plugin |
| `CLAUDE.md` | Global instructions — tech stack, non-negotiable operating rules, coding standards, communication/token efficiency, approval-gated "What NOT To Do" |
| `ecc-setup.sh` | One-shot installer/uninstaller for ECC rules, skills, and agents |
| `everything-claude-code/` | ECC submodule — source for skills, agents, and rules |

---

## Benefits

- **Read-only by default for destructive ops** — `terraform apply`, `kubectl delete`, `kubectl exec/scale`, `helm install`, `docker exec`, `docker rm -f`, `terraform state push`, `talosctl reboot/reset/upgrade/apply-config`, and `flux delete/suspend` are in the deny list; you must approve each explicitly.
- **Auto-summarized tool output** — PostToolUse hooks filter `terraform plan/show`, `docker logs`, `kubectl diff/logs`, `ansible --check`, and `kubectl rollout status` output down to the signal lines (errors, warnings, diffs), saving tokens on verbose commands.
- **Infra-only ECC subset** — installs only the skills and agents relevant to Terraform, Docker, Kubernetes, Flux, Talos, Ansible, Python, and Bash. Language-specific reviewers (TypeScript, Kotlin, Rust, Java) are skipped.
- **Token budget enforced** — `CLAUDE_CODE_EFFORT_LEVEL=medium`, `MAX_THINKING_TOKENS=10000`, and `ECC_SESSION_START_CONTEXT=off` keep per-prompt overhead low on Claude Pro's 44K-token window.
- **Dry-run culture built in** — `CLAUDE.md` makes dry-runs (`terraform plan`, `ansible --check`, `kubectl diff`, `helm --dry-run`, `task --dry-run`) a non-negotiable operating rule, not a suggestion.
- **Approval-gated destructive actions** — `terraform apply/destroy`, `kubectl delete`, `helm uninstall`, `rm -rf`, `git push --force`, and `talosctl reset` require my explicit approval per instance, enforced both in `settings.json`'s deny list and as a non-negotiable rule in `CLAUDE.md`.
- **MCP guidance included** — `ecc-setup.sh --mcp` explains which MCP servers to keep (context7, github, sequential-thinking) and which to disable (exa, memory, playwright) to preserve context window.

---

## Capabilities

### Enforced Permissions

**Auto-allowed (no prompt):**
- `terraform plan/validate/show/output/state list`
- `docker ps/images/inspect/logs/stats/compose config/compose logs`
- `docker service ls/inspect/logs/ps`
- `ansible-playbook --check`, `ansible --list-hosts/tasks`
- `docker network ls/volume ls/compose ps/compose images`
- `kubectl get/describe/logs/top/diff/rollout status/rollout history`
- `helm list/diff/show/template/upgrade --dry-run`
- `flux get/logs/diff`
- `kubeseal --fetch-cert`, `kubectl get sealedsecrets`
- `talosctl version/health/get/logs/dmesg/dashboard`
- `task --list`, `task * --dry-run`
- `jq`
- `bash -n`, `shellcheck`, `git log/diff/status/show/branch/remote -v`

**Always denied:**
- `terraform apply/destroy/import/state rm/state mv/state push`
- `kubectl delete/exec/apply/patch/drain/cordon/edit/scale/label/annotate`
- `helm install/uninstall/upgrade --install * --values *`
- `docker push`, `docker rm -f`, `docker exec`
- `talosctl reboot/reset/upgrade/apply-config`
- `flux delete/suspend`
- `rm -rf *`, `chmod 000 *`
- Writes to `/etc/*`, `/root/*`, `*.prod.yml`, `*.prod.yaml`

### ECC Skills Installed

| Skill | Use |
|---|---|
| `deployment-patterns` | Container and service deployment best practices |
| `docker-patterns` | Compose, Swarm, image build patterns |
| `backend-patterns` | API and service architecture |
| `python-patterns` | Idiomatic Python with type hints |
| `python-testing` | pytest, coverage, test structure |
| `api-design` | RESTful API design and review |
| `database-migrations` | Schema migration safety |
| `security-review` | Pre-commit security scan |
| `verification-loop` | Iterative verify-and-fix workflow |
| `tdd-workflow` | Red-green-refactor enforcement |
| `search-first` | Research before implementation |
| `mcp-server-patterns` | MCP server design and usage |
| `autonomous-loops` | Long-running agent loop patterns |
| `kubernetes-patterns` | K8s manifest and cluster-change review |
| `git-workflow` | Commit/PR message and branching conventions |
| `github-ops` | GitHub issue/PR/Actions automation |
| `homelab-network-readiness` | Auditing homelab network before a change |
| `homelab-network-setup` | Standing up new homelab network segments |
| `homelab-pihole-dns` | Pi-hole/DNS configuration |
| `homelab-vlan-segmentation` | VLAN design/segmentation work |
| `homelab-wireguard-vpn` | WireGuard VPN setup |
| `network-bgp-diagnostics` | Diagnosing BGP routing issues |
| `network-config-validation` | Validating router/switch config changes |
| `network-interface-health` | Diagnosing interface-level network health |
| `netmiko-ssh-automation` | Scripting network device automation via Netmiko |
| `flox-environments` | Managing Flox dev environments |

### ECC Agents Installed

| Agent | Trigger |
|---|---|
| `code-reviewer` | After writing or modifying any code |
| `security-reviewer` | Before commits touching auth, secrets, or infra |
| `python-reviewer` | Python file changes |
| `architect` | Architectural decisions |
| `planner` | Complex feature or refactor planning |
| `build-error-resolver` | When a build or script fails |
| `homelab-architect` | Designing/changing homelab network topology |
| `network-architect` | Enterprise/multi-site network design |
| `network-config-reviewer` | Reviewing router/switch config for safety |
| `network-troubleshooter` | Diagnosing live network connectivity issues |

### CLAUDE.md Rules Enforced

**Non-Negotiable Operating Rules:**
- Web-search before any DevOps tool/version advice (versions change fast)
- State version context explicitly ("as of [month/year], avoid X because Y")
- Push back on operational debt — single points of failure flagged
- Dry-run/plan before any mutating operation, output shown before applying
- Kubernetes: always namespace-aware (`-n <namespace>`, never default)
- No destructive/irreversible action without explicit per-instance approval

**Code & Config Standards:**
- No `latest` tags in Docker for production
- Bash scripts must use `set -euo pipefail`
- Python requires type hints and Google-style docstrings
- `kubeseal` version must match the sealed-secrets controller in cluster
- `talosctl` must be version-locked to the cluster (never mix versions)
- Flux GitOps: prefer `flux reconcile` over direct `kubectl apply`

**What NOT To Do — non-negotiable unless explicitly approved in-session:**
- No Linux/DevOps fundamentals explanations, no unsolicited multiple solutions, no cloud-only bias, no over-engineering Homelab, no editing outside the repo, no commits — Claude prepares changes, the user commits

---

## Requirements

| Dependency | Version | Notes |
|---|---|---|
| [Claude Code](https://github.com/anthropics/claude-code) | Latest | CLI or desktop app |
| Claude Pro / Team / API | — | 44K token window assumed |
| Model | `claude-sonnet-5` | Pinned in `settings.json` (`model` + `ANTHROPIC_DEFAULT_SONNET_MODEL`); Haiku fallback is `claude-haiku-4-5-20251001` |
| Git | 2.x+ | For submodule management |
| Node.js | 18+ | Required by ECC install script |
| npm | 9+ | ECC dependency install |
| Terraform | 1.15.7 | IaC provisioning (1.16 in alpha — do not adopt yet) |
| Docker Engine | 29.6.1 | Standalone & Swarm |
| kubectl | 1.36.2 | Kubernetes CLI |
| Helm | 4.2.2 | Kubernetes package manager (v4 — breaking changes from v3) |
| kubeseal | 0.38.1 | Must match sealed-secrets controller version in cluster |
| Flux | 2.8.6 | GitOps reconciliation (adds Helm v4 support: server-side apply, CEL health checks) |
| talosctl | 1.13.2 | Talos node management; install via [talos.dev/install](https://talos.dev/install) |
| go-task | 3.51.1 | Task runner for `talos-provisioning/taskfile.yaml` |
| jq | 1.8.2 | Required by backup/restore scripts |
| Ansible | 13.6.0 (ansible-core 2.21.1) | Config management |
| Python | 3.14.6 | Scripting and automation |
| `shellcheck` | Any | Optional, used by Bash validation hook |

---

## Usage

### 1. Clone with submodule

```bash
git clone --recurse-submodules https://github.com/whil/claudecode-devops-settings.git
cd claudecode-devops-settings
```

Or if already cloned without the submodule:

```bash
git submodule update --init --remote
```

### 2. Install ECC rules, skills, and agents

```bash
./ecc-setup.sh --install
```

This clones/updates the ECC submodule, installs npm dependencies, copies the infra-relevant rules to `~/.claude/rules/ecc/`, skills to `~/.claude/skills/ecc/`, and agents to `~/.claude/agents/`.

### 3. Symlink settings into `~/.claude/`

```bash
./ecc-setup.sh --link-settings
```

Creates symlinks `~/.claude/settings.json` → `./settings.json` and `~/.claude/CLAUDE.md` → `./CLAUDE.md`. Changes to this repo are picked up automatically.

### 4. Install the ECC plugin inside Claude Code

Run these two commands at the Claude Code prompt:

```
/plugin marketplace add https://github.com/affaan-m/everything-claude-code.git
/plugin install ecc@ecc
```

### 5. Review MCP recommendations

```bash
./ecc-setup.sh --mcp
```

Prints which MCP servers to keep enabled and which to disable for an IaC-focused workflow.

### Uninstall

```bash
./ecc-setup.sh --uninstall
```

Removes ECC rules, skills, and agents from `~/.claude/`. Then inside Claude Code:

```
/plugin uninstall everything-claude-code@everything-claude-code
```

---

## Token Budget Notes

- `ECC_HOOK_PROFILE=minimal` and `ECC_SESSION_START_CONTEXT=off` reduce per-session overhead
- `MAX_THINKING_TOKENS=10000` caps extended thinking (toggle with `Alt+T` in Claude Code)
- `CLAUDE_CODE_EFFORT_LEVEL=medium` balances quality vs token spend
- Use `/compact` when context exceeds 60%; `/clear` between unrelated infra tasks
- Target ≤ 10 active MCPs, ≤ 80 total MCP tools to preserve context window headroom

---

## License

[GNU General Public License v3.0](LICENSE)
