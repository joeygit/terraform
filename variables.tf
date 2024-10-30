# Retrieve SSH public key from Vault
data "vault_generic_secret" "ssh_public_key" {
  path = "ssh/vm-ssh-key"
}
locals {
  vm-ssh-key = data.vault_generic_secret.ssh_public_key.data["public_key"]
}
