# cord-snapshot
cd ~
git clone https://github.com/mkl0301/cord-snapshot.git
ln -s cord-snapshot/ opencord

sed -e "s/\/root\/vagrant\/test/"$(pwd|sed -e 's/\//\\\//g')"\/opencord\/libvirt/g" ~/opencord/libvirt/Vagrantfile.1 -i

sudo -s


if [ ! -e "~/qemu/aarch64-softmmu/qemu-system-aarch64" ] ; then
        apt-get build-dep -y qemu
        apt-get install -y git libyajl2 libyajl-dev libxml2 libxml2-dev \
        libdevmapper-dev libpciaccess-dev libnl-dev
        #cd ~; git clone git://cagit1.caveonetworks.com/toolchain/qemu.git
        cd ~/qemu
        git checkout ThunderX-4.2
        ./configure --prefix=/usr \
        --localstatedir=/var \
        --sysconfdir=/etc \
        --target-list=aarch64-softmmu \
        --enable-kvm \
        --enable-fdt
        make -j48
        make install
fi

#vagrant
apt-get install -y libapparmor-dev bsdtar


if [ ! -e "~/libvirt/libvirt-1.2.21/./daemon/.libs/libvirtd" ] ; then
        apt install -y libvirt-bin
        mkdir -p ~/libvirt
        cd libvirt
        if [ ! -e "libvirt-1.2.21.tar.gz" ] ; then
                wget http://libvirt.org/sources/libvirt-1.2.21.tar.gz
        fi
        if [ ! -d "libvirt-1.2.21" ] ; then
                tar zxf libvirt-1.2.21.tar.gz
        fi
        cd libvirt-1.2.21
        ./configure --prefix=/usr --localstatedir=/var --sysconfdir=/etc --with-apparmor-profiles
        make install

	cp -bv ~/cord-snapshot/libvirt/usr.sbin.libvirtd /etc/apparmor.d/usr.sbin.libvirtd
	cp -bv ~/cord-snapshot/libvirt/libvirt-qemu /etc/apparmor.d/abstractions/libvirt-qemu

        if [ ! -e "/etc/libvirt/libvirtd.conf.0" ] ; then
                cp /etc/libvirt/libvirtd.conf /etc/libvirt/libvirtd.conf.0
        fi
        if [ `grep "unix_sock_group" /etc/libvirt/libvirtd.conf  |grep -v "#" | wc -l` -eq "0" ] ; then
                echo "unix_sock_group = \"libvirtd\"" >> /etc/libvirt/libvirtd.conf
        fi
        if [ `grep "unix_sock_ro_perms" /etc/libvirt/libvirtd.conf  |grep -v "#" | wc -l` -eq "0" ] ; then
                echo "unix_sock_ro_perms = \"0777\"" >> /etc/libvirt/libvirtd.conf
        fi
        if [ `grep "unix_sock_rw_perms" /etc/libvirt/libvirtd.conf  |grep -v "#" | wc -l` -eq "0" ] ; then
                echo "unix_sock_rw_perms = \"0770\"" >> /etc/libvirt/libvirtd.conf
        fi
        if [ `grep "auth_unix_ro" /etc/libvirt/libvirtd.conf  |grep -v "#" | wc -l` -eq "0" ] ; then
                echo "auth_unix_ro = \"none\"" >> /etc/libvirt/libvirtd.conf
        fi
        if [ `grep "auth_unix_rw" /etc/libvirt/libvirtd.conf  |grep -v "#" | wc -l` -eq "0" ] ; then
               echo "auth_unix_rw = \"none\"" >> /etc/libvirt/libvirtd.conf
        fi
        service libvirt-bin restart
        service apparmor reload
fi
#4. install rvm (refer to rvm.io)

apt-get install -y curl libffi-dev
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\curl -sSL https://get.rvm.io | bash -s stable
source /etc/profile.d/rvm.sh


#5. Build and select ruby-2.2
rvm install ruby-2.2.6
gem install bundler


#6. checkout and bundle vagrant
cd ~/
git clone https://github.com/mitchellh/vagrant.git
cd ~/vagrant
git checkout v1.9.1
bundler install --path vendor/cache
bundler --binstubs exec


#7. add vagrant/exec to $PATH
#export PATH=$PATH:$(pwd)/exec #will failled in next step
export PATH=$(pwd)/exec:$PATH
echo 'export PATH=$(pwd)/exec:$PATH' >> ~/.bashrc
echo 'export PATH=$(pwd)/exec:$PATH' >> /root/.bashrc

#8. install vagrant-libvirt plugin
vagrant plugin install vagrant-libvirt
#exec/vagrant plugin install vagrant-libvirt


#9. Add my test 14.04 box as the name "custom"

vagrant box add aarch64_trusty.box --name "ubuntu/trusty64"


#10. vagrant up
cd ~/opencord/build
vagrant up

cd ~/opencord/vagrant
vagrant up
vagrant up corddev prod --provider libvirt

#-----------------------------------------------------


sudo apt-get install software-properties-common
sudo apt-add-repository ppa:ansible/ansible
sudo apt-get update
sudo apt-get install ansible

sudo addgroup --gid 1000 vagrant
sudo adduser vagrant --uid 1000 --home /home/vagrant --gid 1000

