# DevOps Infrastructure — Global Instructions

## Professional Context
Senior Infrastructure Engineer managing production infrastructure and Homelab automation.
**Constraint:** Claude Pro (44K tokens/5-hour window, ~10-40 prompts depending on complexity)

## Tech Stack & Versions (as of July 2026)
- **Terraform 1.15.7:** HCL, modular architecture, state in remote backend (1.16 in alpha — do not adopt yet)
- **Docker 29.6.1:** Standalone & Swarm
- **Kubernetes 1.36.2:** manifest-based deployments; prefer namespaced resources (1.37.0 due Aug 26, 2026 — not yet released)
- **kubectl 1.36.2:** Always namespace-aware (`-n <namespace>`), use `kubectl diff` before apply
- **helm 4.2.2:** `--dry-run` before install/upgrade; no `helm install` without values file (Helm 4 stable since Nov 2025 — breaking changes from v3; v3 line still gets security fixes via 3.21.2 until Nov 2026)
- **kubeseal 0.38.1:** Version must match sealed-secrets controller in cluster; fetch cert before sealing
- **flux 2.8.6:** GitOps reconciliation; prefer `flux reconcile` over manual `kubectl apply`; Flux 2.8 adds Helm v4 support (server-side apply, CEL health checks)
- **talosctl 1.13.2:** Talos node management; install via https://talos.dev/install; version-lock to cluster
- **go-task 3.51.1:** Task runner for `talos-provisioning/taskfile.yaml`; use `task --list` to discover tasks
- **jq 1.8.2:** Required by backup/restore scripts; use for parsing kubectl/API JSON output
- **Bash 5.0+:** Production scripts require `set -euo pipefail`, idempotent
- **Python 3.14.6:** Type hints (`typing` module), docstrings (Google style)
- **Ansible 13.6.0** (ansible-core 2.21.1)**:** Config management, always run with `--check` first

## Decision Framework
For **production:** Prioritize reliability, observability, operational overhead
For **Homelab:** Acknowledge cost/resource constraints vs distributed tradeoffs

## Non-Negotiable Rules
1. **Always web-search before DevOps tool advice** — versions change, patterns deprecate
2. **Production = HA + monitoring + audit trails** — assume these are required
3. **Push back on operational debt** — flag single points of failure, hidden maintenance costs
4. **Version context matters** — include "as of [current month/year], avoid X because..."
5. **Dry-runs first** — terraform plan, ansible --check, docker compose config, kubectl diff
6. **Kubernetes: namespace-aware** — always specify `-n <namespace>`, never assume default

## ECC Skills & Agents
Available via the `ecc` plugin. Given the Pro token budget, don't invoke proactively for simple/single-file tasks — only when the task's complexity actually requires the specialized workflow (multi-file features, unfamiliar tool version behavior, security-sensitive changes, network/homelab design work, etc). Prefer direct tool use for anything answerable in a few commands.

**Skills** — invoke via `Skill` when the task matches:
| Skill | Use when |
|---|---|
| deployment-patterns | Designing/reviewing a deploy pipeline or rollout strategy |
| docker-patterns | Writing/reviewing Dockerfiles or Compose stacks |
| backend-patterns | Backend service architecture or API server design |
| python-patterns | Non-trivial Python implementation work |
| python-testing | Writing/reviewing Python test suites |
| api-design | Designing new REST endpoints or contracts |
| database-migrations | Writing or reviewing schema migrations |
| security-review | Before committing security-sensitive code (auth, secrets, input handling) |
| verification-loop | Verifying a nontrivial change actually works end-to-end |
| tdd-workflow | New feature or bug fix needing test-first discipline |
| search-first | Before writing new implementation code — check for existing/reusable solutions |
| mcp-server-patterns | Building or modifying an MCP server |
| autonomous-loops | Designing a recurring/autonomous agent loop |
| kubernetes-patterns | Writing/reviewing K8s manifests or cluster changes |
| git-workflow | Commit/PR message and branching conventions |
| github-ops | GitHub issue/PR/Actions automation |
| homelab-network-readiness | Auditing homelab network before a change |
| homelab-network-setup | Standing up new homelab network segments |
| homelab-pihole-dns | Pi-hole/DNS configuration |
| homelab-vlan-segmentation | VLAN design/segmentation work |
| homelab-wireguard-vpn | WireGuard VPN setup |
| network-bgp-diagnostics | Diagnosing BGP routing issues |
| network-config-validation | Validating router/switch config changes |
| network-interface-health | Diagnosing interface-level network health |
| netmiko-ssh-automation | Scripting network device automation via Netmiko |
| flox-environments | Managing Flox dev environments |

**Agents** — invoke via `Agent` when delegating a bounded, independent task:
| Agent | Use when |
|---|---|
| python-reviewer | Reviewing Python code changes |
| security-reviewer | Security-sensitive code before commit |
| code-reviewer | General review after writing/modifying code |
| architect | Architectural decisions, system design tradeoffs |
| planner | Planning complex multi-step features/refactors |
| build-error-resolver | Build is broken and needs a minimal fix |
| homelab-architect | Designing/changing homelab network topology |
| network-architect | Enterprise/multi-site network design |
| network-config-reviewer | Reviewing router/switch config for safety |
| network-troubleshooter | Diagnosing live network connectivity issues |

## Code & Config Standards
**Terraform:** Use state locking, variables.tf for inputs, locals for computed values, modules/ for reusable infrastructure
**Bash:** Fail fast (set -e), handle errors (trap), quote variables ("$var"), no pipes to sudo
**Python:** Type hints required (def func(x: str) -> bool:), docstring per function, f-strings only
**YAML:** Start with schema explanation, show both valid and invalid examples, use anchors for reuse
**Docker:** Compose files validate before apply (docker compose config --quiet), no latest tags in production
**Kubernetes:** Use `kubectl diff` before apply, pin image tags, use resource requests/limits, prefer Deployments over bare Pods, RBAC least-privilege

## Frequent Tasks — Pre-optimized
```bash
# Terraform
terraform -chdir=./terraform plan -out=tfplan
terraform -chdir=./terraform validate

# Docker/Swarm
docker compose config --quiet
docker service ls --format "table {{.Name}}\t{{.Replicas}}"

# Ansible
ansible-playbook --check -i inventory site.yml
ansible-playbook -i inventory site.yml

# Kubernetes
kubectl diff -f manifest.yaml
kubectl apply -f manifest.yaml
kubectl rollout status deployment/<name> -n <namespace>
kubectl rollout undo deployment/<name> -n <namespace>
kubectl get pods -n <namespace> -o wide
kubectl logs -n <namespace> <pod> --previous
kubectl top pods -n <namespace>
kubectl describe pod -n <namespace> <pod>
helm upgrade --install <release> <chart> -n <namespace> --values values.yaml --dry-run

# Flux
flux get all -n <namespace>
flux get sources git -A
flux reconcile source git flux-system
flux reconcile kustomization flux-system
flux logs --follow --level=error
flux diff kustomization flux-system

# Sealed Secrets / kubeseal
kubeseal --fetch-cert --controller-name=sealed-secrets --controller-namespace=kube-system
kubeseal --format=yaml < secret.yaml > sealed-secret.yaml
kubectl get sealedsecrets -n <namespace>

# Talos
talosctl version --nodes <node-ip>
talosctl health --nodes <node-ip>
talosctl get members
talosctl logs -n <node-ip> kubelet
talosctl dmesg -n <node-ip>
talosctl dashboard -n <node-ip>

# go-task
task --list
task <task-name> --dry-run

# jq (common patterns)
kubectl get pods -n <namespace> -o json | jq '.items[].metadata.name'
kubectl get secret <name> -n <namespace> -o json | jq '.data | map_values(@base64d)'

# Bash validation
bash -n script.sh
shellcheck script.sh

# Python
python -m py_compile script.py
pytest -v tests/
```

## What NOT To Do
- Don't explain Linux/DevOps fundamentals — assume expertise
- Don't offer multiple solutions unless asked for trade-offs
- Don't recommend cloud-only when self-hosted works
- Don't suggest over-engineered solutions for Homelab
- Don't ignore operational complexity or hidden costs
- Don't validate excessively ("great approach!") — be direct
- Don't edit files outside the current repo — all file edits must stay within the repo's directory tree
- Don't commit changes — only the user commits; prepare changes and stop

## Communication Style
- **Direct & technical.** Skip preamble, explain trade-offs explicitly
- **Concise outputs.** For Pro token limits, prefer summaries over verbose explanations
- **Practical examples.** Show terraform plan output, docker ps examples, kubectl rollout status, actual bash error handling
- **Security → scalability → maintainability.** Review in that order
- **Uncertain outcomes → test first.** Can't verify without running it? Say so and recommend testing — don't present it as a fix
- **No pointless suggestions.** Speculative or doesn't clearly make sense? Don't suggest it

## Pro Plan Token Management (Sonnet 5 only)
- Sessions reset every 5 hours (44K tokens available); track usage, don't wait for a hard stop
- `/clear` between unrelated infrastructure tasks — don't carry dead context into a new problem
- `/compact` proactively at ~60% context, before Sonnet 5 starts dropping earlier detail
- Batch related prompts into one ask: "update error handling in auth.yml, api.yml, and db.yml" not three separate turns
- Keep one task/ticket per session — mixing unrelated infra changes burns tokens on re-establishing context
- Avoid pasting full file contents when a path + line range will do; let Claude read only what's needed
- Skip re-explaining stack/versions already in this file — reference them, don't restate them
- For exploratory/investigation asks, request a direct answer with trade-offs, not an exhaustive multi-option writeup
