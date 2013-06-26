#!/bin/sh

# A simple backup script using the Rackspace php-opencloud library.

#Information specific to your site
backup_root="/use/absolute/path" # a directory outside of your site root used to stage files - /home/user/backup_staging.
siteroot="/your/site/path/" # /home/user/public_html
db_host="database_host"
db_user="database_user"
db_password="database_user_password"
db_name="database_name"

# set the date and name for the backup files. 2012-12-12-24-59
date=`date '+%F-%H-%M'`
backupname="backup.$date.tgz"

echo "Creating a backup for $date" 

echo "Dumping site database."
mysqldump -h $db_host -u $db_user --password="$db_password" $db_name | gzip > $backup_root/db_backup.sql.gz

echo "Compressing site files."
cd $siteroot && tar -czpvf $backup_root/site_files.tgz .

echo "Packaging backup files."
# tarball DB and site_files into one file and then remove them.
cd $backup_root && tar -czpvf $backupname site_files.tgz db_backup.sql.gz --remove-files

if [ ! -f $backup_root/$backupname ];
then
	echo "File packaging failed."
else
	#Upload files to rackspace. Calls cloudfiles_backup.php inside backup_root.
	#First argument is the location of the backup file, second argument is the name to be used when uploaded.
	echo "Uploading backup to external host."
	php $backup_root/cloudfiles_backup.php $backup_root/$backupname $backupname
	
	if [ $? -ne 0 ]; #check to see if php script ran without errors. 
	then
	    echo "Error processing cloudfiles_backup.php."
	else
		#After a backup has been uploaded, remove the tar ball from the filesystem.
		echo "Removing generated files from local system."
		rm $backup_root/$backupname
		
		echo "Backup process complete."
	fi	
fi