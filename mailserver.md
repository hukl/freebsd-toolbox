# Dovecot

### Create Password

```
doveadm pw -s SHA512-CRYPT
```

### Migrate a User from old Server
```
sudo -u vmail doveadm -o imapc_user=user@domain -o imapc_password=foobar backup -R -u user@domain imapc:
```
