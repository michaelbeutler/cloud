[proxmox_hosts]
%{ for host in proxmox_hosts ~}
${host.hostname} ansible_host=${host.ip} ansible_user=michaelbeutler local_ip=${host.local_ip} nat_subnet=10.0.0.0/16
%{ endfor ~}

[proxmox_master]
node01
