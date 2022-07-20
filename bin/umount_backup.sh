#!/bin/bash
export PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin/btrfs_backup"

backup_drive_list="/etc/btrfs_backup/backup_drive_list.txt"

umount /mnt/backup_filesystems/* 2>/dev/null
for uuid in `cat $backup_drive_list`
do
    cryptsetup luksClose ${uuid} 2>/dev/null
done
