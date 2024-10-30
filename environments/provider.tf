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
variable "VAULT_ADDR" {
  type = string
}

variable "VAULT_TOKEN" {
  type = string
}
provider "vault" {
  # Vault address and token
  address = var.VAULT_ADDR  # Adjust this to your Vault server's address
  token   = var.VAULT_TOKEN         # Use a Vault token here, avoid hardcoding tokens in production
}