#!/bin/sh 


MARKETPLACE_ENDPOINT=${MARKETPLACE_ENDPOINT:-http://marketplace.stratuslab.eu}
PDISK_ENDPOINT=${PDISK_ENDPOINT:-pdisk.lal.stratuslab.eu}

set +x
if [ -z "$PDISK_USERNAME" -o -z "$PDISK_PASSWORD" ]; then
   echo "PDisk username/password should be defined with PDISK_USERNAME/PDISK_PASSWORD. Aborting!"
   exit 1
fi
set -xe


export OS=openSUSE
export OS_VERSION=12.2
export OS_ARCH=x86_64
export IMAGE_VERSION=1.0
export TYPE=base
export IMAGE_SIZE=5
export MAC_ADDRESS=0a:0a:86:9e:49:60
export NAME=suse


#clean from failed build
sudo su - root -c "rm -f /etc/libvirt/qemu/$NAME.xml"

#restart libvirtd
sudo su - root -c "service libvirtd restart"

sudo su - root -c "virt-install --accelerate --hvm --name $NAME --ram=2000 --disk $PWD/$OS-$OS_VERSION-$OS_ARCH-$TYPE-$IMAGE_VERSION.img,bus=ide,size=$IMAGE_SIZE --location=http://download.opensuse.org/distribution/$OS_VERSION/repo/oss/ -x \"install=http://download.opensuse.org/distribution/$OS_VERSION/repo/oss/ autoyast=http://$NODE_IP/opensuse12.1_stratus.xml\" --network bridge=br0 --mac=$MAC_ADDRESS  --noreboot"



while [ -n "`sudo su - root -c "virsh list | grep $NAME"|| true`" ]; do 
  sleep 120 
done


#Second stage
sudo su - root -c "virsh start $NAME"
sleep 180

sudo su - root -c "yum install -y --nogpgcheck stratuslab-cli-user stratuslab-cli-sysadmin"

sudo su - root -c "virsh destroy $NAME"

sudo su - root -c "cd $PWD ; stratus-build-metadata --author=\"hudson builder\" --os=$OS --os-version=$OS_VERSION --os-arch=$OS_ARCH --image-version=$IMAGE_VERSION --comment=\"$OS  $OS_VERSION $TYPE image automatically created by hudson. Configured only with a root user. The firewall in the image is disabled, IPv6 is enabled, and SELinux disabled. Allows both standard StratusLab and cloud-init contextualization mechanisms. A swap volume is expected to be provided on /dev/sdb. \" --compression=gz $OS-$OS_VERSION-$OS_ARCH-$TYPE-$IMAGE_VERSION.img"

sudo su - root -c "stratus-generate-p12 --common-name=\"hudson builder\" --email=\"hudson.builder@stratuslab.eu\" -o $PWD/test.p12"


set +x
cmd="stratus-upload-image --machine-image-origin --public --compress gz --marketplace-endpoint $MARKETPLACE_ENDPOINT --pdisk-endpoint $PDISK_ENDPOINT --p12-cert=test.p12 --p12-password=XYZXYZ $OS-$OS_VERSION-$OS_ARCH-$TYPE-$IMAGE_VERSION.img"
echo "Lanching: $cmd"
sudo su - root -c "cd $PWD ; $cmd --pdisk-username ${PDISK_USERNAME} --pdisk-password ${PDISK_PASSWORD}"
set -x

#Clean

sudo su - root -c "rm -f /etc/libvirt/qemu/$NAME.xml"
sudo su - root -c "virsh destroy $NAME" || true

