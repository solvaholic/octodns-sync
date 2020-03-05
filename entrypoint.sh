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

# Change to config directory, so relative paths will work.
cd "$(dirname "${CONFIG_PATH}")"

# TODO: Implement octodns override, so user can run octodns from a fork.

# Activate virtualenv.
. /env/bin/activate

# Install PIP_EXTRAS.
echo "PIP_EXTRAS: ${PIP_EXTRAS}"
if [ -n "${PIP_EXTRAS}" ]; then pip install ${PIP_EXTRAS}; fi

# Run octodns.
echo "CONFIG_PATH: ${CONFIG_PATH}"
if [ "${DOIT}" = "--doit" ]; then
  octodns-sync --config-file="${CONFIG_PATH}" --doit
else
  octodns-sync --config-file="${CONFIG_PATH}"
fi
