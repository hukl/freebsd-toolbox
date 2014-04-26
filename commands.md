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
sysctl                                  # tool to show/set all system/kernel coniguration variables
sysctl -a                               # show all stystem/kernel configuration variables
sysctl hw                               # show hardware related info and settings
sysctl net                              # show all network related info and settings
sysctl hw.model                         # show CPU model
sysctl net.inet.tcp.delayed_ack=0       # disable delayed ack in tcp
```


# System Statistics

```
top                                     # display and update information about the top cpu processes
ps auxwww | grep <processname>          # display process status
ifconfig                                # show and configure network interface parameters
systat -vmstat 1                        # show general overview of load, memory, interrupts, disk io
systat -iostat 1                        # show disk throughput
systat -ifstat 1                        # show network throughput for all interfaces
systat -netstat 1                       # show netstat output but automatically refreshed
systat -tcp 1                           # show tcp statistics
```

# ZFS

```
zfs list                                # list all zfs datasets (volumes)
zfs snapshot <pool>/<dataset>@<name>    # generic way of creating a snapshot of a dataset in a storage pool
zfs snapshot -r tank@2014021301         # create a snapshot of all datasets in the pool "tank"
zfs rollback <pool>/<dataset>@name      # rollback of a dataset to a given snapshot
zfs destroy <pool>/<dataset>            # destroy a dataset / remove it from the pool
zfs destroy <pool>/<dataset>@name       # destroy a snapshot
zfs set <key>=<val> <pool>/<dataset>    # generic way of setting options on a given dataset
zfs set compression=lzjb tank/var/log   # enable LZJB compression on /var/logs
zfs get compressratio <pool>/<dataset>  # show the current compression ratio of a dataset
zfs send -R tank@snapshot | \           # send all datasets@snapshot recursively to another host
ssh root@[IP] zfs recv -F tank
zfs unmount <pool>/<dataset>            # unmount a zfs dataset
zpool status                            # show health info about currently imported ZFS storage pools
zpool scrub                             # check all written blocks for consistency
zpool iostat -v tank                    # show more information about the pool including log devices
zpool add <pool> mirror <dev1> <dev1>   # add two disks as mirror to a storage pool
zpool remove <pool> <device>            # remove single devices or mirror sets from the storage pool
```

# Software

```
# Ports
portsnap fetch                          # fetch the latest portfiles
portsnap update                         # update the portfiles on disk with the previously fetched portfiles
whereis <portname>                      # show the directory of the portfile
cd /usr/ports/*/<portname>              # find the parent directory of a given portname
locate <portname> | grep ports          # manual way of searching for ports
cd <portdir> && make install            # compile and install a port
cd <portdir> && make config             # re-run configuration of a port when available

# Packages
pkg search <packagename>                # search for binary packages
pkg install <packagename>               # install binary package and its dependencies
pkg info                                # show list of currently installed ports/packages with version info
pkg version                             # show which ports/packages are outdated and need an update
pkg upgrade <packagename>               # upgrade a packages
pkg which <filename>                    # find out which package installed a given file
```

# Network

```
 /etc/rc.d/netif restart && \           # restart networking and routing after changing the configuration
 /etc/rc.d/routing restart                without rebooting. Execute in tmux or screen session
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
