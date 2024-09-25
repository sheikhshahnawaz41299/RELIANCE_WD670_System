#!/bin/sh
/usr/sbin/mkfs.ubifs -m 4096 -e 253952 -c 261 -x lzo -f 8 -k r5 -p 1 -l 4 -r ./rootfs img-396211929_vol-rootfs.ubifs
/usr/sbin/mkfs.ubifs -m 4096 -e 253952 -c 899 -x lzo -f 8 -k r5 -p 1 -l 4 -r ./usrfs img-396211929_vol-usrfs.ubifs
/usr/sbin/mkfs.ubifs -m 4096 -e 253952 -c 265 -x lzo -f 8 -k r5 -p 1 -l 4 -r ./cachefs img-396211929_vol-cachefs.ubifs
/usr/sbin/ubinize -p 262144 -m 4096 -O 4096 -s 4096 -x 1 -o img-396211929.ubi img-396211929.ini
