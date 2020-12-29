# Release checklist

TODO: Make this simpler and more reliable.

## Prerequisites

- [ ] Identify the release version, for example `v2.1.2`
- [ ] All the changes you're shipping have been documented
- [ ] All the changes you're shipping have been merged to `main`

## Publish a release

- [ ] Push the Docker image with the desired release tag
- [ ] Create a branch named, for example, `release-2.1.2`
- [ ] Set the version in action.yml accordingly
- [ ] Push that change and let checks run
- [ ] Create and publish the release

## Clean up

- [ ] Delete any branches you're done with
