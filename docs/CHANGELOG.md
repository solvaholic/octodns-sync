# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.2.1] - Unreleased

### Known issues
### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security

## [2.2.0] - 2021-05-09

### Known issues

- ([#57](https://github.com/solvaholic/octodns-sync/issues/57)) [2.2.x] Running octodns-sync twice in one job fails

### Added

- ([#53](https://github.com/solvaholic/octodns-sync/pull/53)) Enable user to specify a release tag or branch of octodns to use.
- ([#55](https://github.com/solvaholic/octodns-sync/issues/55)) Document manual release procedures.

### Changed

- Change default **octodns/octodns** from v0.9.11 to v0.9.12.
- ([#55](https://github.com/solvaholic/octodns-sync/issues/55)) Make linter.yml faster, reducing its workflow time from 100 sec to 20 sec.

### Removed

- ([#53](https://github.com/solvaholic/octodns-sync/pull/53)) Removed Docker dependency :tada:

### Fixed

- ([#55](https://github.com/solvaholic/octodns-sync/issues/55)) Improve release workflow to sync tags properly.

## [2.1.3] - 2021-05-08

### Known issues

solvaholic/octodns-sync release 2.1.3 uses octodns 0.9.11 and outdated versions of some octodns and provider dependencies.

### Added

- ([#36](https://github.com/solvaholic/octodns-sync/pull/36)) Save `octodns-sync` plan output to a file.
- ([#36](https://github.com/solvaholic/octodns-sync/pull/36)) Add `octodns-sync` plan output to a pull request comment.
- ([#37](https://github.com/solvaholic/octodns-sync/pull/37)) Add dockerfile_lint to Lint Code Base workflow.
- ([#37](https://github.com/solvaholic/octodns-sync/pull/37)) Add labels to container image: `name`, `version`, `maintainer`.

### Changed

- ([#30](https://github.com/solvaholic/octodns-sync/issues/30), [#32](https://github.com/solvaholic/octodns-sync/issues/32)) Improve the administrative release workflow to facilitate consistent releasing.

### Fixed

- ([#34](https://github.com/solvaholic/octodns-sync/issues/34)) Deleted the `v99` and `v99.0.0` tags.
- ([#40](https://github.com/solvaholic/octodns-sync/issues/40)) Exit 1 when octodns-sync exits non-zero.

## [2.1.2] - 2020-12-28

### Changed

- Upgrade **github/octodns** from v0.9.10 to v0.9.11.
- ([#22](https://github.com/solvaholic/octodns-sync/issues/22)) Build from the **python:3.7-slim** image rather than **python:3-slim**.
- ([#28](https://github.com/solvaholic/octodns-sync/pull/28)) Install octodns from PyPI rather than a Git clone.

## [2.1.0] - 2020-11-03

### Added

- ([#11](https://github.com/solvaholic/octodns-sync/pull/11)) Write `octodns-sync` output to `octodns-sync.log` in the workspace directory.
- Push the **solvaholic/octodns-sync** container image to GitHub's container registry.

### Changed

- **solvaholic/octodns-sync** uses the container image from GitHub's container registry rather than from Docker hub.
- Running `solvaholic/octodns-sync@main` will pull the `:latest` container image.
- Upgrade **github/octodns** from v0.9.9 to v0.9.10.

### Deprecated

- The `master` branch will no longer be updated. Use `main` instead.

### Removed

- Stop pushing the **solvaholic/octodns-sync** container image GitHub's package registry.
- Stop pushing the **solvaholic/octodns-sync** container image to Docker hub.

## [2.0.0] - 2020-03-25

- Rename **octodns-action** to **octodns-sync**.
- Pull image from Docker hub public repo.
- Run time ~20s for small configuration.

## [1.1.0] - 2020-03-22

### Available on Docker hub

Use the prebuilt image from Docker hub in your workflow, for faster run times.

To see how, check out [_Example workflow_](https://github.com/solvaholic/octodns-action/tree/0b6e3b5b49a78bca8c6b6095fdf990fee0ecfe1d#example-workflow) in the README.

### Uses python:3-slim

I went back to -slim for a more familiar environment inside the Docker container.

### Ignores pip-extras

The prebuilt image includes all of **octodns**'s dependencies.

If these or any of the other changes in this release cause an issue for you, please [let me know](https://github.com/solvaholic/octodns-action/issues/new/choose).

## [1.0.6] - 2020-03-09

**Uses python:3-alpine rather than python:3-slim**

The python:3-alpine image is smaller, and shares more of its base with [the images cached for Linux runners](https://help.github.com/actions/reference/software-installed-on-github-hosted-runners). This change brought runtime for publishing a simple change down to 35 seconds. (v1.0.3 took 1min 10sec.)

If speed is very important, though, then just run [octodns-action.sh](https://github.com/solvaholic/octodns-action/blob/v1.0.6/octodns-action.sh) from your workflow - the runners have python and pip.

## [1.0.5] - 2020-03-07

Moves work from `Dockerfile` and `entrypoint.sh` to `octodns-action.sh`.

## [1.0.4] - 2020-03-07

Updated title in README; Added chmod to Dockerfile to ensure /entrypoint.sh will be executable.

## [1.0.3] - 2020-03-05

v1 provides basic functionality, passed limited manual testing with Route53.

`--doit` deployments with a small config and small change have been taking about 1min 10sec.

Have comments or questions? Please [open an issue](https://github.com/solvaholic/octodns-action/issues/new/choose).

## [1.0.0] - 2020-03-05

Initial realease. Local and workflow runs tested OK with a few record types in Route53.
