#!/bin/bash
export PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin/btrfs_backup"

# The device name for the new encrypted file system.
# CAUTION: ALL DATA WILL BE DESTROYED
backup_device_path=$1

# The backup set the new backup file system belongs to.
backup_fs_set=$2

backup_device_uuid_list="/etc/btrfs_backup/backup_device_uuid_list.txt"
backup_device_password=`cat "/etc/btrfs_backup/backup_device_password.txt"`

if test "$#" -ne 2; then
    echo "Illegal number of parameters"
    exit 1
fi

# Ensure drives aren't already mounted.
umount_backup.sh

uuid=`uuidgen`
echo $uuid
if echo -n ${backup_device_password} | cryptsetup luksFormat ${backup_device_path} - --uuid=${uuid}; then
    echo Device encrypted successfully.
else
    echo Encryption failure, exiting.
    exit 1
fi

# Decrypt and format new backup file system.
echo ${backup_device_password} | cryptsetup luksOpen ${backup_device_path} ${uuid}
mkfs.btrfs -m dup "/dev/mapper/${uuid}"

# Mount new backup file system.
mkdir -p "/mnt/backup_filesystems/${uuid}"
mount "/dev/mapper/${uuid}" "/mnt/backup_filesystems/${uuid}"

# Ensure backup file system has encrypted drive uuid label.
echo ${uuid} > "/mnt/backup_filesystems/${uuid}/backup_uuid"

# Set backup set for new backup file system.
echo ${backup_fs_set} > "/mnt/backup_filesystems/${uuid}/backup_fs_set"

# Update backup uuid list.
echo ${uuid} >> ${backup_device_uuid_list}

# Unmount drives.
umount_backup.sh
