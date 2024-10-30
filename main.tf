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
resource "proxmox_vm_qemu" "kube-master" {
    provider = proxmox.node1
    name = "kube-master0${count.index + 1}"
    desc = "A test for using terraform and cloudinit"
    count = 1
    # Node name has to be the same name as within the cluster
    # this might not include the FQDN
    target_node = "pve2"

    # The destination resource pool for the new VM
    #pool = "pool0"

    # The template name to clone this vm from
    clone = "ubuntutemplate"

    # Activate QEMU agent for this VM
    agent = 1

    os_type = "cloud-init"
    cores = 4
    sockets = 1
    vcpus = 0
    cpu = "host"
    memory = 4096
    scsihw = "virtio-scsi-single"

    # Setup the disk
    disks {
        ide{
            ide0 {
                cloudinit {
                    storage = "local-lvm"
                }
            }
        }
        scsi {
            scsi1 {
                disk {
                    storage = "local-lvm"
                    size = 35
                }
            }
        }
    }

    # Setup the network interface and assign a vlan tag: 256
    network {
        model = "virtio"
        bridge = "vmbr0"
    }

    # Setup the ip address using cloud-init.
    boot = "order=scsi1"
    # Keep in mind to use the CIDR notation for the ip.
    ipconfig0 = "ip=10.1.1.2${count.index + 1}/24,gw=10.1.1.1"
    nameserver = "1.1.1.1"
    sshkeys = <<EOF
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDKpTAYU3Ucc6x9rRj82RdSc0Yw6/raETjEFz1KZbarqr95k9o8v725UxpOo7HfAXe1k2FYKutCf6pFk3hkmfhct1UHBYnrfXNn51FZNaBpZhyfVYrwaRNI5CmAADz7D3GzkHrSNO8AewWrGrflkpjBmfDBQF0lUMXwUfiH42LU444Jaeek2/KTE9EBmQRYPtEGj1w4cpONJ7MaI7ErQytr8t+dhvgZo2mTPiWIP1AsNiNr8nxgBMBC5XP6UsMntyU4KWJw4bp8xLPvtrsh7Yk2N9HhNwzp+6m61rz2OE+NhhS3n0kukduDnNSs7EgE2hfOKy3/HNwInm/mgbIdzN4/I+GTJB3O2kgKkvy1VWJBdfh29LNleE2uoUqygDp6XpUg+bV/OGpAQZYSwPZPa8rgVrPfdya0bUlHvCixL9qHYoVVfJvv9TIkBF7dyOlwEMcLT6IpvoRVjpfglLjBKhpsC5aiTQZpovR/kofqwXSrleJJowWz9zT45MZ6r6dJn6gTyp92lhrvxfyHHYWZoRQyGSlPfymeN9Xg7Hwb2ImpOn1bFaiuVUYgGtGI8CceSFGPfDDcVzVGs0Z97yFzXTWf6ng+ZgYttBia11T5E/3/a+NiHyb3Ijg6sV2dNVH38BiYbmmsmPY/5d2jVkh6JqddHd1PVu5j5nngHexwryJiTQ== jnielson@ansible
    EOF
    ciuser = "jnielson"
}

resource "proxmox_vm_qemu" "kube-worker" {
    provider = proxmox.node1
    name = "kube-worker0${count.index + 1}"
    desc = "kube worker - built using terraform"
    count = 2
    # Node name has to be the same name as within the cluster
    # this might not include the FQDN
    target_node = "pve2"

    # The destination resource pool for the new VM
    #pool = "pool0"

    # The template name to clone this vm from
    clone = "ubuntutemplate"

    # Activate QEMU agent for this VM
    agent = 1

    os_type = "cloud-init"
    cores = 2
    sockets = 1
    vcpus = 0
    cpu = "host"
    memory = 4096
    scsihw = "virtio-scsi-single"

    # Setup the disk
    disks {
        ide{
            ide0 {
                cloudinit {
                    storage = "local-lvm"
                }
            }
        }
        scsi {
            scsi1 {
                disk {
                    storage = "local-lvm"
                    size = 35
                }
            }
        }
    }

    # Setup the network interface and assign a vlan tag: 256
    network {
        model = "virtio"
        bridge = "vmbr0"
    }

    # Setup the ip address using cloud-init.
    boot = "order=scsi1"
    # Keep in mind to use the CIDR notation for the ip.
    ipconfig0 = "ip=10.1.1.3${count.index + 1}/24,gw=10.1.1.1"
    nameserver = "1.1.1.1"
    sshkeys = <<EOF
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDKpTAYU3Ucc6x9rRj82RdSc0Yw6/raETjEFz1KZbarqr95k9o8v725UxpOo7HfAXe1k2FYKutCf6pFk3hkmfhct1UHBYnrfXNn51FZNaBpZhyfVYrwaRNI5CmAADz7D3GzkHrSNO8AewWrGrflkpjBmfDBQF0lUMXwUfiH42LU444Jaeek2/KTE9EBmQRYPtEGj1w4cpONJ7MaI7ErQytr8t+dhvgZo2mTPiWIP1AsNiNr8nxgBMBC5XP6UsMntyU4KWJw4bp8xLPvtrsh7Yk2N9HhNwzp+6m61rz2OE+NhhS3n0kukduDnNSs7EgE2hfOKy3/HNwInm/mgbIdzN4/I+GTJB3O2kgKkvy1VWJBdfh29LNleE2uoUqygDp6XpUg+bV/OGpAQZYSwPZPa8rgVrPfdya0bUlHvCixL9qHYoVVfJvv9TIkBF7dyOlwEMcLT6IpvoRVjpfglLjBKhpsC5aiTQZpovR/kofqwXSrleJJowWz9zT45MZ6r6dJn6gTyp92lhrvxfyHHYWZoRQyGSlPfymeN9Xg7Hwb2ImpOn1bFaiuVUYgGtGI8CceSFGPfDDcVzVGs0Z97yFzXTWf6ng+ZgYttBia11T5E/3/a+NiHyb3Ijg6sV2dNVH38BiYbmmsmPY/5d2jVkh6JqddHd1PVu5j5nngHexwryJiTQ== jnielson@ansible
    EOF
    ciuser = "jnielson"
}

resource "proxmox_vm_qemu" "docker-host" {
    provider = proxmox.node2
    name = "docker-host0${count.index + 1}"
    desc = "docker host - built using terraform"
    count = 2
    # Node name has to be the same name as within the cluster
    # this might not include the FQDN
    target_node = "pve1"

    # The destination resource pool for the new VM
    #pool = "pool0"

    # The template name to clone this vm from
    clone = "UbuntucloudinitTemplate"

    # Activate QEMU agent for this VM
    agent = 1

    os_type = "cloud-init"
    cores = 2
    sockets = 1
    vcpus = 0
    cpu = "host"
    memory = 8096
    scsihw = "virtio-scsi-single"

    # Setup the disk
    disks {
        ide{
            ide0 {
                cloudinit {
                    storage = "nvme2"
                }
            }
        }
        scsi {
            scsi1 {
                disk {
                    storage = "nvme2"
                    size = 50
                }
            }
        }
    }

    # Setup the network interface and assign a vlan tag: 256
    network {
        model = "virtio"
        bridge = "vmbr0"
    }

    # Setup the ip address using cloud-init.
    boot = "order=scsi1"
    # Keep in mind to use the CIDR notation for the ip.
    ipconfig0 = "ip=10.1.1.4${count.index + 1}/24,gw=10.1.1.1"
    nameserver = "8.8.8.8"
    sshkeys = <<EOF
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDKpTAYU3Ucc6x9rRj82RdSc0Yw6/raETjEFz1KZbarqr95k9o8v725UxpOo7HfAXe1k2FYKutCf6pFk3hkmfhct1UHBYnrfXNn51FZNaBpZhyfVYrwaRNI5CmAADz7D3GzkHrSNO8AewWrGrflkpjBmfDBQF0lUMXwUfiH42LU444Jaeek2/KTE9EBmQRYPtEGj1w4cpONJ7MaI7ErQytr8t+dhvgZo2mTPiWIP1AsNiNr8nxgBMBC5XP6UsMntyU4KWJw4bp8xLPvtrsh7Yk2N9HhNwzp+6m61rz2OE+NhhS3n0kukduDnNSs7EgE2hfOKy3/HNwInm/mgbIdzN4/I+GTJB3O2kgKkvy1VWJBdfh29LNleE2uoUqygDp6XpUg+bV/OGpAQZYSwPZPa8rgVrPfdya0bUlHvCixL9qHYoVVfJvv9TIkBF7dyOlwEMcLT6IpvoRVjpfglLjBKhpsC5aiTQZpovR/kofqwXSrleJJowWz9zT45MZ6r6dJn6gTyp92lhrvxfyHHYWZoRQyGSlPfymeN9Xg7Hwb2ImpOn1bFaiuVUYgGtGI8CceSFGPfDDcVzVGs0Z97yFzXTWf6ng+ZgYttBia11T5E/3/a+NiHyb3Ijg6sV2dNVH38BiYbmmsmPY/5d2jVkh6JqddHd1PVu5j5nngHexwryJiTQ== jnielson@ansible
    EOF
    ciuser = "jnielson"
}


resource "proxmox_vm_qemu" "wordpress" {
    provider = proxmox.node2
    name = "wordpress0${count.index + 1}"
    desc = "wordpress instance"
    count = 1
    # Node name has to be the same name as within the cluster
    # this might not include the FQDN
    target_node = "pve1"

    # The destination resource pool for the new VM
    #pool = "pool0"

    # The template name to clone this vm from
    clone = "UbuntucloudinitTemplate"

    # Activate QEMU agent for this VM
    agent = 1

    os_type = "cloud-init"
    cores = 2
    sockets = 1
    vcpus = 0
    cpu = "host"
    memory = 4096
    scsihw = "virtio-scsi-single"

    # Setup the disk
    disks {
        ide{
            ide0 {
                cloudinit {
                    storage = "local-lvm"
                }
            }
        }
        scsi {
            scsi1 {
                disk {
                    storage = "local-lvm"
                    size = 35
                }
            }
        }
    }

    # Setup the network interface and assign a vlan tag: 256
    network {
        model = "virtio"
        bridge = "vmbr0"
    }

    # Setup the ip address using cloud-init.
    boot = "order=scsi1"
    # Keep in mind to use the CIDR notation for the ip.
    ipconfig0 = "ip=10.1.1.36/24,gw=10.1.1.1"
    nameserver = "10.1.1.4"
    sshkeys = <<EOF
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDKpTAYU3Ucc6x9rRj82RdSc0Yw6/raETjEFz1KZbarqr95k9o8v725UxpOo7HfAXe1k2FYKutCf6pFk3hkmfhct1UHBYnrfXNn51FZNaBpZhyfVYrwaRNI5CmAADz7D3GzkHrSNO8AewWrGrflkpjBmfDBQF0lUMXwUfiH42LU444Jaeek2/KTE9EBmQRYPtEGj1w4cpONJ7MaI7ErQytr8t+dhvgZo2mTPiWIP1AsNiNr8nxgBMBC5XP6UsMntyU4KWJw4bp8xLPvtrsh7Yk2N9HhNwzp+6m61rz2OE+NhhS3n0kukduDnNSs7EgE2hfOKy3/HNwInm/mgbIdzN4/I+GTJB3O2kgKkvy1VWJBdfh29LNleE2uoUqygDp6XpUg+bV/OGpAQZYSwPZPa8rgVrPfdya0bUlHvCixL9qHYoVVfJvv9TIkBF7dyOlwEMcLT6IpvoRVjpfglLjBKhpsC5aiTQZpovR/kofqwXSrleJJowWz9zT45MZ6r6dJn6gTyp92lhrvxfyHHYWZoRQyGSlPfymeN9Xg7Hwb2ImpOn1bFaiuVUYgGtGI8CceSFGPfDDcVzVGs0Z97yFzXTWf6ng+ZgYttBia11T5E/3/a+NiHyb3Ijg6sV2dNVH38BiYbmmsmPY/5d2jVkh6JqddHd1PVu5j5nngHexwryJiTQ== jnielson@ansible
    EOF
    ciuser = "jnielson"
}

resource "proxmox_vm_qemu" "docker-host2" {
    provider = proxmox.node1
    name = "docker-host02"
    desc = "docker host - built using terraform"
    count = 1
    # Node name has to be the same name as within the cluster
    # this might not include the FQDN
    target_node = "pve2"

    # The destination resource pool for the new VM
    #pool = "pool0"

    # The template name to clone this vm from
    clone = "ubuntutemplate"

    # Activate QEMU agent for this VM
    agent = 1

    os_type = "cloud-init"
    cores = 2
    sockets = 1
    vcpus = 0
    cpu = "host"
    memory = 8096
    scsihw = "virtio-scsi-single"

    # Setup the disk
    disks {
        ide{
            ide0 {
                cloudinit {
                    storage = "local-lvm"
                }
            }
        }
        scsi {
            scsi1 {
                disk {
                    storage = "local-lvm"
                    size = 50
                }
            }
        }
    }

    # Setup the network interface and assign a vlan tag: 256
    network {
        model = "virtio"
        bridge = "vmbr0"
    }

    # Setup the ip address using cloud-init.
    boot = "order=scsi1"
    # Keep in mind to use the CIDR notation for the ip.
    ipconfig0 = "ip=10.1.1.3/24,gw=10.1.1.1"
    nameserver = "8.8.8.8"
    sshkeys = <<EOF
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDKpTAYU3Ucc6x9rRj82RdSc0Yw6/raETjEFz1KZbarqr95k9o8v725UxpOo7HfAXe1k2FYKutCf6pFk3hkmfhct1UHBYnrfXNn51FZNaBpZhyfVYrwaRNI5CmAADz7D3GzkHrSNO8AewWrGrflkpjBmfDBQF0lUMXwUfiH42LU444Jaeek2/KTE9EBmQRYPtEGj1w4cpONJ7MaI7ErQytr8t+dhvgZo2mTPiWIP1AsNiNr8nxgBMBC5XP6UsMntyU4KWJw4bp8xLPvtrsh7Yk2N9HhNwzp+6m61rz2OE+NhhS3n0kukduDnNSs7EgE2hfOKy3/HNwInm/mgbIdzN4/I+GTJB3O2kgKkvy1VWJBdfh29LNleE2uoUqygDp6XpUg+bV/OGpAQZYSwPZPa8rgVrPfdya0bUlHvCixL9qHYoVVfJvv9TIkBF7dyOlwEMcLT6IpvoRVjpfglLjBKhpsC5aiTQZpovR/kofqwXSrleJJowWz9zT45MZ6r6dJn6gTyp92lhrvxfyHHYWZoRQyGSlPfymeN9Xg7Hwb2ImpOn1bFaiuVUYgGtGI8CceSFGPfDDcVzVGs0Z97yFzXTWf6ng+ZgYttBia11T5E/3/a+NiHyb3Ijg6sV2dNVH38BiYbmmsmPY/5d2jVkh6JqddHd1PVu5j5nngHexwryJiTQ== jnielson@ansible
    EOF
    ciuser = "jnielson"
}

resource "proxmox_vm_qemu" "sql-host01" {
    provider = proxmox.node1
    name = "sql-host01"
    desc = "sql-host01 - built using terraform"
    count = 1
    # Node name has to be the same name as within the cluster
    # this might not include the FQDN
    target_node = "pve2"

    # The destination resource pool for the new VM
    #pool = "pool0"

    # The template name to clone this vm from
    clone = "ubuntutemplate"

    # Activate QEMU agent for this VM
    agent = 1

    os_type = "cloud-init"
    cores = 4
    sockets = 1
    vcpus = 0
    cpu = "host"
    memory = 8096
    scsihw = "virtio-scsi-single"

    # Setup the disk
    disks {
        ide{
            ide0 {
                cloudinit {
                    storage = "local-lvm"
                }
            }
        }
        scsi {
            scsi1 {
                disk {
                    storage = "local-lvm"
                    size = 200
                }
            }
        }
    }

    # Setup the network interface and assign a vlan tag: 256
    network {
        model = "virtio"
        bridge = "vmbr0"
    }

    # Setup the ip address using cloud-init.
    boot = "order=scsi1"
    # Keep in mind to use the CIDR notation for the ip.
    ipconfig0 = "ip=10.1.1.71/24,gw=10.1.1.1"
    nameserver = "8.8.8.8"
    sshkeys = <<EOF
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDKpTAYU3Ucc6x9rRj82RdSc0Yw6/raETjEFz1KZbarqr95k9o8v725UxpOo7HfAXe1k2FYKutCf6pFk3hkmfhct1UHBYnrfXNn51FZNaBpZhyfVYrwaRNI5CmAADz7D3GzkHrSNO8AewWrGrflkpjBmfDBQF0lUMXwUfiH42LU444Jaeek2/KTE9EBmQRYPtEGj1w4cpONJ7MaI7ErQytr8t+dhvgZo2mTPiWIP1AsNiNr8nxgBMBC5XP6UsMntyU4KWJw4bp8xLPvtrsh7Yk2N9HhNwzp+6m61rz2OE+NhhS3n0kukduDnNSs7EgE2hfOKy3/HNwInm/mgbIdzN4/I+GTJB3O2kgKkvy1VWJBdfh29LNleE2uoUqygDp6XpUg+bV/OGpAQZYSwPZPa8rgVrPfdya0bUlHvCixL9qHYoVVfJvv9TIkBF7dyOlwEMcLT6IpvoRVjpfglLjBKhpsC5aiTQZpovR/kofqwXSrleJJowWz9zT45MZ6r6dJn6gTyp92lhrvxfyHHYWZoRQyGSlPfymeN9Xg7Hwb2ImpOn1bFaiuVUYgGtGI8CceSFGPfDDcVzVGs0Z97yFzXTWf6ng+ZgYttBia11T5E/3/a+NiHyb3Ijg6sV2dNVH38BiYbmmsmPY/5d2jVkh6JqddHd1PVu5j5nngHexwryJiTQ== jnielson@ansible
    EOF
    ciuser = "jnielson"
}

resource "proxmox_vm_qemu" "sql-host02" {
    provider = proxmox.node2
    name = "sql-host02"
    desc = "sql-host02 - built using terraform"
    count = 1
    # Node name has to be the same name as within the cluster
    # this might not include the FQDN
    target_node = "pve1"

    # The destination resource pool for the new VM
    #pool = "pool0"

    # The template name to clone this vm from
    clone = "UbuntucloudinitTemplate"

    # Activate QEMU agent for this VM
    agent = 1

    os_type = "cloud-init"
    cores = 4
    sockets = 1
    vcpus = 0
    cpu = "host"
    memory = 8096
    scsihw = "virtio-scsi-single"

    # Setup the disk
    disks {
        ide{
            ide0 {
                cloudinit {
                    storage = "local-lvm"
                }
            }
        }
        scsi {
            scsi1 {
                disk {
                    storage = "local-lvm"
                    size = 200
                }
            }
        }
    }

    # Setup the network interface and assign a vlan tag: 256
    network {
        model = "virtio"
        bridge = "vmbr0"
    }

    # Setup the ip address using cloud-init.
    boot = "order=scsi1"
    # Keep in mind to use the CIDR notation for the ip.
    ipconfig0 = "ip=10.1.1.72/24,gw=10.1.1.1"
    nameserver = "8.8.8.8"
    sshkeys = <<EOF
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDKpTAYU3Ucc6x9rRj82RdSc0Yw6/raETjEFz1KZbarqr95k9o8v725UxpOo7HfAXe1k2FYKutCf6pFk3hkmfhct1UHBYnrfXNn51FZNaBpZhyfVYrwaRNI5CmAADz7D3GzkHrSNO8AewWrGrflkpjBmfDBQF0lUMXwUfiH42LU444Jaeek2/KTE9EBmQRYPtEGj1w4cpONJ7MaI7ErQytr8t+dhvgZo2mTPiWIP1AsNiNr8nxgBMBC5XP6UsMntyU4KWJw4bp8xLPvtrsh7Yk2N9HhNwzp+6m61rz2OE+NhhS3n0kukduDnNSs7EgE2hfOKy3/HNwInm/mgbIdzN4/I+GTJB3O2kgKkvy1VWJBdfh29LNleE2uoUqygDp6XpUg+bV/OGpAQZYSwPZPa8rgVrPfdya0bUlHvCixL9qHYoVVfJvv9TIkBF7dyOlwEMcLT6IpvoRVjpfglLjBKhpsC5aiTQZpovR/kofqwXSrleJJowWz9zT45MZ6r6dJn6gTyp92lhrvxfyHHYWZoRQyGSlPfymeN9Xg7Hwb2ImpOn1bFaiuVUYgGtGI8CceSFGPfDDcVzVGs0Z97yFzXTWf6ng+ZgYttBia11T5E/3/a+NiHyb3Ijg6sV2dNVH38BiYbmmsmPY/5d2jVkh6JqddHd1PVu5j5nngHexwryJiTQ== jnielson@ansible
    EOF
    ciuser = "jnielson"
}

resource "proxmox_vm_qemu" "sql-quorum01" {
    provider = proxmox.node1
    name = "sql-quorum01"
    desc = "sql-quorum01 - built using terraform"
    count = 1
    # Node name has to be the same name as within the cluster
    # this might not include the FQDN
    target_node = "pve2"

    # The destination resource pool for the new VM
    #pool = "pool0"

    # The template name to clone this vm from
    clone = "ubuntutemplate"

    # Activate QEMU agent for this VM
    agent = 1

    os_type = "cloud-init"
    cores = 2
    sockets = 1
    vcpus = 0
    cpu = "host"
    memory = 4000
    scsihw = "virtio-scsi-single"

    # Setup the disk
    disks {
        ide{
            ide0 {
                cloudinit {
                    storage = "local-lvm"
                }
            }
        }
        scsi {
            scsi1 {
                disk {
                    storage = "local-lvm"
                    size = 40
                }
            }
        }
    }

    # Setup the network interface and assign a vlan tag: 256
    network {
        model = "virtio"
        bridge = "vmbr0"
    }

    # Setup the ip address using cloud-init.
    boot = "order=scsi1"
    # Keep in mind to use the CIDR notation for the ip.
    ipconfig0 = "ip=10.1.1.73/24,gw=10.1.1.1"
    nameserver = "8.8.8.8"
    sshkeys = <<EOF
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDKpTAYU3Ucc6x9rRj82RdSc0Yw6/raETjEFz1KZbarqr95k9o8v725UxpOo7HfAXe1k2FYKutCf6pFk3hkmfhct1UHBYnrfXNn51FZNaBpZhyfVYrwaRNI5CmAADz7D3GzkHrSNO8AewWrGrflkpjBmfDBQF0lUMXwUfiH42LU444Jaeek2/KTE9EBmQRYPtEGj1w4cpONJ7MaI7ErQytr8t+dhvgZo2mTPiWIP1AsNiNr8nxgBMBC5XP6UsMntyU4KWJw4bp8xLPvtrsh7Yk2N9HhNwzp+6m61rz2OE+NhhS3n0kukduDnNSs7EgE2hfOKy3/HNwInm/mgbIdzN4/I+GTJB3O2kgKkvy1VWJBdfh29LNleE2uoUqygDp6XpUg+bV/OGpAQZYSwPZPa8rgVrPfdya0bUlHvCixL9qHYoVVfJvv9TIkBF7dyOlwEMcLT6IpvoRVjpfglLjBKhpsC5aiTQZpovR/kofqwXSrleJJowWz9zT45MZ6r6dJn6gTyp92lhrvxfyHHYWZoRQyGSlPfymeN9Xg7Hwb2ImpOn1bFaiuVUYgGtGI8CceSFGPfDDcVzVGs0Z97yFzXTWf6ng+ZgYttBia11T5E/3/a+NiHyb3Ijg6sV2dNVH38BiYbmmsmPY/5d2jVkh6JqddHd1PVu5j5nngHexwryJiTQ== jnielson@ansible
    EOF
    ciuser = "jnielson"
}

resource "proxmox_vm_qemu" "sql-watch01" {
    provider = proxmox.node2
    name = "sql-watch01"
    desc = "sql-watch01 - built using terraform"
    count = 1
    # Node name has to be the same name as within the cluster
    # this might not include the FQDN
    target_node = "pve1"

    # The destination resource pool for the new VM
    #pool = "pool0"

    # The template name to clone this vm from
    clone = "UbuntucloudinitTemplate"

    # Activate QEMU agent for this VM
    agent = 1

    os_type = "cloud-init"
    cores = 2
    sockets = 1
    vcpus = 0
    cpu = "host"
    memory = 4000
    scsihw = "virtio-scsi-single"

    # Setup the disk
    disks {
        ide{
            ide0 {
                cloudinit {
                    storage = "local-lvm"
                }
            }
        }
        scsi {
            scsi1 {
                disk {
                    storage = "local-lvm"
                    size = 40
                }
            }
        }
    }

    # Setup the network interface and assign a vlan tag: 256
    network {
        model = "virtio"
        bridge = "vmbr0"
    }

    # Setup the ip address using cloud-init.
    boot = "order=scsi1"
    # Keep in mind to use the CIDR notation for the ip.
    ipconfig0 = "ip=10.1.1.73/24,gw=10.1.1.1"
    nameserver = "8.8.8.8"
    sshkeys = <<EOF
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDKpTAYU3Ucc6x9rRj82RdSc0Yw6/raETjEFz1KZbarqr95k9o8v725UxpOo7HfAXe1k2FYKutCf6pFk3hkmfhct1UHBYnrfXNn51FZNaBpZhyfVYrwaRNI5CmAADz7D3GzkHrSNO8AewWrGrflkpjBmfDBQF0lUMXwUfiH42LU444Jaeek2/KTE9EBmQRYPtEGj1w4cpONJ7MaI7ErQytr8t+dhvgZo2mTPiWIP1AsNiNr8nxgBMBC5XP6UsMntyU4KWJw4bp8xLPvtrsh7Yk2N9HhNwzp+6m61rz2OE+NhhS3n0kukduDnNSs7EgE2hfOKy3/HNwInm/mgbIdzN4/I+GTJB3O2kgKkvy1VWJBdfh29LNleE2uoUqygDp6XpUg+bV/OGpAQZYSwPZPa8rgVrPfdya0bUlHvCixL9qHYoVVfJvv9TIkBF7dyOlwEMcLT6IpvoRVjpfglLjBKhpsC5aiTQZpovR/kofqwXSrleJJowWz9zT45MZ6r6dJn6gTyp92lhrvxfyHHYWZoRQyGSlPfymeN9Xg7Hwb2ImpOn1bFaiuVUYgGtGI8CceSFGPfDDcVzVGs0Z97yFzXTWf6ng+ZgYttBia11T5E/3/a+NiHyb3Ijg6sV2dNVH38BiYbmmsmPY/5d2jVkh6JqddHd1PVu5j5nngHexwryJiTQ== jnielson@ansible
    EOF
    ciuser = "jnielson"
}