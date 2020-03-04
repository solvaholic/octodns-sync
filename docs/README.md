# Octodns Action

This action runs [**github/octodns**](https://github.com/github/octodns) to deploy your octodns config.

## Inputs

### Secrets

**Required** To authenticate with your DNS provider, this action uses [encrypted secrets](https://help.github.com/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets#about-encrypted-secrets) you've configured on your repository. For example if you use Amazon Route53 then [create these secrets](https://help.github.com/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets#creating-encrypted-secrets) on the repository where you store your octodns config:

    "route53-aws-key-id": "YOURIDGOESHERE"
    "route53-aws-secret-access-key": "YOURKEYGOESHERE"

Then include them in `env` in your workflow:

```
env:
  AWS_ACCESS_KEY_ID: ${{ secrets.route53-aws-key-id }}
  AWS_SECRET_ACCESS_KEY: ${{ secrets.route53-aws-secret-access-key }}
```

### `config-path`

**Required** Path, relative to your repository root, of the config file you'd like octodns to use.

Default `"dns/public.yaml"`.

### `pip-extras`

**Optional** List packages required by octodns for your DNS providers. Check [the list of supported providers](https://github.com/github/octodns#supported-providers) to find requirements for yours.

Default `""` (empty string).

### `fork-name`

**Not implemented** Name of the GitHub repository containing the octodns code you'd like to run.

Default `"github/octodns"`.

### `release-tag`

**Not implemented** Tag marking the release of the octodns code you'd like to run.

Default `"v0.9.9"`.

## Outputs

--

## Example workflow

```
name: octodns

on:
  # Deploy config whenever DNS changes are pushed to master.
  push:
    branches:
      - master
    paths:
      - 'dns/*'

jobs:
  publish:
    name: Publish DNS config from master
    runs-on: ubuntu-latest
    steps:
      - uses: actions:checkout@v2
      - name: Publish
        uses: solvaholic/octodns-action@master
        with:
          config-path: dns/config/public.yaml
          pip-extras: boto3
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.route53_aws_key_id }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.route53_aws_secret_access_key }}
```
