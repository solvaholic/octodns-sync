#!/bin/bash -l

# Run octodns-sync with your config.

# Requirements:
#   - /github/workspace contains a clone of the user's config repository.

# If GITHUB_WORKSPACE is set, prepend it to $1 for _config_path.
echo "INFO: GITHUB_WORKSPACE is '${GITHUB_WORKSPACE}'."
_config_path="${GITHUB_WORKSPACE%/}/${1:-public.yaml}"

_doit="${2}"

# Change to config directory, so relative paths will work.
cd "$(dirname "${_config_path}")" || echo "INFO: Cannot cd to $(dirname "${_config_path}")."

# Get octodns, if it's not already there.
# (This should only run during docker build.)
if ! git rev-parse --resolve-git-dir /octodns/.git >/dev/null 2>&1; then
  git clone --branch v0.9.9 --depth 1 \
  https://github.com/github/octodns.git /octodns
fi

# Install /octodns, if not already there.
# (This should only run during docker build.)
if ! command -v octodns-sync >/dev/null 2>&1; then
  pip3 install --upgrade pip
  pip3 install -r /octodns/requirements.txt
  pip3 install /octodns
fi

# Exit 0, if $_config_path is not readable.
# (This should only happen during docker build, or if misconfigured.)
if [ ! -r "${_config_path}" ]; then
  echo "INFO: Config '${_config_path}' is not readable. Exit 0."
  exit 0
fi

# Run octodns-sync.
echo "INFO: _config_path: ${_config_path}"
if [ "${_doit}" = "--doit" ]; then
  RESULT=$(octodns-sync --config-file="${_config_path}" --log-stream-stdout --doit)
else
  RESULT=$(octodns-sync --config-file="${_config_path}" --log-stream-stdout)
fi
echo "$RESULT"

# We want the result after a line starting with *
SHORT_RESULT=$(echo "$RESULT" | sed -ne "/\*/,$ p")

# We need to escape newlines or we only get first line of result
SHORT_RESULT="${SHORT_RESULT//'%'/'%25'}"
SHORT_RESULT="${SHORT_RESULT//$'\n'/'%0A'}"
SHORT_RESULT="${SHORT_RESULT//$'\r'/'%0D'}"

echo "::set-output name=result::$SHORT_RESULT"
