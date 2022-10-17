#!/bin/bash
# Run octodns-sync

# Requires these, provided in action.yml:
# - CONFIG_PATH
# - DOIT

_config_path=$CONFIG_PATH
_doit=$DOIT

# Run octodns-sync.
_logfile="${GITHUB_WORKSPACE}/octodns-sync.log"
_planfile="${GITHUB_WORKSPACE}/octodns-sync.plan"

echo "INFO: Cleaning up plan and log files if they already exist"
rm -f "$_logfile"
rm -f "$_planfile"

echo "INFO: _config_path: ${_config_path}"
if [ ! "${_doit}" = "--doit" ]; then
  _doit=
fi

if ! octodns-sync --config-file="${_config_path}" "${_doit}" \
1>"${_planfile}" 2>"${_logfile}"; then
  echo "FAIL: octodns-sync exited with an error."
  echo "FAIL: Here are the contents of ${_logfile}:"
  cat "${_logfile}"
  exit 1
fi

# Acknowledge that the log output went away; Link to issue
echo "INFO: octodns-sync log output has been written to ${_logfile}"
echo "INFO: https://github.com/solvaholic/octodns-sync/issues/92"

# https://github.community/t/set-output-truncates-multiline-strings/16852/4
_plan="$(cat "$_planfile")"
_plan="${_plan//'%'/'%25'}"
_plan="${_plan//$'\n'/'%0A'}"
_plan="${_plan//$'\r'/'%0D'}"

# Output the plan file
echo "::set-output name=plan::${_plan}"
