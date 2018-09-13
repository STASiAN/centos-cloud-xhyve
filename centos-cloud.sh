#!/bin/sh
curl -s https://cloud.centos.org/centos/7/images/sha256sum.txt -O
VER=$(tail -n1 sha256sum.txt | cut -d ' ' -f3 | cut -d . -f 1)
IMG=$VER.raw
URL=https://cloud.centos.org/centos/7/images
wget -c $URL/$IMG.tar.gz
shasum sha256sum.txt && if [ ! -f $VER.raw ]; then tar xvzf $VER.raw.tar.gz; fi
mkisofs -output $VER-cidata.iso -volid cidata -joliet -rock user-data meta-data 2> /dev/null
KERNEL=$(ls -1 | grep vmlinuz)
INITRD=$(ls -1 | grep initramfs) 
ISO="$VER-cidata.iso"
CMDLINE="earlyprintk=serial console=ttyS0 root=/dev/vda1 ro crashkernel=auto"
MEM="-m 4G"
SMP="-c 2"
#ACPI="-A"
NET="-s 2:0,virtio-net"
PCI_DEV="-s 0:0,hostbridge -s 31,lpc"
LPC_DEV="-l com1,stdio"
IMG_CD="-s 3:0,ahci-cd,$ISO"
IMG_HDD="-s 4,virtio-blk,$IMG"

./xhyve $ACPI $MEM $SMP $PCI_DEV $LPC_DEV $NET $IMG_CD $IMG_HDD $UUID -f kexec,$KERNEL,$INITRD,"$CMDLINE"
