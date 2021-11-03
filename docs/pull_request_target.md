# Accepting pull requests from forks

When accepting **octodns** configuration changes via pull requests from forks, it becomes appealing to trigger workflows on the [`pull_request_target` event]. That approach involves some complications - and some risks - it's important to know about beforehand.

This document points out the risks and complications related to running the **solvaholic/octodns-sync** action, proposes ways to address them, and links to example configurations and relevant documentation.

## Token permissions

When a [GitHub Actions] workflow is triggered on the [`pull_request` event], the GitHub token the workflow receives will have [different permissions] depending on whether the pull request's head branch is local, or in a fork.

For example, when the pull request's head is in a fork, a workflow triggered on `pull_request` will not have access to repository or environment [secrets]. This means it cannot use secrets to run `octodns-sync` and validate the proposed configuration changes.

Its GitHub token will also not have permission to [add comments to pull requests].

Work around these complications by triggering the workflow, instead, on the [`pull_request_target` event]. And consider these effects of doing so:

- The workflow will run in the context of the pull request base, rather than its head.
- Any user who can create a pull request can potentially access repository and environment secrets.

## Running in the pull request base

Workflows running in the context of the pull request head use the pull request merge commit as their [`github.ref`]. By default, they'll use the contributed code as it would look if the pull request had already been merged.

Workflows running in the context of the pull request base use that base as their [`github.ref`]. For example, `refs/heads/main`. By default, they'll use only the code that was already in the repository.

So, when triggering workflows on the `pull_request_target` event, it's necessary to explicitly check out **octodns** configuration files from `refs/pull/NNN/merge` or `refs/pull/NNN/head`.

## Protecting repository and environment secrets

GitHub has already written this up, so it won't be repeated here. Read this post:

[_Keeping your GitHub Actions and workflows secure: Preventing pwn requests_]

If it doesn't feel relevant, or doesn't seem to address the concern related to **octodns** configuration repositories, set a reminder to read it again tomorrow.

## Example workflows

TODO

## References and other examples

[_Keeping your GitHub Actions and workflows secure: Preventing pwn requests_]

[Example workflows](https://gist.github.com/xt0rted/a0ef1d3739cc333f8e3461532697d2ba) @xt0rted provided [in #41](https://github.com/solvaholic/octodns-sync/issues/58#issuecomment-835873880)

## Thank you

Thank you @xt0rted @patcon @travislikestocode for helping @solvaholic understand this use case, and for improving **solvaholic/octodns-sync** :bow:


[`pull_request_target` event]: https://docs.github.com/actions/reference/events-that-trigger-workflows#pull_request_target
[`pull_request` event]: https://docs.github.com/actions/reference/events-that-trigger-workflows#pull_request
[secrets]: https://docs.github.com/actions/reference/encrypted-secrets
[add comments to pull requests]: add_pr_comment.md
[different permissions]: https://docs.github.com/actions/reference/events-that-trigger-workflows#pull-request-events-for-forked-repositories
[`github.ref`]: https://docs.github.com/actions/reference/context-and-expression-syntax-for-github-actions#github-context
[GitHub Actions]: https://docs.github.com/actions/learn-github-actions/introduction-to-github-actions
[_Keeping your GitHub Actions and workflows secure: Preventing pwn requests_]: https://securitylab.github.com/research/github-actions-preventing-pwn-requests/