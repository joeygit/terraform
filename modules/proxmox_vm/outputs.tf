output "vm_id" {
  value = proxmox_vm_qemu.vm[*].id
}

output "vm_ip" {
  value = proxmox_vm_qemu.vm[*].ipconfig0
}
