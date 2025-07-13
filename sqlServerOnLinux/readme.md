# SQL Server on Linux Setup

## Prerequisites

- Ubuntu 22.04
- NVMe disks: `/dev/nvme1n1` (data), `/dev/nvme2n1` (backup)
- Root/sudo access

## 1. LVM Setup

### Run LVM Script

```bash
chmod +x lvm_script.sh
./lvm_script.sh
```

### What it does:

- Creates Physical Volumes (PVs) on NVMe disks
- Creates Volume Groups (VGs): `vg_db`, `vg_backup`
- Creates Logical Volumes (LVs): `lv_db`, `lv_backup`
- Formats with different filesystems:
  - Data: XFS (`/mnt/dbdata`)
  - Backup: EXT4 (`/mnt/dbbackup`)
- Mounts and adds to fstab

## 2. SQL Server Installation

### Run Installation Script

```bash
chmod +x sql_server.sh
./sql_server.sh
```

### Manual Setup

```bash
# Add Microsoft GPG key
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg

# Add repository
curl -fsSL https://packages.microsoft.com/config/ubuntu/22.04/mssql-server-2022.list | sudo tee /etc/apt/sources.list.d/mssql-server-2022.list

# Install SQL Server
sudo apt-get update
sudo apt-get install -y mssql-server

# Configure SQL Server
sudo /opt/mssql/bin/mssql-conf setup
# Choose: 1 (Developer) or 5 (Standard)
```

## 3. Folder Setup

### Run Folder Setup Script

```bash
chmod +x folder_setup.sh
./folder_setup.sh
```

### What it does:

- Creates SQL Server directories on LVM volumes
- Sets proper ownership (mssql:mssql)
- Configures SQL Server to use custom data/log directories
- Creates shared group `dbaccess` for file access
- Sets proper permissions (770 for dirs, 660 for files)

## Filesystem Differences

### XFS (Data Volume)

- **Performance**: Better for large files, high throughput
- **Online resizing**: Can only grow, not shrink
- **Journaling**: Metadata journaling for crash recovery
- **Use case**: Database data files

### EXT4 (Backup Volume)

- **Flexibility**: Can grow and shrink
- **Compatibility**: Widely supported
- **Journaling**: Full journaling
- **Use case**: Backup files, general storage

## Resizing Volumes

### Add New Disk

```bash
# Create PV on new disk
sudo pvcreate /dev/nvme3n1

# Extend VG
sudo vgextend vg_backup /dev/nvme3n1

# Resize LV
sudo lvresize -l +100%FREE /dev/vg_backup/lv_backup
```

### Resize Filesystem

**EXT4 (Backup)**:

```bash
sudo resize2fs /dev/vg_backup/lv_backup
```

**XFS (Data)**:

```bash
sudo xfs_growfs /mnt/dbdata
```

### Check Current Status

```bash
# View LVs
sudo lvs

# View VGs
sudo vgs

# View PVs
sudo pvs

# Check filesystem usage
df -h
```

## Verification

```bash
# Check SQL Server status
sudo systemctl status mssql-server

# Check mount points
mount | grep mssql

# Check permissions
ls -la /mnt/dbdata /mnt/dbbackup
```
