#!/bin/sh
set -eu
work_dir=$(ls -dt work-* | head -1)
find ${work_dir} -maxdepth 1 -regextype egrep -regex ${work_dir}'/log_[0-9]+(|\.err)' | xargs tail -f
