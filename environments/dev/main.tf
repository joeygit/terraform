terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc3"
    }
  }
}
provider "proxmox" {
    alias = "node2"
    pm_tls_insecure = true
    pm_api_url = "https://10.1.1.6:8006/api2/json"
    pm_password = "formterra2024"
    pm_user = "terraform@pve"
    pm_otp = ""
}

provider "proxmox" {
    alias = "node1"
    pm_tls_insecure = true
    pm_api_url = "https://10.1.1.5:8006/api2/json"
    pm_password = "formterra2024"
    pm_user = "terraform@pve"
    pm_otp = ""
}
provider "vault" {
  # Vault address and token
  address = env("VAULT_ADDR")  # Adjust this to your Vault server's address
  token   = env("VAULT_TOKEN")         # Use a Vault token here, avoid hardcoding tokens in production
}
module "dev-docker01" {
  source           = "../../modules/proxmox_vm"
  vm_name          = "dev-docker01"
  vm_description   = "Dev environment VM"
  vm_count         = 1
  target_node      = "pve2"
  template         = "ubuntutemplate"
  agent            = 1
  os_type          = "cloud-init"
  cores            = 4
  sockets          = 1
  memory           = 6272
  scsihw           = "virtio-scsi-single"
  boot_order       = "order=scsi1"
  ipconfig0        = "ip=10.1.1.23/24,gw=10.1.1.1"
  nameserver       = "1.1.1.1"
  ciuser           = "jnielson"
  ssh_pub_key      = local.dev_pub_key
  storage          = "local-lvm"
  disk_size        = 35
  network_model    = "virtio"
  network_bridge   = "vmbr0"
  providers = {
    proxmox = proxmox.node1
  }
}

module "dev-pg01" {
  source           = "../../modules/proxmox_vm"
  vm_name          = "dev-pg01"
  vm_description   = "Dev postgresql node 01"
  vm_count         = 1
  target_node      = "pve1"
  template         = "ubuntutemplate"
  agent            = 1
  os_type          = "cloud-init"
  cores            = 4
  sockets          = 1
  memory           = 4096
  scsihw           = "virtio-scsi-single"
  boot_order       = "order=scsi1"
  ipconfig0        = "ip=10.1.1.43/24,gw=10.1.1.1"
  nameserver       = "1.1.1.1"
  ciuser           = "jnielson"
  ssh_pub_key      = local.dev_pub_key
  storage          = "local-lvm"
  disk_size        = 35
  network_model    = "virtio"
  network_bridge   = "vmbr0"
  providers = {
    proxmox = proxmox.node1
  }
}

module "dev-pg02" {
  source           = "../../modules/proxmox_vm"
  vm_name          = "dev-pg02"
  vm_description   = "Dev postgresql node 02"
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
  ipconfig0        = "ip=10.1.1.44/24,gw=10.1.1.1"
  nameserver       = "1.1.1.1"
  ciuser           = "jnielson"
  ssh_pub_key      = local.dev_pub_key
  storage          = "local-lvm"
  disk_size        = 35
  network_model    = "virtio"
  network_bridge   = "vmbr0"
  providers = {
    proxmox = proxmox.node2
  }
}