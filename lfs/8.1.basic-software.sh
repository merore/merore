#!/bin/bash

export MAKEFLAGS='-j4'

# man-pages
tar -xf man-pages-5.13.tar.xz

pushd man-pages-5.13
make prefix=/usr install
popd

rm -rf man-pages-5.13

# lana-etc

tar -xf iana-etc-20210611.tar.gz
pushd iana-etc-20210611
cp services protocols /etc
popd
rm -rf iana-etc-20210611

# glibc
tar -xf glibc-2.34.tar.xz
pushd glibc-2.34
sed -e '/NOTIFY_REMOVED)/s/)/ \&\& data.attr != NULL)/' \
    -i sysdeps/unix/sysv/linux/mq_notify.c
patch -Np1 -i ../glibc-2.34-fhs-1.patch
mkdir -v build
cd       build
echo "rootsbindir=/usr/sbin" > configparms
../configure --prefix=/usr                            \
             --disable-werror                         \
             --enable-kernel=3.2                      \
             --enable-stack-protector=strong          \
             --with-headers=/usr/include              \
             libc_cv_slibdir=/usr/lib
make 
#make check
touch /etc/ld.so.conf
sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile
make install
sed '/RTLDLIST=/s@/usr@@g' -i /usr/bin/ldd
cp -v ../nscd/nscd.conf /etc/nscd.conf
mkdir -pv /var/cache/nscd
install -v -Dm644 ../nscd/nscd.tmpfiles /usr/lib/tmpfiles.d/nscd.conf
install -v -Dm644 ../nscd/nscd.service /usr/lib/systemd/system/nscd.service
mkdir -pv /usr/lib/locale
localedef -i POSIX -f UTF-8 C.UTF-8 2> /dev/null || true
localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8
localedef -i de_DE -f ISO-8859-1 de_DE
localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro
localedef -i de_DE -f UTF-8 de_DE.UTF-8
localedef -i el_GR -f ISO-8859-7 el_GR
localedef -i en_GB -f ISO-8859-1 en_GB
localedef -i en_GB -f UTF-8 en_GB.UTF-8
localedef -i en_HK -f ISO-8859-1 en_HK
localedef -i en_PH -f ISO-8859-1 en_PH
localedef -i en_US -f ISO-8859-1 en_US
localedef -i en_US -f UTF-8 en_US.UTF-8
localedef -i es_ES -f ISO-8859-15 es_ES@euro
localedef -i es_MX -f ISO-8859-1 es_MX
localedef -i fa_IR -f UTF-8 fa_IR
localedef -i fr_FR -f ISO-8859-1 fr_FR
localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
localedef -i fr_FR -f UTF-8 fr_FR.UTF-8
localedef -i is_IS -f ISO-8859-1 is_IS
localedef -i is_IS -f UTF-8 is_IS.UTF-8
localedef -i it_IT -f ISO-8859-1 it_IT
localedef -i it_IT -f ISO-8859-15 it_IT@euro
localedef -i it_IT -f UTF-8 it_IT.UTF-8
localedef -i ja_JP -f EUC-JP ja_JP
localedef -i ja_JP -f SHIFT_JIS ja_JP.SIJS 2> /dev/null || true
localedef -i ja_JP -f UTF-8 ja_JP.UTF-8
localedef -i nl_NL@euro -f ISO-8859-15 nl_NL@euro
localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R
localedef -i ru_RU -f UTF-8 ru_RU.UTF-8
localedef -i se_NO -f UTF-8 se_NO.UTF-8
localedef -i ta_IN -f UTF-8 ta_IN.UTF-8
localedef -i tr_TR -f UTF-8 tr_TR.UTF-8
localedef -i zh_CN -f GB18030 zh_CN.GB18030
localedef -i zh_HK -f BIG5-HKSCS zh_HK.BIG5-HKSCS
localedef -i zh_TW -f UTF-8 zh_TW.UTF-8
make localedata/install-locales
localedef -i POSIX -f UTF-8 C.UTF-8 2> /dev/null || true
localedef -i ja_JP -f SHIFT_JIS ja_JP.SIJS 2> /dev/null || true

cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf

passwd: files
group: files
shadow: files

hosts: files dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf
EOF

tar -xf ../../tzdata2021a.tar.gz

ZONEINFO=/usr/share/zoneinfo
mkdir -pv $ZONEINFO/{posix,right}

for tz in etcetera southamerica northamerica europe africa antarctica  \
          asia australasia backward; do
    zic -L /dev/null   -d $ZONEINFO       ${tz}
    zic -L /dev/null   -d $ZONEINFO/posix ${tz}
    zic -L leapseconds -d $ZONEINFO/right ${tz}
done

cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
zic -d $ZONEINFO -p America/New_York
unset ZONEINFO

ln -sfv /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 配置动态加载器
cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib

EOF
cat >> /etc/ld.so.conf << "EOF"
# Add an include directory
include /etc/ld.so.conf.d/*.conf

EOF
mkdir -pv /etc/ld.so.conf.d

popd
rm -rf glibc-2.34


# zlib
tar -xf zlib-1.2.11.tar.xz
pushd zlib-1.2.11
./configure --prefix=/usr
make 
#make check
make install
rm -fv /usr/lib/libz.a
popd
rm -rf zlib-1.2.11

# bzip2
tar -xf bzip2-1.0.8.tar.gz
pushd bzip2-1.0.8
patch -Np1 -i ../bzip2-1.0.8-install_docs-1.patch
sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile
make -f Makefile-libbz2_so
make clean
make 
make PREFIX=/usr install
cp -av libbz2.so.* /usr/lib
ln -sv libbz2.so.1.0.8 /usr/lib/libbz2.so
cp -v bzip2-shared /usr/bin/bzip2
for i in /usr/bin/{bzcat,bunzip2}; do
  ln -sfv bzip2 $i
done
rm -fv /usr/lib/libbz2.a
popd
rm -rf bzip2-1.0.8


# xz
tar -xf xz-5.2.5.tar.xz
pushd xz-5.2.5
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/xz-5.2.5
make 
#make check
make install
popd
rm -rf xz-5.2.5


# zstd
tar -xf zstd-1.5.0.tar.gz
pushd zstd-1.5.0
make 
#make check
make prefix=/usr install
rm -v /usr/lib/libzstd.a
popd
rm -rf zstd-1.5.0


# file
tar -xf file-5.40.tar.gz
pushd file-5.40
./configure --prefix=/usr
make 
#make check
make install
popd 
rm -rf file-5.40.tar.gz

# readline
tar -xf readline-8.1.tar.gz
pushd readline-8.1
sed -i '/MV.*old/d' Makefile.in
sed -i '{OLDSUFF}/c:' support/shlib-install

./configure --prefix=/usr    \
            --disable-static \
            --with-curses    \
            --docdir=/usr/share/doc/readline-8.1
make SHLIB_LIBS="-lncursesw" 
mkdir -pv /usr/share/doc/readline-8.1
install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-8.1
popd
rm -rf readline-8.1

# m4
tar -xf m4-1.4.19.tar.xz
pushd m4-1.4.19
./configure --prefix=/usr
make
#make check
make install
popd
rm -rf m4-1.4.19

# bc
tar -xf bc-5.0.0.tar.xz
pushd bc-5.0.0
CC=gcc ./configure --prefix=/usr -G -O3
make
make test
make install
popd
rm -rf bc-5.0.0

# flex
tar -xf flex-2.6.4.tar.gz
pushd flex-2.6.4
./configure --prefix=/usr \
            --docdir=/usr/share/doc/flex-2.6.4 \
            --disable-static
make 
#make check
make install
ln -sv flex /usr/bin/lex
popd
rm -rf flex-2.6.4

# tcl
tar -xf tcl8.6.11-src.tar.gz
pushd tcl8.6.11
tar -xf ../tcl8.6.11-html.tar.gz --strip-components=1
SRCDIR=$(pwd)
cd unix
./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            $([ "$(uname -m)" = x86_64 ] && echo --enable-64bit)
make
sed -e "s|$SRCDIR/unix|/usr/lib|" \
    -e "s|$SRCDIR|/usr/include|"  \
    -i tclConfig.sh
sed -e "s|$SRCDIR/unix/pkgs/tdbc1.1.2|/usr/lib/tdbc1.1.2|" \
    -e "s|$SRCDIR/pkgs/tdbc1.1.2/generic|/usr/include|"    \
    -e "s|$SRCDIR/pkgs/tdbc1.1.2/library|/usr/lib/tcl8.6|" \
    -e "s|$SRCDIR/pkgs/tdbc1.1.2|/usr/include|"            \
    -i pkgs/tdbc1.1.2/tdbcConfig.sh
sed -e "s|$SRCDIR/unix/pkgs/itcl4.2.1|/usr/lib/itcl4.2.1|" \
    -e "s|$SRCDIR/pkgs/itcl4.2.1/generic|/usr/include|"    \
    -e "s|$SRCDIR/pkgs/itcl4.2.1|/usr/include|"            \
    -i pkgs/itcl4.2.1/itclConfig.sh
unset SRCDIR
make test
make install
chmod -v u+w /usr/lib/libtcl8.6.so
make install-private-headers
ln -sfv tclsh8.6 /usr/bin/tclsh
mv /usr/share/man/man3/{Thread,Tcl_Thread}.3
popd
rm -rf tcl8.6.11

# expect
tar -xf expect5.45.4.tar.gz
pushd expect5.45.4
./configure --prefix=/usr           \
            --with-tcl=/usr/lib     \
            --enable-shared         \
            --mandir=/usr/share/man \
            --with-tclinclude=/usr/include
make
make test
make install
ln -svf expect5.45.4/libexpect5.45.4.so /usr/lib
popd
rm -rf expect5.45.4

# dejagnu
tar -xf dejagnu-1.6.3.tar.gz
pushd dejagnu-1.6.3
mkdir -v build
cd       build
../configure --prefix=/usr
makeinfo --html --no-split -o doc/dejagnu.html ../doc/dejagnu.texi
makeinfo --plaintext       -o doc/dejagnu.txt  ../doc/dejagnu.texi
make install
install -v -dm755  /usr/share/doc/dejagnu-1.6.3
install -v -m644   doc/dejagnu.{html,txt} /usr/share/doc/dejagnu-1.6.3
#make check
popd
rm -rf dejagnu-1.6.3

# binutils
# expect -c "spawn ls"

tar -xf binutils-2.37.tar.xz
pushd binutils-2.37
patch -Np1 -i ../binutils-2.37-upstream_fix-1.patch
sed -i '63d' etc/texi2pod.pl
find -name \*.1 -delete
mkdir -v build
cd       build
../configure --prefix=/usr       \
             --enable-gold       \
             --enable-ld=default \
             --enable-plugins    \
             --enable-shared     \
             --disable-werror    \
             --enable-64-bit-bfd \
             --with-system-zlib
make tooldir=/usr
#make -k check
make tooldir=/usr install -j1
rm -fv /usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes}.a
popd
rm -rf binutils-2.37

# gmp
tar -xf gmp-6.2.1.tar.xz
pushd gmp-6.2.1
cp -v configfsf.guess config.guess
cp -v configfsf.sub   config.sub
./configure --prefix=/usr    \
            --enable-cxx     \
            --disable-static \
            --docdir=/usr/share/doc/gmp-6.2.1
make
make html
#make check 2>&1 | tee gmp-check-log
#awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log
make install
make install-html
popd
rm -rf gmp-6.2.1

# mpfr
tar -xf mpfr-4.1.0.tar.xz
pushd mpfr-4.1.0
./configure --prefix=/usr        \
            --disable-static     \
            --enable-thread-safe \
            --docdir=/usr/share/doc/mpfr-4.1.0
make
make html
#make check
make install
make install-html
popd
rm -rf mpfr-4.1.0

# mpc
tar -xf mpc-1.2.1.tar.gz
pushd mpc-1.2.1
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/mpc-1.2.1
make
make html
#make check
make install
make install-html
popd
rm -rf mpc-1.2.1

# attr
tar -xf attr-2.5.1.tar.gz
pushd attr-2.5.1
./configure --prefix=/usr     \
            --disable-static  \
            --sysconfdir=/etc \
            --docdir=/usr/share/doc/attr-2.5.1
make
#make check
make install
popd
rm -rf attr-2.5.1

# acl
tar -xf acl-2.3.1.tar.xz
pushd acl-2.3.1
./configure --prefix=/usr         \
            --disable-static      \
            --docdir=/usr/share/doc/acl-2.3.1
make
make install
popd
rm -rf acl-2.3.1

# libcap
tar -xf libcap-2.53.tar.xz
pushd libcap-2.53
sed -i '/install -m.*STA/d' libcap/Makefile
make prefix=/usr lib=lib
make test
make prefix=/usr lib=lib install
chmod -v 755 /usr/lib/lib{cap,psx}.so.2.53
popd
rm -rf libcap-2.53

# shadow
tar -xf shadow-4.9.tar.xz
pushd shadow-4.9
sed -i 's/groups$(EXEEXT) //' src/Makefile.in
find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \;
find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;

sed -e 's:#ENCRYPT_METHOD DES:ENCRYPT_METHOD SHA512:' \
    -e 's:/var/spool/mail:/var/mail:'                 \
    -e '/PATH=/{s@/sbin:@@;s@/bin:@@}'                \
    -i etc/login.defs
sed -e "224s/rounds/min_rounds/" -i libmisc/salt.c
touch /usr/bin/passwd
./configure --sysconfdir=/etc \
            --with-group-name-max-length=32
make
make exec_prefix=/usr install
make -C man install-man
mkdir -p /etc/default
useradd -D --gid 999
pwconv
grpconv
popd
rm -rf shadow-4.9

# gcc
tar -xf gcc-11.2.0.tar.xz
pushd gcc-11.2.0
sed -e '/static.*SIGSTKSZ/d' \
    -e 's/return kAltStackSize/return SIGSTKSZ * 4/' \
    -i libsanitizer/sanitizer_common/sanitizer_posix_libcdep.cpp
sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
mkdir -v build
cd build
../configure --prefix=/usr            \
             LD=ld                    \
             --enable-languages=c,c++ \
             --disable-multilib       \
             --disable-bootstrap      \
             --with-system-zlib
make
#ulimit -s 32768
#chown -Rv tester .
#su tester -c "PATH=$PATH make -k check"
#../contrib/test_summary
make install
rm -rf /usr/lib/gcc/$(gcc -dumpmachine)/11.2.0/include-fixed/bits/
chown -v -R root:root \
    /usr/lib/gcc/*linux-gnu/11.2.0/include{,-fixed}
ln -svr /usr/bin/cpp /usr/lib
ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/11.2.0/liblto_plugin.so \
        /usr/lib/bfd-plugins/
rm -v dummy.c a.out dummy.log
mkdir -pv /usr/share/gdb/auto-load/usr/lib
mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib
popd
rm -rf gcc-11.2.0

# pkg-config
tar -xf pkg-config-0.29.2.tar.gz
pushd pkg-config-0.29.2
make
#make check
make install
popd
rm -rf pkg-config-0.29.2

# ncureses
tar -xf ncurses-6.2.tar.gz
pushd ncurses-6.2
./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --with-shared           \
            --without-debug         \
            --without-normal        \
            --enable-pc-files       \
            --enable-widec
make
make install

for lib in ncurses form panel menu ; do
    rm -vf                    /usr/lib/lib${lib}.so
    echo "INPUT(-l${lib}w)" > /usr/lib/lib${lib}.so
    ln -sfv ${lib}w.pc        /usr/lib/pkgconfig/${lib}.pc
done

rm -vf                     /usr/lib/libcursesw.so
echo "INPUT(-lncursesw)" > /usr/lib/libcursesw.so
ln -sfv libncurses.so      /usr/lib/libcurses.so

rm -fv /usr/lib/libncurses++w.a
mkdir -v       /usr/share/doc/ncurses-6.2
cp -v -R doc/* /usr/share/doc/ncurses-6.2

make distclean
./configure --prefix=/usr    \
            --with-shared    \
            --without-normal \
            --without-debug  \
            --without-cxx-binding \
            --with-abi-version=5
make sources libs
cp -av lib/lib*.so.5* /usr/lib
popd
rm -rf ncurses-6.2

# sed
tar -xf sed-4.8.tar.xz 
pushd sed-4.8
./configure --prefix=/usr
make
make html
#chown -Rv tester .
#su tester -c "PATH=$PATH make check"
make install
install -d -m755           /usr/share/doc/sed-4.8
install -m644 doc/sed.html /usr/share/doc/sed-4.8
popd
rm -rf sed-4.8

# psmisc
tar -xf psmisc-23.4.tar.xz
pushd psmisc-23.4
./configure --prefix=/usr
make
make install
popd
rm -rf psmisc-23.4

# gettext
tar -xf gettext-0.21.tar.xz 
pushd gettext-0.21
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/gettext-0.21
make
#make check
make install
chmod -v 0755 /usr/lib/preloadable_libintl.so
popd
rm -rf gettext-0.21

# bison
tar -xf bison-3.7.6.tar.xz
pushd bison-3.7.6
./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.7.6
make
#make check
make install
popd
rm -rf bison-3.7.6

# grep
tar -xf grep-3.7.tar.xz
pushd grep-3.7
./configure --prefix=/usr
make
#make check
make install
popd
rm -rf grep-3.7

# bash
tar -xf bash-5.1.8.tar.gz
pushd bash-5.1.8
./configure --prefix=/usr                      \
            --docdir=/usr/share/doc/bash-5.1.8 \
            --without-bash-malloc              \
            --with-installed-readline
make
#chown -Rv tester .
#su -s /usr/bin/expect tester << EOF
#set timeout -1
#spawn make tests
#expect eof
#lassign [wait] _ _ _ value
#exit $value
#EOF
make install
exec /bin/bash --login +h
popd
rm -rf bash-5.1.8

# libtool
tar -xf libtool-2.4.6.tar.xz
pushd libtool-2.4.6
./configure --prefix=/usr
make
#make check
make install
rm -fv /usr/lib/libltdl.a
popd
rm -rf libtool-2.4.6

# gdbm
tar -xf gdbm-1.20.tar.gz
pushd gdbm-1.20
./configure --prefix=/usr    \
            --disable-static \
            --enable-libgdbm-compat
make
#make -k check
make install
popd
rm -rf gdbm-1.20

# gperf
tar -xf gperf-3.1.tar.gz
pushd gperf-3.1
./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.1
make
#make -j1 check
make install
popd
rm -rf gperf-3.1

# expat
tar -xf expat-2.4.1.tar.xz
pushd expat-2.4.1
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/expat-2.4.1
#make check
make install
install -v -m644 doc/*.{html,png,css} /usr/share/doc/expat-2.4.1
popd
rm -rf expat-2.4.1

# inetutils
tar -xf inetutils-2.1.tar.xz
pushd inetutils-2.1
./configure --prefix=/usr        \
            --bindir=/usr/bin    \
            --localstatedir=/var \
            --disable-logger     \
            --disable-whois      \
            --disable-rcp        \
            --disable-rexec      \
            --disable-rlogin     \
            --disable-rsh        \
            --disable-servers
make
#make check
make install
mv -v /usr/{,s}bin/ifconfig
popd
rm -rf inetutils-2.1

# less
tar -xf less-590.tar.gz
pushd less-590
./configure --prefix=/usr --sysconfdir=/etc
make
make install
popd
rm -rf less-590

# perl
tar -xf perl-5.34.0.tar.xz
pushd perl-5.34.0
patch -Np1 -i ../perl-5.34.0-upstream_fixes-1.patch
export BUILD_ZLIB=False
export BUILD_BZIP2=0
sh Configure -des                                         \
             -Dprefix=/usr                                \
             -Dvendorprefix=/usr                          \
             -Dprivlib=/usr/lib/perl5/5.34/core_perl      \
             -Darchlib=/usr/lib/perl5/5.34/core_perl      \
             -Dsitelib=/usr/lib/perl5/5.34/site_perl      \
             -Dsitearch=/usr/lib/perl5/5.34/site_perl     \
             -Dvendorlib=/usr/lib/perl5/5.34/vendor_perl  \
             -Dvendorarch=/usr/lib/perl5/5.34/vendor_perl \
             -Dman1dir=/usr/share/man/man1                \
             -Dman3dir=/usr/share/man/man3                \
             -Dpager="/usr/bin/less -isR"                 \
             -Duseshrplib                                 \
             -Dusethreads
make
#make test
make install
unset BUILD_ZLIB BUILD_BZIP2
popd
rm -rf perl-5.34.0

# xml parser
tar -xf XML-Parser-2.46.tar.gz
pushd XML-Parser-2.46
perl Makefile.PL
make
#make test
make install
popd
rm -rf XML-Parser-2.46

# intltool
tar -xf intltool-0.51.0.tar.gz
pushd intltool-0.51.0
sed -i 's:\\\${:\\\$\\{:' intltool-update.in
./configure --prefix=/usr
make
#make check
make install
install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO
popd
rm -rf intltool-0.51.0

# autoconf
tar -xf autoconf-2.71.tar.xz
pushd autoconf-2.71
./configure --prefix=/usr
make
#make check
make install
popd
rm -rf autoconf-2.71

# automake
tar -xf automake-1.16.4.tar.xz
pushd automake-1.16.4
./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.16.4
make
#make -j4 check
make install
popd
rm -rf automake-1.16.4

# kmod
tar -xf kmod-29.tar.xz
pushd kmod-29
./configure --prefix=/usr          \
            --sysconfdir=/etc      \
            --with-xz              \
            --with-zstd            \
            --with-zlib
make
make install
for target in depmod insmod modinfo modprobe rmmod; do
  ln -sfv ../bin/kmod /usr/sbin/$target
done
ln -sfv kmod /usr/bin/lsmod
popd
rm -rf kmod-29

# libelf
tar -xf elfutils-0.185.tar.bz2
pushd elfutils-0.185
./configure --prefix=/usr                \
            --disable-debuginfod         \
            --enable-libdebuginfod=dummy
make
#make check
make -C libelf install
install -vm644 config/libelf.pc /usr/lib/pkgconfig
rm /usr/lib/libelf.a
popd
rm -rf elfutils-0.185

# libffi
tar -xf libffi-3.4.2.tar.gz
pushd libffi-3.4.2
./configure --prefix=/usr          \
            --disable-static       \
            --with-gcc-arch=native \
            --disable-exec-static-tramp
make
#make check
make install
popd
rm -rf libffi-3.4.2

# openssl
tar -xf openssl-1.1.1l.tar.gz
pushd openssl-1.1.1l
./config --prefix=/usr         \
         --openssldir=/etc/ssl \
         --libdir=lib          \
         shared                \
         zlib-dynamic
make
#make test
sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
make MANSUFFIX=ssl install
mv -v /usr/share/doc/openssl /usr/share/doc/openssl-1.1.1l
cp -vfr doc/* /usr/share/doc/openssl-1.1.1l
popd
rm -rf openssl-1.1.1l

# python 3.9.6
tar -xf Python-3.9.6.tar.xz
pushd Python-3.9.6
./configure --prefix=/usr       \
            --enable-shared     \
            --with-system-expat \
            --with-system-ffi   \
            --with-ensurepip=yes \
            --enable-optimizations
make
make install
install -v -dm755 /usr/share/doc/python-3.9.6/html

tar --strip-components=1  \
    --no-same-owner       \
    --no-same-permissions \
    -C /usr/share/doc/python-3.9.6/html \
    -xvf ../python-3.9.6-docs-html.tar.bz2
popd
rm -rf Python-3.9.6

# ninja
export NINJAJOBS=4
tar -xf ninja-1.10.2.tar.gz
pushd ninja-1.10.2
sed -i '/int Guess/a \
  int   j = 0;\
  char* jobs = getenv( "NINJAJOBS" );\
  if ( jobs != NULL ) j = atoi( jobs );\
  if ( j > 0 ) return j;\
' src/ninja.cc
python3 configure.py --bootstrap

#./ninja ninja_test
#./ninja_test --gtest_filter=-SubprocessTest.SetWithLots

install -vm755 ninja /usr/bin/
install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja
install -vDm644 misc/zsh-completion  /usr/share/zsh/site-functions/_ninja
popd
rm -rf ninja-1.10.2

# meson
tar -xf meson-0.59.1.tar.gz
pushd meson-0.59.1
python3 setup.py build
python3 setup.py install --root=dest
cp -rv dest/* /
install -vDm644 data/shell-completions/bash/meson /usr/share/bash-completion/completions/meson
install -vDm644 data/shell-completions/zsh/_meson /usr/share/zsh/site-functions/_meson
popd
rm -rf meson-0.59.1

# coreutils
tar -xf coreutils-8.32.tar.xz
pushd coreutils-8.32
patch -Np1 -i ../coreutils-8.32-i18n-1.patch
autoreconf -fiv
FORCE_UNSAFE_CONFIGURE=1 ./configure \
            --prefix=/usr            \
            --enable-no-install-program=kill,uptime
make
#make NON_ROOT_USERNAME=tester check-root
#echo "dummy:x:102:tester" >> /etc/group
#chown -Rv tester .
#su tester -c "PATH=$PATH make RUN_EXPENSIVE_TESTS=yes check"
#sed -i '/dummy/d' /etc/group
make install
mv -v /usr/bin/chroot /usr/sbin
mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/' /usr/share/man/man8/chroot.8
popd
rm -rf coreutils-8.32

# check
tar -xf check-0.15.2.tar.gz
pushd check-0.15.2
./configure --prefix=/usr --disable-static
make
#make check
make docdir=/usr/share/doc/check-0.15.2 install
popd
rm -rf check-0.15.2

# diffutils
tar -xf diffutils-3.8.tar.xz
pushd diffutils-3.8
./configure --prefix=/usr
make
#make check
make install
popd
rm -rf diffutils-3.8

# gawk
tar -xf gawk-5.1.0.tar.xz
pushd gawk-5.1.0
sed -i 's/extras//' Makefile.in
./configure --prefix=/usr
make
#make check
make install
mkdir -v /usr/share/doc/gawk-5.1.0
cp    -v doc/{awkforai.txt,*.{eps,pdf,jpg}} /usr/share/doc/gawk-5.1.0
popd
rm -rf gawk-5.1.0

# findutils
tar -xf findutils-4.8.0.tar.xz
pushd findutils-4.8.0
./configure --prefix=/usr --localstatedir=/var/lib/locate
make
#chown -Rv tester .
#su tester -c "PATH=$PATH make check"
make install
popd
rm -rf findutils-4.8.0

# groff
tar -xf groff-1.22.4.tar.gz
pushd groff-1.22.4
PAGE=A4 ./configure --prefix=/usr
make -j1
make install
popd
rm -rf groff-1.22.4

# grub
tar -xf grub-2.06.tar.xz
pushd grub-2.06
./configure --prefix=/usr          \
            --sysconfdir=/etc      \
            --disable-efiemu       \
            --disable-werror
make
make install
mv -v /etc/bash_completion.d/grub /usr/share/bash-completion/completions
popd
rm -rf grub-2.06

# gzip
tar -xf gzip-1.10.tar.xz
pushd gzip-1.10
./configure --prefix=/usr
make
#make check
make install
popd
rm -rf gzip-1.10

# iproute2
tar -xf iproute2-5.13.0.tar.xz
pushd iproute2-5.13.0
sed -i /ARPD/d Makefile
rm -fv man/man8/arpd.8
sed -i 's/.m_ipt.o//' tc/Makefile
make
make SBINDIR=/usr/sbin install
mkdir -v              /usr/share/doc/iproute2-5.13.0
cp -v COPYING README* /usr/share/doc/iproute2-5.13.0
popd
rm -rf iproute2-5.13.0

# kbd
tar -xf kbd-2.4.0.tar.xz
pushd kbd-2.4.0
patch -Np1 -i ../kbd-2.4.0-backspace-1.patch
sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure
sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in
./configure --prefix=/usr --disable-vlock
make
#make check
make install
popd
rm -rf kbd-2.4.0

# libpipeline
tar -xf libpipeline-1.5.3.tar.gz
pushd libpipeline-1.5.3
./configure --prefix=/usr
make
#make check
make install
popd
rm -rf libpipeline-1.5.3

# make
tar -xf make-4.3.tar.gz
pushd make-4.3
./configure --prefix=/usr
make
#make check
make install
popd
rm -rf make-4.3

# patch
tar -xf patch-2.7.6.tar.xz
pushd patch-2.7.6
./configure --prefix=/usr
make
#make check
make install
popd
rm -rf patch-2.7.6

# tar 
tar -xf tar-1.34.tar.xz
pushd tar-1.34
FORCE_UNSAFE_CONFIGURE=1  \
./configure --prefix=/usr
make
#make check
make install
make -C doc install-html docdir=/usr/share/doc/tar-1.34
popd
rm -rf tar-1.34

# texinfo
tar -xf texinfo-6.8.tar.xz
pushd texinfo-6.8
./configure --prefix=/usr
sed -e 's/__attribute_nonnull__/__nonnull/' \
    -i gnulib/lib/malloc/dynarray-skeleton.c
make
#make check
make install
make TEXMF=/usr/share/texmf install-tex
pushd /usr/share/info
  rm -v dir
  for f in *
    do install-info $f dir 2>/dev/null
  done
popd
popd
rm -rf texinfo-6.8

# vim
tar -xf vim-8.2.3337.tar.gz
pushd vim-8.2.3337
echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h
./configure --prefix=/usr
make
#chown -Rv tester .
#su tester -c "LANG=en_US.UTF-8 make -j1 test" &> vim-test.log
make install
ln -sv ../vim/vim82/doc /usr/share/doc/vim-8.2.3337

cat > /etc/vimrc << "EOF"
" Begin /etc/vimrc

" Ensure defaults are set before customizing settings, not after
source $VIMRUNTIME/defaults.vim
let skip_defaults_vim=1 

set nocompatible
set backspace=2
set mouse=
syntax on
if (&term == "xterm") || (&term == "putty")
  set background=dark
endif

" End /etc/vimrc
EOF
popd
rm -rf vim-8.2.3337

# markupsafe
tar -xf MarkupSafe-2.0.1.tar.gz
pushd MarkupSafe-2.0.1
python3 setup.py build
python3 setup.py install --optimize=1
popd
rm -rf MarkupSafe-2.0.1

# jinja2
tar -xf Jinja2-3.0.1.tar.gz
pushd Jinja2-3.0.1
python3 setup.py install --optimize=1
popd
rm -rf Jinja2-3.0.1

# systemd
tar -xf systemd-249.tar.gz
pushd systemd-249
patch -Np1 -i ../systemd-249-upstream_fixes-1.patch
sed -i -e 's/GROUP="render"/GROUP="video"/' \
       -e 's/GROUP="sgx", //' rules.d/50-udev-default.rules.in
mkdir -p build
cd       build

LANG=en_US.UTF-8                    \
meson --prefix=/usr                 \
      --sysconfdir=/etc             \
      --localstatedir=/var          \
      --buildtype=release           \
      -Dblkid=true                  \
      -Ddefault-dnssec=no           \
      -Dfirstboot=false             \
      -Dinstall-tests=false         \
      -Dldconfig=false              \
      -Dsysusers=false              \
      -Db_lto=false                 \
      -Drpmmacrosdir=no             \
      -Dhomed=false                 \
      -Duserdb=false                \
      -Dman=false                   \
      -Dmode=release                \
      -Ddocdir=/usr/share/doc/systemd-249 \
      ..
LANG=en_US.UTF-8 ninja
LANG=en_US.UTF-8 ninja install
tar -xf ../../systemd-man-pages-249.tar.xz --strip-components=1 -C /usr/share/man
rm -rf /usr/lib/pam.d
systemd-machine-id-setup
systemctl preset-all
systemctl disable systemd-time-wait-sync.service
popd
rm -rf systemd-249

# D Bus
tar -xf dbus-1.12.20.tar.gz
pushd dbus-1.12.20
./configure --prefix=/usr                        \
            --sysconfdir=/etc                    \
            --localstatedir=/var                 \
            --disable-static                     \
            --disable-doxygen-docs               \
            --disable-xml-docs                   \
            --docdir=/usr/share/doc/dbus-1.12.20 \
            --with-console-auth-dir=/run/console \
            --with-system-pid-file=/run/dbus/pid \
            --with-system-socket=/run/dbus/system_bus_socket
make
make install
ln -sfv /etc/machine-id /var/lib/dbus
popd
rm -rf dbus-1.12.20

# man db
tar -xf man-db-2.9.4.tar.xz
pushd man-db-2.9.4
./configure --prefix=/usr                        \
            --docdir=/usr/share/doc/man-db-2.9.4 \
            --sysconfdir=/etc                    \
            --disable-setuid                     \
            --enable-cache-owner=bin             \
            --with-browser=/usr/bin/lynx         \
            --with-vgrind=/usr/bin/vgrind        \
            --with-grap=/usr/bin/grap
make
#make check
make install
popd
rm -rf man-db-2.9.4

# procps-ng
tar -xf procps-ng-3.3.17.tar.xz
pushd procps-3.3.17
./configure --prefix=/usr                            \
            --docdir=/usr/share/doc/procps-ng-3.3.17 \
            --disable-static                         \
            --disable-kill                           \
            --with-systemd
make
#make check
make install
popd
rm -rf procps-3.3.17

# util-linux
tar -xf util-linux-2.37.2.tar.xz
pushd util-linux-2.37.2
./configure ADJTIME_PATH=/var/lib/hwclock/adjtime   \
            --libdir=/usr/lib    \
            --docdir=/usr/share/doc/util-linux-2.37.2 \
            --disable-chfn-chsh  \
            --disable-login      \
            --disable-nologin    \
            --disable-su         \
            --disable-setpriv    \
            --disable-runuser    \
            --disable-pylibmount \
            --disable-static     \
            --without-python     \
            runstatedir=/run
make
#
make install
popd
rm -rf util-linux-2.37.2

# e2fsprogs
tar -xf e2fsprogs-1.46.4.tar.gz
pushd e2fsprogs-1.46.4
mkdir -v build
cd       build
../configure --prefix=/usr           \
             --sysconfdir=/etc       \
             --enable-elf-shlibs     \
             --disable-libblkid      \
             --disable-libuuid       \
             --disable-uuidd         \
             --disable-fsck
make
#make check
make install
rm -fv /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a
gunzip -v /usr/share/info/libext2fs.info.gz
install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info
makeinfo -o      doc/com_err.info ../lib/et/com_err.texinfo
install -v -m644 doc/com_err.info /usr/share/info
install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info
popd
rm -rf e2fsprogs-1.46.4
