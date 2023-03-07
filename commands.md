# Users
```
adduser                                 # wrapper script to add users
chsh                                    # change user shell and other info
pw groupadd teamtwo                     # add a group to the system
pw groupmod teamtwo -m <username>       # add a user to a group
/etc/group                              # file to edit groups manually
id                                      # show group membership for current user
```



# System Configuration

```
cat /var/run/dmesg.boot                 # show boot log with info about disks and pci devices
kenv                                    # show bios, board and chassi info (dump from kernel env)
pciconf -l -cv                          # show info about PCI devices of the machine
camcontrol devlist -v                   # list of attached ATA devices
ifconfig                                # show and configure network interface parameters
sysctl                                  # tool to show/set all system/kernel coniguration variables
sysctl -a                               # show all system/kernel configuration variables
sysctl hw                               # show hardware related info and settings
sysctl net                              # show all network related info and settings
sysctl hw.model                         # show CPU model
sysctl net.inet.tcp.delayed_ack=0       # disable delayed ack in tcp
```


# System Statistics

```
top                                     # display and update information about the top cpu processes
ps auxwww | grep <processname>          # display process status
CTRL-t                                  # on running commands will output useful info
systat -vmstat 1                        # show general overview of load, memory, interrupts, disk io
systat -iostat 1                        # show disk throughput
systat -ifstat 1                        # show network throughput for all interfaces
systat -netstat 1                       # show netstat output but automatically refreshed
systat -tcp 1                           # show tcp statistics
```

# ZFS

```
zfs list                                # list all zfs datasets (volumes)
zfs list -t snapshot                    # list all zfs snapshots
zfs list -r -t snapshot <pool>          # list zfs snapshots for a given pool
zfs snapshot <pool>/<dataset>@<name>    # generic way of creating a snapshot of a dataset in a storage pool
zfs snapshot -r tank@2014021301         # create a snapshot of all datasets in the pool "tank"
zfs create <pool>/<dataset>             # create a new dataset
zfs rollback <pool>/<dataset>@name      # rollback of a dataset to a given snapshot
zfs destroy <pool>/<dataset>            # destroy a dataset / remove it from the pool
zfs destroy <pool>/<dataset>@name       # destroy a snapshot
zfs set <key>=<val> <pool>/<dataset>    # generic way of setting options on a given dataset
zfs set compression=lz4 tank/var/log    # enable LZ4 compression on /var/logs
zfs get compressratio <pool>/<dataset>  # show the current compression ratio of a dataset
zfs send -R tank@snapshot | \           # send all datasets@snapshot recursively to another host
ssh root@[IP] zfs recv -F tank
zfs unmount <pool>/<dataset>            # unmount a zfs dataset
zfs upgrade -r <pool>                   # upgrade all volumes in the pool (technically its the root volume e.g. tank)
zpool status                            # show health info about currently imported ZFS storage pools
zpool scrub                             # check all written blocks for consistency
zpool iostat -v tank                    # show more information about the pool including log devices
zpool add <pool> mirror <dev1> <dev1>   # add two disks as mirror to a storage pool
zpool remove <pool> <device>            # remove single devices or mirror sets from the storage pool
zpool upgrade <pool>                    # upgrade the storage pool to latest version
zpool labelclear [-f] <pool>            # Clear vdev headers on disk of previous / faulted / obsolete pools
zfs send pool/volume@snapshot \         # Compress and Encrypt a snapshot and send it to a remote host for backups
  | lz4 \                               # Decrypt with: openssl enc -d -aes-256-cbc -a -in /path/to/backup/snapshot.lz4.ssl | unlz4 > /path/to/dest 
  | openssl enc -aes-256-cbc -a -salt -pbkdf2 \ # OR | zfs receive tank/volume
  | ssh u@h "cat > /snapshot.lz4.ssl
```

# Software

```
# Ports
portsnap fetch                          # fetch the latest portfiles
portsnap update                         # update the portfiles on disk with the previously fetched portfiles
portsnap update -p /usr/jails/basejail/usr/ports # update ports tree for jails
whereis <portname>                      # show the directory of the portfile
cd /usr/ports/*/<portname>              # find the parent directory of a given portname
locate <portname> | grep ports          # manual way of searching for ports
cd <portdir> && make install            # compile and install a port
cd <portdir> && make config             # re-run configuration of a port when available
cd <portdir> && sudo make deinstall clean reinstall # upgrade the port

# Packages
pkg search <packagename>                # search for binary packages
pkg install <packagename>               # install binary package and its dependencies
pkg delete  <packagename>               # delete an installed package
pkg autoremove                          # remove unneeded dependencies
pkg info                                # show list of currently installed ports/packages with version info
pkg version                             # show which ports/packages are outdated and need an update
pkg upgrade <packagename>               # upgrade a packages
pkg which <filename>                    # find out which package installed a given file
pkg audit -F                            # look for ports/packages with security vulnerabilities

# System
freebsd-update fetch                    # fetch updates from server
freebsd-update -r <target> upgrade      # fetch upgrades to specified version (e.g. '10.1-RELEASE') from server
freebsd-update install                  # install downloaded updates/upgrades
```

# Services

```
service -l                              # list all available services
service -e                              # list all enabled services
service <servicename> status            # show the status of the service with the given servicename
service <servicename> start             # start the service with the given servicename
service <servicename> stop              # stop the service with the given servicename
service <servicename> restart           # restart the service with the given servicename
service <servicename> reload            # reload the configuration of the service with the given servicename
```

# Network

```
ifconfig <iface> inet <ip/mask>         # configure IP address on interface
ifconfig <iface> inet <ip/mask> alias   # configure IP address alias on interface
ifconfig <iface> del <ip>               # remove IP address from interface
route add -net default <gw_ip>          # add default route
route add -net <ip/mask> <gw_ip>        # add a custom route for given network
/etc/rc.d/netif restart && \            # restart networking and routing after changing the configuration
/etc/rc.d/routing restart                 without rebooting. Execute in tmux or screen session
netstat -rn                             # display routing table
netstat -an                             # display all connections
netstat -m                              # display buffer usage
netstat -Lan                            # display status of listen queues
netstat -s                              # display extensive statistics per protocol (use -p tcp to only show tcp)
sockstat -l                             # display listening sockets, process names and pids
sockstat -4                             # display all IPv4 sockets - good with -l as above
sysctl kern.ipc.numopensockets          # display number of open sockets
vmstat -z | egrep "ITEM|tcpcb"          # number of hash table buckets to handle incoming tcp connections
                                          increase net.inet.tcp.tcbhashsize if hitting the limit
sysctl net.inet.tcp.hostcache.list      # display current content of hostcache with its parameters per IP
ssh <host> sudo tcpdump \               # Send remote tcpdump output to local wireshark for live analysis
  -i em0 -U \
  -w - "not port 22" | wireshark -i - -k
```

# Firewall

```
pfctl -si                               # show current state table and counters (useful for tuning)
pfctl -s state                          # show current content of state table
```

# IPsec

```
ipsec start                             # start VPN and establish (auto=start) VPN connections
setkey -D                               # show extensive Kernel information about current connections
setkey -DP                              # show more condensed connection information
ipsec statusall [conn]                  # show returns detailed status information either on connection or all 
                                          connections if no name is provided
ipsec leases                            # show current leases from virtual IP address pool
ipsec rereadsecrets                     # flushes and rereads all secrets defined in ipsec.secrets
ipsec rereadall                         # flushes and rereads all secrets defined in ipsec.secrets as well as all 
                                          certificates and and certificate revocation lists
ipsec update                            # sends a HUP signal to the daemon that determines any changes in ipsec.conf 
                                          and updates the configuration on the running IKE daemon charon
ipsec reload                            # sends a USR1 signal to the daemon that reloads the whole configuration 
                                          on the running IKE daemon charon based on the actual ipsec.conf
ipsec restart                           # terminates all ipsec connections, sends a TERM signal to the daemon and     
                                          restarts it afterwards
ipsec stroke up [conn]                  # initiate connection [conn]
ipsec stroke down [conn]                # terminate connection [conn]
```

# ezjail

```
ezjail-admin start|stop                 # start and stop all the jails
ezjail-admin start|stop <JID>|<hostname># start and stop individual jail
ezjail-admin list                       # list all the jails on the host system
ezjail-admin console <JID>|<hostname>   # open root shell into jail
ezjail-admin create -f exmaple <hostname> <IP> # create a new jail
ezjail-admin delete -w hostname         # delete the jail (in case you use zfs also delete the volume)
ezjail-admin update -U -s 11.1-RELEASE  # update basejail from -s <RELEASE> to current host system
```

# Boot Environments
```
bectl list                              # List existing boot environments
bectl create <envname>                  # Create a new boot environment e.g. 13_1_RELEASE
bectl mount <envname>                   # Mount boot environment temporary mountpoint like /tmp/be_mount.JO5Y
bectl activate -t <envname>             # Activate new boot environment for one-time-boot
bectl activate <envname>                # Activate new boot environment permanently
---
freebsd-update \                        # Example for upgrading FreeBSD to a release in a boot environment
-b /tmp/be_mount.JO5Y \
-d /tmp/be_mount.JO5Y/var/db/freebsd-update \
-r 13.1-RELEASE upgrade
