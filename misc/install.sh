#!/bin/sh

OPENSHIFT_RUNTIME_DIR=$OPENSHIFT_HOMEDIR/app-root/runtime
OPENSHIFT_REPO_DIR=$OPENSHIFT_HOMEDIR/app-root/runtime/repo

# PHP https://secure.php.net/downloads.php
VERSION_PHP=5.6.12

# Apache http://www.gtlib.gatech.edu/pub/apache/httpd/
VERSION_APACHE=2.4.16
# APR http://artfiles.org/apache.org/apr/
VERSION_APR=1.5.2
VERSION_APR_UTIL=1.5.4

# PCRE ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre
VERSION_PCRE=8.37

# XDebug http://xdebug.org/files/
VERSION_XDEBUG=2.3.3

# ZLib http://zlib.net/
VERSION_ZLIB=1.2.8

echo "Prepare directories"
cd $OPENSHIFT_RUNTIME_DIR
mkdir srv
mkdir srv/pcre
mkdir srv/httpd
mkdir srv/php
mkdir tmp

cd tmp/

echo "Install pcre"
wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-$VERSION_PCRE.tar.gz
tar -zxf pcre-$VERSION_PCRE.tar.gz
cd pcre-$VERSION_PCRE
./configure \
--prefix=$OPENSHIFT_RUNTIME_DIR/srv/pcre
make && make install
cd ..

echo "Install Apache httpd"
wget http://www.gtlib.gatech.edu/pub/apache/httpd/httpd-$VERSION_APACHE.tar.gz
tar -zxf httpd-$VERSION_APACHE.tar.gz
wget http://artfiles.org/apache.org/apr/apr-$VERSION_APR.tar.gz
tar -zxf apr-$VERSION_APR.tar.gz
mv apr-$VERSION_APR httpd-$VERSION_APACHE/srclib/apr
wget http://artfiles.org/apache.org/apr/apr-util-$VERSION_APR_UTIL.tar.gz
tar -zxf apr-util-$VERSION_APR_UTIL.tar.gz
mv apr-util-$VERSION_APR_UTIL httpd-$VERSION_APACHE/srclib/apr-util
cd httpd-$VERSION_APACHE
./configure \
--prefix=$OPENSHIFT_RUNTIME_DIR/srv/httpd \
--with-included-apr \
--with-pcre=$OPENSHIFT_RUNTIME_DIR/srv/pcre \
--enable-so \
--enable-auth-digest \
--enable-rewrite \
--enable-setenvif \
--enable-mime \
--enable-deflate \
--enable-headers
make && make install
cd ..

#echo "INSTALL ICU"
#wget http://download.icu-project.org/files/icu4c/50.1/icu4c-50_1-src.tgz
#tar -zxf icu4c-50_1-src.tgz
#cd icu/source/
#chmod +x runConfigureICU configure install-sh
#./configure \
#--prefix=$OPENSHIFT_RUNTIME_DIR/srv/icu/
#make && make install
#cd ../..

echo "Install zlib"
wget http://zlib.net/zlib-$VERSION_ZLIB.tar.gz
tar -zxf zlib-$VERSION_ZLIB.tar.gz
cd zlib-$VERSION_ZLIB
./configure \
--prefix=$OPENSHIFT_RUNTIME_DIR/srv/zlib/
make && make install
cd ..

echo "INSTALL PHP"
wget http://de2.php.net/get/php-$VERSION_PHP.tar.gz/from/this/mirror
tar -zxf php-$VERSION_PHP.tar.gz
cd php-$VERSION_PHP
./configure \
--prefix=$OPENSHIFT_RUNTIME_DIR/srv/php/ \
--with-config-file-path=$OPENSHIFT_RUNTIME_DIR/srv/php/etc/apache2 \
--with-apxs2=$OPENSHIFT_RUNTIME_DIR/srv/httpd/bin/apxs \
--with-zlib=$OPENSHIFT_RUNTIME_DIR/srv/zlib \
--with-libdir=lib64 \
--with-layout=PHP \
--with-gd \
--with-curl \
--with-mysqli \
--with-openssl \
--enable-mbstring \
--enable-zip
#--enable-intl \
#--with-icu-dir=$OPENSHIFT_RUNTIME_DIR/srv/icu \

make && make install
mkdir $OPENSHIFT_RUNTIME_DIR/srv/php/etc/apache2
cd ..

#echo "Install APC"
#wget http://pecl.php.net/get/APC-3.1.13.tgz
#tar -zxf APC-3.1.13.tgz
#cd APC-3.1.13
#$OPENSHIFT_RUNTIME_DIR/srv/php/bin/phpize
#./configure \
#--with-php-config=$OPENSHIFT_RUNTIME_DIR/srv/php/bin/php-config \
#--enable-apc \
#--enable-apc-debug=no
#make && make install
#cd ..

echo "Install xdebug"
wget http://xdebug.org/files/xdebug-$VERSION_XDEBUG.tgz
tar -zxf xdebug-$VERSION_XDEBUG.tgz
cd xdebug-$VERSION_XDEBUG
$OPENSHIFT_RUNTIME_DIR/srv/php/bin/phpize
./configure \
--with-php-config=$OPENSHIFT_RUNTIME_DIR/srv/php/bin/php-config
make && cp modules/xdebug.so $OPENSHIFT_RUNTIME_DIR/srv/php/lib/php/extensions
cd ..

echo "Cleanup"
rm -r $OPENSHIFT_RUNTIME_DIR/tmp/*.tar.gz
rm -r $OPENSHIFT_RUNTIME_DIR/tmp/*.tgz

echo "COPY TEMPLATES"
cp $OPENSHIFT_REPO_DIR/misc/templates/bash_profile.tpl $OPENSHIFT_HOMEDIR/app-root/data/.bash_profile
python $OPENSHIFT_REPO_DIR/misc/parse_templates.py

echo "START APACHE"
$OPENSHIFT_RUNTIME_DIR/srv/httpd/bin/apachectl start

echo "*****************************"
echo "***  F I N I S H E D !!   ***"
echo "*****************************"
