#!/bin/bash
export PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin/btrfs_backup"

btrfs_filesystem_list="/etc/btrfs_backup/btrfs_filesystem_list.txt"
for filesystem in `cat $btrfs_filesystem_list`
do
    btrfs scrub start -B $filesystem >> /var/log/local_bitrot_check.log
done
