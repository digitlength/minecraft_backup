#!/bin/bash

# Copyright (c) 2015, Kevin Song
# All rights reserved.
#
# This file is licensed under the the BSD 3-clause license.
# A copy of the license text can be found in the included LICENSE.txt

# Note: cannot be executed correctly if a minecraft server is already running.
# To search for running MC server, run `ps aux | grep java`

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

# $MCPIPE (defined in config.sh)  will be the input device for the server
# instead of STDIN (the shell). Set permissions so that minecraft group can write to it
if [ ! -p $MCPIPE ]; then
  mkfifo $MCPIPE
  chgrp minecraft $MCPIPE
  chmod 664 $MCPIPE
fi

# Make sure files are written to the right place (server writes to $(pwd))
cd $SERVPATH

echo "Starting Minecraft Server..."

# Start the server, reading from  $MCPIPENAME instead of standard in
# This command is really complex...full explanation at the end
java -Xmx${HEAPMEM} -Xms${HEAPMEM} -jar $SERVPATH/$JARNAME $STARTCOMMAND <> $MCPIPE > >(tee $OUTFILE) &

# Record the PID of this process so that systemd can track it, then fork
SERVER_PID=$!
disown
echo "Disowned MC Server"
echo "$SERVER_PID" > $PIDFILE

echo "Minecraft server initialization finished. Exiting setup script..."
exit 0

# DONE

######################################

# The first couple arguments are pretty simple: we start the server with java, using 'go' (for Sponge)
# to make sure that dependencies are automagically installed. We then set the server to read from
# the pipe we set up instead of STDIN, so that we can continue to feed the server commands even though
# we are no longer attached to it. Send commands to the server by echoing the desired text to the pipe.
# Pipe is opened in R/W mode to prevent blocking (see SO links)

# http://stackoverflow.com/questions/179291/setting-up-pipelines-reading-from-named-pipes-without-blocking-in-bash
