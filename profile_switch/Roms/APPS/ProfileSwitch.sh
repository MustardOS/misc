#!/bin/sh
cd $(dirname "$0")/ProfileSwitch
HOME=$(readlink -f ../..)
RUNNER=/mnt/mmc/CFW/profile/runner.sh
./ProfileSwitch
[ -e $RUNNER ] && $RUNNER
sync
