#!/bin/sh

var_path=`cat /app/config/var.conf`

at_test at+cpin? | busybox grep "SIM not inserted"

if [ $? -eq 0 ]; then
  busybox echo 0 >  ${var_path}/modem/sim_st
else
  busybox echo 1 >  ${var_path}/modem/sim_st
fi

