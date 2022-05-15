#!/bin/bash

ARCH="$1";
SOURCE_DIR="$2"

case $ARCH in
    "armhf" )
        NODE_ARCH="armv7l";;
    "arm64" )
        NODE_ARCH="arm64";;
    "amd64" )
        NODE_ARCH="x64";;
    * )
        echo "$ARCH doesn't have nodeJS version"; exit;;
esac

NODE_VERSION="v17.9.0"
NODE_DIST="node-$NODE_VERSION-linux-$NODE_ARCH"

pwd; ls ${SOURCE_DIR}

rm -r ${SOURCE_DIR}/nodeJS

wget https://nodejs.org/dist/$NODE_VERSION/$NODE_DIST.tar.xz;
tar -xf $NODE_DIST.tar.xz -C ${SOURCE_DIR} && rm $NODE_DIST.tar.xz;
mv ${SOURCE_DIR}/$NODE_DIST/ ${SOURCE_DIR}/nodeJS
