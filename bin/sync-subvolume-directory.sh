#!/bin/bash
source_pool=$1
dest_pool=$2

export PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin/btrfs_backup"

# TODO: Wonder what this does?
shopt -s nullglob

# Make destination directory on target drive
mkdir -p "$dest_pool"
failed=0
vol_number=0
prev_snap=""
snap=""
cd $source_pool
ls -d *.* | while read snap
do
    # Verify if the snap is on the target end and skip if so.
    if [ -e "$dest_pool/$snap" ]; then
	echo "$dest_pool/$snap"
        echo "$snap already in destination pool, skipping."
    else
        echo "$snap not in destination pool, copying."
        # If this is the first snapshot we need to do a full send.
        if [ $vol_number -eq 0 ]; then
            echo "$snap is the first subvol, sending full version."
            btrfs send "$snap" | btrfs receive -C "$dest_pool/" || failed=1
            if [ $failed -eq 1 ]; then
                echo "Command failed:  btrfs send "$snap" | btrfs receive -C "$dest_pool/""
                exit 1
            fi
        # If this is not the first snapshot we need to try to send a diff.
        else
            echo "Previous snapshot is $prev_snap"
            echo "Current snapshot is $snap"
            echo "Sending diff"
            btrfs send -p "$prev_snap" "$snap" | btrfs receive -C "$dest_pool/" || failed=1
            # If the diff send fails, we need to do a full send instead.
            if [ $failed -eq 1 ]; then
                echo "Command failed:  btrfs send -p "$prev_snap" "$snap" | btrfs receive -C "$dest_pool/""
                echo "Sending diff failed, attempting to send full version."
                failed=0
                btrfs send "$snap" | btrfs receive -C "$dest_pool/" || failed=1
                if [ $failed -eq 1 ]; then
                    echo "Command failed:  btrfs send "$snap" | btrfs receive -C "$dest_pool/""
                    exit 1
                fi
            fi
        fi
    fi

    prev_snap=$snap
    vol_number=$(( vol_number + 1))
done
