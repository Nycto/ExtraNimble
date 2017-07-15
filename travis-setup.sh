#!/bin/bash

set -e
set -o pipefail
set -o xtrace

compile() {
    ./bin/nim c koch
    ./koch boot -d:release
    ./koch nimble
}

# If Nim and nimble are still cached from the last time
if [ -x nim/bin/nim ]; then

    cd nim
    git fetch origin

    test "$(git rev-parse HEAD)" == "$(git rev-parse @{u})" || compile

# Download nim from scratch and compile it
else

    git clone -b devel --depth 1 git://github.com/nim-lang/nim nim
    cd nim

    git clone --depth 1 git://github.com/nim-lang/csources csources
    (cd csources && sh build.sh)

    rm -rf csources

    compile
fi

cd ..

ls ./nim/bin
