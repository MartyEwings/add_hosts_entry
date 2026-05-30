#!/usr/bin/env powershell

# Puppet Task: add_hosts_entry::hosts_update (PowerShell implementation)
#
# Appends an "<ip> <host>" entry to the hosts file on a Windows target.
# The operation is idempotent: an identical entry is only written once.

[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [String]
  $m_ip,

  [Parameter(Mandatory = $true)]
  [String]
  $m_host,

  [Parameter(Mandatory = $false)]
  [String]
  $hosts_file = "$env:windir\System32\drivers\etc\hosts"
)

$ErrorActionPreference = 'Stop'

$entry = "$m_ip $m_host"

$existing = @()
if (Test-Path -Path $hosts_file) {
  $existing = Get-Content -Path $hosts_file
}

# Idempotency: do nothing if the exact ip/host pair is already present.
$pattern = '^\s*' + [Regex]::Escape($m_ip) + '\s+' + [Regex]::Escape($m_host) + '(\s|$)'
if ($existing -match $pattern) {
  Write-Output "Entry '$entry' already present in $hosts_file, nothing to do"
  exit 0
}

Add-Content -Path $hosts_file -Value $entry
Write-Output "Added '$entry' to $hosts_file"
