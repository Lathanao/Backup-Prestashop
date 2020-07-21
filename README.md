# Backup-Prestashop
Backup script to archive Prestashop projects

1) Make a SQL dump in root project
2) Make a zip archive
3) Remove all cached + compiled files
4) Remove all generated pictures
5) Remove all Node.js files
6) Remove all Composer files
7) ( 3 -> 6 ) + 1 + 2 

2) Clean Prestashop
2) Copy directory in tmp, max reduce, then archive