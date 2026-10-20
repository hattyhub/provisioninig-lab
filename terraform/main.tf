terraform {
  required_version = ">= 1.5.0"

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "= 0.8.1"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

# Base cloud image volume (uploaded once into libvirt storage pool)
resource "libvirt_volume" "ubuntu_cloud_image" {
  name   = "noble-server-cloudimg-amd64.img"
  pool   = "default"
  source = "/home/karthick/projects/provisioning-cicd/images/noble-server-cloudimg-amd64.img"
  format = "qcow2"
}

# Per-VM disk backed by the base image (copy-on-write)
resource "libvirt_volume" "sandbox_new_disk" {
  name           = "sandbox-new-disk.qcow2"
  pool           = "default"
  base_volume_id = libvirt_volume.ubuntu_cloud_image.id
  size           = 21474836480 # 20 GiB
}

# Cloud-init seed ISO
resource "libvirt_cloudinit_disk" "sandbox_new_seed" {
  name      = "sandbox-new-seed.iso"
  user_data = file("${path.module}/cloudinit/user-data")
  meta_data = file("${path.module}/cloudinit/meta-data")
}

# The actual VM
resource "libvirt_domain" "sandbox_new" {
  name   = "sandbox-new"
  memory = 2048
  vcpu   = 2

  disk {
    volume_id = libvirt_volume.sandbox_new_disk.id
  }

  # Attach cloud-init ISO as CDROM
  cloudinit = libvirt_cloudinit_disk.sandbox_new_seed.id

  network_interface {
    network_name = "default"
  }
}