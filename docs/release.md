# Release checklist

TODO: Make this simpler and more reliable.

## Prerequisites

- [ ] Identify the release version, for example `v2.1.2`

## Run [the _Create a release_ workflow](https://github.com/solvaholic/octodns-sync/actions)

Which will preform these tasks:

- [ ] Ensure the specified version has a section in CHANGELOG.md
- [ ] Check out a branch named, for example, `release-2.1.2`
- [ ] Set the Docker image version in action.yml
- [ ] Commit and push changes
- [ ] Create the draft release

## Finalize and publish [the release](https://github.com/solvaholic/octodns-sync/releases)

Which will push a tag and trigger [the build, push, and test workflow](https://github.com/solvaholic/octodns-sync/actions?query=workflow%3A%22Build%2C+push%2C+and+test+container%22). That workflow will:

- [ ] Push the Docker image with the desired release tag

## Clean up

- [ ] Delete any [branches](https://github.com/solvaholic/octodns-sync/branches) you're done with
- [ ] Delete any [untagged container images](https://github.com/users/solvaholic/packages/container/octodns-sync/versions?filters%5Bversion_type%5D=untagged)