# Kickstart file automatically generated by anaconda.

install
#cdrom
lang en_US.UTF-8
keyboard us-acentos
network --device eth0 --bootproto dhcp
rootpw --iscrypted $1$FrX6A2Fj$9dTXl5vYGePOCCKGDOl181
firewall --enabled --port=22:tcp
authconfig --enableshadow --enablemd5
selinux --disabled
timezone --utc UTC
bootloader --location=mbr --driveorder=hda

url --url=http://web.example.com/packages/os/centos550-x86_64/base/

# Determine what to do at the end of the installation phase.
#reboot
#halt
poweroff

# The following is the partition information you requested
# Note that any partitions you deleted are not expressed
# here so unless you clear all partitions first, this is
# not guaranteed to work
clearpart --all --initlabel --drives=hda
part /boot --fstype ext3 --size=100 --ondisk=hda
part pv.01 --size=0 --grow --ondisk=hda
volgroup VolGroup00 --pesize=32768 pv.01
logvol / --fstype ext3 --name=LogVol00 --vgname=VolGroup00 --size=1024 --grow

%packages --nobase
which
etup
basesystem
rootfiles
zlib
glib2
libgcc
audit-libs
libstdc++
bzip2-libs
libgcrypt
libtermcap
libsepol
ncurses
readline
sqlite
glib2
libjpeg
libattr
keyutils-libs
atk
libgpg-error
keyutils
diffutils
iptables
db4
libsysfs
libXau
libsepol
libXau
iptables-ipv6
less
binutils
tcl
libusb
grep
gdbm
wireless-tools
cyrus-sasl-lib
libXdmcp
gnutls
libstdc++
libXdmcp
udftools
file
setserial
libtermcap
libX11
libXext
bitstream-vera-fonts
libXinerama
libXrandr
centos-release
libX11
libXrender
libXfixes
libXinerama
libXi
shadow-utils
findutils
fontconfig
openssl
cairo
newt
tar
cracklib
audit-libs-python
yum-metadata-parser
m2crypto
MAKEDEV
net-tools
system-config-securitylevel-tui
rhpl
fontconfig
cairo
cracklib
libuser
trousers
python-urlgrabber
fipscheck-lib
dbus-libs
e2fsprogs
dbus
dmraid-events
yum-fastestmirror
libselinux
pam
util-linux
passwd
SysVinit
policycoreutils
kbd
sysklogd
prelink
ecryptfs-utils
hwdata
kernel
kudzu
gpg-pubkey
tzdata
glibc
nss
popt
bzip2-libs
libpng
udev
freetype
gnutls
logrotate
libxml2
openldap
selinux-policy
openssh-server
selinux-policy-targeted
device-mapper
gnutls
nspr
krb5-libs
lvm2
cups-libs
pango
rpm-libs
module-init-tools
rpm-python
groff
man
cracklib-dicts
filesystem
termcap
centos-release-notes
libgcc
chkconfig
mktemp
audit-libs
zlib
expat
libgpg-error
elfutils-libelf
bash
info
freetype
sed
gawk
libacl
libcap
libjpeg
hmaccalc
cpio
atk
slang
libgcrypt
keyutils-libs
iproute
procps
gzip
iputils
pcre
dmidecode
sgpio
mingetty
ethtool
tcp_wrappers
checkpolicy
sysfsutils
ed
hdparm
readline
xorg-x11-filesystem
libXrender
libXfixes
libXcursor
libXi
crontabs
redhat-logos
grub
libXext
libXcursor
libXrandr
libselinux
e2fsprogs-libs
coreutils
python
cryptsetup-luks
libsemanage
rpm-libs
libselinux-utils
python-elementtree
libselinux-python
python-sqlite
openldap
libXft
psmisc
libhugetlbfs
vim-minimal
hicolor-icon-theme
libXft
pam
gtk2
libhugetlbfs
python-iniparse
dmraid
e2fsprogs-libs
fipscheck
yum
ecryptfs-utils
usermode
initscripts
mcstrans
setools
dhcpv6-client
authconfig
openssl
gtk2
trousers
pciutils
hal
pm-utils
nash
glibc-common
nspr
device-mapper
krb5-libs
kpartx
device-mapper-multipath
expat
libtiff
openssh
cups-libs
dbus-glib
db4
libvolume_id
openssh-clients
dhclient
glibc
freetype
libpng
libtiff
device-mapper-event
pango
nss
expat
mkinitrd
rpm
mkinitrd
bzip2

%post

cat > post-install.sh << 'EOF'
#!/bin/bash -v
yum -y upgrade >/root/post_install.log 2>&1

cat >> /etc/fstab <<'EOG'
/dev/hdb                none                    swap    defaults        0 0
EOG

cat > /etc/sysconfig/network-scripts/ifcfg-eth0 <<'EOG'
DEVICE=eth0
BOOTPROTO=dhcp
DHCPCLASS=
ONBOOT=yes
EOG

cat > /etc/sysconfig/network-scripts/ifcfg-eth1 <<'EOG'
DEVICE=eth1
BOOTPROTO=dhcp
DHCPCLASS=
ONBOOT=yes
EOG

sed s/PasswordAuthentication\ yes/PasswordAuthentication\ no/ -i /etc/ssh/sshd_config
sed s/GSSAPIAuthentication\ yes/GSSAPIAuthentication\ no/ -i /etc/ssh/sshd_config
sed s/ChallengeResponseAuthentication\ yes/ChallengeResponseAuthentication\ no/ -i /etc/ssh/sshd_config
cat >> /etc/ssh/sshd_config <<'EOG'
PermitRootLogin without-password
EOG

# Randomize root password now and also do at each boot.
dd if=/dev/urandom count=50|md5sum|passwd --stdin root

cat >> /etc/rc.d/rc.local <<'EOG'
# Randomize root password.
dd if=/dev/urandom count=50|md5sum|passwd --stdin root

# Contextualization
. /usr/bin/onecontext
EOG

cat > /usr/bin/onecontext <<'EOG'
#!/bin/sh -e
  
[ -e /dev/hdc ] && DEVICE=hdc || DEVICE=sr0
  
mount -t iso9660 /dev/$DEVICE /mnt
  
if [ -f /mnt/context.sh ]; then
  . /mnt/init.sh
fi
  
umount /mnt
  
EOG

chmod 0755 /usr/bin/onecontext 

EOF

chmod 0755 post-install.sh
(./post-install.sh) > post-install.log 2>&1
