#!/bin/bash

# 以 root 运行

# 修改文件所有者为 root，因为 chroot 后权限一致
chown -R root:root $LFS/{usr,lib,var,etc,bin,sbin,tools}
chown -R root:root $LFS/lib64

# 创建虚拟文件系统的挂载点
mkdir -pv $LFS/{dev,proc,sys,run}

# 创建初始设备节点
mknod -m 066 $LFS/dev/console c 5 1
mknod -m 666 $LFS/dev/null c 1 3

# 绑定挂载 /dev
mount -v --bind /dev $LFS/dev

# 挂载虚拟内核文件系统

mount -v --bind /dev/pts $LFS/dev/pts

mount -vt proc proc $LFS/proc
mount -vt sysfs sysfs $LFS/sys
mount -vt tmpfs tmpfs $LFS/run

mkdir -pv $LFS/$(readlink $LFS/dev/shm)

#chroot "$LFS" /usr/bin/env -i   \
#    HOME=/root                  \
#    TERM="$TERM"                \
#    PS1='(lfs chroot) \u:\w\$ ' \
#    PATH=/usr/bin:/usr/sbin \
#    /bin/bash --login +h

