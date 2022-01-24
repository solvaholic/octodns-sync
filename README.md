# octodns-sync

This action runs `octodns-sync` from [octodns/octodns](https://github.com/octodns/octodns) to deploy your DNS config to any cloud.

octodns allows you to manage your DNS records in a portable format and publish changes across different DNS providers. It is extensible and customizable.

When you manage your octodns DNS configuration in a GitHub repository, this [GitHub Action](https://help.github.com/actions/getting-started-with-github-actions/about-github-actions) allows you to test and publish your changes automatically using a [workflow](https://help.github.com/actions/configuring-and-managing-workflows) you define.

## Example workflow

```yaml
name: octodns-sync

on:
  # Deploy config whenever DNS changes are pushed to main.
  push:
    branches:
      - main
    paths:
      - '*.yaml'

env:
  AWS_ACCESS_KEY_ID: ${{ secrets.route53_aws_key_id }}
  AWS_SECRET_ACCESS_KEY: ${{ secrets.route53_aws_secret_access_key }}

jobs:
  publish:
    name: Publish DNS config from main
    runs-on: ubuntu-20.04
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-python@v2
        with:
          python-version: '3.10'
      - run: pip install -r requirements.txt
      - uses: solvaholic/octodns-sync@main
        with:
          config_path: public.yaml
          doit: '--doit'
```

## Inputs

### Secrets

To authenticate with your DNS provider, this action uses
[encrypted secrets](https://help.github.com/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets#about-encrypted-secrets)
you've configured on your repository. For example, if you use Amazon
Route53, [create these secrets](https://help.github.com/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets#creating-encrypted-secrets)
on the repository where you store your DNS configuration:

```text
"route53-aws-key-id": "YOURIDGOESHERE"
"route53-aws-secret-access-key": "YOURKEYGOESHERE"
```

Then include them as environment variables in your workflow. For example:

```yaml
env:
  AWS_ACCESS_KEY_ID: ${{ secrets.route53-aws-key-id }}
  AWS_SECRET_ACCESS_KEY: ${{ secrets.route53-aws-secret-access-key }}
```

### `config_path`

Path, relative to your repository root, of the config file you would like octodns to use.

Default `"public.yaml"`.

### `doit`

Really do it? Set "--doit" to do it; Any other string to not do it.

Default `""` (empty string).

### `add_pr_comment`

Add plan as a comment, when triggered by a pull request? Set "Yes" to do it.

Default `"No"`.

If you would like to add the plan `octodns-sync` generates as a pull request comment, be sure to also read [_Add pull request comment_](#add-pull-request-comment) below.

### `pr_comment_token`

Provide a token to use, if you set `add_pr_comment` to "Yes".

Default `"Not set"`.

### `octodns_ref`

Select a release tag or a branch of octodns to use. For example "v0.9.14" or "awesome-feature".

Default `"v0.9.14"`.

## Outputs

### plan

If you have configured `plan_outputs` for **octodns**, PlanHtml or PlanMarkdown output will be written to `$GITHUB_WORKSPACE/octodns-sync.plan`.

For convenience, this file is output by this action as the `plan` output if you need to use it in subsequent steps.

### Log file

`octodns-sync` will compare your configuration file to the configurations your providers have, and report any planned changes. The command logs this output in the workflow run log.

That same output is saved to `$GITHUB_WORKSPACE/octodns-sync.log`.

### Add pull request comment

If you would like this action to add the `octodns-sync` plan to a pull request comment, configure `plan_outputs` in your **octodns** configuration, for example `public.yml`:

```yaml
manager:
  plan_outputs:
    html:
      class: octodns.provider.plan.PlanHtml
```

Then configure your workflow to run this action on the `pull_request` event, set `add_pr_comment` to "Yes", and provide an API token. For example:

```yaml
on:
  pull_request:
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: solvaholic/octodns-sync@latest
        with:
          config_path: public.yaml
          add_pr_comment: 'Yes'
          pr_comment_token: '${{ github.token }}'
```

Please note: This configuration will add a new comment to the pull request each time it's triggered. To find out how to change that, check out [issue #41](https://github.com/solvaholic/octodns-sync/issues/41) and **[docs/add_pr_comment.md](docs/add_pr_comment.md)**.
