#!/bin/bash

git clone -b devel --depth 1 git://github.com/nim-lang/nim nim
cd nim

git clone --depth 1 git://github.com/nim-lang/csources csources/
cd csources

sh build.sh
cd ..

rm -rf csources

bin/nim c koch
./koch boot -d:release

cd ..
