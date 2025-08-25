#!/bin/bash
# Put backup drives into standby when not in use to save power and drive wear.
export PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin/btrfs_backup"

backup_device_uuid_list="/etc/btrfs_backup/backup_device_uuid_list.txt"

for uuid in `cat ${backup_device_uuid_list}`
do
    if [[ -e "/dev/disk/by-uuid/${uuid}" ]]; then
        /sbin/hdparm -y "/dev/disk/by-uuid/${uuid}"
    fi
done

