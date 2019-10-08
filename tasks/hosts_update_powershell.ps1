#!/usr/bin/env powershell

[CmdletBinding()]
param(
  # NOTE: init.json cannot yet be shared, so must have windows.json / windows.ps1
  [Parameter(Mandatory = $true)]
  [String]
  $m_ip,

  [Parameter(Mandatory = $true)]
  [String]
  $m_host
)

# Puppet Task Name: add_host

 "$m_ip $m_host" | Add-Content -PassThru $env:windir\System32\drivers\etc\hosts
