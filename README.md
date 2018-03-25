# SQUASH-PORTAGE

Scripts for squashing portage tree.

Based on solution from https://www.brunsware.de/blog/gentoo/portage-tree-squashfs-overlayfs.html

__It is important to read the article and prepare portage configuration.__


Required kernel options:
```bash
File systems  --->
 [*] Miscellaneous filesystems  --->
   <*>   SquashFS 4.0 - Squashed file system support
...
 <*> Overlay filesystem support
```

Install squashfs-tools
```bash
emerge -av squashfs-tools
```

## Preparation
Make new DISTDIR folder outside $PORTDIR:

```bash
mkdir -p /var/lib/portage/distfiles
chown portage:portage /var/lib/portage/distfiles
```

Move $DISTDIR to new destination in /etc/portage/make.conf. For example:

```bash
DISTDIR="/var/lib/portage/distfiles"
```
Remove old $DISTDIR directory content
```bash
rm /usr/portage/distfiles/*
```

Make directory for lower overlayfs layer

```bash
mkdir /usr/portage-ro
```
## Installation

Create squashfs portage file and remove $PORTDIR content:

```bash
mksquashfs /usr/portage /usr/portage.sqfs
rm -r /usr/portage/*
```


### squash script
Symlink squash-portage.sh to /usr/local/bin:

```bash
ln -s squash-portage.sh /usr/local/bin/squash-portage
chmod u+x /usr/local/bin/squash-portage
```

### systemd service
For systemd, symlink service file to /etc/systemd/system/squash-portage.service

```bash
ln -s squash-portage.service /etc/systemd/system/squash-portage.service
systemctl enable squash-portage.service
```
### emerge --sync hook

Create a file in /etc/portage/postsync.d. 

/etc/portage/postsync.d/squash-portage
```bash
#!/bin/bash
systemctl restart squash-portage

```
