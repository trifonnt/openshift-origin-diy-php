#!/bin/sh

OPENSHIFT_RUNTIME_DIR=$OPENSHIFT_HOMEDIR/app-root/runtime
OPENSHIFT_REPO_DIR=$OPENSHIFT_HOMEDIR/app-root/runtime/repo

echo "Prepare directories"
cd $OPENSHIFT_RUNTIME_DIR
mkdir srv
mkdir srv/pcre
mkdir srv/httpd
mkdir srv/php
mkdir tmp

cd tmp/

echo "Install pcre"
wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.33.tar.gz
tar -zxf pcre-8.33.tar.gz
cd pcre-8.33
./configure \
--prefix=$OPENSHIFT_RUNTIME_DIR/srv/pcre
make && make install
cd ..

echo "Install Apache httpd"
wget http://www.gtlib.gatech.edu/pub/apache//httpd/httpd-2.4.7.tar.gz
tar -zxf httpd-2.4.7.tar.gz
wget http://artfiles.org/apache.org/apr/apr-1.5.0.tar.gz
tar -zxf apr-1.5.0.tar.gz
mv apr-1.5.0 httpd-2.4.7/srclib/apr
wget http://artfiles.org/apache.org/apr/apr-util-1.5.3.tar.gz
tar -zxf apr-util-1.5.3.tar.gz
mv apr-util-1.5.3 httpd-2.4.7/srclib/apr-util
cd httpd-2.4.7
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
wget http://zlib.net/zlib-1.2.8.tar.gz
tar -zxf zlib-1.2.8.tar.gz
cd zlib-1.2.8
./configure \
--prefix=$OPENSHIFT_RUNTIME_DIR/srv/zlib/
make && make install
cd ..

echo "INSTALL PHP"
wget http://de2.php.net/get/php-5.5.7.tar.gz/from/this/mirror
tar -zxf php-5.5.7.tar.gz
cd php-5.5.7
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
wget http://xdebug.org/files/xdebug-2.2.3.tgz
tar -zxf xdebug-2.2.3.tgz
cd xdebug-2.2.3
$OPENSHIFT_RUNTIME_DIR/srv/php/bin/phpize
./configure \
--with-php-config=$OPENSHIFT_RUNTIME_DIR/srv/php/bin/php-config
make && cp modules/xdebug.so $OPENSHIFT_RUNTIME_DIR/srv/php/lib/php/extensions/no-debug-zts-20100525
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
