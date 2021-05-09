#!/bin/bash
# Install octodns and dependencies

_ver="$OCTODNS_REF"

if [[ "$_ver" = v* ]]; then
  # Assume input 'version' is an available release
  curl -O "https://raw.githubusercontent.com/octodns/octodns/$_ver/requirements.txt"
  pip install "octodns==${_ver#v}" -r requirements.txt
else
  # Assume input 'version' is a Git ref in octodns/octodns
  if git clone --single-branch --branch "$_ver" --no-tags \
  https://github.com/octodns/octodns.git octodns-src; then
    pip install ./octodns-src -r ./octodns-src/requirements.txt
  else
    exit 1
  fi
fi
