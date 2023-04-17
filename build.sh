#!/bin/zsh

PWD=`pwd`
DIST_DIR="$PWD/dist"
BUILD_DIR="$PWD/build"

rm -rf $BUILD_DIR
mkdir $BUILD_DIR
cd $BUILD_DIR

cmake .. -DCMAKE_INSTALL_PREFIX=$DIST_DIR -DCMAKE_BUILD_TYPE=Debug
make
make install

if [ "$1" = "run" ]; then
    printf "\n"
    $DIST_DIR/ijoVM
fi