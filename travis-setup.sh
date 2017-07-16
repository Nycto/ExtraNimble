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
if [ -x "$NIM_ROOT/bin/nim" ]; then

    # Check if the Nim cache is older than 7 days
    if ! find "$NIM_ROOT" -maxdepth 0 -type d -ctime +7 -exec false {} +; then

        # Now check to see if there is a new revision
        cd "$NIM_ROOT"
        git fetch origin
        test "$(git rev-parse HEAD)" == "$(git rev-parse @{u})" || compile
    fi

# Download nim from scratch and compile it
else

    git clone -b devel --depth 1 git://github.com/nim-lang/nim "$NIM_ROOT"
    cd "$NIM_ROOT"

    git clone --depth 1 git://github.com/nim-lang/csources csources
    (cd csources && sh build.sh)

    rm -rf csources

    compile
fi

ls "$NIM_ROOT/bin"
