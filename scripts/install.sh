#!/bin/bash
# Install octodns and dependencies

# Exit early if octodns is already installed
if command -v octodns-sync; then
  # Hello reader!
  # This works as a cheap, relatively safe way to respond to #57
  # If you'd like to improve it, please raise an issue or PR
  echo "FAIL: It looks like octodns is already installed."
  exit 1
fi

# Set some variables
_ver="$OCTODNS_REF"
_src="$(mktemp -d)"
_api="repos/octodns/octodns/git/matching-refs"
_via=""

# Authenticate gh
echo "${GITHUB_TOKEN}" | gh auth login --with-token

# Is _ver a valid pip version or Git ref?
if pip download -q "octodns==${_ver#v}"; then
  # _ver is a PyPI version
  _via=pip
elif gh api --silent "${_api}/tags/${_ver}"; then
  # _ver is a tag in octodns/octodns
  _via=git
elif gh api --silent "${_api}/heads/${_ver}"; then
  # _ver is a branch in octodns/octodns
  _via=git
else
  # _ver is not a branch, tag, or PyPI version
  echo "FAIL: Didn't find an octodns version '${_ver}'."
  exit 1
fi

# Install octodns
if [ "${_via}" = "pip" ]; then
  # Use pip to install octodns
  _req="https://raw.githubusercontent.com/octodns/octodns/v${_ver#v}/requirements.txt"
  if curl --output "${_src}/requirements.txt" "${_req}"; then
    pip install "octodns==${_ver#v}" -r "${_src}/requirements.txt"
  else
    echo "FAIL: Error downloading requirements.txt."
  fi
elif [ "${_via}" = "git" ]; then
  # Use Git and then pip to install octodns
  if git clone --single-branch --branch "${_ver}" --no-tags \
    https://github.com/octodns/octodns.git "${_src}"; then
    pip install "${_src}" -r "${_src}/requirements.txt"
  else
    echo "FAIL: Error cloning octodns/octodns."
    exit 1
  fi
else
  echo "FAIL: How did this happen?"
  exit 1
fi
