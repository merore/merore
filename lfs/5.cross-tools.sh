#!/bin/bash

P=4
cd $LFS/sources


# 第一次构建binutils
tar -xf binutils-2.37.tar.xz
pushd binutils-2.37
mkdir -v build
cd build
../configure --prefix=$LFS/tools \
             --with-sysroot=$LFS \
             --target=$LFS_TGT   \
             --disable-nls       \
             --disable-werror
make 
make install -j 1
popd
rm -rf binutils-2.37

# 第一次构建不完整的gcc
tar -xf gcc-11.2.0.tar.xz
pushd gcc-11.2.0
tar -xf ../mpfr-4.1.0.tar.xz
mv -v mpfr-4.1.0 mpfr
tar -xf ../gmp-6.2.1.tar.xz
mv -v gmp-6.2.1 gmp
tar -xf ../mpc-1.2.1.tar.gz
mv -v mpc-1.2.1 mpc

sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64

mkdir -v build
cd build

../configure                                       \
    --target=$LFS_TGT                              \
    --prefix=$LFS/tools                            \
    --with-glibc-version=2.11                      \
    --with-sysroot=$LFS                            \
    --with-newlib                                  \
    --without-headers                              \
    --enable-initfini-array                        \
    --disable-nls                                  \
    --disable-shared                               \
    --disable-multilib                             \
    --disable-decimal-float                        \
    --disable-threads                              \
    --disable-libatomic                            \
    --disable-libgomp                              \
    --disable-libquadmath                          \
    --disable-libssp                               \
    --disable-libvtv                               \
    --disable-libstdcxx                            \
    --enable-languages=c,c++
make 
make install

cd ..
cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
  `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/install-tools/include/limits.h
popd
rm -rf gcc-11.2.0

# 安装 Linux API 头文件
tar -xf linux-5.13.12.tar.xz
pushd linux-5.13.12

make mrproper
make headers
find usr/include -name '.*' -delete
rm usr/include/Makefile
cp -rv usr/include $LFS/usr
popd
rm -rf linux-5.13.12

# 安装 glibc
ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3

tar -xf glibc-2.34.tar.xz
pushd glibc-2.34
patch -Np1 -i ../glibc-2.34-fhs-1.patch
mkdir -v build
cd build

echo "rootsbindir=/usr/sbin" > configparms

../configure                             \
      --prefix=/usr                      \
      --host=$LFS_TGT                    \
      --build=$(../scripts/config.guess) \
      --enable-kernel=3.2                \
      --with-headers=$LFS/usr/include    \
      libc_cv_slibdir=/usr/lib
make 
make DESTDIR=$LFS install
popd
rm -rf glibc-2.34

# 更正 ldd 脚本中可执行文件加载器路径
sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd

# 安装 limits.h 头文件
$LFS/tools/libexec/gcc/$LFS_TGT/11.2.0/install-tools/mkheaders

# 第一次编译不完整 libstdc++
tar -xf gcc-11.2.0.tar.xz
pushd gcc-11.2.0
mkdir -v build
cd build
../libstdc++-v3/configure           \
    --host=$LFS_TGT                 \
    --build=$(../config.guess)      \
    --prefix=/usr                   \
    --disable-multilib              \
    --disable-nls                   \
    --disable-libstdcxx-pch         \
    --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/11.2.0

make 
make DESTDIR=$LFS install
popd
rm -rf gcc-11.2.0

# 交叉编译临时工具
tar -xf m4-1.4.19.tar.xz
pushd 
