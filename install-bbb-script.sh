#!/bin/bash

numofargs=$#

if [ $numofargs -eq 0 ]
  then
	echo "ERROR: Please enter server ip or host name"
	echo "  example of using this script:"
	echo "	 install-bbb-script.sh ec2-50-17-30-204.compute-1.amazonaws.com"
	echo "  We need IP to configure BBB with it"
	exit
fi

echo "STARTING INSTALLING BBB"

# Add the BigBlueButton key
wget http://ubuntu.bigbluebutton.org/bigbluebutton.asc -O- | sudo apt-key add -

# Add the BigBlueButton repository URL and ensure the multiverse is enabled
echo "deb http://ubuntu.bigbluebutton.org/lucid_dev_08/ bigbluebutton-lucid main" | sudo tee /etc/apt/sources.list.d/bigbluebutton.list
echo "deb http://us.archive.ubuntu.com/ubuntu/ lucid multiverse" | sudo tee -a /etc/apt/sources.list

echo y | sudo apt-get update
echo y | sudo apt-get dist-upgrade

echo y | sudo apt-get install zlib1g-dev libssl-dev libreadline5-dev libyaml-dev build-essential bison checkinstall libffi5 gcc checkinstall libreadline5 libyaml-0-2

#--- INSTALL RUBY
cd /tmp
wget http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p290.tar.gz
tar xvzf ruby-1.9.2-p290.tar.gz
cd ruby-1.9.2-p290
./configure --prefix=/usr\
            --program-suffix=1.9.2\
            --with-ruby-version=1.9.2\
            --disable-install-doc
make
sudo checkinstall -D -y\
                  --fstrans=no\
                  --nodoc\
                  --pkgname='ruby1.9.2'\
                  --pkgversion='1.9.2-p290'\
                  --provides='ruby'\
                  --requires='libc6,libffi5,libgdbm3,libncurses5,libreadline5,openssl,libyaml-0-2,zlib1g'\
sudo update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby1.9.2 500\
                        --slave   /usr/bin/ri   ri   /usr/bin/ri1.9.2\
                        --slave   /usr/bin/irb  irb  /usr/bin/irb1.9.2\
                        --slave   /usr/bin/gem  gem  /usr/bin/gem1.9.2\
                        --slave   /usr/bin/erb  erb  /usr/bin/erb1.9.2\
                        --slave   /usr/bin/rdoc rdoc /usr/bin/rdoc1.9.2

# -- INSTALL FREESWITCH
echo y | sudo apt-get install bbb-freeswitch-config

# -- INSTALL BBB
echo y | sudo apt-get install bigbluebutton

# -- INSTALL API DEMOS
echo y | sudo apt-get install bbb-demo

# -- SET SERVER IP FROM FIRST VAR IN A SCRIPT
sudo bbb-conf --setip "$1"

# -- DO CLEAN RESTART
sudo bbb-conf --clean
sudo bbb-conf --check