## This file contains configuration variables for all the Minecraft
## server and backup scripts. It should not be exported or run
## directly. Instead, it is sourced by all other scripts to keep
## track of where crucial files and structures are located. Think of
## this as the "Options" page.

### IMPORTANT ###
## This file must stay in the same directory as the server launch
## and backup scripts, or BAD THINGS will happen!


##########################
##### Server Options #####
##########################

# Where the server directory is located
SERVPATH=/opt/Minecraft

# The name of the minecraft server JARfile
JARNAME="sponge-1.8-1446-2.1DEV-512.jar"

# The location of the backup directory
BKUPNAME="backups"

# How much memory to assign to the JVM heap
# See -Xmx in the java manpage for syntax details
# If in doubt, leave this line blank
HEAPMEM=350M

# Where to store the output from the server
OUTFILENAME=mc_server.log

# The name for the server input file. This named pipe
# will be used to send console input to the server
PIPENAME=minecraft_IO.pipe

# The command used to run the Minecraft server. For sponge, it is 'go'
# For vanilla Minecraft servers, the command is 'nogui'
STARTCOMMAND=go
# STARTCOMMAND=nogui

##########################
##### Backup Options #####
##########################

# Retention is measured in days, and is a little flaky because we can't control
# exactly when systemd runs (eg. if we want to delete "today's" backups, if the
# script runs at 11:59, we delete all the backups, but if it runs at 12:01 we delete
# nothing).

# These numbers do not stack, i.e. if we retain 7 days of daily backups, it does not
# mean 7 days past where the hourly backups end. It is 7 days from today.

#How many days of hourly backups to retain
RETAIN_HOURLY=3

#How many days of daily backups to retain
RETAIN_DAILY=7

#How many days of weekly backups to retain
#E.g. 10 days = retain weeklies that happened less than 10 days ago
#Default is 6 months, 180 days
RETAIN_WEEKLY=180

# If you need more long-term backup than this, make your own backups
# with make_backup.sh <backupname>. These will not be touched by the pruner.

#############################################################################
####################### DO NOT EDIT BELOW THIS BANNER #######################
################### unless you know what you're doing ;) ####################
#############################################################################

# Some utility names so we don't have to human centipede paths together
MCPIPE=$SERVPATH/$PIPENAME
OUTFILE=$SERVPATH/$OUTFILENAME
BKUPDIR=$SERVPATH/$BKUPNAME

# The file that's used to store the PID of the server
PIDFILE=/var/run/minecraft.pid
