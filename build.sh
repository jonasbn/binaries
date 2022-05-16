#!/usr/bin/env bash

set -eu

VERSION="2022.02.1"
FOLDER="buildroot-$VERSION"
URL="https://github.com/buildroot/buildroot"

pull_or_clone() {
	if [[ ! -d "$FOLDER" ]]; then
		git clone "$URL" "$FOLDER"
	else
		git -C "$FOLDER" checkout master
		git -C "$FOLDER" pull
	fi

	git -C "$FOLDER" checkout "$VERSION"
}

build() {
    local arch="$1"

	pull_or_clone

    cp "config-$arch" "$FOLDER/.config"
    cd "$FOLDER"

    make -j "$(nproc)"
}

deploy() {
    local arch
    local dir
    arch="$1"
    dir="$(mktemp -d)"

    find "$FOLDER/output/target" -type f -executable -exec cp '{}' "$dir/" \;
    rsync -e "ssh" -rP --delete "$dir/" "deploy@tatooine.sevenbyte.org:binaries.rumpelsepp.org/binaries/$arch"

    rm -rf "$dir"
}

usage() {
    local SCRIPTNAME
    SCRIPTNAME=$(basename "$0")

    echo "usage: $SCRIPTNAME [-b ARCH] [-d ARCH] [-gh]"
    echo ""
    echo "commands:"
    echo "  -b       Build all stuff for architecture"
    echo "  -d       Deploy all stuff for architecture"
    echo "  -g       Download and untar buildroot"
    echo "  -h       Show this page and exit"
}

while getopts "b:d:ph" arg; do
    case "$arg" in
        b) build  "$OPTARG";;
        d) deploy "$OPTARG";;
        p) pull_or_clone;;
        h) usage && exit 0;;
        *) usage && exit 1;;
    esac
done
