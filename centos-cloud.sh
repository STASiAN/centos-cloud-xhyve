#!/bin/sh
curl -s https://cloud.centos.org/centos/7/images/sha256sum.txt -O
VER=$(tail -n1 sha256sum.txt | cut -d ' ' -f3 | cut -d . -f 1)
URL=https://cloud.centos.org/centos/7/images
wget -c $URL/$VER.raw.tar.gz
shasum sha256sum.txt && if [ ! -f *.raw ]; then tar xvzf $VER.raw.tar.gz; fi
hdiutil makehybrid -hfs -joliet -iso -default-volume-name cidata cidata -o $VER-cidata.iso 2> /dev/null
IMG=$(ls -1 | grep raw$)
KERNEL=$(ls -1 | grep vmlinuz | tail -n 1 )
INITRD=$(ls -1 | grep initramfs | tail -n 1)
ISO="$VER-cidata.iso"
CMDLINE="earlyprintk=serial console=ttyS0 root=/dev/vda1 ro crashkernel=auto"
MEM="-m 4G"
SMP="-c 2"
ACPI="-A"
NET="-s 2:0,virtio-net"
PCI_DEV="-s 0:0,hostbridge -s 31,lpc"
LPC_DEV="-l com1,stdio"
IMG_CD="-s 3:0,ahci-cd,$ISO"
IMG_HDD="-s 4,virtio-blk,$IMG"
UUID="-U deadbeef-dead-dead-dead-deaddeafbeef"

screen -mS "$VER" sudo ./xhyve -H -P $ACPI $MEM $SMP $PCI_DEV $LPC_DEV $NET $IMG_CD $IMG_HDD $UUID -f kexec,$KERNEL,$INITRD,"$CMDLINE"
