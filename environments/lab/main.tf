terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc3"
    }
  }
}
variable "PM_PW" {
  type = string
}

variable "PM_USER" {
  type = string
}
provider "proxmox" {
    alias = "node2"
    pm_tls_insecure = true
    pm_api_url = "https://10.1.1.6:8006/api2/json"
    pm_password = var.PM_PW
    pm_user = var.PM_USER
    pm_otp = ""
}

provider "proxmox" {
    alias = "node1"
    pm_tls_insecure = true
    pm_api_url = "https://10.1.1.5:8006/api2/json"
    pm_password = var.PM_PW
    pm_user = var.PM_USER
    pm_otp = ""
}
provider "vault" {
  # Vault address and token
  address = "http://10.1.1.20:8200"  # Adjust this to your Vault server's address
  token   = "hvs.fTjF0fWnYC2Bu1ZDK8nKJkPg"         # Use a Vault token here, avoid hardcoding tokens in production
}
module "kube-master" {
  source           = "../../modules/proxmox_vm"
  vm_name          = "kube-master01"
  vm_description   = "Lab environment VM"
  vm_count         = 1
  target_node      = "pve2"
  template         = "ubuntutemplate"
  agent            = 1
  os_type          = "cloud-init"
  cores            = 4
  sockets          = 1
  memory           = 4096
  scsihw           = "virtio-scsi-single"
  boot_order       = "order=scsi1"
  ipconfig0        = "ip=10.1.1.21/24,gw=10.1.1.1"
  nameserver       = "1.1.1.1"
  ciuser           = "jnielson"
  ssh_pub_key      = local.ssh_pub_key
  storage          = "local-lvm"
  disk_size        = 35
  network_model    = "virtio"
  network_bridge   = "vmbr0"
  providers = {
    proxmox = proxmox.node1
  }
}





