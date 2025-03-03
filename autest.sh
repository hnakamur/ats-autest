#!/bin/sh
set -eu
project_name=${PROJECT:-autest}
build_instance=${BUILD_INSTANCE:-build}
shard_prefix=${SHARD_PREFIX:-shard}
single=${SINGLE:-single}
jenkins_uid=${JENKINS_UID:-1200}

export INCUS_PROJECT=${project_name}

shardcnt=${SHARDCNT:-0}

work_dir_datetime=$(date +%Y%m%dT%H%M%S)

incus file push instance_scripts/jenkins/run_autest.sh ${build_instance}/home/jenkins/

if [ ${shardcnt} -le 0 ]; then
  if incus info ${single} 2>/dev/null >/dev/null; then
    incus delete ${single} --force
  fi
  incus copy ${build_instance} ${single} --ephemeral
  incus start ${single}
  incus exec ${single} -- cloud-init status --wait

  work_dir=work-${work_dir_datetime}-single
  mkdir -p ${work_dir}
  incus exec ${single} --user ${jenkins_uid} --env HOME=/home/jenkins --cwd /home/jenkins/trafficserver/tests -- /home/jenkins/run_autest.sh "$@" 2>&1 | tee ${work_dir}/autest.log
else
  work_dir=work-${work_dir_datetime}-shard
  mkdir -p ${work_dir}
  seq 0 $((${shardcnt}-1)) | parallel "if incus info ${shard_prefix}{} 2>/dev/null >/dev/null; then incus delete ${shard_prefix}{} --force; fi"
  seq 0 $((${shardcnt}-1)) | parallel "incus copy ${build_instance} ${shard_prefix}{} --ephemeral"
  seq 0 $((${shardcnt}-1)) | parallel "incus start ${shard_prefix}{}"
  seq 0 $((${shardcnt}-1)) | parallel "incus exec ${shard_prefix}{} -- cloud-init status --wait"
  seq 0 $((${shardcnt}-1)) | parallel "incus exec ${shard_prefix}{} --user ${jenkins_uid} --env SHARD={} --env SHARDCNT=${shardcnt} --env HOME=/home/jenkins --cwd /home/jenkins/trafficserver/tests -- /home/jenkins/run_autest.sh "$@" 2>&1 | tee ${work_dir}/autest-{}-of-${shardcnt}.log"
fi
