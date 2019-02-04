#!/usr/bin/env bash
#yum update -y
#yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm
#yum install yum-utils -y
yum install -y bash-completion tree vim mc elinks wget unzip zip expect ncdu
#SELinux to permissive
setenforce 0
mkdir -p ~root/.ssh
cp ~vagrant/.ssh/auth* ~root/.ssh
yum install -y mdadm smartmontools hdparm gdisk screen


mdadm --zero-superblock --force /dev/sd{b,c}
echo yes | mdadm --create --verbose /dev/md0 -l 1 -n 2 /dev/sd{b,c} -q
cat /proc/mdstat
mdadm -D /dev/md0

echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf


parted -s /dev/md0 mklabel gpt

parted /dev/md0 mkpart primary ext4 0% 20%
parted /dev/md0 mkpart primary ext4 20% 40%
parted /dev/md0 mkpart primary ext4 40% 60%
parted /dev/md0 mkpart primary ext4 60% 80%
parted /dev/md0 mkpart primary ext4 80% 100%
for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done
mkdir -p /raid/part{1,2,3,4,5}
for i in $(seq 1 5); do mount /dev/md0p$i /raid/part$i; done

echo "Registering in fstab.."
/bin/mv /etc/fstab /etc/fstab.orig

for i in $(seq 1 5); do echo  "/dev/md0p$i  /raid/part$i  ext4    defaults 0 0" >> /etc/fstab; done
echo "Check fstab.."
mount -av
echo "--------------------END SCRIPT------------------------------"