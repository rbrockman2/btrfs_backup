#!/bin/bash
export PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin/btrfs_backup"

backup_device_uuid_list="/etc/btrfs_backup/backup_device_uuid_list.txt"

umount /mnt/backup_filesystems/* 2>/dev/null
for uuid in `cat ${backup_device_uuid_list}`
do
    cryptsetup luksClose ${uuid} 2>/dev/null
done
