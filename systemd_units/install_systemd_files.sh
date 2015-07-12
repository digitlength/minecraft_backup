#!/bin/bash

if [ "$0" != "./install_systemd_files.sh" ]; then
  echo "Error: this script must be run from the parent directory"
  echo "i.e. you need to run it as ./install_systemd_files.sh"
  exit -1
fi

if [ $(whoami) != "root" ]; then
  echo "This script needs to be run as root or in sudo"
  exit -1
fi

export SCRIPTSDIR=$(dirname $(pwd))
for j in *.template; do
  target=$(basename $j .template)
  sed s,SCRIPTDIR,$SCRIPTSDIR, $j -- > $target
  cp $target /etc/systemd/system/
  rm $target
done

