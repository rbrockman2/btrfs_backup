#!/bin/bash
# Cron sometimes has the wrong path.
export PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin/btrfs_backup"

# Check for master lock.
if [[ -e "/run/backup.lock" ]]; then
    echo "Backup already in progress, aborting."
    exit 1
fi

# Create master lock.
touch "/run/backup.lock"

target_subvol_list="/etc/btrfs_backup/source_subvol_list.txt"

mount_backup.sh
for subvol in `cat ${target_subvol_list}`
do
    external_restore.sh ${subvol}
done

umount_backup.sh

# Remove locks.
rm "/run/backup.lock"
