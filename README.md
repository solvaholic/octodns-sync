# octodns-action

This action runs [**github/octodns**](https://github.com/github/octodns) to deploy your DNS config to any cloud.

**octodns** allows you to manage your DNS records in a provider-agnostic format and test and publish changes with many different DNS providers. It is extensible and customizable.

When you manage your **octodns** DNS configuration in a GitHub repository, this [GitHub Action](https://help.github.com/actions/getting-started-with-github-actions/about-github-actions) allows you to test and publish your changes automatically using a [workflow](https://help.github.com/actions/configuring-and-managing-workflows) you define.

## Example workflow

```
name: octodns

on:
  # Deploy config whenever DNS changes are pushed to master.
  push:
    branches:
      - master
    paths:
      - '*.yaml'

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
          config_path: public.yaml
          doit: --doit
```

Please note running this action that way :point_up: will rebuild the Docker image on every run. This adds about 40 seconds to run time, and it uses more processing and I/O. To use [the image hosted on Docker hub](https://hub.docker.com/repository/docker/solvaholic/octodns-action) instead, pass the same `args` you would to `octodns-sync`:

```
      - name: Publish
        uses: docker://solvaholic/octodns-action:v1
        with:
          args: public.yaml --doit
```

## Inputs

### Secrets

(**Required**) To authenticate with your DNS provider, this action uses [encrypted secrets](https://help.github.com/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets#about-encrypted-secrets) you've configured on your repository. For example if you use Amazon Route53 then [create these secrets](https://help.github.com/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets#creating-encrypted-secrets) on the repository where you store your octodns config:

    "route53-aws-key-id": "YOURIDGOESHERE"
    "route53-aws-secret-access-key": "YOURKEYGOESHERE"

Then include them as environment variables in your workflow. For example:

```
env:
  AWS_ACCESS_KEY_ID: ${{ secrets.route53-aws-key-id }}
  AWS_SECRET_ACCESS_KEY: ${{ secrets.route53-aws-secret-access-key }}
```

### `config-path`

(**Required**) Path, relative to your repository root, of the config file you would like octodns to use.

Default `"dns/public.yaml"`.

### `doit`

(**Optional**) Really do it? Set "--doit" to do it; Any other string to not do it.

Default `""` (empty string).

## Outputs

--

## Run locally

Notice this example uses `wslpath -a`. If you're not running this in Linux in WSL in Windows, you'll probably use `realpath` or so.

```
_image=solvaholic/octodns-action:v1
_config_path=dns/config/public.yaml   # Path to your config, from inside the container
_env_path=dns/.env                    # .env file with secret keys and stuff
_volume="$(wslpath -a ./dns)"         # Path Docker will mount at $_mountpoint
_mountpoint=/config                   # Mountpoint for your config directory

# Test changes:
docker run --rm -v "${_volume}":${_mountpoint} --env-file ${_env_path} ${_image} ${_config_path}

# Really do it:
docker run --rm -v "${_volume}":${_mountpoint} --env-file ${_env_path} ${_image} ${_config_path} --doit
```
