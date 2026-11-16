


```
i3-msg exit 

# dette kræsjer hvis du kjører X11
echo "0000:01:00.0" > /sys/bus/pci/devices/0000:01:00.0/driver/unbind
echo "0000:01:00.1" > /sys/bus/pci/devices/0000:01:00.1/driver/unbind

# men nå kan du gå tilbake til X11.
```

nå skal ting se slik ut:

```
klm@rex ~ > sudo lspci -kd 10de:
01:00.0 VGA compatible controller: NVIDIA Corporation GP106 [GeForce GTX 1060 3GB] (rev a1)
	Subsystem: Micro-Star International Co., Ltd. [MSI] Device 3287
	Kernel modules: nouveau
01:00.1 Audio device: NVIDIA Corporation GP106 High Definition Audio Controller (rev a1)
	Subsystem: Micro-Star International Co., Ltd. [MSI] Device 3287
	Kernel modules: snd_hda_intel
```

da skal vi få opp vfio.

```
echo 10de 1c02 > /sys/bus/pci/drivers/vfio-pci/new_id
```
