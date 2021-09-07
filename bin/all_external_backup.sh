#!/bin/bash
# Cron sometimes has the wrong path.
export PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin/btrfs_backup"

source_subvol_list="/etc/btrfs_backup/source_subvol_list.txt"

mount_backup.sh
for subvol in `cat $source_subvol_list`
do
    echo $subvol
    external_backup.sh $subvol
done
umount_backup.sh
