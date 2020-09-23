#!/bin/bash

if [[ $1 != "nginx" ]]; then

new_ip=$TRACKER_SERVER
old_ip="139.159.151.94"

new_group_name=$GROUP_NAME
old_group_name="MIIT"

sed -i "s/$old_ip/$new_ip/g" /etc/fdfs/client.conf
sed -i "s/$old_ip/$new_ip/g" /etc/fdfs/storage.conf
sed -i "s/$old_ip/$new_ip/g" /etc/fdfs/mod_fastdfs.conf

sed -i "s/$old_group_name/$new_group_name/g" /etc/fdfs/storage.conf

fi

if [[ $1 = "nginx" ]]; then

echo "start nginx"
/usr/sbin/nginx

elif [[ $1 = "tracker" ]]; then

echo "start tracker"
/etc/init.d/fdfs_trackerd start

elif [[ $1 = "storage" ]]; then

echo "start storage"
/etc/init.d/fdfs_storaged start

elif [[ $1 = "fastdfs" ]]; then

echo "start tracker"
/etc/init.d/fdfs_trackerd start

echo "start storage"
/etc/init.d/fdfs_storaged start

else

echo "start trackerd"
/etc/init.d/fdfs_trackerd start

echo "start storage"
/etc/init.d/fdfs_storaged start

echo "start nginx"
/usr/sbin/nginx

fi

tail -f  /dev/null