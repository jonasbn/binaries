#!/bin/bash

VERSION="2020.02"
FOLDER="buildroot-$VERSION"
DOWNLOAD_URL="https://buildroot.org/downloads/buildroot-$VERSION.tar.gz"

if [[ -d "$FOLDER" ]]; then
    rm -rf buildroot
fi

curl -LO "$DOWNLOAD_URL"
tar xf "$(basename $DOWNLOAD_URL)"

cp config-x86_64 buildroot/.config
cd "$FOLDER"

make -j$(nproc)

