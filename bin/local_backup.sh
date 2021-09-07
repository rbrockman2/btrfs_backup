#!/bin/bash
export PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin/btrfs_backup"

interval=$1
keep=$2

source_subvol_list="/etc/btrfs_backup/source_subvol_list.txt"
for subvol in `cat $source_subvol_list`
do
    btrfs-subvolume-local-backup.sh --interval $interval --keep $keep --backupdir `dirname $subvol` `basename $subvol`
done
