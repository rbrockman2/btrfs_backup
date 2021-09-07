#!/bin/bash
export PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin/btrfs_backup"

# number of snapshots to keep around in each directory
keep=20

source_top_level_subvol=`dirname $1`
source_subvol=`basename $1`
backup_top_level_subvol="/mnt/backup"

backup_uuid=`blkid | grep /dev/mapper/backup | cut -f 2- -d "\"" | cut -f 1 -d "\""`

# Ensure both source and destination drives are mounted.
if [[ -e ${source_top_level_subvol}/.source_top_level_subvol ]]; then
    echo "Source drive found."
    if [[ -e ${backup_top_level_subvol}/.backup_top_level_subvol ]]; then
        echo "Destination drive found."
    else
        echo "Error:  Destination drive missing."
        exit 1
    fi
else
    echo "Error:  Source drive missing."
    exit 1
fi

source_snapshot_dir="${source_top_level_subvol}/backup_drive_${backup_uuid}/${source_subvol}_backup"
target_snapshot_dir="${backup_top_level_subvol}/${source_subvol}_backup"

mkdir -p $source_snapshot_dir
mkdir -p $target_snapshot_dir

DATE="$(date '+%Y%m%d_%H:%M:%S')"
btrfs subvol snapshot -r "${source_top_level_subvol}/${source_subvol}" "${source_snapshot_dir}/${source_subvol}.$DATE" 

echo "Transferrring $source_snapshot_dir to $target_snapshot_dir"
sync-subvolume-directory.sh "$source_snapshot_dir" "$target_snapshot_dir"

# Delete old subvolumes AFTER successful transfer.
delete_old_snapshots.sh $source_snapshot_dir $keep
delete_old_snapshots.sh $target_snapshot_dir $keep
