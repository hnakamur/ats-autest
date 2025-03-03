#!/bin/sh
set -eu
work_dir=$(ls -dt work-* | head -1)
tail -f ${work_dir}/*.log
