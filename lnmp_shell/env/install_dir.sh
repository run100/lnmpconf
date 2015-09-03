#!/bin/bash

#ifcentos=$(cat /proc/version | grep centos)
ifubuntu=$(cat /proc/version | grep ubuntu)

userdel www
groupadd www
if [ "$ifubuntu" != "" ];then
useradd -g www -M -d /home/www -s /usr/sbin/nologin www &> /dev/null
else
useradd -g www -M -d /home/www -s /sbin/nologin www &> /dev/null
fi

#if [ "$ifcentos" != "" ];then
#useradd -g www -M -d /alidata/www -s /sbin/nologin www &> /dev/null
#elif [ "$ifubuntu" != "" ];then
#useradd -g www -M -d /alidata/www -s /usr/sbin/nologin www &> /dev/null
#fi



mkdir -p /home/www
mkdir -p /usr/local/webserver
mkdir -p /home/logs
mkdir -p /home/logs/php
mkdir -p /home/logs/mysql
mkdir -p /home/logs/nginx
mkdir -p /home/logs/nginx/access
chown -R www:www /home/log



