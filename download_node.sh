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

pwd

NODE_VERSION="v17.9.0"
NODE_DIST="node-$NODE_VERSION-linux-$NODE_ARCH"

wget --no-clobber https://nodejs.org/dist/$NODE_VERSION/$NODE_DIST.tar.xz;
tar -xf $NODE_DIST.tar.xz -C ./install --skip-old-files;
mv ./install/$NODE_DIST/ ./install/nodeJS;