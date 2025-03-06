#!/bin/sh
set -eu
build_parallel=${BUILD_PARALLEL:-}

cd $HOME/trafficserver
if [ -d cmake ]; then
  cmake -B build --preset ci-fedora-autest -DCMAKE_INSTALL_PREFIX=$HOME/ts-autest
  cmake --build build -j${build_parallel} -v
  cmake --install build

  cd $HOME/trafficserver/build/tests
  pipenv install
else
  echo "CMake builds are not supported for this branch."
  echo "Building with autotools instead."

  autoreconf -fiv
  ./configure \
  	--with-openssl=/opt/openssl-quic \
  	--enable-experimental-plugins \
  	--enable-example-plugins \
  	--prefix=$HOME/ts-autest \
  	--enable-werror \
  	--enable-debug \
  	--enable-wccp \
  	--enable-ccache
  make -j${build_parallel}
  make install

  cd $HOME/trafficserver/tests
  pipenv install
fi
