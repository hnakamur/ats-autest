#!/bin/sh
set -eu

set -x
shardcnt=${1:-4}

work_dir=${PWD}/work-shard-$(date +%Y%m%dT%H%M%S)
mkdir -p ${work_dir}

jenkins_uid=1200
chown ${jenkins_uid}:${jenkins_uid} ${work_dir}

seq 0 $(($shardcnt-1)) | parallel "docker run -e SHARD={} -e SHARDCNT=${shardcnt}  -e LANG=C --mount type=bind,source=${work_dir},target=/work --rm fedora41autest 2>&1 | tee ${work_dir}/autest-{}-of-${shardcnt}.log"
