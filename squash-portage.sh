#!/bin/bash
SQFS_CUR="/usr/portage.sqfs"
OVERLAY_DIR="/dev/shm/.portage-overlay"
RO_DIR="/usr/portage-ro"
PORT_DIR="/usr/portage"
UPPER_DIR="$OVERLAY_DIR/upper"
WORK_DIR="$OVERLAY_DIR/work"
SQFS_NEW="$OVERLAY_DIR/portage-new.sqfs"


start() {
	echo "Mounting read-only portage tree squashfs image"
	[ -d $RO_DIR ] || mkdir -p $RO_DIR
	mount -rt squashfs -o loop,nodev,noexec $SQFS_CUR $RO_DIR
	retval=$?
	#eend $?
	[ $retval -ne 0 ] && return $retval

	echo "Mounting read-write portage tree with overlay"
	[ -d $UPPER_DIR ] || mkdir -p $UPPER_DIR
	[ -d $WORK_DIR ] || mkdir -p $WORK_DIR

	mount -t overlay -o lowerdir=$RO_DIR,upperdir=$UPPER_DIR,workdir=$WORK_DIR overlay $PORT_DIR
	#eend $?
}

stop() {
	if [ ! -z `ls $UPPER_DIR | head -n1` ]; then
		echo "Update portage tree squashfs"
		#        mksquashfs $PORT_DIR $SQFS_NEW -comp xz -b 1M -Xdict-size 100% 2>/dev/null
		mksquashfs $PORT_DIR $SQFS_NEW 2>/dev/null
		#eend $?
	fi
	echo "Unmounting portage tree"
	umount -t overlay $PORT_DIR
	umount -t squashfs $RO_DIR
	if [ -f $SQFS_NEW ]; then
		mv $SQFS_NEW $SQFS_CUR
	fi
	rm -rf $OVERLAY_DIR
	#eend 0
}

if [ -z $1 ]; then
	start
else
	if [ $1 = "start" ]; then
		start
	fi

	if [ $1 = "stop" ]; then
		stop
	fi
fi
