#!/bin/bash
##WebsiteBackupscript via PHP AKEEBA REMOTE CLI
## V 5 27012022
##Activated by systemd - stderr and stdout to /root/logs/backupweb.log
id=0
#Delete old Backups
find /fsrv/x/*/*de-202*.j* -type f -mtime +2 -delete
#Backup of Webspace
/usr/bin/php /root/scripts/remote-phar.raw --action=backup --host=http://your.web.space --secret="123456789" --dlpath="/fsrv/x/y" --download --dlmode=http --delete
#Sendmail
if grep -q Error "/root/logs/backupweb.log"; then
    id=$(/usr/bin/php /root/scripts/remote-phar.raw --action=listbackups --from 0 --to 0 --host=http://your.web.space --secret="123456789" | grep ok | cut -d "|" -f1 | xargs)
    if test -z "$id"; then
        #should not reach this part of the script ever
        echo "Some sketchy shit happend" | mailx -s "Akeeba Error" admin@web.space
    else
        /usr/bin/php /root/scripts/remote-phar.raw --action=download --id $id --host=http://your.web.space --secret="123456789" --dlpath="/fsrv/x/y" --dlmode=http --delete
        #if this still goes wrong just delete
        /usr/bin/php /root/scripts/remote-phar.raw --action=delete --id $id --host=http://your.web.space --secret="123456789"
    fi
    echo "Akeeba download messed around again. ID $id" | mailx -s "Akeeba Error" admin@web.space
fi
exit 0
