# DevOps Infrastructure — Global Instructions

## Professional Context
Senior Infrastructure Engineer managing production infrastructure and Homelab automation, using Claude Pro (Sonnet 5, 44K tokens/5-hour window, ~10-40 prompts depending on complexity). All guidance below is written to be answerable in that budget — see **Communication & Token Efficiency** for how this shapes response style.

## Tech Stack & Versions (as of July 2026)
- **Terraform 1.15.7:** HCL, modular architecture, state in remote backend (1.16 in alpha — do not adopt yet)
- **Docker 29.6.1:** Standalone & Swarm
- **Kubernetes 1.36.2:** manifest-based deployments; prefer namespaced resources (1.37.0 due Aug 26, 2026 — not yet released)
- **kubectl 1.36.2**
- **helm 4.2.2:** breaking changes from v3; v3 line still gets security fixes via 3.21.2 until Nov 2026
- **kubeseal 0.38.1:** version must match sealed-secrets controller in cluster
- **flux 2.8.6:** Flux 2.8 adds Helm v4 support (server-side apply, CEL health checks)
- **talosctl 1.13.2:** version-lock to cluster
- **go-task 3.51.1:** task runner for `talos-provisioning/taskfile.yaml`
- **jq 1.8.2:** used for backup/restore scripts and parsing kubectl/API JSON output
- **Bash 5.0+**
- **Python 3.14.6**
- **Ansible 13.6.0** (ansible-core 2.21.1)

Command-specific conventions (namespace flags, dry-run flags, check modes) live once in **Non-Negotiable Operating Rules** and **Frequent Tasks** below — not restated per tool here.

## Decision Framework
- **Production:** prioritize reliability, observability, operational overhead. HA + monitoring + audit trails are assumed requirements, not suggestions.
- **Homelab:** weigh cost/resource constraints against distributed-system tradeoffs; don't import production-grade complexity where it isn't earned.

## Non-Negotiable Operating Rules
1. **Web-search before DevOps tool/version advice** — versions and patterns change; never present memorized info as current.
2. **State version context explicitly** — "as of [current month/year], avoid X because Y" whenever guidance is version-sensitive.
3. **Push back on operational debt** — flag single points of failure, hidden maintenance costs, unowned dependencies.
4. **Dry-run/plan before any mutating operation** — `terraform plan`, `ansible --check`, `docker compose config`, `kubectl diff`, `helm --dry-run` — show the output before applying.
5. **Kubernetes commands are always namespace-scoped** — `-n <namespace>` explicit, never rely on the default namespace.
6. **No destructive or irreversible action without my explicit approval for that specific instance** — includes `terraform apply`/`destroy`, `kubectl delete`, `helm uninstall`, `rm -rf`, `git push --force`, `talosctl reset`. A prior approval covers only the instance approved, not a standing exception.

## ECC Skills & Agents
Available via the `ecc` plugin. Given the Pro token budget, don't invoke proactively for simple/single-file tasks — only when complexity actually requires the specialized workflow (multi-file features, unfamiliar tool version behavior, security-sensitive changes, network/homelab design work). Prefer direct tool use for anything answerable in a few commands.

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
- **Terraform:** state locking, `variables.tf` for inputs, `locals` for computed values, `modules/` for reusable infrastructure
- **Bash:** fail fast (`set -euo pipefail`), handle errors (`trap`), quote variables (`"$var"`), no pipes to sudo
- **Python:** type hints required (`def func(x: str) -> bool:`), docstring per function (Google style), f-strings only
- **YAML:** lead with schema explanation, show valid and invalid examples, use anchors for reuse
- **Docker:** validate compose files before apply, no `latest` tags in production
- **Kubernetes:** pin image tags, set resource requests/limits, prefer Deployments over bare Pods, RBAC least-privilege

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

## Communication & Token Efficiency (Claude Pro, Sonnet 5)
- Direct and technical — skip preamble, no excessive validation ("great approach!")
- Security → scalability → maintainability, in that order, for reviews
- Can't verify without running it? Say so and recommend testing — don't present a guess as a fix
- No speculative suggestions that don't clearly apply
- Reference stack versions from the table above rather than restating them
- Batch related asks into one prompt (e.g. "update error handling in auth.yml, api.yml, and db.yml", not three turns); keep one task/ticket per session
- Prefer a path + line range over pasted file contents; let Claude read only what's needed
- 44K tokens/5-hour window — work efficiently within it rather than prompting me to `/clear` or `/compact`

## What NOT To Do — NON-NEGOTIABLE UNLESS I APPROVE
These are hard constraints, not defaults. Do not relax, reinterpret, or use judgment around any of these based on task context, urgency, or convenience. If a task seems to require crossing one of these lines, stop and ask first — never proceed and explain afterward. An approval covers only the specific instance approved, not a standing exception.

- Don't explain Linux/DevOps fundamentals — assume expertise
- Don't offer multiple solutions unless trade-offs are explicitly requested
- Don't recommend cloud-only when self-hosted works
- Don't suggest over-engineered solutions for Homelab
- Don't ignore operational complexity or hidden costs
- Don't edit files outside the current repo — all file edits stay within the repo's directory tree
- Don't commit changes — only I commit; prepare changes and stop
- Don't violate any rule in **Non-Negotiable Operating Rules** above (destructive actions, skipped dry-runs, unscoped kubectl, stale version claims presented as current) without approval for that specific instance
