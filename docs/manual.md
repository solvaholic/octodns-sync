# Manual instructions

Manual instructions for **solvaholic/octodns-sync** maintenance tasks

## Lint files

Running `make lint` in your clone should get **github/super-linter** and run its linters for this repository.

In case you'd prefer to run the commands directly, here they are:

```bash
# cd into your clone of this repository
cd ~/repos/octodns-sync

# Run yamllint to lint the YAML
yamllint --no-warnings ./

# Run shellcheck to lint the bash
shellcheck ./scripts/*.sh
```

## Create a release

If automations are available, follow the [release checklist](release.md). The instructions here are for manually creating a release.

1. Identify the release version, for example `2.2.1`
1. Create a corresponding branch from `main`, for example `release-2.2.1`
1. Ensure the specified version has a section in [CHANGELOG.md](CHANGELOG.md)
1. Make any required changes to [CHANGELOG.md](CHANGELOG.md) and [README.md](../README.md)

    _Note: If you make changes you want to backport to the default branch, either copy changes manually or cherry-pick commits._

1. Push your branch
1. Create the draft release:

    https://github.com/solvaholic/octodns-sync/releases/new

    For the tag name prepend a "v" to the release version, for example `v2.2.1`. For the target specify your branch.

1. Fill in the release title and notes. Follow style from previous release. The content should match the relevant section of [CHANGELOG.md](CHANGELOG.md).
1. After you're pretty sure everything is ready, finalize and publish the release. If you'd like to publish this release to the marketplace, be sure to check that box.
1. Update the major and minor version tags to point to the same commit as the new release. For example:

    ```bash
    # cd into your clone and checkout your branch
    cd ~/repos/octodns-sync
    git checkout release-2.2.1
    # Set up variables.
    TAG="v2.2.1"                # v2.2.1
    MINOR="${TAG%.*}"           # v2.2
    MAJOR="${MINOR%.*}"         # v2
    MESSAGE="Release ${TAG}"
    # Update MAJOR/MINOR tag
    git tag -fa "${MAJOR}" -m "${MESSAGE}"
    git tag -fa "${MINOR}" -m "${MESSAGE}"
    # Push MAJOR/MINOR tag
    git push --force origin "${MINOR}"
    git push --force origin "${MAJOR}"
    ```

## Rolling back a release

1. Unpublish the release:

    https://github.com/solvaholic/octodns-sync/releases

1. Correct the major and minor version tags. For example, if you're rolling back from 2.2.1 to 2.2.0:

    ```bash
    # cd into your clone and checkout v2.2.0
    cd ~/repos/octodns-sync
    git checkout v2.2.0
    # Set up variables.
    TAG="v2.2.0"                # v2.2.0
    MINOR="${TAG%.*}"           # v2.2
    MAJOR="${MINOR%.*}"         # v2
    MESSAGE="Release ${TAG}"
    # Update MAJOR/MINOR tag
    git tag -fa "${MAJOR}" -m "${MESSAGE}"
    git tag -fa "${MINOR}" -m "${MESSAGE}"
    # Push MAJOR/MINOR tag
    git push --force origin "${MINOR}"
    git push --force origin "${MAJOR}"
    ```

1. Remove the version tag you rolled back from. For example:

1. Unless the release is dangerous somehow, consider leaving it unpublished and calling out known issues in the release notes.

    If you're sure you want to remove the release, delete it [in the web UI](https://github.com/solvaholic/octodns-sync/releases) and delete its tag:

    ```bash
    TAG="v2.2.0"
    git tag -d ${TAG}
    git push origin :${TAG}
    ```
