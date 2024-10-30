terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc3"
    }
  }
}

resource "proxmox_vm_qemu" "vm" {
  name          = var.vm_name
  desc          = var.vm_description
  count         = var.vm_count
  target_node   = var.target_node
  clone         = var.template
  agent         = var.agent
  os_type       = var.os_type
  cores         = var.cores
  sockets       = var.sockets
  memory        = var.memory
  scsihw        = var.scsihw
  boot          = var.boot_order
  ipconfig0     = var.ipconfig0
  nameserver    = var.nameserver
  ciuser        = var.ciuser

  disks {
        ide{
            ide0 {
                cloudinit {
                    storage = var.storage
                }
            }
        }
        scsi {
            scsi1 {
                disk {
                    storage = var.storage
                    size = var.disk_size
                }
            }
        }
    }
  
  network {
    model   = var.network_model
    bridge  = var.network_bridge
  }
}

