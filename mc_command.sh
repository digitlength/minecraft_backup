#!/bin/bash

# Copyright (c) 2015, Kevin Song
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
#   are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation and/or
# other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors
# may be used to endorse or promote products derived from this software without
# specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


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

#Maybe do some shenanigans here to detect when the MC server has been
#silent for a while?

# go run waitsilence.go -timeout 5s -command "$WAITCMD"

exit 0
