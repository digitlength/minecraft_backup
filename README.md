Minecraft Server Backup Scripts
===============================

I've been hosting a Sponge alpha server for a friend, and it's been
really tricky to do backups because of the lack of a stable API.
Of course, because of the unstable API, it's a good idea to do backups
frequently!

There were a few other backup solutions I found that weren't Bukkit-based, but
they all had some things I didn't quite like.
[Benjick's Minecraft Backup](https://github.com/benjick/Minecraft-Autobackup/blob/master/backup.sh)
was probably one of the best solutions, but it requires you to run in screen,
which has some quirks to it. It also doesn't deal with the server trying to
write files to the files while you're archiving them. [Pete Waller's waitsilence](https://github.com/pwaller/waitsilence)
deals with that, but it's not really a full tool (though it did prove
incredibly useful).

### What is this tool?

This is a set of bash scripts that automates the process of launching and
backing up your Minecraft server. It also comes with a set of systemd units so
that you can "set it and forget it"--the server will automatically start when
you bring the computer online, and backups will be made and pruned in the
background.

### How do I install it?

#### Quick and Dirty overview
* Install go
* Clone to $MINECRAFT_SERVER_DIR/backup_scripts
* Set the variables in config.sh
* Run the scripts

OPTIONAL:
* Install systemd units by running `./install_systemd_files.sh` with
    elevated priviledges.
* Enable/start `minecraft.service`, `minecraft_backup.timer`, `minecraft_prunebackups.timer`

#### Prerequisites

First, you're going to need a Linux computer. Sorry Windows users :(

If you want to take advantage of the automation features, you need a Linux
distribution that uses systemd. That rules out older Ubuntu/Debian versions,
but anything based on RedHat (Fedora/CentOS) or Arch should be fine.

You need a minecraft server that's already functioning (i.e. you can run it and
connect to it). For that, you can look at the instructions at
[DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-minecraft-server-on-linux)

<small> *NOTE: It's fine to use screen to follow those instructions, but you won't use it
in the final install* </small>

Finally, before you install these scripts, you'll need to install `go` from your repositories.

For Fedora/CentOS users:
```
  sudo yum install golang
```

For Ubuntu/Debian:

```
  sudo apt-get install golang
```

For Arch:
```
  sudo pacman -S go
```

#### Installing

`cd` to the directory where you installed Minecraft (the directory that contains
`server.properties` and friends). Once you're there, clone this repo with

```
git clone https://github.com/chipbuster/minecraft_backup.git backup_scripts
```

To configure the scripts, edit the config file with `nano backup_scripts/config.sh`
The two things you really need to configure are `SERVPATH` and `JARNAME`.

`SERVPATH` refers to the path to the server. If you don't remember it, exit nano
with Ctrl+X, then run `pwd` to get the working directory. That's what needs to
be assigned to `SERVPATH`

`JARNAME` is the name of the Minecraft server JARfile you're using. In my case,
I'm using Sponge Alpha builds, so the name will change quite often.

Finally, if you're running a vanilla server, you need to change `STARTCOMMAND`.
That's the argument passed to the JARfile--for Sponge, it's `go`, but for
others, it's `nogui`. Choose the appropriate one by uncommenting it (remove the
hash mark at the start of the line).

The comments explain all the other options. Edit them as you need to.

When you're done, hit Ctrl+X to exit, then type `y` and enter to save changes.
Hit enter again to confirm.

If you want to use these scripts manually, then just `cd` to `backup_scripts` and
run `./scriptname.sh`. If you want to automate these with systemd, you need to
go to backup_scripts/systemd_units and run `sudo ./install_systemd_files.sh`

Once you've installed the systemd files, run the following commands to enable
automatic server launch, backups, and backup pruning as needed:

```
    sudo systemctl enable minecraft
    sudo systemctl enable minecraft_backup.timer
    sudo systemctl enable minecraft_prunebackups.timer
```
Now reboot your system and enjoy automatic backups!

If you don't want to reboot your system, you can also run
```
    sudo systemctl start minecraft
    sudo systemctl start minecraft_backup.timer
    sudo systemctl start minecraft_prunebackups.timer
```

#### TODO

* Automated scripts to restore a backup and issue commands to the server

#### More Details!

Traditional methods of running Minecraft use screen, which has some irksome
limitations when it comes to automatic rebooting and multi-user environments.
Instead, these scripts attach the Minecraft server input to a *named pipe*, which
you can use to send commands to the server. For instance, if you want to tell
everyone on the server you're watching them, you would use
```
 echo "say I'm WATCHING YOUUUUU" > [pipename]
```
This has the same effect as typing "say I'm WATCHING YOUUUUU" directly into the
server. The pipename can be found in `config.sh` (default = minecraft_IO.pipe).
It is created in the Minecraft server directory. The output of the server is
also found in the main directory, under the name in config.sh (default = mc_server.log)

Backups use the named pipe to force a world save, then stop saves so that
we can save the server. Then, we use Peter Waller's waitsilence to
wait until no accesses are made to the world directory for 5 seconds. At that
point, we assume the server is done saving. We save the world (and
Nether/End directories if needed), then resume autosaves on the server.

Of course, hourly backups get very expensive after a while, so we prune them
with the prune_backups script. This retains (by default) 3 days of hourly
backups, 7 days of daily backups, and 6 months of weekly backups. This keeps
the total number of backups under 100 while still providing decent
granularity. If you need incremental backups, [bup](https://github.com/bup/bup)
seems like a promising choice.
