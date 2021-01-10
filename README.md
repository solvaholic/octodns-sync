# octodns-sync

This action runs `octodns-sync` from [github/octodns](https://github.com/github/octodns) to deploy your DNS config to any cloud.

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
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Publish
        uses: solvaholic/octodns-sync@v2
        with:
          config_path: public.yaml
          doit: --doit
```

## Inputs

### Secrets

(**Required**) To authenticate with your DNS provider, this action uses
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

### `config-path`

(**Required**) Path, relative to your repository root, of the config file you would like octodns to use.

Default `"public.yaml"`.

### `doit`

(**Optional**) Really do it? Set "--doit" to do it; Any other string to not do it.

Default `""` (empty string).

### `add_pr_comment`

(**Required**) Add plan as a comment, when triggered by a pull request?

Default `"No"`.

If you would like to add the plan `octodns-sync` generates as a pull request comment, be sure to also configure `plan_outputs` in your configuration file. For example in `public.yaml`:

```yaml
manager:
  plan_outputs:
    html:
      class: octodns.provider.plan.PlanHtml
```

## Outputs

`octodns-sync` will compare your configuration file to the configurations your providers have, and report any planned changes. For example:

```text
********************************************************************************
* example.org.
********************************************************************************
* route53 (Route53Provider)
*   Update
*     <CnameRecord CNAME 3600, mail.example.org., before.example.org.> ->
*     <CnameRecord CNAME 3600, mail.example.org., after.example.org.> (config)
*   Create <ARecord A 3600, after.example.org., ['192.168.0.33']> (config)
*   Create <CaaRecord CAA 3600, after.example.org., ['0 issue "letsencrypt.org"']> (config)
*   Delete <ARecord A 3600, before.example.org., ['192.168.0.33']>
*   Delete <CaaRecord CAA 3600, before.example.org., ['0 issue "letsencrypt.org"']>
*   Update
*     <CnameRecord CNAME 3600, www.example.org., before.example.org.> ->
*     <CnameRecord CNAME 3600, www.example.org., after.example.org.> (config)
*   Summary: Creates=2, Updates=2, Deletes=2, Existing Records=8
```

## Run locally

```sh
_image=ghcr.io/solvaholic/octodns-sync:latest
_config_path=public.yaml    # Path to config file in your repository
_env_path=.env              # .env file with secret keys and stuff
_volume="$(realpath .)"     # Path Docker will mount at $_mountpoint
_mountpoint=/config         # Mountpoint for your config directory

# Test changes:
docker run --rm -v "${_volume}":${_mountpoint} \
--env-file ${_env_path} ${_image} ${_mountpoint#/}/${_config_path}

# Really do it:
docker run --rm -v "${_volume}":${_mountpoint} \
--env-file ${_env_path} ${_image} ${_mountpoint#/}/${_config_path} --doit
```
