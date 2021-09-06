#!/bin/bash

P=4
cd $LFS/sources

# m4
tar -xf m4-1.4.19.tar.xz

pushd m4-1.4.19
./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)
make 
make DESTDIR=$LFS install
popd

rm -rf m4-1.4.19

# ncurses
tar -xf ncurses-6.2.tar.gz

pushd ncurses-6.2
sed -i s/mawk// configure
mkdir build
pushd build
../configure
make -C include
make -C progs tic
popd
./configure --prefix=/usr                \
            --host=$LFS_TGT              \
            --build=$(./config.guess)    \
            --mandir=/usr/share/man      \
            --with-manpage-format=normal \
            --with-shared                \
            --without-debug              \
            --without-ada                \
            --without-normal             \
            --enable-widec

make 
make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install
popd
rm -rf ncurses-6.2

echo "INPUT(-lncursesw)" > $LFS/usr/lib/libncurses.so

# bash
tar -xf bash-5.1.8.tar.gz

pushd bash-5.1.8
./configure --prefix=/usr                   \
            --build=$(support/config.guess) \
            --host=$LFS_TGT                 \
            --without-bash-malloc
make 
make DESTDIR=$LFS install
popd
rm -rf bash-5.1.8

ln -sv bash $LFS/bin/sh

# coreutils
tar -xf coreutils-8.32.tar.xz

pushd coreutils-8.32
./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --enable-install-program=hostname \
            --enable-no-install-program=kill,uptime
make 
make DESTDIR=$LFS install
popd
rm -rf coreutils-8.32

mv -v $LFS/usr/bin/chroot                                     $LFS/usr/sbin
mkdir -pv $LFS/usr/share/man/man8
mv -v $LFS/usr/share/man/man1/chroot.1                        $LFS/usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/'                                           $LFS/usr/share/man/man8/chroot.8

# diffutils
tar -xf diffutils-3.8.tar.xz

pushd diffutils-3.8
./configure --prefix=/usr --host=$LFS_TGT
make 
make DESTDIR=$LFS install
popd

rm -rf diffutils-3.8

# file
tar -xf file-5.40.tar.gz

pushd file-5.40
mkdir build
pushd build
../configure --disable-bzlib      \
             --disable-libseccomp \
             --disable-xzlib      \
             --disable-zlib
make 
make install
popd

./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess)
make FILE_COMPILE=$(pwd)/build/src/file
make DESTDIR=$LFS install
popd

rm -rf file-5.40

# findutils-4.8.0
