#!/bin/bash
# Run octodns-sync

_config_path=$CONFIG_PATH
_doit=$DOIT

# Run octodns-sync.
_logfile="${GITHUB_WORKSPACE}/octodns-sync.log"
_planfile="${GITHUB_WORKSPACE}/octodns-sync.plan"

echo "INFO: _config_path: ${_config_path}"
if [ "${_doit}" = "--doit" ]; then
  script "${_logfile}" -e -c \
  "octodns-sync --config-file=\"${_config_path}\" --doit \
  >>\"${_planfile}\""
else
  script "${_logfile}" -e -c \
  "octodns-sync --config-file=\"${_config_path}\" \
  >>\"${_planfile}\""
fi

# Exit 1 if octodns-sync exited non-zero.
if tail --lines=1 "$_logfile" | \
grep --quiet --fixed-strings --invert-match \
'[COMMAND_EXIT_CODE="0"]'; then
  echo "FAIL: octodns-sync exited with an error."
  exit 1
fi