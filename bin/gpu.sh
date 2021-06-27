#!/bin/sh

# inspired by
# https://arseniyshestakov.com/2016/03/31/how-to-pass-gpu-to-vm-and-back-without-x-restart/


t=$1

if [ "" = "$t" ] ; then
    echo "usage: amdgpu|vfio"
    echo "  give my GPU hardware to specifiec driver"
    exit 0
fi

if [ "amdgpu" = "$t" ] ; then
    # lose the current driver
    echo "0000:01:00.0" > /sys/bus/pci/devices/0000:01:00.0/driver/unbind
    echo "0000:01:00.1" > /sys/bus/pci/devices/0000:01:00.1/driver/unbind
    # add the amdgpu one
    echo "1002 0501" > /sys/bus/pci/drivers/amdgpu/new_id
    echo "1002 aaf0" > /sys/bus/pci/drivers/amdgpu/new_id
fi

# this currently crashes my machine, but I'm leaving it here because
# it _should_ work (I think).
if [ "vfio" = "$t" ] ; then
    # lose the current driver
    echo "0000:01:00.0" > /sys/bus/pci/devices/0000:01:00.0/driver/unbind
    echo "0000:01:00.1" > /sys/bus/pci/devices/0000:01:00.1/driver/unbind
    # echo 1 > /sys/bus/pci/devices/0000:01:00.0/remove
    # echo 1 > /sys/bus/pci/devices/0000:01:00.1/remove
    echo 1 > /sys/bus/pci/rescan
fi

