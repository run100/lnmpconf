#!/bin/bash
rm -rf nginx-1.4.4
if [ ! -f nginx-1.4.4.tar.gz ];then
  wget http://oss.aliyuncs.com/aliyunecs/onekey/nginx/nginx-1.4.4.tar.gz
fi
tar zxvf nginx-1.4.4.tar.gz
cd nginx-1.4.4
./configure --user=www \
--group=www \
--prefix=/usr/local/webserver/nginx \
--with-http_stub_status_module \
--without-http-cache \
--with-http_ssl_module \
--with-http_gzip_static_module
CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)
if [ $CPU_NUM -gt 1 ];then
    make -j$CPU_NUM
else
    make
fi
make install
touch /home/logs/nginx/error.log
chmod 775 /home/logs/nginx/error.log
chmod 775 /usr/local/webserver/nginx/logs
chown -R www:www /usr/local/webserver/nginx/logs
chmod -R 775 /home/www
chown -R www:www /home/www
cd ..
cp -fR ./config-nginx/* /usr/local/webserver/nginx/conf/
sed -i 's/worker_processes  2/worker_processes  '"$CPU_NUM"'/' /usr/local/webserver/nginx/conf/nginx.conf
chmod 755 /usr/local/webserver/nginx/sbin/nginx
#/alidata/server/nginx/sbin/nginx
cp /usr/local/webserver/nginx/conf/nginx /etc/init.d/
chmod +x /etc/init.d/nginx
/etc/init.d/nginx start