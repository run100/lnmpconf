#!/bin/bash

if [ "$1" != "in" ];then
	echo "Before cleaning the installation script environment !"
	echo "Please backup your data !!"
	read -p "Enter the y or Y to continue:" isY
	if [ "${isY}" != "y" ] && [ "${isY}" != "Y" ];then
	   exit 1
	fi
fi


/etc/init.d/mysqld stop &> /dev/null
/etc/init.d/nginx stop &> /dev/null
/etc/init.d/php-fpm stop &> /dev/null
/etc/init.d/vsftpd stop &> /dev/null
/etc/init.d/httpd stop &> /dev/null
killall mysqld &> /dev/null
killall nginx &> /dev/null
killall httpd &> /dev/null
killall apache2 &> /dev/null
killall vsftpd &> /dev/null
killall php-fpm &> /dev/null

echo "--------> Clean up the installation environment"
rm -rf /usr/local/freetype.2.1.10
rm -rf /usr/local/libpng.1.2.50
rm -rf /usr/local/freetype.2.1.10
rm -rf /usr/local/libpng.1.2.50
rm -rf /usr/local/jpeg.6

echo ""
echo "--------> Delete directory"
echo "/usr/local/webserver/mysql             delete ok!" 
rm -rf /usr/local/webserver/mysql
echo "rm -rf /usr/local/webserver/mysql-*    delete ok!"
rm -rf /usr/local/webserver/mysql-*
echo "/usr/local/webserver/php               delete ok!"
rm -rf /usr/local/webserver/php
echo "/usr/local/webserver/php-*             delete ok!"
rm -rf /usr/local/webserver/php-*
echo "/usr/local/webserver/nginx             delete ok!"
rm -rf /usr/local/webserver/nginx
echo "rm -rf /usr/local/webserver/nginx-*    delete ok!"
rm -rf /usr/local/webserver/nginx-*
echo "/usr/local/webserver/httpd             delete ok!"
rm -rf /usr/local/webserver/httpd
echo "/usr/local/webserver/httpd-*           delete ok!"
rm -rf /usr/local/webserver/httpd-*
echo ""
echo "/home/logs/php                  delete ok!"
rm -rf /home/logs/php
echo "/home/logs/mysql                delete ok!"
rm -rf /home/logs/mysql
echo "/home/logs/nginx                delete ok!"
rm -rf /home/logs/nginx
echo "/home/logs/httpd                delete ok!"
rm -rf /home/logs/httpd
#echo ""
#echo "/alidata/www/phpwind              delete ok!"
#rm -rf /alidata/www/phpwind


echo ""
echo "--------> Delete file"
echo "/etc/my.cnf                delete ok!"
rm -f /etc/my.cnf
echo "/etc/init.d/mysqld         delete ok!"
rm -f /etc/init.d/mysqld
echo "/etc/init.d/nginx          delete ok!"
rm -f /etc/init.d/nginx
echo "/etc/init.d/php-fpm        delete ok!"
rm -r /etc/init.d/php-fpm
echo "/etc/init.d/httpd          delete ok!"
rm -f /etc/init.d/httpd

echo ""
ifrpm=$(cat /proc/version | grep -E "redhat|centos")
ifdpkg=$(cat /proc/version | grep -Ei "ubuntu|debian")
ifcentos=$(cat /proc/version | grep centos)
echo "--------> Clean up files"
echo "/etc/rc.local                   clean ok!"
if [ "$ifrpm" != "" ];then
	if [ -L /etc/rc.local ];then
		echo ""
	else
		\cp /etc/rc.local /etc/rc.local.bak
		rm -rf /etc/rc.local
		ln -s /etc/rc.d/rc.local /etc/rc.local
	fi
	sed -i "/\/etc\/init\.d\/mysqld.*/d" /etc/rc.d/rc.local
	sed -i "/\/etc\/init\.d\/nginx.*/d" /etc/rc.d/rc.local
	sed -i "/\/etc\/init\.d\/php-fpm.*/d" /etc/rc.d/rc.local
	sed -i "/\/etc\/init\.d\/vsftpd.*/d" /etc/rc.d/rc.local
	sed -i "/\/etc\/init\.d\/httpd.*/d" /etc/rc.d/rc.local
else
	sed -i "/\/etc\/init\.d\/mysqld.*/d" /etc/rc.local
	sed -i "/\/etc\/init\.d\/nginx.*/d" /etc/rc.local
	sed -i "/\/etc\/init\.d\/php-fpm.*/d" /etc/rc.local
	sed -i "/\/etc\/init\.d\/vsftpd.*/d" /etc/rc.local
	sed -i "/\/etc\/init\.d\/httpd.*/d" /etc/rc.local
fi

echo ""
echo "/etc/profile                    clean ok!"
sed -i "/export PATH=\$PATH\:\/usr\/local\/webserver\/mysql\/bin.*/d" /etc/profile
source /etc/profile

echo ""
if [ "$ifrpm" != "" ];then
	yum -y remove vsftpd  &> /dev/null
	cp -f ./ftp/config-ftp/rpm_ftp/* /etc/vsftpd/
	rm -f /etc/vsftpd/chroot_list
	rm -f /etc/vsftpd/ftpusers
	rm -f /etc/vsftpd/user_list
	rm -f /etc/vsftpd/vsftpd.conf
else
	apt-get -y remove vsftpd
	rm -f /etc/vsftpd.conf
	rm -f /etc/vsftpd.chroot_list
	rm -f /etc/vsftpd.user_list
	rm -rf /etc/pam.d/vsftpd
fi
echo "vsftpd                    remove ok!"
