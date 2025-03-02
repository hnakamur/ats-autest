#!/bin/sh
(cd ${trafficserver_ci_dir:-./trafficserver-ci}/docker/fedora41; docker build -t fedora41autestbase .)
