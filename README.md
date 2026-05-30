# add_hosts_entry

#### Table of Contents

1. [Description](#description)
2. [Compatibility](#compatibility)
3. [Use cases](#use-cases)
4. [Usage](#usage)
5. [Parameters](#parameters)
6. [Behaviour](#behaviour)
7. [Development](#development)

## Description

`add_hosts_entry` provides a cross-platform [Bolt](https://www.puppet.com/docs/bolt/latest/bolt.html)
task that adds an `<ip> <hostname>` entry to the hosts file of a remote node
(`/etc/hosts` on \*nix, `%windir%\System32\drivers\etc\hosts` on Windows).

It is most useful when you need a node to resolve a name *before* DNS is
available or correctly configured — classically, when bootstrapping a new
Puppet agent that cannot yet resolve the primary server's FQDN.

The task ships two implementations and Bolt selects the right one for the
target automatically:

* `hosts_update_linux.sh` — POSIX `sh` (runs under `dash` and `bash`)
* `hosts_update_powershell.ps1` — Windows PowerShell

## Compatibility

This module works with both **Puppet Enterprise (PE)** and **open source
Puppet (Puppet Core)**:

* **Puppet Enterprise** — run the task from the PE console (**Run > Task**) or
  with `puppet task run` on the primary server. Compatible with PE releases
  built on Puppet 7 and Puppet 8 (PE 2021.x through the latest LTS).
* **Puppet Core / Bolt** — run the task directly with `bolt task run`. Requires
  Bolt, or a Puppet agent 7.x/8.x.

Supported target operating systems include RHEL/CentOS/Rocky/AlmaLinux/Oracle
8 & 9, Debian 11 & 12, Ubuntu 20.04/22.04/24.04, SLES 15, Fedora, macOS, Solaris
11 and Windows 10/11 & Server 2019/2022. See `metadata.json` for the
authoritative list.

## Use cases

* **Bootstrapping agents without DNS** — add the primary server's IP and FQDN
  to a new node's hosts file before running `pe_bootstrap`, so the agent can
  reach the primary server to request its certificate.
* **Air-gapped / lab environments** — seed name resolution where no DNS
  infrastructure exists.
* **Pinning a name to a specific IP** — temporarily override resolution for a
  service during a migration or failover test.
* **Fixing split-horizon / partial DNS** — ensure an internal FQDN resolves to
  the correct internal address on selected nodes.

## Usage

### With Bolt (Puppet Core)

```shell
bolt task run add_hosts_entry::hosts_update \
  m_ip=10.10.10.1 m_host=master.puppet.com \
  --targets new_agent01 --run-as root
```

### With Puppet Enterprise

From the primary server:

```shell
puppet task run add_hosts_entry::hosts_update \
  m_ip=10.10.10.1 m_host=master.puppet.com \
  --nodes new_agent01
```

Or use **Run > Task** in the PE console, choose `add_hosts_entry::hosts_update`
and supply the parameters.

### Run before pe_bootstrap

A common pattern is to target your fresh nodes over SSH/WinRM inventory and add
the primary server entry first, then bootstrap:

```shell
bolt task run add_hosts_entry::hosts_update \
  m_ip=10.10.10.1 m_host=master.puppet.com --targets newnodes
bolt task run pe_bootstrap pe_server=master.puppet.com --targets newnodes
```

## Parameters

| Parameter    | Required | Description                                                                                                  |
|--------------|----------|--------------------------------------------------------------------------------------------------------------|
| `m_ip`       | yes      | IP address (IPv4 or IPv6) to add to the hosts file.                                                          |
| `m_host`     | yes      | Hostname / FQDN to associate with `m_ip`.                                                                    |
| `hosts_file` | no       | Path to the hosts file to update. Defaults to `/etc/hosts` (\*nix) or the Windows system hosts file.         |

With `m_ip = 10.10.10.1` and `m_host = master.puppet.com`, the following line is
added to the hosts file:

```
10.10.10.1 master.puppet.com
```

## Behaviour

* **Idempotent** — if the exact `<ip> <hostname>` pair is already present the
  task makes no change and reports that the entry already exists. Safe to re-run.
* **Validated input** — both `m_ip` and `m_host` are required and pattern-checked
  by the task metadata; the shell implementation also guards against missing
  values and unwritable hosts files, returning a structured Bolt error.
* **Privileges** — writing to the system hosts file requires root/Administrator.
  On \*nix, pass `--run-as root` (or run as a privileged user).

## Development

This module is managed with [PDK](https://www.puppet.com/docs/pdk/latest/pdk.html).

```shell
pdk validate          # metadata, syntax, lint, rubocop
pdk test unit         # rspec unit tests (spec/tasks)
shellcheck tasks/*.sh # static analysis of the shell implementation
```

Pull requests are automatically validated by GitHub Actions
(`.github/workflows/ci.yml`), which runs Puppet/Ruby linting, the unit tests,
ShellCheck and PSScriptAnalyzer.
