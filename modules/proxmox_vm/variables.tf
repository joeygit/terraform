variable "vm_name" {
  description = "Name of the VM"
  type        = string
}

variable "vm_description" {
  description = "Description of the VM"
  type        = string
}

variable "vm_count" {
  description = "Number of VMs to create"
  type        = number
}

variable "target_node" {
  description = "Target node for the VM"
  type        = string
}

variable "template" {
  description = "Template to clone the VM from"
  type        = string
}

variable "agent" {
  description = "Activate QEMU agent"
  type        = number
}

variable "os_type" {
  description = "Operating system type"
  type        = string
}

variable "cores" {
  description = "Number of CPU cores"
  type        = number
}

variable "sockets" {
  description = "Number of CPU sockets"
  type        = number
}

variable "memory" {
  description = "Memory for the VM in MB"
  type        = number
}

variable "scsihw" {
  description = "SCSI hardware type"
  type        = string
}

variable "boot_order" {
  description = "Boot order for the VM"
  type        = string
}

variable "ipconfig0" {
  description = "IP configuration for the VM"
  type        = string
}

variable "nameserver" {
  description = "Nameserver for the VM"
  type        = string
}

variable "ciuser" {
  description = "Cloud-init user"
  type        = string
}

variable "ssh_pub_key" {
  description = "SSH public keys for cloud-init"
  type        = string
}

variable "storage" {
  description = "Storage for the disk"
  type        = string
}

variable "disk_size" {
  description = "Size of the disk"
  type        = number
}

variable "network_model" {
  description = "Network model"
  type        = string
}

variable "network_bridge" {
  description = "Network bridge"
  type        = string
}
