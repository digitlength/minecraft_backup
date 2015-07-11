## This file contains configuration variables for all the Minecraft
## server and backup scripts. It should not be exported or run
## directly. Instead, it is sourced by all other scripts to keep
## track of where crucial files and structures are located. Think of
## this as the "Options" page.


### IMPORTANT ###
## This file must stay in the same directory as the server launch
## and backup scripts, or BAD THINGS will happen!

# Where the server directory is located
SERVPATH=/opt/Minecraft

# The name of the minecraft server JARfile
JARNAME="sponge-1.8-1446-2.1DEV-512.jar"

# The location of the backup directory
BKUPNAME="auto_backups"

# How much memory to assign to the JVM heap
# See -Xmx in the java manpage for syntax details
# If in doubt, leave this line blank
HEAPMEM=350M

# Where to store the output from the server
OUTFILENAME=server.out

# The name for the server input file. This named pipe
# will be used to send console input to the server
PIPENAME=minecraft_IO.pipe

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
