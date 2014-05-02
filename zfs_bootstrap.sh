#!/bin/sh

# Check:
# https://wiki.freebsd.org/RootOnZFS/GPTZFSBoot/Mirror
# http://wp.strahlert.net/wordpress/zfs-2/expanding-zpool/


# Create Partition Table
echo "Create Partition Table"
gpart create -s gpt ada0 # Main HDD
gpart create -s gpt ada1 # Main HDD

# Optional if you have SSDs for ZIL and L2ARC
# gpart create -s gpt ada2 # ZIL and L2ARC SSD
# gpart create -s gpt ada3 # ZIL and L2ARC SSD


# Create Boot Partition
echo "Create Boot Partition"
gpart add -a 4k -s 64k -t freebsd-boot ada0
gpart add -a 4k -s 64k -t freebsd-boot ada1


# Create Swap Partitions
echo "Create Swap Partitions"
gpart add -a 4k -s 2G -t freebsd-swap -l swap0 ada0
gpart add -a 4k -s 2G -t freebsd-swap -l swap1 ada1


# Create Main Partitions
echo "Create Main Partitions"
gpart add -a 4k -t freebsd-zfs -l disk0 ada0
gpart add -a 4k -t freebsd-zfs -l disk1 ada1


# Write Bootcode
echo "Write Bootcode"
gpart bootcode -b /boot/pmbr -p /boot/gptzfsboot -i 1 ada0
gpart bootcode -b /boot/pmbr -p /boot/gptzfsboot -i 1 ada1


# Create ZIL Partions
# echo "Create ZIL Partions"
# gpart add -a 4k -b 2048 -s 10G -t freebsd-zfs -l zil0 ada2
# gpart add -a 4k -b 2048 -s 10G -t freebsd-zfs -l zil1 ada3


# Create L2ARC Partitions
# echo "Create L2ARC Partitions"
# gpart add -a 4k -t freebsd-zfs -l l2arc0 ada2
# gpart add -a 4k -t freebsd-zfs -l l2arc1 ada3


# Create ZFS Pool
echo "Create ZFS Pool"
zpool create tank mirror /dev/gpt/disk0 /dev/gpt/disk1

# Set proper mountpoint
echo "Setting Mountpoint"
zfs set mountpoint=/ tank

# Export and import the Pool 
zpool export tank
zpool import -o altroot=/mnt -o cachefile=/var/tmp/zpool.cache tank

# Enable Compression
echo "Enabling Compression"
zfs set compression=lz4 tank


# Add ZIL and L2ARC
# echo "Add ZIL and L2ARC"
# zpool add tank log mirror /dev/gpt/zil0 /dev/gpt/zil1
# zpool add tank cache /dev/gpt/l2arc0 /dev/gpt/l2arc1


# Set BOOTFS
echo "Set BOOTFS"
zpool set bootfs=tank tank


# Copy FreeBSD files
echo "Installing FreeBSD"

cd /usr/freebsd-dist
export DESTDIR=/mnt
for f in base.txz lib32.txz kernel.txz doc.txz ports.txz src.txz;do
  (cat $f | tar --unlink -xvpJf - -C ${DESTDIR:-/}); 
done

cp /var/tmp/zpool.cache /mnt/boot/zfs/


cat > /etc/rc.conf << RCCONF
hostname="my.host.name"

zfs_enable="YES"

# Network

defaultrouter="xxx.xxx.xxx.xxx"
ifconfig_em1="inet xxx.xxx.xxx.xxx/xx"

# Services
sendmail_enable="NONE"
sshd_enable="YES"
RCCONF


cat > /etc/fstab << FSTAB
# Device                       Mountpoint              FStype  Options         Dump    Pass#
/dev/gpt/swap0                 none                    swap    sw              0       0
/dev/gpt/swap1                 none                    swap    sw              0       0
FSTAB


cat > /boot/loader.conf << LOADER
zfs_load="YES"
vfs.root.mountfrom="zfs:tank"
vfs.zfs.arc_max="16G"
LOADER
