#!/bin/bash

set -e
set -o pipefail
set -o xtrace

export NIM_ROOT=$HOME/Nim

compile() {
    ./bin/nim c koch
    ./koch boot -d:release
    ./koch nimble
}

# If Nim and nimble are still cached from the last time
if [ -x $NIM_ROOT/bin/nim ]; then

    cd $NIM_ROOT
    git fetch origin

    test "$(git rev-parse HEAD)" == "$(git rev-parse @{u})" || compile

# Download nim from scratch and compile it
else

    git clone -b devel --depth 1 git://github.com/nim-lang/nim $NIM_ROOT
    cd $NIM_ROOT

    git clone --depth 1 git://github.com/nim-lang/csources csources
    (cd csources && sh build.sh)

    rm -rf csources

    compile
fi

ls $NIM_ROOT/nim/bin
