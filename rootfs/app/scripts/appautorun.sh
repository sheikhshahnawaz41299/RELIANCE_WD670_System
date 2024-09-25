#!/bin/sh

export PATH=/app/bin:$PATH
export LD_LIBRARY_PATH=/app/lib:$LD_LIBRARY_PATH

data_path="/ww_data"
nv_path="/ww_data/nv"
mkdir ${data_path}

mtd_file=/proc/mtd

mtd_block_number=`cat $mtd_file | grep -i data | sed 's/^mtd//' | awk -F ':' '{print $1}'`
ubiattach /dev/ubi_ctrl -m $mtd_block_number -d 3 -b 5
ubimkvol /dev/ubi3 -s 4MiB -N data 
while [ 1 ]
do
	if [ -c /dev/ubi3_0 ];then
		mount -t ubifs -o sync /dev/ubi3_0 ${data_path}
		break
	else
		ubimkvol /dev/ubi3 -s 4MiB -N data 
		sleep 0.010
	fi
done
#mkdir /webui
#mtd_block_number=`cat $mtd_file | grep -i webui | sed 's/^mtd//' | awk -F ':' '{print $1}'`
#ubiattach /dev/ubi_ctrl -m $mtd_block_number -d 4 -b 5
#mount -t ubifs /dev/ubi4_0 /webui

/app/scripts/usb_mode.sh

var_path=`cat /app/config/var.conf`

mkdir ${var_path}
mkdir ${var_path}/run
mkdir ${var_path}/lib
mkdir ${var_path}/lib/misc/
mkdir ${var_path}/tmp
mkdir ${var_path}/boa
mkdir ${var_path}/modem
mkdir ${var_path}/modem/stat
mkdir ${var_path}/modem/time
mkdir ${var_path}/dnrd
mkdir ${var_path}/fota
mkdir ${var_path}/db
mkdir ${data_path}/property
mkdir ${var_path}/batt
mkdir ${var_path}/sysinfo
mkdir ${var_path}/config
mkdir /app/log/

#rm -rf /app/var
#ln -sf /var/volatile /app/var

busybox chmod a-x,go-w  ${var_path}/dnrd

mkdir /tmp

# ln -s /system/vendor/wewins/app /app
# ln -s /system/vendor/wewins/webui /webui
# ln -s /app/lib /lib
# ln -s /system/bin/busybox /app/bin/syslogd
# ln -s /system/bin/busybox /app/bin/klogd
#ln -s /bin/busybox /app/bin/syslogd
#ln -s /bin/busybox /app/bin/klogd

# chmod -R 0777 /system/vendor/wewins/app/bin
# chmod -R 0777 /system/vendor/wewins/app/lib
# chmod -R 0777 /system/vendor/wewins/app/scripts

# rm /system/bin/ifconfig
# busybox ln -s busybox /system/bin/ifconfig
# rm /system/bin/route
# busybox ln -s busybox /system/bin/route
# busybox ln -s busybox /system/bin/killall
# busybox ln -s busybox /system/bin/echo

rm -rf /etc/hosts
ln -sf ${var_path}/hosts /etc/hosts
rm -rf /etc/dnrd
ln -sf ${var_path}/dnrd /etc/dnrd
rm -rf /etc/resolv.conf
ln -sf ${var_path}/resolv.conf /etc/resolv.conf

busybox echo 1 > /proc/sys/net/ipv4/ip_forward

busybox echo 1 > /proc/sys/net/ipv6/conf/all/forwarding

busybox echo 1,0 > ${var_path}/modem/time/phase
busybox echo 0 > ${var_path}/modem/time/phase_lock

busybox cp -rf ${nv_path}/stat_conntime  ${var_path}/modem/stat/backup_stat_conntime
busybox cp -rf ${nv_path}/stat_rxbytes   ${var_path}/modem/stat/backup_stat_rxbytes
busybox cp -rf ${nv_path}/stat_txbytes   ${var_path}/modem/stat/backup_stat_txbytes

#open roam
if [ "0"x != "`busybox cat ${nv_path}/data_roarming`x" ];then
    busybox echo 0 > ${nv_path}/data_roarming
fi

#syslogd -L -s 32 -b 1 &
# start time services, must before boa
ww_time_daemon

# sleep 3
at &
ww_qmi_proxy &

# let modem works, but tx and rx circuits are turned off
at_test at+cfun=4

# upgrade
/app/scripts/upgrade.sh

# uim status
/app/scripts/gen_uim_status.sh

# imsi
/app/scripts/gen_imsi.sh

# imei
/app/scripts/gen_imei.sh

# spn
/app/scripts/gen_spn.sh

#start app
ww_netctrlc start
wnet &
boa &
hf_server &

key_led&

insmod /lib/modules/rtl8192es.ko
#insmod /lib/modules/rtl8189es.ko

sysconf init

patrol &

klogd&


#disable dload mode
echo 0 > /sys/module/msm_poweroff/parameters/download_mode 
echo 1 > /app/var/modem/hplmn_valid
echo 1 > /app/var/modem/spn_valid
echo "" > /ww_data/nv/usb3g_apn_0
echo auto > /ww_data/nv/usb3g_apn_name_0
at_tools ven_set_pdp_context
