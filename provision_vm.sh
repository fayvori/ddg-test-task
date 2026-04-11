#!/usr/bin/env bash
set -euo pipefail

DEBIAN_IMAGE="$1"
VM_NAME="$2"
VIRSH_NETWORK_NAME="$3"
BASE_IP="$4"
GATEWAY="$5"
TEMP_PUBLIC_KEY_LOCATION="$6"

BUILD_DIR="build"
IMAGES_DIR="$BUILD_DIR/images"
SEED_DIR="$BUILD_DIR/seed"
NET_DIR="$BUILD_DIR/network"
USERDATA_DIR="$BUILD_DIR/user-data"

# Ensure directories exist
mkdir -p "$IMAGES_DIR" "$SEED_DIR" "$NET_DIR" "$USERDATA_DIR"

# Avoiding gateway collision
VM_NUM=$(echo "$VM_NAME" | grep -o '[0-9]*$')
VM_IP="$BASE_IP.$((100 + VM_NUM))"

echo "Creating VM '$VM_NAME' with IP $VM_IP"

# Create cloud-init user-data
cat >"$USERDATA_DIR/$VM_NAME-user-data.yaml" <<EOF
#cloud-config
hostname: $VM_NAME

# Disable root login via ssh
disable_root: true

users:
  - name: debian
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    lock_passwd: true
    ssh_authorized_keys:
      - $(cat $TEMP_PUBLIC_KEY_LOCATION)

ssh_pwauth: false # Password authentication off
write_files:
  - path: /etc/ssh/sshd_config.d/99-hardening.conf
    content: |
      PasswordAuthentication no
      ChallengeResponseAuthentication no
      PermitRootLogin no
      PubkeyAuthentication yes
    permissions: '0644'

# Restart sshd daemon
runcmd:
  - systemctl restart sshd || systemctl restart ssh
EOF

# Create meta-data file (required for cloud-init to work)
cat >"$USERDATA_DIR/$VM_NAME-meta-data.yaml" <<EOF
instance-id: $VM_NAME
local-hostname: $VM_NAME
EOF

# Create cloud-init network config
cat >"$NET_DIR/$VM_NAME-network.yaml" <<EOF
version: 2
ethernets:
  enp1s0:
    dhcp4: false
    addresses:
      - $VM_IP/24
    gateway4: $GATEWAY
    nameservers:
      addresses: [8.8.8.8, 1.1.1.1]
EOF

# Create a seed file from all cloud-init configs
# This seed file will be used at Debian cloud image startup for initial configuration
cloud-localds "$SEED_DIR/$VM_NAME-seed.iso" \
  "$USERDATA_DIR/$VM_NAME-user-data.yaml" \
  --network-config "$NET_DIR/$VM_NAME-network.yaml" \
  "$USERDATA_DIR/$VM_NAME-meta-data.yaml"

# Create overlay disk image based on debian 13 image
qemu-img create -f qcow2 -F qcow2 -b "$(pwd)/$DEBIAN_IMAGE" "$IMAGES_DIR/$VM_NAME-disk.qcow2"

# Resize overlay disk to atleast 5Gb
qemu-img resize "$IMAGES_DIR/$VM_NAME-disk.qcow2" 5G

# Run the VM using virt-install
virt-install \
  --connect qemu:///system \
  --name "$VM_NAME" \
  --memory 2048 \
  --vcpus 1 \
  --disk path="$IMAGES_DIR/$VM_NAME-disk.qcow2",format=qcow2,bus=virtio \
  --disk path="$SEED_DIR/$VM_NAME-seed.iso",device=cdrom \
  --network network="$VIRSH_NETWORK_NAME",model=virtio \
  --graphics none \
  --boot uefi \
  --os-variant debian13 \
  --import \
  --noautoconsole \
  --console pty,target_type=serial
