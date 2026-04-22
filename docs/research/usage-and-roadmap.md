# Usage Research and Roadmap Signals

Research into how `solvaholic/octodns-sync` is used in the wild, and what the findings suggest for the project's direction. Based on public GitHub data collected April 2026.

## Methodology

- **19 forks** discovered via the GitHub API; 6 have changes ahead of upstream
- **27 public workflow files** found via GitHub code search across 15 distinct repositories
- **4 fork-based usages** found (GrantBirki and edkadigital use their own forks)
- Only public repositories were analyzed; private usage is not represented
- Findings are anonymous except where specific public work is credited

---

## Version Pinning

| Version ref | Count | % |
|-------------|-------|---|
| `@main` (floating) | 14 | 54% |
| `@v3.1.1` (exact) | 4 | 15% |
| `@v3.0.1` (exact) | 3 | 12% |
| `@v3` (major tag) | 2 | 8% |
| `@SHA` (commit pin) | 2 | 8% |
| `@issue92` (branch) | 1 | 4% |

Over half of users pin to `@main`. Only 2 use the recommended `@v3` major tag pattern. This suggests either users don't know about version tags, or they want the latest fixes and accept the risk.

**Signal**: Update README examples to use `@v3`. Fix the major-tag update workflow ([#108](https://github.com/solvaholic/octodns-sync/issues/108)) so `@v3` stays current.

---

## Input Usage

### `config_path` (default: `public.yaml`)

Nobody uses the default. Every single user sets a custom config path:

| Config path | Count |
|-------------|-------|
| `production.yaml` | 4 |
| `dns/config.yaml` | 4 |
| Dynamic: `${{ needs.meta.outputs.config }}` | 4 |
| `config/production.yaml` | 3 |
| `config.yaml` | 3 |
| `dns/dns.yaml` | 2 |
| `octodns.yaml` | 2 |
| `dns/production.yaml` | 2 |
| `./config/production.yaml` | 1 |
| `domains.yaml` | 1 |
| `config/config.yaml` | 1 |

**Signal**: Change the default to `config.yaml` (the most generic common choice), or remove the default entirely and make it required. Either change would better match real-world usage.

### `doit` (default: `""`)

| Value | Count |
|-------|-------|
| `--doit` | 16 |
| (not set / default) | 9 |
| Dynamic: `${{ steps.noop-check.outputs.doit }}` | 1 |
| Empty string | 1 |

Most deploy workflows set `--doit`. Plan/dry-run workflows omit it. One creative use dynamically computes it based on whether the deployment is a noop -- see [GrantBirki's branch-deploy workflow](https://github.com/GrantBirki/dns/blob/84071641c6e77db3f2bff91bd701600581f43bfe/.github/workflows/branch-deploy.yml).

### `force` (default: `No`)

| Value | Count |
|-------|-------|
| (not set / default) | 19 |
| `Yes` | 6 |
| Dynamic: `${{ steps.force-check.outputs.force }}` | 1 |
| `True` | 1 |

Force mode is used in ~25% of steps, typically in dry-run/plan workflows. One user passes `True` instead of `Yes`, which may not work as intended since the Action checks for `"Yes"` specifically.

### `add_pr_comment` (default: `No`)

| Value | Count |
|-------|-------|
| (not set / default) | 23 |
| `Yes` | 4 |

Only 15% of octodns-sync steps use the built-in PR comment feature. But 8 out of 27 workflows (30%) consume the `plan` output to build their own PR comments. Users prefer external comment actions (like `peter-evans/create-or-update-comment`) because they can update existing comments instead of adding new ones -- the exact pain point described in [#41](https://github.com/solvaholic/octodns-sync/issues/41).

### `pr_comment_token` (default: `Not set`)

| Pattern | Count |
|---------|-------|
| (not set) | 23 |
| `${{ secrets.GITHUB_TOKEN }}` | 2 |
| `${{ secrets.* }}` (other) | 2 |

### `zones` (default: `""`)

Zero public users use the `zones` input (added in v3.1.0). Either users don't need zone filtering, the feature isn't well-known, or the use case is limited to private repos.

**Signal**: Don't deprecate yet, but don't invest further. If nobody uses it after another year, consider removing it in the next major version.

---

## Output Usage

8 of 27 workflows (30%) consume the Action's outputs:

| Output | Consumers |
|--------|-----------|
| `outputs.plan` | 8 workflows |
| `outputs.log` | 2 workflows |

### How `outputs.plan` is used

The dominant pattern is **roll-your-own PR comments** using `peter-evans/create-or-update-comment`:

1. Run octodns-sync in a "plan" job, expose `outputs.plan` as a job output
2. In a separate "comment" job, use `peter-evans/find-comment` to locate any existing comment
3. Use `peter-evans/create-or-update-comment` to create or replace the comment
4. Skip the comment if the plan contains "No changes were planned"

This pattern is independently implemented by at least 3 users:
- [bsoyka/infra](https://github.com/bsoyka/infra/blob/129e0ce7f105569edb4a2e1514b79fb30c901e10/.github/workflows/dns-dry-run.yaml) -- clean two-job approach with "no changes" filtering
- [python-discord/infra](https://github.com/python-discord/infra/blob/80a33c2aafdfb4c5c3317a4ae20ffe130dec9a93/.github/workflows/dns-dry-run.yaml) -- similar pattern
- [GrantBirki/dns](https://github.com/GrantBirki/dns/blob/84071641c6e77db3f2bff91bd701600581f43bfe/.github/workflows/branch-deploy.yml) -- feeds plan output into a custom deploy message updater

### How `outputs.log` is used

Only GrantBirki's workflows print the log output for debugging. Keep the output (it's cheap), but it's not a priority for enhancement.

---

## Workflow Structure

### Triggers

| Trigger | Count | Typical use |
|---------|-------|-------------|
| `push` | 14 | Deploy on merge to main |
| `workflow_dispatch` | 13 | Manual deployment trigger |
| `pull_request` | 9 | Dry-run / plan on PR |
| `repository_dispatch` | 2 | External trigger |
| `issue_comment` | 1 | IssueOps / branch deploy |

`workflow_dispatch` is nearly as common as `push`, suggesting users want manual deploy capability alongside automated deploys.

### Common workflow pattern: Plan + Apply

Most repos have two workflows:
1. **Plan** -- triggered on `pull_request`, runs octodns-sync without `--doit`, posts plan as PR comment
2. **Apply** -- triggered on `push` to main (or `workflow_dispatch`), runs with `--doit`

Examples: aw1cks/dns, bsoyka/infra, felixdorn/dns, diamondzxd/dns-as-code

The README example only shows a single deploy workflow. A complete two-workflow example would better match real-world usage.

### Runners

All observed usage is on GitHub-hosted runners: `ubuntu-latest` (24 steps) and `ubuntu-20.04` (14 steps). No self-hosted runners observed.

### Python versions

| Version | Count |
|---------|-------|
| `3.10` | 13 |
| (not specified) | 6 |
| `3.12` | 3 |
| `3.12.x` | 2 |
| `3.12.1` | 1 |

### DNS Providers (inferred from env vars)

| Provider | Count | Env vars |
|----------|-------|----------|
| **Cloudflare** | 15 | `CLOUDFLARE_TOKEN`, `CLOUDFLARE_ACCOUNT_ID` |
| **Azure DNS** | 4 | `AZURE_APPLICATION_ID`, `AZURE_*` |
| **PowerDNS** | 3 | `POWERDNS_API_KEY_NS1/2/3` |
| **DigitalOcean** | 2 | `DO_TOKEN`, `DIGITALOCEAN_OAUTH_TOKEN` |
| **OVH** | 2 | `OVH_APPLICATION_KEY`, `OVH_*` |

Cloudflare dominates at ~55% of observed usage.

---

## Creative and Noteworthy Uses

### IssueOps Branch Deploy (GrantBirki)

The most sophisticated usage pattern observed. Uses `github/branch-deploy` to trigger DNS deployments via PR comments (`.deploy`, `.noop`). Dynamically sets `doit` and `force` inputs based on deploy parameters. Supports noop previews, force deploys, and deployment locking.

See: [branch-deploy.yml](https://github.com/GrantBirki/dns/blob/84071641c6e77db3f2bff91bd701600581f43bfe/.github/workflows/branch-deploy.yml)

### Self-Contained Action with Embedded Dependencies (starburst997)

Embeds `setup-python`, `pip install`, and a pinned `requirements.txt` directly in the composite action steps -- making it a single `uses:` call with no pre-steps needed.

See: [commit 3d62f02](https://github.com/starburst997/octodns-sync/commit/3d62f02338f1f1040faf71decfb3e17dca700774)

### Docker-Based Action with Extended CLI Flags (antonydevanchi)

Completely rewrote the Action as a Docker action using `ghcr.io`, adding `--source`, `--target`, and `--debug` flags that upstream doesn't support.

See: [action.yml](https://github.com/antonydevanchi/octodns-sync/blob/main/action.yml)

### Poetry Support (GrantBirki)

Added a `poetry` input to run `poetry run octodns-sync` instead of bare `octodns-sync`, supporting projects that use Poetry for dependency management.

See: [commit 3c85724](https://github.com/GrantBirki/octodns-action/commit/3c85724f437dd2affabab6d9b0ce86007fb837e7)

---

## Fork Activity Summary

| Status | Count | Description |
|--------|-------|-------------|
| **Active + modified** | 6 | Changes ahead of upstream |
| **Stale mirror** | 13 | Behind upstream, no unique changes |

Of the 6 modified forks:

| Fork | Changes | Status |
|------|---------|--------|
| GrantBirki/octodns-action | Poetry support, custom comments URL, zones, release tooling | Active, renamed |
| MetaMask/octodns-sync | Python HTTP comment script (replaced curl) | Archived |
| antonydevanchi/octodns-sync | Complete Docker rewrite with source/target/debug flags | Older, 3 stars |
| edkadigital/octodns-sync | Dropped `comments_url` requirement | Active |
| prezly/octodns-sync | Dropped `comments_url` requirement | Stale |
| starburst997/octodns-sync | Self-contained action with embedded deps | Recent |

---

## Roadmap Signals

Signals extracted from the usage data, prioritized by evidence strength.

### High Priority

**PR Comment Rework**

30% of workflows build their own PR comment flow using `outputs.plan` + `peter-evans/create-or-update-comment`. Only 15% use the built-in `add_pr_comment`. The long-standing [#41](https://github.com/solvaholic/octodns-sync/issues/41) ("add_pr_comment adds new comment for each run") is the root cause.

Evidence:
- [bsoyka/infra](https://github.com/bsoyka/infra/blob/129e0ce7f105569edb4a2e1514b79fb30c901e10/.github/workflows/dns-dry-run.yaml) -- two-job pattern: find existing comment, create-or-update
- [python-discord/infra](https://github.com/python-discord/infra/blob/80a33c2aafdfb4c5c3317a4ae20ffe130dec9a93/.github/workflows/dns-dry-run.yaml) -- same pattern with "No changes" filtering
- MetaMask fork rewrote comment posting entirely (Python HTTP script)
- edkadigital and prezly both dropped the `comments_url` requirement

Options:
1. Switch `comment.sh` to use `gh pr comment` with find-and-replace semantics (update existing comment)
2. Deprecate the built-in comment feature and document the `peter-evans` pattern as the recommended approach
3. Both: improve the built-in feature AND document the DIY pattern for advanced use cases

Also consider: skip commenting when the plan shows no changes (the bsoyka/python-discord pattern).

**"No changes" detection**

Multiple users independently implemented `if: ${{ ! contains(outputs.plan, 'No changes were planned') }}` to skip PR comments when nothing changed. This should be a first-class output: `outputs.has_changes` (boolean).

### Medium Priority

**Missing CLI flags**

antonydevanchi's fork added `source`, `target`, and `debug` inputs mapping to real `octodns-sync` CLI flags. These are straightforward to add (just pass-through to the CLI) and would reduce the need to fork.

**Poetry / alternative package manager support**

GrantBirki added a `poetry` input. A more generic approach: a `command_prefix` input (default: empty) that prepends to the octodns-sync invocation. This would support poetry (`poetry run`), pipx, or any other wrapper without adding tool-specific inputs.

### Low Priority

**`outputs.log` adoption**: Only 2 workflows reference it. Keep the output, don't invest in enhancing it.

**`zones` input adoption**: Zero public users. Wait and see.

---

## Fork Changes Worth Considering

| Fork | Change | Recommendation |
|------|--------|----------------|
| GrantBirki | [Poetry support](https://github.com/GrantBirki/octodns-action/commit/3c85724f437dd2affabab6d9b0ce86007fb837e7) | Consider generic `command_prefix` input |
| GrantBirki | Uses `${{ github.action_path }}` instead of `${GITHUB_ACTION_PATH}` | Already addressed in [#107](https://github.com/solvaholic/octodns-sync/pull/107) |
| antonydevanchi | [source/target/debug CLI flags](https://github.com/antonydevanchi/octodns-sync/blob/main/action.yml) | Add as optional inputs |
| starburst997 | [Self-contained action with embedded deps](https://github.com/starburst997/octodns-sync/commit/3d62f02338f1f1040faf71decfb3e17dca700774) | Interesting but too opinionated for upstream -- document as alternative |
| edkadigital + prezly | Dropped `comments_url` requirement | Already addressed in PR comment rework |

---

## Documentation Improvements

1. **Document the Plan + Apply pattern**: The dominant two-workflow pattern should be in the README
2. **Document the DIY PR comment pattern**: The `peter-evans/create-or-update-comment` approach is the community standard
3. **Add `workflow_dispatch`**: Nearly half of observed workflows include it
4. **Update runner/Python version recommendations**: Some users still reference `ubuntu-20.04` (EOL) and Python 3.10

### DIY PR comment example

```yaml
# In the plan job
outputs:
  plan: ${{ steps.octodns.outputs.plan }}

# In a separate comment job
- uses: peter-evans/find-comment@v3
  id: fc
  with:
    issue-number: ${{ github.event.pull_request.number }}
    comment-author: github-actions[bot]
    body-includes: "OctoDNS Plan"
- uses: peter-evans/create-or-update-comment@v4
  with:
    comment-id: ${{ steps.fc.outputs.comment-id }}
    issue-number: ${{ github.event.pull_request.number }}
    body: |
      ## OctoDNS Plan
      ${{ needs.plan.outputs.plan }}
    edit-mode: replace
```

---

## Open Questions from Community

| Issue | Status | Signal |
|-------|--------|--------|
| [#72](https://github.com/solvaholic/octodns-sync/issues/72) | Open | How to safely run on `pull_request_target`? Security question about fork PRs accessing secrets |
| [#95](https://github.com/solvaholic/octodns-sync/issues/95) | Open | Teach this Action to test itself |
| [#101](https://github.com/solvaholic/octodns-sync/issues/101) | Closed | Custom working-directory support; may still be relevant for monorepo users |
| [#108](https://github.com/solvaholic/octodns-sync/issues/108) | Open | Update major tag workflow fails; blocks version tag updates, contributes to `@main` pinning |
| [octodns/octodns#673](https://github.com/octodns/octodns/issues/673) | Closed | Mention octodns-sync in octodns README |
