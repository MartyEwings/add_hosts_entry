#!/bin/sh

# Puppet Task Name: hosts_update_linux
#
# Learn more at: https://puppet.com/docs/bolt/0.x/writing_tasks.html#ariaid-title11
#

declare PT_m_ip
declare PT_m_host
m_host=$PT_m_host
m_ip=$PT_m_ip

echo "$m_ip  $m_host" >> /etc/hosts
