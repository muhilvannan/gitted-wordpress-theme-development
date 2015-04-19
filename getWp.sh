#!/bin/bash
echo "please enter directory name to get stock wordpress to"
read dirName
cd ../$dirName	
wget http://wordpress.org/latest.tar.gz
tar zxf latest.tar.gz
cd wordpress
cp -rpf * ../
cd ../
rm -rf wordpress/
rm -f latest.tar.gz
cd ../linux-config-scripts
