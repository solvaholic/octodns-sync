#!/bin/sh -l

# Run octodns with your config.

# Requirements:
#   - $GITHUB_WORKSPACE contains a clone of the user's config repository. This
#     will default to /config.

# Parse arguments.
CONFIG_PATH="${GITHUB_WORKSPACE}/${1:-public.yaml}"
DOIT="${2}"

# Change to config directory, so relative paths will work.
cd "$(dirname "${CONFIG_PATH}")" || echo "INFO: Cannot cd to $(dirname "${CONFIG_PATH}")."

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
