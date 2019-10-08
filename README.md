
# add_hosts_entry

This Module Provides a Task that allows you to set hostfile entries in remote Windows and Linux Hosts.

This is Useful when adding nodes to Management In Puppet enterprise, that do not have DNS configured and can not resolve the Master FQDN.
This task can be run prior to the the task pe_bootstrap Via Bolt and targetted at SSH or WINRM inventory to add the master ip and fqdn to the local hosts file


#### Table of Contents

1. [Description](#description)

## Description

This Module Provides a Task that allows you to set hostfile entries in remote Windows and Linux Hosts.

This is Useful when adding nodes to Management In Puppet enterprise, that do not have DNS configured and can not resolve the Master FQDN.
This task can be run prior to the the task pe_bootstrap Via Bolt and targetted at SSH or WINRM inventory to add the master ip and fqdn to the local hosts file



### Beginning with add_hosts_entry

This Task has two mandatory parameters:


m_ip  - the Ipaddress you wish to add to the target hosts file

m_host - the FQDN associated with the ip in m_ip


In an example where m_ip  = 10.10.10.1 and m_host = master.puppet.com

the following would be printed on a new line in your hosts file:


"10.10.10.1 master.puppet.com"


