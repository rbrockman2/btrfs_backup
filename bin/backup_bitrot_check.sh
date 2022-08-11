#!/bin/bash
export PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin/btrfs_backup"

backup_device_uuid_list="/etc/btrfs_backup/backup_device_uuid_list.txt"

# Check for lock.
if [[ -e "/run/backup.lock" ]]; then
    echo "Backup operation already in progress, aborting."
    exit 1
fi

# Create lock.
touch "/run/backup.lock"

mount_backup.sh

for uuid in `cat ${backup_device_uuid_list}`
do
    if [[ -e "/mnt/backup_filesystems/${uuid}/backup_fs_set" ]]; then
        btrfs scrub start -B "/mnt/backup_filesystems/${uuid}/" >> /var/log/backup_bitrot_check.log
    fi
done

umount_backup.sh

# Remove lock.
rm "/run/backup.lock"

