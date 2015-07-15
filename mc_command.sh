#!/bin/bash

# Copyright (c) 2015, Kevin Song
# All rights reserved.
#
# This file is licensed under the the BSD 3-clause license.
# A copy of the license text can be found in the included LICENSE.txt


## This script will take the backups in BKUPDIR and prume
## them appropriately. It retains two days' worth of hourly
## backup (NOT 48 hrs!), 7 days' worth of weekly backup, and
## up to 6 months of weekly backups, though this can be
## reconfigured in config.sh. See the comments there for what
## the numbers all mean.


# If we can't find the config files, some names resolve to "/"
# This is a VERY BAD THING, so we kill the script if it happens
# rather than accidentally overwrite the entire computer.

THIS_DIR=$(dirname $0)

# If we can't find the config files, some names resolve to "/"
# This is a VERY BAD THING, so we kill the script if it happens
# rather than accidentally overwrite the entire computer.
if [ ! -f $THIS_DIR/config.sh ]; then
  echo "Server launch failed--script could not find configuration file!"
  echo "Please place config.sh in directory with server launch scripts."
  exit -1
fi

source $THIS_DIR/config.sh

####==================#####

echo "$@" > $MCPIPE &

# go run waitsilence.go -timeout 5s -command "$WAITCMD"

exit 0
