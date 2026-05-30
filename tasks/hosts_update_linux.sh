#!/bin/sh

# Puppet Task: add_hosts_entry::hosts_update (POSIX shell implementation)
#
# Appends an "<ip> <host>" entry to the hosts file on a *nix target.
# The operation is idempotent: an identical entry is only written once.
#
# Bolt passes task parameters as PT_<name> environment variables. This script
# is intentionally POSIX sh (no bashisms such as `declare`) so it runs under
# dash on modern Debian/Ubuntu as well as bash on EL/SLES/macOS.
#
# Learn more at: https://www.puppet.com/docs/bolt/latest/writing_tasks.html

set -eu

ip="${PT_m_ip:-}"
host="${PT_m_host:-}"
hosts_file="${PT_hosts_file:-/etc/hosts}"

# Emit a structured Bolt error and exit non-zero.
fail() {
  echo "{ \"_error\": { \"kind\": \"add_hosts_entry/error\", \"msg\": \"$1\" } }"
  exit 1
}

[ -n "$ip" ] || fail "Parameter 'm_ip' is required"
[ -n "$host" ] || fail "Parameter 'm_host' is required"

entry="$ip $host"

# Idempotency: do nothing if the exact ip/host pair is already present.
if grep -qE "^[[:space:]]*${ip}[[:space:]]+${host}([[:space:]]|\$)" "$hosts_file" 2>/dev/null; then
  echo "Entry '${entry}' already present in ${hosts_file}, nothing to do"
  exit 0
fi

if [ ! -w "$hosts_file" ]; then
  fail "Cannot write to ${hosts_file} (the task must run with root privileges)"
fi

printf '%s\n' "$entry" >> "$hosts_file"
echo "Added '${entry}' to ${hosts_file}"
