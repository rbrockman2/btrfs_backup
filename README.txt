Install process:

- Move files in bin to /usr/local/bin/btrfs_backup.
- Move files in etc to /etc/btrfs_backup.
- Add the LUKS password to /etc/btrfs_backup/backup_device_password.txt.
- Run init_backup.sh with the target backup device (WILL BE DELETED)
  and backup set name.
- Add the full path to the btrfs subvolumes to be backed up to 
  /etc/btrfs_backup/source_subvol_list.txt.
- Add file backup_fs_set.[BASENAME OF FILESYSTEM MOUNT POINT] to the
  top level directory of the filesystem with subvolumes to be backed up.
  The file should contain the backup set to be used for those subvolumes.
- Put appropriate entries into cron (see doc/sample_cron.txt).
