## References

* https://docs.freebsd.org/en/books/handbook/cutting-edge/
* https://klarasystems.com/articles/managing-boot-environments/

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
* Run the following command 2x in a row without rebooting 
  ```sh
  freebsd-update \                     
  -b /tmp/be_mount.JO5Y \
  -d /tmp/be_mount.JO5Y/var/db/freebsd-update \
  install
  ````
* Disable ezjail in rc.conf
* Temporarily activate boot environment `bectl activate -t 13_1_RELEASE`
* After successful reboot, permanently activate boot environment  `bectl activate 13_1_RELEASE`
* Delete ezjail basejail and newjail `zfs destroy tank/ezjail/basejail` and `zfs destroy tank/ezjail/newjail`
* Re-install ezjail basejail and newjail `ezjail-admin install -sp`
* Mergemaster jails, starting with the most important ones `etcupdate -D /path/to/jail` or use the `quicketc.sh` script included in this repo to speed up the process
* Check ZFS `zpool status`
