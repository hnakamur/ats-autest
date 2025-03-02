#!/bin/sh
docker build -t fedora41autest . 2>&1 | tee build.log
