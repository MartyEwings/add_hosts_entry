# Changelog

All notable changes to this project will be documented in this file.

## Release 1.0.0

**Features**

* Modernised the module with PDK 3.4 (latest pdk-templates).
* Declared support for Puppet 7 and 8, covering current Puppet Enterprise and
  Puppet Core releases.
* Refreshed `operatingsystem_support` to modern OSes (RHEL/Rocky/Alma 8 & 9,
  Debian 11/12, Ubuntu 20.04–24.04, SLES 15, Windows 10/11 & Server 2019/2022,
  etc).
* Added an optional `hosts_file` task parameter and pattern validation for
  `m_ip` / `m_host`.
* Added rspec unit tests for the task metadata and the shell implementation.
* Added a GitHub Actions workflow that runs linting, unit tests, ShellCheck and
  PSScriptAnalyzer on pull requests.

**Bugfixes**

* Rewrote `hosts_update_linux.sh` as POSIX `sh` (removed the `declare` bashism)
  so it runs under `dash` on modern Debian/Ubuntu. Both implementations are now
  idempotent and fail cleanly with structured Bolt errors on bad input.

**Known Issues**

This release uses cross-platform task metadata; older Bolt task runners and PE
older than 2019.0.0 are not compatible.

## Release 0.1.1

Removed stray JSON file affecting powershell


## Release 0.1.0

**Features**

**Bugfixes**

**Known Issues**

This release only uses cross platform task metadata, this means older bolt task runners, or that in PE less that 2019.0.0 are not compatible


