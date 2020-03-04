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

# TODO: Implement octodns override, so user can run octodns from a fork.

# Activate virtualenv.
. /env/bin/activate

# Install PIP_EXTRAS.
echo "PIP_EXTRAS: ${PIP_EXTRAS}"
if [ -n "${PIP_EXTRAS}" ]; then pip install $2; fi

# Run octodns in test mode.
echo "CONFIG_PATH: ${CONFIG_PATH}"
octodns-sync --config-file=${CONFIG_PATH}
