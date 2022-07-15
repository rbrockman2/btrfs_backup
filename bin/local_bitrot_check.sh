#!/bin/bash
export PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin/btrfs_backup"

source_subvol_list="/etc/btrfs_backup/source_subvol_list.txt"
for subvol in `cat $source_subvol_list`
do
    btrfs scrub start -B $subvol > /var/log/local_bitrot_check.log
done
