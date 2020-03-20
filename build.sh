#!/bin/bash

if [[ -d "buildroot" ]]; then
    rm -rf buildroot
fi

git clone https://git.buildroot.net/buildroot

cp config-x64_64 buildroot/.config
cd buildroot

make -j$(nproc)

