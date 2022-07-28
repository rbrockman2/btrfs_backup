#!/bin/bash
export PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin/btrfs_backup"

target_fs=`dirname $1`
target_subvol=`basename $1`

# Ensure restore target filesystem is mounted.
target_label="${target_fs}/backup_fs_set.`basename ${target_fs}`"
if [[ -e ${target_label} ]]; then
    echo "Restore target filesystem found."
else
    echo "Error:  Restore target filesystem missing."
    exit 1
fi


# Ensure backup filesystem is mounted.
backup_fs=/mnt/backup_filesystems/`cat ${source_label}`
backup_label="${backup_fs}/backup_fs_set"
if [[ -e ${backup_label} ]]; then
    echo "Backup filesystem found."
else
    echo "Error:  Backup filesystem missing."
    exit 1
fi

backup_snapshot_dir="${backup_fs}/${target_subvol}_backup"
exclude_file="${backup_snapshot_dir}/${target_subvol}/.exclude"

rsync -ax --delete "${backup_snapshot_dir}/${target_subvol}/" "${target_fs}/${target_subvol}" --exclude-from=${exclude_file}
