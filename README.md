# Backup-Prestashop

**Backup-Prestashop 1.7**  allow to reduce the size of the main directory of your Prestashop 1.7.
hen make a backup.

- **How to use**:
  - Go on your root directory project
  - Run the script

- **The script allow you to**:
  - Make a SQL dump in root project
  - Make a zip archive
  - Remove all cached + compiled files
  - Remove all generated pictures
  - Remove all Node.js files
  - Remove all Composer files
  - All together

- **TODO**:
  - Add exception and message in red
  - Add a log file
  - Set zip compression
  - Check if install MozJpeg could improve again the archive weight lost
  - Clean DB
  - Remove the search index and the facet cache in DB
  - CronJOb
  - Send Archive on Gdrive with rclone
  
- **Here what's look like the menu**:

![synth-shell](doc/2020-07-28_19-42.png)