#!/usr/bin/env bash

export PUPPET_GEM_VERSION='< 4.0.0'

rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs
mkdir -p /etc/puppet/hieradata
mkdir -p /etc/puppet/modules
yum -y install git puppet ruby-devel vim
mv /tmp/Gemfile /etc/puppet/
mv /tmp/hiera.yaml /etc/puppet/
touch /etc/puppet/hieradata/global.yaml
gem install bundle rake --no-rdoc --no-ri
/usr/local/bin/bundle config --global silence_root_warning 1
cd /etc/puppet
rm -f Gemfile.lock
/usr/local/bin/bundle install
cd /etc/puppet/modules/mailexchanger
rm -f Puppetfile.lock
/usr/local/bin/librarian-puppet install --verbose --path=/etc/puppet/modules
