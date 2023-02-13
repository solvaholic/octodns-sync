#!/bin/bash
# Run octodns-sync

# Requires these, provided in action.yml:
# - CONFIG_PATH
# - DOIT

# shellcheck disable=SC2005,SC2086,SC2129

_config_path=$CONFIG_PATH
_doit=$DOIT
_force=$FORCE

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

if [ "${_force}" = "Yes" ]; then
  echo "INFO: Running octodns-sync in force-mode"
  _force="--force"
else
  _force=
fi

if ! octodns-sync --config-file="${_config_path}" ${_doit} ${_force} \
1>"${_planfile}" 2>"${_logfile}"; then
  echo "FAIL: octodns-sync exited with an error."
  echo "FAIL: Here are the contents of ${_logfile}:"
  cat "${_logfile}"
  exit 1
fi

# Acknowledge that the log output went away; Link to issue
echo "INFO: octodns-sync log output has been written to ${_logfile}"
echo "INFO: https://github.com/solvaholic/octodns-sync/issues/92"

# Set the plan and log outputs
echo 'log<<EOF' >> $GITHUB_OUTPUT
echo "$(cat "$_logfile")" >> $GITHUB_OUTPUT
echo 'EOF' >> $GITHUB_OUTPUT
echo 'plan<<EOF' >> $GITHUB_OUTPUT
echo "$(cat "$_planfile")" >> $GITHUB_OUTPUT
echo 'EOF' >> $GITHUB_OUTPUT
