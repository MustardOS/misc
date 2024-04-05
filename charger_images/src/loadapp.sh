#!/system/bin/sh

BIN="/system/dmenu/dmenu_ln"

DEBUG="/mnt/data/xudebug.ini"

needSync=0

# load dynamic library
LDD_FILE="/lib/ld-linux-armhf.so.3"


if [ ! -f  $LDD_FILE ]
then
	cp -Rf /system/usr/local/lib   /
#	cp -Rf /libdeepJoy.so   /lib
	
#os + game in one TF
	mount -t vfat -o rw,utf8,noatime,nodiratime /dev/block/mmcblk0p4   /mnt/mmc

fi


if [ $needSync -eq 1 ]
then
	echo "exec sync"
	/system/bin/sync
	echo "exec sync done"
fi

while [ -f $DEBUG ]
do
	sleep 30
done

while [ -f $BIN ]
do
#	sleep 2
	$BIN
done

