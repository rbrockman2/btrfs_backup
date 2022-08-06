Install process:

- Move files in bin to /usr/local/bin/btrfs_backup.
- Move files in etc to /etc/btrfs_backup.
- Add the LUKS password to /etc/btrfs_backup/backup_device_password.txt.
- Run init_backup.sh with the target backup device (WILL BE DELETED)
  and backup set name.
- Add the full path to the btrfs subvolumes to be backed up to 
  /etc/btrfs_backup/source_subvol_list.txt.
- Add file backup_fs_set.[name of directory] to the directory
  or directories containing the subvolumes to be backed up. 
  It should contain the backup set to be used for those subvolumes.
- Put appropriate entries into cron (see doc/sample_cron.txt).
