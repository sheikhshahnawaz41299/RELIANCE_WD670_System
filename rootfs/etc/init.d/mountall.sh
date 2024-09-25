#!/bin/sh
### BEGIN INIT INFO
# Provides:          mountall
# Required-Start:    mountvirtfs
# Required-Stop: 
# Default-Start:     S
# Default-Stop:
# Short-Description: Mount all filesystems.
# Description:
### END INIT INFO

. /etc/default/rcS

#
# Mount local filesystems in /etc/fstab. For some reason, people
# might want to mount "proc" several times, and mount -v complains
# about this. So we mount "proc" filesystems without -v.
#
test "$VERBOSE" != no && echo "Mounting local filesystems..."
mount -at nonfs,nosmbfs,noncpfs 2>/dev/null

#
# We might have mounted something over /dev, see if /dev/initctl is there.
#
if test ! -p /dev/initctl
then
	rm -f /dev/initctl
	mknod -m 600 /dev/initctl p
fi
kill -USR1 1

#
# Execute swapon command again, in case we want to swap to
# a file on a now mounted filesystem.
#
swapon -a 2> /dev/null


#wewins
FindAndMountVolumeUBI () {
   volume_name=$1
   dir=$2
   if [ ! -d $dir ]
   then
       mkdir -p $dir
   fi
   mount -t ubifs ubi0:$volume_name $dir -o bulk_read
}

ActionForOTA()
{
	mkdir /cache
#cachfs_id=`ubinfo /dev/ubi0 -N cachefs | grep -i volume | sed 's/^Volume ID:   //' | awk -F ' ' '{print $1}'`
	mount -t ubifs -o sync /dev/ubi0_2 /cache 

	if [ -f /cache/recovery/install_next_boot.sh ]; then
		mkdir /cache/log
		chmod +x /cache/recovery/install_next_boot.sh
		/cache/recovery/install_next_boot.sh > /cache/log/install_next_boot.log 2>&1
		rm /cache/recovery/install_next_boot.sh
	fi

	if [ -f /cache/recovery/install_clean.sh ]; then
		chmod +x /cache/recovery/install_clean.sh
		/cache/recovery/install_clean.sh > /cache/log/install_clean.log 2>&1
		rm /cache/recovery/install_clean.sh
	fi
}

mtd_file=/proc/mtd

fstype="UBI"
eval FindAndMountVolume${fstype} usrfs /data

ActionForOTA

: exit 0

