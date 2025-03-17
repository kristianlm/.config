
# kee

Gammel Asus EEE maskin. Den er 32-bit, og kjørte Debian i 2 år. Men 


```
$ set -U disk $(guix system image --volatile --system=i686-linux ~/.config/system-kee/system-kee.scm)
$ qemu-system-i386 -accel kvm -m 2G -drive file=$disk,format=raw -snapshot -nographic -netdev user,id=n0,help \
 -device e1000,netdev=n0,mac=00:24:8c:78:c0:a9
```
