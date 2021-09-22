#!/bin/bash

# Copyright (c) 2015, Kevin Song
# All rights reserved.
#
# This file is licensed under the the BSD 3-clause license.
# A copy of the license text can be found in the included LICENSE.txt

## Makes a backup file in the BKUPDIR specified by config.sh
## With the --regular option, it will create a timestamped
## backup in the regular directories which might be killed
## by the cleanup script. Otherwise, it will make a backup
## which is named and will not be touched by the cleanup script.

if [[ "$1" != "--regular" && "$1" = -* ]] || [[ "$1" = "" ]]; then
  echo "Usage: $0 backupname"
  echo "\t Creates a custom backup using the name provided"
  echo "\t Custom backups are never deleted by the backup pruner."
  echo "\t Custom names cannot start with a dash (-)"
  echo "Usage: $0 backupname --regular"
  echo "\t Creates a regular backup, using a timestamped name."
  echo "\t Timestamped names may be removed by the pruner."
  exit 1
fi

CUSTOM_BKUP="FALSE"

if [ "$1" != "--regular" ]; then
  CUSTOM_BKUP="TRUE"
fi

# If we can't find the config files, some names resolve to "/"
# This is a VERY BAD THING, so we kill the script if it happens
# rather than accidentally overwrite the entire computer.
THIS_DIR=$(dirname $0)
if [ ! -f $THIS_DIR/config.sh ]; then
  echo "Server launch failed--script could not find configuration file!"
  echo "Please place config.sh in directory with server launch scripts."
  exit -1
fi

source $THIS_DIR/config.sh

# Set up important variables
TIMESTAMP=$(date +%H%M)
DATESTAMP=$(date +%Y%m%d)
IDENTSTAMP=${DATESTAMP}${TIMESTAMP}
PROPERTIES="server.properties"

# Get world name from server properties
while read line
do
   VARI=$(echo $line | cut -d= -f1)
   if [ "$VARI" == "level-name" ]
   then
      WORLD=$(echo $line | cut -d= -f2)
   fi
done < "$SERVPATH/$PROPERTIES"

#Set target backup directory
if [ "$CUSTOM_BKUP" = "FALSE" ]; then
  TARGET_DIR="$BKUPDIR/hourly/$DATESTAMP/$TIMESTAMP"
else
  TARGET_DIR="$BKUPDIR/custom/$1"
fi

mkdir -p $TARGET_DIR

# Let everyone know we're about to backup
echo "say [BACKUP] Server is running backup process..." > $MCPIPE

if [ "$CUSTOM_BKUP" = "TRUE" ]; then
  echo "Setup completed. Starting backup..."
fi

# Force the save of the world and then turn off auto-saving so that files don't
# change in the middle of a tar run.
echo "save-all" > $MCPIPE
echo "save-off" > $MCPIPE

# use inotifywait and waitsilence to make sure server is done writing
# inotifywait watches for access to the folder, waitsilence will wait
# until it has no input for `timeout` seconds before continuing. We
# wait for 5s to be sure the server is done saving the world
WAITCMD="inotifywait -m -r $SERVPATH/$WORLD --exclude \"^./dynmap.*\" | grep -v ACCESS"

printf "[WAITSILENCE] "
go run $THIS_DIR/waitsilence.go -timeout 5s -command "$WAITCMD"    # -verbose true #optional, enable for debugging

# Now that the server is done writing its save, we can back things up
# Only back up the Nether and The End if they exist

cd $SERVPATH

tar -czf $TARGET_DIR/${WORLD}.${IDENTSTAMP}tar.gz $WORLD
if [ -d "${WORLD}_nether" ]; then
  tar -czf $TARGET_DIR/${WORLD}_nether.${IDENTSTAMP}.tar.gz ${WORLD}_nether
fi
if [ -d "${WORLD}_the_end" ]; then
  tar -czf $TARGET_DIR/${WORLD}_the_end.${IDENTSTAMP}.tar.gz ${WORLD}_the_end
fi

# Backups are done. Turn saves back on and notify the server
echo "save-on" > $MCPIPE
echo "say Backup completed." > $MCPIPE
