# Release checklist

TODO: Make this simpler and more reliable.

## Prerequisites

- [ ] Identify the release version, for example `2.2.1`
- [ ] Create a corresponding branch from `main`, for example `release-2.2.1`
- [ ] Push your branch

## Run [the _Create a release_ workflow](https://github.com/solvaholic/octodns-sync/actions) from your branch

Which will perform these tasks:

- [ ] Ensure the specified version has a section in CHANGELOG.md
- [ ] Create the draft release

## Finalize and publish [the release](https://github.com/solvaholic/octodns-sync/releases)

Which will push the release tag. If you'd like to publish this release to the marketplace, be sure to check that box.

## Clean up

- [ ] Delete any [branches](https://github.com/solvaholic/octodns-sync/branches) you're done with
