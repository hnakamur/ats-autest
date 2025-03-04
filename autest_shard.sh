#!/bin/sh
set -eu

if [ $# -ne 2 ]; then
  >&2 echo Usage: $0 shard_id work_dir
  exit 2
fi

shard=$1
work_dir=$2

project_name=${PROJECT:-autest}
build_instance=${BUILD_INSTANCE:-build}
shard_prefix=${SHARD_PREFIX:-shard}
jenkins_uid=${JENKINS_UID:-1200}

shardcnt=${SHARDCNT:-0}

shard_instance=${shard_prefix}${shard}

export INCUS_PROJECT=${project_name}

if [ "${NO_RECREATE:-}" = "" ]; then
  if incus info ${shard_instance} 2>/dev/null >/dev/null; then
    incus delete ${shard_instance} --force
  fi
  incus copy ${build_instance} ${shard_instance} --ephemeral
  incus start ${shard_instance}
  incus exec ${shard_instance} -- cloud-init status --wait
fi

incus exec ${shard_instance} --env SHARD=${shard} --env SHARDCNT=${shardcnt} --user ${jenkins_uid} --env HOME=/home/jenkins --cwd /home/jenkins/trafficserver/tests -- /home/jenkins/run_autest.sh "$@" 2>&1 | tee ${work_dir}/autest-${shard}-of-${shardcnt}.log

env PROJECT=${project_name} rsync -e fake-ssh -rv ${shard_instance}:/home/jenkins/autest_work/sandbox${shard} ${work_dir}/
