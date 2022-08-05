#!/bin/bash
export PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin/btrfs_backup"

backup_device_uuid_list="/etc/btrfs_backup/backup_device_uuid_list.txt"
backup_device_password=`cat "/etc/btrfs_backup/backup_device_password.txt"`

# Ensure drives aren't already mounted.
umount_backup.sh

for uuid in `cat ${backup_device_uuid_list}`
do
    backup_device_path="/dev/disk/by-uuid/${uuid}"
    if [[ -e ${backup_device_path} ]]; then
        echo ${backup_device_password} | cryptsetup luksOpen ${backup_device_path} ${uuid}
        mkdir -p "/mnt/backup_filesystems/${uuid}"
        mount "/dev/mapper/${uuid}" "/mnt/backup_filesystems/${uuid}"
        if [[ -e "/mnt/backup_filesystems/${uuid}/backup_fs_set" ]]; then
            backup_fs_set=`cat "/mnt/backup_filesystems/${uuid}/backup_fs_set"`
            mkdir -p "/mnt/backup_filesystems/${backup_fs_set}"
            mount --bind "/mnt/backup_filesystems/${uuid}" "/mnt/backup_filesystems/${backup_fs_set}"

            # Ensure backup file system has encrypted drive uuid label.
            echo ${uuid} > "/mnt/backup_filesystems/${uuid}/backup_uuid"
        fi
    fi
done
