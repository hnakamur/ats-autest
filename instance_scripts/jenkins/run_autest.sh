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

# We must set ATS_ROOT environment variable which is used in
# https://github.com/apache/trafficserver/blob/d605c6c82a58f391975e7b17569defba743448b0/tools/cripts/compiler.sh#L27
export ATS_ROOT=/home/${USERNAME:-jenkins}/ts-autest

autest_args=""
if [ -d ../cmake ]; then
  # CMake: Enter into the build's test directory.
  cd ../build/tests
  autest_args="--sandbox ${sandbox_dir}"
else
  # Autoconf.
  autest_args="--ats-bin ${ATS_ROOT}/bin/ --sandbox ${sandbox_dir}"
fi
./autest.sh ${autest_args} "$@"
