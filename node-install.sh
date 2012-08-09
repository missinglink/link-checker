#!/bin/sh

echo "----------------------------------------"
echo "[Installing Node]"
echo "----------------------------------------"

PROCESSORS=`cat /proc/cpuinfo | grep processor | wc -l`
CLONE_PATH='/tmp/node-install'
INSTALL_PATH='/usr/local'

[ -d $CLONE_PATH ] || git clone git://github.com/joyent/node.git $CLONE_PATH
cd $CLONE_PATH
git pull origin master
git checkout v0.8.6
./configure --prefix=$INSTALL_PATH
make -j $(( $PROCESSORS +1 ))
sudo make install
cd -