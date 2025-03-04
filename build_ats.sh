#!/bin/sh
project_name=${PROJECT:-autest}
build_instance=${BUILD_INSTANCE:-build}
jenkins_uid=${JENKINS_UID:-1200}
base_setup_snapshot_name=${BASE_SETUP_SNAPSHOT:-base_setup_done}
ats_built_snapshot_name=${ATS_BUILT_SNAPSHOT:-ats_built}

export INCUS_PROJECT=${project_name}

if incus snapshot show ${build_instance} ${ats_built_snapshot_name} 2>/dev/null >/dev/null; then
  incus snapshot delete ${build_instance} ${ats_built_snapshot_name}
fi
incus snapshot restore ${build_instance} ${base_setup_snapshot_name}

if [ "$(incus info ${build_instance} | grep ^Status)" != 'Status: RUNNING' ]; then
  incus start ${build_instance}
  incus exec ${build_instance} -- cloud-init status --wait
fi

env PROJECT=${project_name} rsync -e fake-ssh -rv ./trafficserver ${build_instance}:/home/jenkins/
incus exec ${build_instance} -- chown -R jenkins: /home/jenkins/trafficserver
incus file push instance_scripts/jenkins/*.sh ${build_instance}/home/jenkins/

incus exec ${build_instance} --user ${jenkins_uid} --env HOME=/home/jenkins --cwd /home/jenkins/trafficserver -- sh -c '/home/jenkins/build_ats.sh 2>&1 | tee /home/jenkins/build_ats.log'

incus snapshot create ${build_instance} ${ats_built_snapshot_name}
