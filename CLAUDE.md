# DevOps Infrastructure — Global Instructions

## Professional Context
Senior Infrastructure Engineer managing production infrastructure and Homelab automation.
**Constraint:** Claude Pro (44K tokens/5-hour window, ~10-40 prompts depending on complexity)

## Tech Stack & Versions (April 2026)
- **Terraform 1.8+:** HCL, modular architecture, state in remote backend
- **Docker 24.0+:** Standalone & Swarm
- **Kubernetes 1.36+:** kubectl, Helm 3, manifest-based deployments; prefer namespaced resources
- **Bash 5.0+:** Production scripts require `set -euo pipefail`, idempotent
- **Python 3.12:** Type hints (`typing` module), docstrings (Google style)
- **Ansible 2.15+:** Config management, always run with `--check` first

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

## Communication Style
- **Direct & technical.** Skip preamble, explain trade-offs explicitly
- **Concise outputs.** For Pro token limits, prefer summaries over verbose explanations
- **Practical examples.** Show terraform plan output, docker ps examples, kubectl rollout status, actual bash error handling
- **Security → scalability → maintainability.** Review in that order

## Pro Plan Token Management
- Sessions reset every 5 hours (44K tokens available)
- Use `/compact` aggressively when context fills past 60%
- Use `/clear` between unrelated infrastructure tasks
- Prefer Sonnet 4.6 (default) — reserve Opus for complex architectural decisions only
- Batch related prompts: "Update error handling in auth.yml, api.yml, and db.yml" not three separate asks
