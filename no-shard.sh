#!/bin/sh
set -eu

set -x
work_dir=${PWD}/work-no-shard-$(date +%Y%m%dT%H%M%S)
mkdir -p ${work_dir}

jenkins_uid=1200
sudo chown ${jenkins_uid}:${jenkins_uid} ${work_dir}

docker run -e LANG=C --mount type=bind,source=${work_dir},target=/work --rm -it fedora41autest "$@" 2>&1 | sudo tee ${work_dir}/autest.log

echo work_dir=${work_dir}
