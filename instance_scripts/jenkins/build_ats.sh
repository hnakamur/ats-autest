#!/bin/sh
set -eu
build_parallel=${BUILD_PARALLEL:-}

cd $HOME/trafficserver
cmake -B build --preset ci-fedora-autest -DCMAKE_INSTALL_PREFIX=$HOME/ts-autest
cmake --build build -j${build_parallel} -v
cmake --install build

cd $HOME/trafficserver/build/tests
pipenv install
