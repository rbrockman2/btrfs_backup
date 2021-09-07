#!/bin/bash
export PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin/btrfs_backup"

shopt -s nullglob
backupdir=$1
if [ -z "$2" ]; then
    keep=5
else
    keep=$2
fi
if [ "$keep" -le 0 ]; then
    echo "Error:  keeping too few snapshots, deletion halted."
    exit 1
fi
cd $backupdir
ls -rd *.* | tail -n +$(( $keep + 1 ))| while read snap
do
    btrfs subvolume delete "$snap" | grep -v 'Transaction commit:'
done

