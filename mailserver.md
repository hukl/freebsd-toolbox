# Upgrading Postfix & Dovecot

First lock the ports so they don't get upgraded by pkg
```
sudo pkg lock postfix dovecot dovecot-pigeonhole
```
Upgrade all other packages through pkg
```
sudo pkg upgrade
```
Unlock postfix, dovecot and dovecot-pigeonhole
```
sudo pkg unlock postfix dovecot dovecot-pigeonhole
```
Upgrade postfix, dovecot and dovecot-pigeonhole via ports
```
cd /usr/ports/mail/postfix
sudo make deinstall clean reinstall

cd /usr/ports/mail/dovecot
sudo make deinstall clean reinstall

cd /usr/ports/mail/dovecot-pigeonhole
sudo make deinstall clean reinstall
```
After that, lock ports again to prevent accidental binary upgrades
```
sudo pkg lock postfix dovecot dovecot-pigeonhole
```



# Dovecot

### Create Password

```
doveadm pw -s SHA512-CRYPT
```

### Migrate a User from old Server
```
sudo -u vmail doveadm -o imapc_user=user@domain -o imapc_password=foobar backup -R -u user@domain imapc:
```
