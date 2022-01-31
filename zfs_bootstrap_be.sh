#!/bin/sh

# Check:
# https://wiki.freebsd.org/RootOnZFS/GPTZFSBoot/9.0-RELEASE
# http://wp.strahlert.net/wordpress/zfs-2/expanding-zpool/
# This script will add ZFS Boot-Enironment support

# Tested on FreeBSD 10, 11 and 12

###############################################################
# WARNING: Go through line by line and adjust where necessary #
###############################################################

# Create Partition Table
echo "Create Partition Table"
gpart create -s gpt ada0 # Main HDD
gpart create -s gpt ada1 # Main HDD

# Optional if you have SSDs for ZIL and L2ARC
# gpart create -s gpt ada2 # ZIL and L2ARC SSD
# gpart create -s gpt ada3 # ZIL and L2ARC SSD


# Create Boot Partition
echo "Create Boot Partition"
gpart add -a 4k -s 512k -t freebsd-boot ada0
gpart add -a 4k -s 512k -t freebsd-boot ada1


# Create Swap Partitions
echo "Create Swap Partitions"
gpart add -a 4k -s 8G -t freebsd-swap -l swap0 ada0
gpart add -a 4k -s 8G -t freebsd-swap -l swap1 ada1


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


# Load ZFS extensions
kldload opensolaris.ko
kldload zfs.ko


# Force ZFS to use 4k sectors
sysctl vfs.zfs.min_auto_ashift=12

# Create ZFS Pool
echo "Create ZFS Pool"
zpool create -o altroot=/mnt -o cachefile=/var/tmp/zpool.cache -f tank mirror /dev/ada0p3 /dev/ada1p3

# Enable Compression
echo "Enabling Compression"
zfs set compression=lz4 tank

# Add ZIL and L2ARC
# echo "Add ZIL and L2ARC"
# zpool add tank log mirror /dev/gpt/zil0 /dev/gpt/zil1
# zpool add tank cache /dev/gpt/l2arc0 /dev/gpt/l2arc1

# Create a very minimal ZFS Boot Environment Layout
# https://wiki.freebsd.org/BootEnvironments
# https://klarasystems.com/articles/managing-boot-environments/
echo "Creating zfs boot-environment layout"
zfs create -o mountpoint=none tank/ROOT
zfs create -o mountpoint=/ tank/ROOT/default

# Set BOOTFS
echo "Set BOOTFS"
zpool set bootfs=tank/ROOT/default tank
zpool set cachefile=/var/tmp/zpool.cache tank

# Copy FreeBSD files
echo "Installing FreeBSD"

cd /usr/freebsd-dist
export DESTDIR=/mnt
for f in base.txz lib32.txz kernel.txz doc.txz ports.txz src.txz;do
  (cat $f | tar --unlink -xvpJf - -C ${DESTDIR:-/});
done

echo "Enter hostname FQDN"
read HOSTNAME

echo "Enter last public IP octet"
read IP_ENDING

echo "Enter username"
read USERNAME

cat > /mnt/etc/rc.conf << RCCONF
hostname="$HOSTNAME"

zfs_enable="YES"

# Network

defaultrouter="0.0.0.0"
ifconfig_igb0="inet 0.0.0.$IP_ENDING/32"

# Services
sendmail_enable="NONE"
sshd_enable="YES"
RCCONF


cat > /mnt/etc/fstab << FSTAB
# Device                       Mountpoint              FStype  Options         Dump    Pass#
/dev/gpt/swap0                 none                    swap    sw              0       0
/dev/gpt/swap1                 none                    swap    sw              0       0
FSTAB


cat >> /mnt/boot/loader.conf << LOADER
opensolaris_load="YES"
zfs_load="YES"
vfs.zfs.arc_max="8G"
LOADER

cat >> /mnt/etc/sysctl.conf << SYSCTL
vfs.zfs.min_auto_ashift=12
SYSCTL


cat > /mnt/etc/resolv.conf << RESOLV
nameserver 0.0.0.0
nameserver 0.0.0.0
RESOLV


# Mount a devfs to have /dev/random /dev/zero etc in our chroot
mount -t devfs none /mnt/dev

# Bootstap pkg and install minimal packages for ansible
chroot -u root -g wheel /mnt/ env ASSUME_ALWAYS_YES=YES pkg bootstrap
chroot -u root -g wheel /mnt/ env ASSUME_ALWAYS_YES=YES pkg install sudo zsh

# Add user
chroot -u root -g wheel /mnt/ pw useradd -n $USERNAME -u 1001 -s /usr/local/bin/zsh -m -d /home/$USERNAME -G wheel -h 0

# Fetch user pub key from github
mkdir -p /mnt/home/$USERNAME/.ssh

# This fetches the pub key from the sepcified github users and adds them 
# to the .authorized_keys of the new system user
echo "List of Github users for pubkey retrieval (space separated):"
read users

for user in $users; do
  fetch https://github.com/$user.keys --no-verify-peer -o - >> /mnt/home/deploy/.ssh/authorized_keys
done

chown -R 1001:1001 /mnt/home/$USERNAME/.ssh

echo "Done"
