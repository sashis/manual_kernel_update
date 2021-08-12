#!/bin/bash


KERNEL_VER="5.13.9"

# Add repo with the newer gcc version (>=4.9 needed)
yum install -y centos-release-scl

# Add build dependencies
yum install -y devtoolset-10-gcc flex bison rpm-build elfutils-libelf-devel openssl-devel bc rsync yum-utils

# Enable env providing the newer gcc
echo "source /opt/rh/devtoolset-10/enable" > /etc/profile.d/devtoolset-10.sh
source /opt/rh/devtoolset-10/enable

# Download the kernel source
curl https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-$KERNEL_VER.tar.xz | tar -xJ
cd linux-$KERNEL_VER

# Build new config based on the current one
cp /boot/config-$(uname -r) .config

# - disable build for debug symblos to reduce the total size of kernel rpms
sed -i s/CONFIG_DEBUG_KERNEL=y/CONFIG_DEBUG_KERNEL=n/ .config
make olddefconfig

# Build in progress
make ARCH=$(uname -m) -j $(nproc) rpm-pkg

# Install the new kernel from local
yum localinstall -y ~/rpmbuild/RPMS/`uname -m`/kernel-*.rpm

# Remove the source and the builder folders
cd ..
rm -rf linux-$KERNEL_VER
rm -rf ~/rpmbuild

# Update GRUB config with the new kernel
grub2-mkconfig -o /boot/grub2/grub.cfg
grub2-set-default 0

shutdown -r now
