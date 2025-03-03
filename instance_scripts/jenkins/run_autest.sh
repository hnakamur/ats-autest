#!/bin/bash
set -e
set -x

# This script is based on
# https://github.com/apache/trafficserver-ci/blob/4dde2d75ca6e3847c1b5b771dad5b50c739c6507/jenkins/github/autest.pipeline

# We want to pick up the OpenSSL-QUIC version of curl in /opt/bin.
# The HTTP/3 AuTests depend upon this, so update the PATH accordingly.
export PATH=/opt/bin:${PATH}
export PATH=/opt/go/bin:${PATH}

export_dir="${WORKSPACE:-$HOME/autest_work}"
mkdir -p ${export_dir}

sandbox_dir=${export_dir}/sandbox${SHARD:-}

autest_args=""
testsall=( $( find . -iname "*.test.py" | awk -F'/' '{print $NF}' | awk -F'.' '{print $1}' ) )
if [ -d ../cmake ]; then
	# CMake: Enter into the build's test directory.
	cd ../build/tests
	pipenv install
	autest_args="--sandbox ${sandbox_dir}"
else
	# Autoconf.
	autest_args="--ats-bin /home/${USERNAME:-jenkins}/ts-autest/bin/ --sandbox ${sandbox_dir}"
fi

if [ ${SHARDCNT:-0} -le 0 ]; then
	if ./autest.sh ${autest_args} "$@"; then
		touch ${export_dir}/No_autest_failures
	else
		touch ${export_dir}/Autest_failures
		ls "${sandbox_dir}"
	fi
else
	testsall=( $(
	  for el in  "${testsall[@]}" ; do
	    echo $el
	  done | sort) )
	ntests=${#testsall[@]}

	shardsize=$((${ntests} / ${SHARDCNT}))
	[ 0 -ne $((${ntests} % ${shardsize})) ] && shardsize=$((${shardsize} + 1))
	shardbeg=$((${shardsize} * ${SHARD}))
	sliced=${testsall[@]:${shardbeg}:${shardsize}}
	if ./autest.sh ${autest_args} -f ${sliced[@]}; then
		touch ${export_dir}/No_autest_failures-${SHARD}
	else
		touch ${export_dir}/Autest_failures-${SHARD}
		ls "${sandbox_dir}"
	fi
fi
