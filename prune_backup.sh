#!/bin/bash

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
if [ ! -f $THIS_DIR/config.sh ]; then
  echo "Server launch failed--script could not find configuration file!"
  echo "Please place config.sh in directory with server launch scripts."
  exit -1
fi

source $THIS_DIR/config.sh

# Make sure the hourly/weekly/daily backup directories are in place

if [ ! -d $BKUPDIR/hourly ]; then
  mkdir $BKUPDIR/hourly
fi
if [ ! -d $BKUPDIR/daily ]; then
  mkdir $BKUPDIR/daily
fi
if [ ! -d $BKUPDIR/weekly ]; then
  mkdir $BKUPDIR/weekly
fi

### NOTE: Backup times are determined from today, i.e. if I'm retaining
### 10 days of weekly backups, I'm retaining backups that are 10 days back
### from today, not from when the daily backups ended.
### However, the data flow *is* chained, i.e. the weekly backups are copied
### from the daily folder. Hope this isn't too confusing.

### Hourly Backups ###

# Remove folders that are older than specified dates
find $BKUPDIR/hourly/* -mtime +$RETAIN_HOURLY | xargs /bin/rm -rf

### Daily Backups ###

# Prune old backups
find $BKUPDIR/daily/* -mtime +$RETAIN_DAILY | xargs /bin/rm -rf

# Move backups from hourly into daily
for dir in $BKUPDIR/hourly/*; do
  cp -nR $dir $BKUPDIR/daily
done

# Make sure that there's only one file in each daily
cd $BKUPDIR/daily
for dir in $BKUPDIR/daily/*; do
  cd $dir
  # remove all but the oldest file
  ls | sort | head -n -1 | xargs /bin/rm -rf
done

### Weekly Backups ###
find $BKUPDIR/weekly/* -mtime +$RETAIN_WEEKLY 2> /dev/null | xargs /bin/rm -rf

# Do we need to make a weekly backup?
find $BKUPDIR/weekly/* -mtime +7 &> /dev/null  && echo "No need to make weekly backup yet." && exit 0

# Make weekly backup
cd $BKUPDIR/daily
#Get latest daily backup and copy it to weekly
LATEST=$(ls | sort | tail -n 1)
cp -R $LATEST $BKUPDIR/weekly/
echo "Weekly Backup Made!"
echo "Done Pruning!"
