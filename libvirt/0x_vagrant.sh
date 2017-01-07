#!/bin/bash
# ---- install rvm -----
if [ ! -e "/usr/local/rvm/bin/rvm" ]; then
   apt-get install -y curl
   gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
   curl -sSL https://get.rvm.io | bash -s stable
   source /etc/profile.d/rvm.sh
fi
# ---- check and build ruby 2.2 ----
if [[ ! `ruby --version` =~ '2.2.6' ]]; then
   rvm install ruby-2.2.6
   rvm use 2.2
fi
# ---- get more deb ----
apt-get install -y libffi-dev bsdtar 
# ---- get vagrant source ---
git clone https://github.com/mitchellh/vagrant.git
cd vagrant
git checkout v1.9.1
# ---- bundle vagrant ---
gem install bundler
bundle install --path vendor/cache
bundle --binstubs exec
# ---- install vagrant-libvirt plugin ----
./exec/vagrant plugin install vagrant-libvirt
cd ..
echo "vagrant is ready, please add $PWD/vagrant/exec to PATH"

