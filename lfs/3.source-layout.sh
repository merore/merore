#!/bin/bash

LFS=/mnt/lfs

mkdir -v $LFS/sources
chmod -v a+wt $LFS/sources


cd $LFS/sources
wget https://mirrors.ustc.edu.cn/lfs/lfs-packages/lfs-packages-11.0.tar
tar --strip-components 1 -xf lfs-packages-11.0.tar
md5sum -c md5sums


# 创建目录布局 
mkdir -pv $LFS/{etc,var} $LFS/usr/{bin,lib,sbin}
for i in bin lib sbin; do
	ln -sv usr/$i $LFS/$i
done

mkdir -pv $LFS/lib64

mkdir -pv $LFS/tools

# 设置 lfs 用户

groupadd lfs
useradd -s /bin/bash -g lfs -m -k /dev/null lfs
echo -e "lfs\nlfs" | passwd lfs

chown -v lfs $LFS/{usr,{/*},lib,var,etc,bin,sbin,tools}
chown -v lfs $LFS/lib64
chown -v lfs $LFS/sources

[ ! -e /etc/bash.bashrc ] || mv -v /etc/bash.bashrc /etc/bash.bashrc.NOUSE
[ ! -e /etc/bashrc ] || mv -v /etc/bashrc /etc/bashrc.NOUSE
