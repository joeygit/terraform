# Retrieve SSH public key from Vault
data "vault_generic_secret" "ssh_public_key" {
  path = "ssh/dev-ssh-key"
}
locals {
  dev_pub_key = data.vault_generic_secret.ssh_public_key.data["public_key"]
}
