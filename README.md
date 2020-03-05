# Octodns Action

This action runs [**github/octodns**](https://github.com/github/octodns) to deploy your octodns config.

**github/octodns** allows you to manage your DNS records in a provider-agnostic format and test and publish changes with many different DNS providers. It is extensible and customizable.

When you manage your octodns configuration in a GitHub repository, this [GitHub Action](https://help.github.com/actions/getting-started-with-github-actions/about-github-actions) allows you to test and publish your changes automatically in a [workflow](https://help.github.com/actions/configuring-and-managing-workflows) you define.

## Inputs

### Secrets

**Required** To authenticate with your DNS provider, this action uses [encrypted secrets](https://help.github.com/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets#about-encrypted-secrets) you've configured on your repository. For example if you use Amazon Route53 then [create these secrets](https://help.github.com/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets#creating-encrypted-secrets) on the repository where you store your octodns config:

    "route53-aws-key-id": "YOURIDGOESHERE"
    "route53-aws-secret-access-key": "YOURKEYGOESHERE"

Then include them as environment variables in your workflow. For example:

```
env:
  AWS_ACCESS_KEY_ID: ${{ secrets.route53-aws-key-id }}
  AWS_SECRET_ACCESS_KEY: ${{ secrets.route53-aws-secret-access-key }}
```

### `config-path`

**Required** Path, relative to your repository root, of the config file you would like octodns to use.

Default `"dns/public.yaml"`.

### `pip-extras`

**Optional** List packages required by octodns for your DNS providers. Check the list of supported providers to find requirements for yours.

Default `""` (empty string).

### `doit`

**Optional** Really do it? Set "--doit" to do it; Any other string to not do it.

Default `""`.

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
      - 'dns/**'

env:
  AWS_ACCESS_KEY_ID: ${{ secrets.route53_aws_key_id }}
  AWS_SECRET_ACCESS_KEY: ${{ secrets.route53_aws_secret_access_key }}

jobs:
  publish:
    name: Publish DNS config from master
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Publish
        uses: solvaholic/octodns-action@v1
        with:
          config_path: dns/config/public.yaml
          pip_extras: boto3
          doit: --doit
```

## Run locally

Notice this example uses `wslpath -a`. If you're not running this in Linux in WSL in Windows, you'll probably use `realpath` or so.

```
_image=docker.pkg.github.com/solvaholic/octodns-action:latest
_config_path=dns/config/public.yaml   # Path to your config, from inside the container
_pip_extras=boto3                     # Additional packages your DNS provider requires
_env_path=dns/.env                    # .env file with secret keys and stuff
_volume="$(wslpath -a ./dns)"         # Path Docker will mount at $_mountpoint
_mountpoint=/dns                      # Mountpoint for your config directory

# Test changes:
docker run --rm -v "${_volume}":${_mountpoint} --env-file ${_env_path} ${_image} ${_config_path} ${_pip_extras}

# Really do it:
docker run --rm -v "${_volume}":${_mountpoint} --env-file ${_env_path} ${_image} ${_config_path} ${_pip_extras} --doit
```
