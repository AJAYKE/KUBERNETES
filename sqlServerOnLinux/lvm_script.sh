#!/bin/bash

set -e

# Input Devices
DB_DISK="/dev/nvme1n1"
BACKUP_DISK="/dev/nvme2n1"

# Volume Groups and Logical Volumes
VG_DB="vg_db"
LV_DB="lv_db"
MOUNT_DB="/mnt/dbdata"

VG_BK="vg_backup"
LV_BK="lv_backup"
MOUNT_BK="/mnt/dbbackup"

# Install LVM2
echo "Installing LVM..."
sudo apt update && sudo apt install -y lvm2 xfsprogs

# Create PVs
sudo pvcreate $DB_DISK
sudo pvcreate $BACKUP_DISK

# Create VGs
sudo vgcreate $VG_DB $DB_DISK
sudo vgcreate $VG_BK $BACKUP_DISK

# Create LVs
sudo lvcreate -l 100%FREE -n $LV_DB $VG_DB
sudo lvcreate -l 100%FREE -n $LV_BK $VG_BK

# Format LVs
sudo mkfs.xfs /dev/$VG_DB/$LV_DB
sudo mkfs.ext4 /dev/$VG_BK/$LV_BK

# Mount Points
sudo mkdir -p $MOUNT_DB
sudo mkdir -p $MOUNT_BK

# Mount volumes
sudo mount /dev/$VG_DB/$LV_DB $MOUNT_DB
sudo mount /dev/$VG_BK/$LV_BK $MOUNT_BK

# Persist in fstab
echo "/dev/$VG_DB/$LV_DB $MOUNT_DB xfs defaults 0 0" | sudo tee -a /etc/fstab
echo "/dev/$VG_BK/$LV_BK $MOUNT_BK ext4 defaults 0 0" | sudo tee -a /etc/fstab

echo ":white_check_mark: LVM setup complete."

# Resizing logic

# sudo lvs
sudo pvresize /dev/nvme3n1
sudo lvresize -l +100%FREE /dev/vg_backup/lv_backup

ext4: sudo resize2fs /dev/vg_backup/lv_backup
xfs: sudo xfs_growfs /mnt/dbdata
