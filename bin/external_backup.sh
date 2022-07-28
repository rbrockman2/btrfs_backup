#!/bin/bash
export PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin/btrfs_backup"

# number of snapshots to keep around in each directory
keep=20

source_fs=`dirname $1`
source_subvol=`basename $1`

# Ensure source filesystem is mounted.
source_label="${source_fs}/backup_fs_set.`basename ${source_fs}`"
if [[ -e ${source_label} ]]; then
    echo "Source filesystem found."
else
    echo "Error:  Source filesystem missing."
    exit 1
fi


# Ensure backup filesystem is mounted.
backup_fs=/mnt/backup_filesystems/`cat ${source_label}`
backup_label="${backup_fs}/backup_fs_set"
backup_uuid_file="${backup_fs}/backup_uuid"
if [[ -e ${backup_label} ]] && [[ -e ${backup_uuid_file} ]]; then
    echo "Backup filesystem found."
else
    echo "Error:  Backup filesystem missing."
    exit 1
fi

backup_uuid=`cat ${backup_uuid_file}`
source_snapshot_dir="${source_fs}/backup_fs_${backup_uuid}/${source_subvol}_backup"
backup_snapshot_dir="${backup_fs}/${source_subvol}_backup"

mkdir -p $source_snapshot_dir
mkdir -p $backup_snapshot_dir

DATE="$(date '+%Y%m%d_%H:%M:%S')"
btrfs subvol snapshot -r "${source_fs}/${source_subvol}" "${source_snapshot_dir}/${source_subvol}.$DATE" 

echo "Transferrring $source_snapshot_dir to $backup_snapshot_dir"
sync-subvolume-directory.sh "$source_snapshot_dir" "$backup_snapshot_dir"

# Create symlink to most recent snapshot for easy restore.
rm -f "${backup_snapshot_dir}/${source_subvol}"
ln -s "${backup_snapshot_dir}/${source_subvol}.$DATE" "${backup_snapshot_dir}/${source_subvol}"

# Delete old subvolumes AFTER successful transfer.
delete_old_snapshots.sh $source_snapshot_dir $keep
delete_old_snapshots.sh $backup_snapshot_dir $keep
