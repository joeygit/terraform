terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc3"
    }
  }
}

provider "vault" {
  # Vault address and token
  address = "http://10.1.1.20:8200"  # Adjust this to your Vault server's address
  token   = "hvs.fTjF0fWnYC2Bu1ZDK8nKJkPg"         # Use a Vault token here, avoid hardcoding tokens in production
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