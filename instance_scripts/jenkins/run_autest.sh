#!/bin/bash
set -e

# This script is based on
# https://github.com/apache/trafficserver-ci/blob/4dde2d75ca6e3847c1b5b771dad5b50c739c6507/jenkins/github/autest.pipeline

# We want to pick up the OpenSSL-QUIC version of curl in /opt/bin.
# The HTTP/3 AuTests depend upon this, so update the PATH accordingly.
export PATH=/opt/bin:${PATH}
export PATH=/opt/go/bin:${PATH}

export_dir="${WORKSPACE:-$HOME/autest_work}"
sandbox_dir=${export_dir}/sandbox
mkdir -p ${sandbox_dir}

autest_args=""
if [ -d ../cmake ]; then
  # CMake: Enter into the build's test directory.
  cd ../build/tests
  autest_args="--sandbox ${sandbox_dir}"
else
  # Autoconf.
  autest_args="--ats-bin /home/${USERNAME:-jenkins}/ts-autest/bin/ --sandbox ${sandbox_dir}"
fi
./autest.sh ${autest_args} "$@"
