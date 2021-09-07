#!/bin/bash
# btrfs-subvolume-local-backup.sh

# By Marc MERLIN <marc_soft@merlins.org>
# License: Apache-2.0

# Modified by Robert Brockman II <robert@firehead.org> to be stripped down.

# Source: http://marc.merlins.org/linux/scripts/
# $Id: btrfs-subvolume-backup 1287 2017-07-05 06:49:53Z svnuser $
#
# Documentation and details at
# http://marc.merlins.org/perso/btrfs/2014-03.html#Btrfs-Tips_-Doing-Fast-Incremental-Backups-With-Btrfs-Send-and-Receive

export PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin/btrfs_backup"

set -o nounset
set -o errexit
set -o pipefail

# From https://btrfs.wiki.kernel.org/index.php/Incremental_Backup

# bash shortcut for `basename $0`
PROG=${0##*/}
lock=/var/run/$PROG

usage() {
    cat <<EOF
Usage:
cd /mnt/source_btrfs_pool
$PROG
	[--init]
	[--keep|-k num]
	[--lockname lockfile (without /var/run prepended)]
	[--postfix foo]
	[--interval daily]
	[--backupdir /mnt/root_top_level_subvol ]
	volume_name

Options:
    --help:          Print this help message and exit.
    --init:          For the first run, required to initialize the copy (only use once)
    --lockname|-l:   Override lockfile in /var/run: $PROG
    --keep num:      Keep the last snapshots for local backups (5 by default)
    --postfix:	     postfix to add to snapshots
    --interval:      name of subdirectory for interval (daily by default)
    --backupdir:      path to snapshot tree (default /mnt/root_top_level_subvol)

This will snapshot volume_name in a btrfs pool.

The num snapshots to keep is to give snapshots you can recover data from locally
and they get deleted after num runs. Set to 0 to disable (one snapshot will
be kept since it's required for the next diff to be computed). 

EOF
    exit 0
}

die () {
    msg=${1:-}
    # don't loop on ERR
    trap '' ERR

    rm $lock

    echo "$msg" >&2
    echo >&2

    # This is a fancy shell core dumper
    if echo $msg | grep -q 'Error line .* with status'; then
	line=`echo $msg | sed 's/.*Error line \(.*\) with status.*/\1/'`
	echo " DIE: Code dump:" >&2
	nl -ba $0 | grep -5 "\b$line\b" >&2
    fi

    exit 1
}

# Trap errors for logging before we die (so that they can be picked up
# by the log checker)
trap 'die "Error line $LINENO with status $?"' ERR

init=""
# Keep the last 5 snapshots locally by default
keep=5
TEMP=$(getopt --longoptions help,usage,interval:,backupdir:,keep:,postfix:,lockname: -o h,i:,b:,k:,p:,l: -- "$@") || usage
pf=""
interval="daily"
backup_root="/mnt/root_top_level_subvol"

# getopt quotes arguments with ' We use eval to get rid of that
eval set -- $TEMP

while :
do
    case "$1" in
        -h|--help|--usage)
            usage
            shift
            ;;

	--postfix)
	    shift
	    pf=_$1
	    lock="$lock.$pf"
	    shift
	    ;;

	--interval)
	    shift
	    interval=$1
	    shift
	    ;;

	--backupdir)
	    shift
	    backup_root=$1
	    shift
	    ;;

	--lockname|-l)
	    shift
	    lock="/var/run/$1"
	    shift
	    ;;

	--keep|-k)
	    shift
	    keep=$1
	    shift
	    ;;

	--)
	    shift
	    break
	    ;;

        *)
	    echo "Internal error from getopt!"
	    exit 1
	    ;;
    esac
done
[[ $keep < 1 ]] && die "Must keep at least one snapshot for things to work ($keep given)"

DATE="$(date '+%Y%m%d_%H:%M:%S')"

[[ $# != 1 ]] && usage
vol="$1"

backup_subdir="${backup_root}/${vol}_backup/${interval}"
mkdir -p "${backup_subdir}"
cd "${backup_subdir}"

if [[ -e $lock ]]; then
    echo "$lock held for $PROG, quitting" >&2
    exit
else
    touch $lock
fi

src_newsnap="${vol}${pf}.$DATE"

btrfs subvolume snapshot -r "${backup_root}/${vol}" "$src_newsnap"

# There is currently an issue that the snapshots to be used with "btrfs send"
# must be physically on the disk, or you may receive a "stale NFS file handle"
# error. This is accomplished by "sync" after the snapshot
btrfs fi sync "$src_newsnap"

# Keep track of the last snapshot to send a diff against.
ln -snf "$(basename $src_newsnap)" "${vol}${pf}_last"

# Delete old snapshots in the source btrfs pool (both read
# only and read-write).
shopt -s nullglob
ls -rd ${vol}${pf}.* | tail -n +$(( $keep + 1 ))| while read snap
do
    btrfs subvolume delete "$snap" | grep -v 'Transaction commit:'
done

rm $lock
