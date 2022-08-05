## References

* https://docs.freebsd.org/en/books/handbook/cutting-edge/

## Preparations

https://www.freebsd.org/releases/13.1R/relnotes/


## General Procedure

* Check Release Notes for potentially breaking changes (which is rare)
* ZFS Snapshot `zfs snapshot -r tank@2022-08-05_01`
* Create Boot Environemnt `bectl create 13_1_RELEASE`
* Mount Boot Environment `bectl mount 13_1_RELEASE`
* Run FreeBSD Upgrade 
  ```sh
  freebsd-update \                     
  -b /tmp/be_mount.JO5Y \
  -d /tmp/be_mount.JO5Y/var/db/freebsd-update \
  -r 13.1-RELEASE upgrade
  ```
* Run `freebsd-update install` with the same flags, two times in a row without rebooting
* Disable ezjail in rc.conf
* Temporarily activate boot environment `bectl activate -t 13_1_RELEASE`
* When machine is back up, delete ezjail basejail and newjail `zfs destroy tank/ezjail/basejail` and `zfs destroy tank/ezjail/newjail`
* Re-install ezjail basejail and newjail `ezjail-admin install -sp`
* Mergemaster jails, starting with the most important ones `sudo mergemaster -U -D /usr/jails/lb-01.production.soba.gg`
* Check ZFS `zpool status`
