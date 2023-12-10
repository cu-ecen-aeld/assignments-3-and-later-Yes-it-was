#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.1.10
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}

    # TODO: Add your kernel build steps here

    #clean
    make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- mrproper

    #configure 
    make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- defconfig

    #make kernal 
    make -j8 ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- all

    #make modules 
    make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- modules

    #build device tree 
    make ARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu- dtbs

fi

#was this suppose to be a TODO?
echo "Adding the Image in outdir"
cp ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ${OUTDIR}/Image

echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi

# TODO: Create necessary base directories
mkdir -p rootfs
cd rootfs

mkdir -p bin dev etc home lib lib64 proc sbin sys tmp usr var
mkdir -p usr/bin usr/lib usr/sbin
mkdir -p var/log


cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # TODO:  Configure busybox
    #make distclean
    #make defconfig
    #configuring here means the config process won't redone as long as the git clone worked, so I done it in the next section. 
else
    cd busybox
fi

# TODO: Make and install busybox
make distclean
make defconfig
#Build
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}
#create symlinks 
make CONFIG_PREFIX=${OUTDIR}/rootfs ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install
#go back to root
cd ${OUTDIR}/rootfs


echo "Library dependencies"
${CROSS_COMPILE}readelf -a bin/busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a bin/busybox | grep "Shared library"

# TODO: Add library dependencies to rootfs
LIBC=$(aarch64-none-linux-gnu-gcc -print-sysroot -v)
#echo The value of libc is $LIBC
cp $LIBC/lib64/libm.so.6 $OUTDIR/rootfs/lib64/libm.so.6
cp $LIBC/lib64/libresolv.so.2 $OUTDIR/rootfs/lib64/libresolv.so.2
cp $LIBC/lib64/libc.so.6 $OUTDIR/rootfs/lib64/libc.so.6

cp $LIBC/lib/ld-linux-aarch64.so.1 $OUTDIR/rootfs/lib/ld-linux-aarch64.so.1


# TODO: Make device nodes
cd $OUTDIR/rootfs
sudo mknod -m 666 dev/null c 1 3
sudo mknod -m 600 dev/console c 5 1



# TODO: Clean and build the writer utility
cd $FINDER_APP_DIR
make clean 
make CROSS_COMPILE=$CROSS_COMPILE writer

# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs
cp build/writer $OUTDIR/rootfs/home/writer
cp finder-test.sh $OUTDIR/rootfs/home/finder-test.sh
cp finder.sh $OUTDIR/rootfs/home/finder.sh
mkdir -p $OUTDIR/rootfs/home/conf
cp conf/assignment.txt $OUTDIR/rootfs/home/conf/assignment.txt
cp conf/username.txt $OUTDIR/rootfs/home/conf/username.txt
cp autorun-qemu.sh $OUTDIR/rootfs/home/autorun-qemu.sh


# TODO: Chown the root directory
cd $OUTDIR/rootfs
sudo chown -R root:root *

# TODO: Create initramfs.cpio.gz
find . | cpio -H newc -ov --owner root:root > ${OUTDIR}/initramfs.cpio
cd $OUTDIR
gzip -f initramfs.cpio
