Install process:

- Move files in bin to /usr/local/bin/btrfs_backup.
- Move files in etc to /etc/btrfs_backup.
- Make backup drives (not partitons) LUKS volumes.
- Format the backup drives to be btrfs.
- Add the uuids of the LUKS volumes to /etc/btrfs_backup/backup_drive_list.txt.
- Add the LUKS password to /etc/btrfs_backup/backup_drive_password.txt.
- Add the full path to the btrfs subvolumes to be backed up to 
  /etc/btrfs_backup/source_subvol_list.txt.
- Add empty file .source_top_level_subvol to the directories containing the 
  btrfs subvolumes to be backed up.
- Add empty file .backup_top_level_subvol to the top level directory of the
  backup drive's file systems.
- Put appropriate entries into cron (see doc/sample_cron.txt).
