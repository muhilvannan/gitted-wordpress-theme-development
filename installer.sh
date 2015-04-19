#!/bin/bash
# LAMP App server install
# install php apache mysql and 
directory="/home/vagrant/public_html"
echo 'installing LAMP stack Dependencies ...'
yum -y install wget vim

if [ ! -f /etc/yum.repos.d/epel.repo ]; then
	wget https://accentdesign.co.uk/rpmdep/epel-release-6-8.noarch.rpm
	rpm -Uvh epel-release-6*.rpm
	rm -f epel*
fi

if [ ! -f /etc/yum.repos.d/remi.repo ]; then
	wget https://accentdesign.co.uk/rpmdep/remi-release-6.rpm
	rpm -Uvh remi-release-6*.rpm
	rm -f remi*
fi
wget https://accentdesign.co.uk/rpmdep/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
rpm -Uvh "https://accentdesign.co.uk/rpmdep/libmcrypt-2.5.8-9.el6.x86_64.rpm"
rpm -Uvh "https://accentdesign.co.uk/rpmdep/libmcrypt-devel-2.5.8-9.el6.x86_64.rpm"
yum -y install libxml2-devel curl-devel libpng libjpeg libpng-devel libjpeg-devel pcre-devel lua-devel autoconf libtool doxygen mailcap rpm-build openssl-devel sqlite-devel memcached perl-Cache-Memcached gcc make git expat-devel libuuid-devel db4-devel postgresql-devel mysql-devel freetds-devel unixODBC-devel openldap-devel nss-devel libicu-devel

wget https://accentdesign.co.uk/rpmdep/rpms.tar.gz
tar -zxvf rpms.tar.gz
cd rpms
yum -y localinstall * --skip-broken
chkconfig httpd on
service httpd start
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.bak.bak
sed -i.bak -e "s/^#LoadModule rewrite_/LoadModule rewrite_/g" /etc/httpd/conf/httpd.conf
sed -i.bak -e "s/^#LoadModule userdir_/LoadModule userdir_/g" /etc/httpd/conf/httpd.conf
service httpd restart
mkdir /etc/httpd/sites-enabled
echo "<?php phpinfo();" > /var/www/html/phpinfo.php
echo -e "<FilesMatch \\.php\$>\nSetHandler application/x-httpd-php\n</FilesMatch>" >> /etc/httpd/conf/httpd.conf
/etc/init.d/httpd restart

yum -y groupinstall "Development Tools"
yum install -y libxml2-devel libXpm-devel gmp-devel libicu-devel t1lib-devel aspell-devel openssl-devel bzip2-devel libcurl-devel libjpeg-devel libvpx-devel libpng-devel freetype-devel readline-devel libtidy-devel libxslt-devel
mkdir ~/php
cd ~/php
wget https://accentdesign.co.uk/rpmdep/php-5.4.37.tar.bz2
tar jxf php-5.4.37.tar.bz2
cd php-5.4.37
./configure --with-config-file-path=/etc --with-apxs2 --with-config-file-scan-dir=/etc/php.d --with-libdir=lib64 --enable-fpm --enable-cgi --with-layout=PHP --with-pear --with-apxs2 --enable-calendar --enable-bcmath --with-gmp --enable-exif --with-mcrypt --with-mhash --with-zlib --with-bz2 --enable-zip --enable-ftp --enable-mbstring --with-iconv --enable-intl --with-icu-dir=/usr --with-gettext --with-pspell --enable-sockets --with-openssl --with-curl --with-curlwrappers --with-gd --enable-gd-native-ttf --with-jpeg-dir=/usr --with-png-dir=/usr --with-zlib-dir=/usr --with-xpm-dir=/usr --with-vpx-dir=/usr --with-freetype-dir=/usr --with-t1lib=/usr --with-libxml-dir=/usr --with-mysql --with-mysqli --enable-pdo --with-pdo-mysql --enable-soap --with-xmlrpc --with-xsl --with-tidy=/usr --with-readline --enable-pcntl --enable-sysvshm --enable-sysvmsg --enable-shmop
make && make install
libtool --finish /root/php/php-5.4.37/libs
mv /usr/local/etc/php-fpm.conf.default /usr/local/etc/php-fpm.conf
mv ~/php/php-5.4.37/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
mv /root/php/php-5.4.37/php.ini-production /etc/php.ini
chmod 755 /etc/init.d/php-fpm 
chkconfig php-fpm on
service php-fpm start

echo 'configuring apache for virtual hosts ....'

cat >> /etc/httpd/conf/httpd.conf << EOL
AddType text/html .php
php_value session.save_handler "files"
php_value session.save_path    "/var/lib/php/session"
DirectoryIndex index.php
ServerName linux-app-dev.accentdesign.co.uk
<IfModule mod_userdir.c>
    UserDir enabled
    UserDir public_html
</IfModule>
<Directory "/home/*/public_html">
	AllowOverride All
    	Options MultiViews SymLinksIfOwnerMatch IncludesNoExec
    	Require method GET POST OPTIONS
</Directory>
EnableSendfile on
<VirtualHost *:80>
    DocumentRoot /var/www/html
</VirtualHost>
IncludeOptional /etc/httpd/conf.d/*.conf
EOL

echo 'Disabling SELinux ....'
setenforce 0
echo 'SELINUX=disabled' > /etc/sysconfig/selinux

mkdir /var/lib/php
mkdir /var/lib/php/session
chmod 777 /var/lib/php/session

echo 'PHP session folders configured ....'

service httpd restart

yum install -y system-config-firewall