# octodns Design and Ecosystem

Research into octodns/octodns's design, CLI tools, intended workflows, reference implementations, and ecosystem -- to inform what octodns-sync should (and shouldn't) automate. April 2026.

## Design Philosophy

From the docs and codebase:

1. **DNS as code** -- DNS config lives in a repo, deployed like other infrastructure code
2. **Pluggable architecture** -- providers, sources, processors are all swappable modules
3. **Plan then apply** -- dry-run first (`octodns-sync`), then apply (`octodns-sync --doit`)
4. **Safety by default** -- unsafe plans (too many changes) require `--force`; new checksum mode adds another gate
5. **Multiple plan output formats** -- `PlanLogger` (default), `PlanJson`, `PlanMarkdown`, `PlanHtml`
6. **Provider-agnostic** -- 40+ DNS providers supported via separate modules

### The GitHub workflow octodns envisions

From the [getting-started docs](https://octodns.readthedocs.io/en/latest/getting-started.html), the intended workflow is modeled after GitHub's own deployment process:

1. **Create a PR** with DNS changes
2. **Noop deploy** -- `octodns-sync` runs without `--doit` to show planned changes
3. **Human review** -- teammate reviews the plan output + the config diff
4. **Branch deploy** -- deploy from the PR branch (with ability to roll back to main)
5. **Verify** -- check with `dig` and/or `octodns-report`
6. **Merge** -- merge the PR after successful deployment

This is a branch-deploy workflow, not a merge-then-deploy workflow. That's a key design distinction -- most octodns-sync users do merge-then-deploy instead.

---

## CLI Tools

octodns provides **7 CLI commands**:

| Command | Purpose | Automatable with Actions? |
|---------|---------|--------------------------|
| `octodns-sync` | Plan and/or apply DNS changes | **Yes** -- this is what octodns-sync does |
| `octodns-validate` | Validate config and zone files (no provider calls) | **Yes** -- fast, safe, no secrets needed |
| `octodns-dump` | Export current DNS state from a provider to YAML files | **Maybe** -- useful for initial setup or drift detection |
| `octodns-report` | Query live DNS and report on records | **Maybe** -- useful for post-deploy verification |
| `octodns-compare` | Compare records between two sources | **Maybe** -- useful for drift detection between providers |
| `octodns-schema` | Generate JSON Schema for zone YAML files | **No** -- one-time dev tool |
| `octodns-versions` | Print installed provider versions | **No** -- debugging tool |

### CLI flags octodns-sync supports vs. what the Action exposes

| CLI flag | Purpose | In Action? |
|----------|---------|-----------|
| `--config-file` | Config file path | Yes (`config_path`) |
| `--doit` | Apply changes | Yes (`doit`) |
| `--force` | Allow unsafe plans | Yes (`force`) |
| `--checksum` | Verify plan checksum before applying | **No** |
| `zone` (positional) | Limit to specific zone(s) | Yes (`zones`) |
| `--source` | Limit to zones with specific source(s) | **No** |
| `--target` | Limit to specific target(s) | **No** |
| `--log-stream-stdout` | Send logs to stdout | **No** (implicit in how run.sh captures output) |
| `--debug` | Verbose logging | **No** |
| `--quiet` | Suppress non-essential output | **No** |

### Plan output formats

octodns natively supports structured plan output via the `manager.plan_outputs` config:

| Format | Class | Good for |
|--------|-------|----------|
| Logger (default) | `PlanLogger` | Human-readable console output |
| JSON | `PlanJson` | Machine-readable, programmatic consumption |
| Markdown | `PlanMarkdown` | PR comments, documentation |
| HTML | `PlanHtml` | Web dashboards, email reports |

**Key insight**: octodns already has `PlanMarkdown` built in. The Action could configure `plan_outputs` to include `PlanMarkdown` and use that directly for PR comments instead of capturing raw stderr/stdout.

---

## Reference Implementations

### hackclub/dns (206 stars)

Listed in octodns docs as a sample implementation. 5 workflows:

| Workflow | Trigger | What it does |
|----------|---------|-------------|
| `deploy.yml` | push to main, workflow_dispatch | `octodns-sync --doit` with force-label check |
| `test.yml` | push, pull_request_target, merge_group | `octodns-sync` dry-run with read-only tokens |
| `validate.yml` | push, pull_request_target, merge_group | YAML validation + sort-order check |
| `stale.yml` | schedule | Close stale issues/PRs |
| `contact-check.yml` | schedule | Check domain contacts |

Notable patterns:
- Uses `pull_request_target` with read-only API tokens (addresses [#72](https://github.com/solvaholic/octodns-sync/issues/72))
- `--force` is controlled via a PR label, not a workflow input
- Uses `concurrency` to prevent parallel deploys
- Calls `octodns-sync` directly, does NOT use solvaholic/octodns-sync Action
- Custom `bin/sort-zones` script for zone file ordering

### kubernetes/k8s.io (Kubernetes project)

Listed in octodns docs as a sample implementation. Uses a custom shell script approach:

- Runs octodns-sync per-zone with `--debug` and `--log-stream-stdout`
- Manages canary zones (canary.k8s.io.) alongside production zones
- Pre-processes zone configs by merging multi-file zones
- Uses Docker-based octodns, not pip install
- Does NOT use GitHub Actions at all -- uses Prow CI

Notable patterns:
- Canary zone pattern: deploy to canary.{zone} first, verify, then deploy to {zone}
- Per-zone invocation with explicit zone names
- Log capture per zone for debugging

### jekyll/dns (14 stars)

Listed in octodns docs. Uses octodns-sync directly, simple push-to-deploy.

---

## What Workflows Make Sense to Automate?

### Tier 1: Core (what octodns-sync already does)

| Workflow | CLI | Trigger | Notes |
|----------|-----|---------|-------|
| **Plan** (dry-run) | `octodns-sync` | pull_request | Show what would change |
| **Apply** (deploy) | `octodns-sync --doit` | push to main | Make the changes |
| **Force apply** | `octodns-sync --doit --force` | manual/labeled | Override safety thresholds |

### Tier 2: Valuable additions

| Workflow | CLI | Trigger | Notes |
|----------|-----|---------|-------|
| **Validate** | `octodns-validate` | pull_request | Fast config validation, no secrets needed. Could be a separate Action or a mode of octodns-sync. |
| **Checksum-gated apply** | `octodns-sync --doit --checksum=X` | push to main | Plan produces a checksum; apply only proceeds if checksum matches. Prevents TOCTOU bugs where config changes between plan and apply. **New octodns feature that no Action supports yet.** |

### Tier 3: Useful but niche

| Workflow | CLI | Trigger | Notes |
|----------|-----|---------|-------|
| **Dump** | `octodns-dump` | workflow_dispatch / schedule | Export current DNS state for initial setup or drift detection |
| **Report** | `octodns-report` | push to main (post-deploy) | Verify deployed records match expectations |
| **Compare** | `octodns-compare` | schedule | Detect drift between providers |

---

## Complementary Actions Worth Studying

### Actions used in the octodns ecosystem

| Action | Used by | Purpose |
|--------|---------|---------|
| `peter-evans/create-or-update-comment` | bsoyka, python-discord, felixdorn | Update PR comments (replaces add_pr_comment) |
| `peter-evans/find-comment` | bsoyka, python-discord | Find existing comment to update |
| `github/branch-deploy` | GrantBirki | IssueOps branch deployment |
| `GrantBirki/json-yaml-validate` | hackclub | YAML validation on PRs |
| `actions/github-script` | hackclub | Force-label detection from PR |

### Design pattern references

| Action | Why study it |
|--------|-------------|
| `hashicorp/setup-terraform` | Similar "infrastructure CLI wrapper" pattern; handles plan/apply separation well |
| `bridgecrewio/checkov-action` | IaC validation action; similar to what octodns-validate would be |
| `peter-evans/create-or-update-comment` | The de facto standard for PR comments in Actions |

---

## Gaps Between octodns Design and octodns-sync Action

### Things octodns supports that the Action doesn't expose

1. **`--source` and `--target` flags** -- antonydevanchi's fork added these
2. **`--checksum` flag** -- new feature for safe plan-then-apply
3. **`--debug` / `--quiet` flags** -- logging verbosity control
4. **`octodns-validate`** -- config validation without provider credentials
5. **Plan output formats** (`PlanMarkdown`, `PlanJson`, `PlanHtml`) -- the Action captures raw stdout/stderr; it could configure `plan_outputs` for structured output
6. **Multiple config files** -- octodns supports `staging.yaml` + `production.yaml`; the Action only takes one `config_path`

### Things the community does that the Action doesn't support well

1. **Branch deploy workflow** -- octodns was designed for branch deploys, but most users do merge-then-deploy because the Action doesn't facilitate branch deploys
2. **Update-in-place PR comments** -- most popular request, built outside the Action
3. **`pull_request_target`** -- needed for fork PRs to access read-only secrets; [#72](https://github.com/solvaholic/octodns-sync/issues/72) is still open
4. **Force via PR label** -- hackclub's elegant pattern; Action requires explicit input
5. **Separate validate step** -- no secrets needed, fast, could run on every PR
6. **Concurrency control** -- hackclub uses `concurrency:` to prevent parallel deploys; the Action's README doesn't mention this

### Things the Action does that octodns doesn't need

1. **Installing octodns** -- removed in v3.0.0, correctly delegated to user. But starburst997 fork tried to add it back in. There's still demand for a simpler setup.
2. **Python setup** -- every single workflow does `setup-python` + `pip install` before the Action. This is friction.

---

## Recommendations

### Align with octodns's design

1. **Expose missing CLI flags**: `--source`, `--target`, `--debug`, `--checksum`
2. **Leverage PlanMarkdown**: Configure `plan_outputs` to produce markdown natively instead of capturing raw output
3. **Document the branch-deploy pattern**: This is how octodns was designed to be used

### Consider a second Action: octodns-validate

A lightweight Action that runs `octodns-validate` (no secrets required). Could run on every PR, including from forks. Fast validation feedback before the heavier sync step.

### Consider the checksum workflow

octodns's new `--checksum` flag enables a secure plan-then-apply pattern:
1. PR: plan -> capture checksum
2. Merge: apply with `--checksum=X` -> only proceeds if plan hasn't changed

No Action supports this yet.

### Study the setup friction

Every user writes 3-5 steps before calling octodns-sync: checkout, setup-python, pip install requirements. The official Docker images (`octodns/octodns-docker`) solve this for Docker-based workflows. A composite action could optionally embed setup steps (like starburst997 tried).

---

## Ecosystem Overview

| Repository | Stars | Role |
|-----------|-------|------|
| octodns/octodns | 3683 | Core tool |
| hackclub/dns | 206 | Reference implementation |
| octodns/octodns-cloudflare | 48 | Most-used provider |
| sukiyaki/octodns-netbox | 40 | NetBox integration |
| solvaholic/octodns-sync | 35 | This Action |
| octodns/octodns-docker | 13 | Official Docker images |
| jekyll/dns | 14 | Reference implementation |
