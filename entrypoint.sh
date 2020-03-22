#!/bin/sh -l

# Run octodns with your config.

# Requirements:
#   - /github/workspace contains a clone of the user's config repository.

# If GITHUB_WORKSPACE is set, assume repository root is /github/workspace.
CONFIG_PATH="${GITHUB_WORKSPACE:+/github/workspace}/${1:-public.yaml}"

DOIT="${2}"

# Change to config directory, so relative paths will work.
cd "$(dirname "${CONFIG_PATH}")" || echo "INFO: Cannot cd to $(dirname "${CONFIG_PATH}")."

# If $CONFIG_PATH is not in a Git repository, fail.
if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
  echo "FAIL: Did not find your config repository."
  exit 1
fi

# Get octodns, if it's not already there.
if ! git rev-parse --resolve-git-dir /octodns/.git >/dev/null 2>&1; then
  git clone --branch v0.9.9 --depth 1 \
  https://github.com/github/octodns.git /octodns
fi

# Install /octodns, if not already there.
if ! command -v octodns-sync >/dev/null 2>&1; then
  pip3 install --upgrade pip
  pip3 install -r /octodns/requirements.txt
  pip3 install /octodns
fi

# Exit 0, if $CONFIG_PATH is not readable.
if [ ! -r "${CONFIG_PATH}" ]; then
  echo "INFO: Config '${CONFIG_PATH}' is not readable. Exit 0."
  exit 0
fi

# Run octodns.
echo "CONFIG_PATH: ${CONFIG_PATH}"
if [ "${DOIT}" = "--doit" ]; then
  octodns-sync --config-file="${CONFIG_PATH}" --doit
else
  octodns-sync --config-file="${CONFIG_PATH}"
fi
