#!/bin/bash
export PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin/btrfs_backup"

backup_drive_list="/etc/btrfs_backup/backup_drive_list.txt"
backup_drive_password=`cat /etc/btrfs_backup/backup_drive_password.txt`

drive_found=0
for uuid in `cat $backup_drive_list`
do
    backup_drive_path="/dev/disk/by-uuid/${uuid}"
    if [[ -e ${backup_drive_path} ]]; then
        drive_found=1
        break
    fi
done

if [[ $drive_found == 0 ]]; then
    echo "Backup drive not present."
    exit 1
fi

echo $backup_drive_password | cryptsetup luksOpen $backup_drive_path backup
mount /dev/mapper/backup /mnt/backup
