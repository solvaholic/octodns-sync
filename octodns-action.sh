#!/bin/sh -l

# Run octodns with your config.

# Requirements:
#   - $GITHUB_WORKSPACE contains a clone of the user's config repository.

# TODO:
#   - If $OVERRIDE_OCTODNS is set, $GITHUB_WORKSPACE/$OCTODNS_PATH contains a
#     runnable copy of octodns.

# Parse arguments.
CONFIG_PATH="${GITHUB_WORKSPACE}/$1"
PIP_EXTRAS="$2"
DOIT="$3"

# Activate virtualenv, if it's there.
if [ -f /env/bin/activate ]; then
  . /env/bin/activate
fi

# Change to config directory, so relative paths will work.
cd "$(dirname "${CONFIG_PATH}")"

# TODO: Implement octodns override, so user can run octodns from a fork.

# Get octodns, if it's not already there.
if ! git rev-parse --resolve-git-dir /octodns/.git 2>&1 >/dev/null; then
  git clone --branch v0.9.9 --depth 1 \
  https://github.com/github/octodns.git /octodns
fi

# Install /octodns and PIP_EXTRAS.
echo "PIP_EXTRAS: ${PIP_EXTRAS}"
pip3 install /octodns ${PIP_EXTRAS}

# Run octodns.
echo "CONFIG_PATH: ${CONFIG_PATH}"
if [ "${DOIT}" = "--doit" ]; then
  octodns-sync --config-file="${CONFIG_PATH}" --doit
else
  octodns-sync --config-file="${CONFIG_PATH}"
fi
