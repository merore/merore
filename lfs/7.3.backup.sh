#!/bin/bash

LFS=/mnt/lfs

umount $LFS/dev{/pts,}
umount $LFS/{sys,proc,run}
cd $LFS
tar -cJpf $HOME/lfs-temp-tools-11.0-systemd.tar.xz .

