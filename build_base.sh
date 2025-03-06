#!/bin/sh
project_name=${PROJECT:-autest}
instance_timezone=${TIMEZONE:-$(cat /etc/timezone)}
build_instance=${BUILD_INSTANCE:-build}

# Create a project if not exist
if ! incus project info "$project_name" 2>/dev/null >/dev/null; then
  incus project create "$project_name"
  incus profile show default --project default | incus profile edit --project "$project_name" default
fi

export INCUS_PROJECT=${project_name}

# Create a container if not exist
if ! incus info "$build_instance" 2>/dev/null >/dev/null; then
  incus launch images:fedora/41/cloud ${build_instance} -c user.user-data="#cloud-config
timezone: ${instance_timezone}
"
fi

# Set up base and dependent packages
base_setup_snapshot_name=${BASE_SETUP_SNAPSHOT:-base_setup_done}
if ! info snapshot show ${build_instance} ${base_setup_snapshot_name} 2>/dev/null >/dev/null; then
  if [ "$(incus info ${build_instance} | grep ^Status)" = 'Status: RUNNING' ]; then
    incus start ${build_instance}
  fi
  incus file push instance_scripts/root/*.sh ${build_instance}/root/
  incus exec ${build_instance} -- cloud-init status --wait
  incus exec ${build_instance} -- sh -c 'sh -x ./setup_base.sh 2>&1 | tee setup_base.log'
  incus stop ${build_instance}
  incus snapshot create ${build_instance} ${base_setup_snapshot_name}
fi
