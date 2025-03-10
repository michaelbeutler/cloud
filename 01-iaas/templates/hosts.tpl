[proxmox_hosts]
%{ for address in proxmox_hosts ~}
${address}
%{ endfor ~}