#!/bin/bash
#stand alone LAMP builder - 8/2/2018, Matt Brister
#because *someone* got alergic to Ansible. Looking at you Frode...

#1. Install updates
apt-get update && apt-get dist-upgrade -y

#2. fix timezone
#echo "America/Los_Angeles" > /etc/timezone
#dpkg-reconfigure -f noninteractive tzdata
timedatectl set-timezone America/Los_Angeles

#3. mount /tmp as RAMDisk
echo 'tmpfs /tmp  tmpfs defaults,noatime,mode=1777,uid=root,gid=root,size=1024M 0 0' >> /etc/fstab
mount /tmp

#4. kernel tuning
sysctl -w net.ipv4.ip_local_port_range="1024 65535"
sysctl -w net.ipv4.tcp_tw_reuse=1
sysctl -w net.ipv4.tcp_max_syn_backlog=1
sysctl -w net.core.rmem_max=16777216
sysctl -w net.core.wmem_max=16777216
sysctl -w net.core.somaxconn=1024
sysctl -w vm.swappiness=0
sysctl -w kernel.sched_migration_cost_ns=5000000
sysctl -w kernel.sched_autogroup_enabled=0

#5. install all the things
#add-apt-repository -y ppa:ondrej/php
#add-apt-repository -y ppa:webupd8team/java
#cat << EOF > /etc/apt/sources.list.d/xenial.list
#deb http://archive.ubuntu.com/ubuntu/ xenial main
#deb http://archive.ubuntu.com/ubuntu/ xenial-updates main
#EOF
#cat << EOF > /etc/apt/preferences.d/ruby-xenial
#Package: ruby
#Pin: release v=16.04, l=Ubuntu
#Pin-Priority: 1024
#
#Package: rake
#Pin: release v=16.04, l=Ubuntu
#Pin-Priority: 1024
#EOF
apt-get update
apt-get install -y apache2 apache2-utils libapache2-mod-php7.1 clamav htop iotop mailutils mysql-common nmap nmon libxml2-dev php7.1-common php7.1-cli php7.1-curl php7.1-dev php7.1-gd php7.1-imagick php7.1-intl php7.1-json php7.1-memcache php7.1-redis php7.1-mysql php7.1-readline php7.1-bcmath php7.1-bz2 php7.1-gnupg php7.1-dba php7.1-mbstring php7.1-memcached php7.1-soap php7.1-ssh2 php7.1-zip php7.1-xml php7.1-mcrypt pkg-php-tools python3 python-pip sysstat tcl tcptraceroute tcptrace php-pear ruby gdebi-core tcsh unzip whois wireshark
mv /etc/init.d/codedeploy-agent.service /lib/systemd/system/codedeploy-agent.service
systemctl enable codedeploy-agent.service

#6.install pecl Packages
#yes '' | /usr/bin/pecl install xmldiff
#yes '' | /usr/bin/pecl install apcu
#echo extension=mcrypt.so > /etc/php/7.1/mods-available/mcrypt.ini
#echo extension=xmldiff.so > /etc/php/7.1/mods-available/xmldiff.ini
#echo extension=apcu.so > /etc/php/7.1/mods-available/apcu.ini
#echo apc.enabled=1 >> /etc/php/7.1/mods-available/apcu.ini
#echo apc.enable_cli=On >> /etc/php/7.1/mods-available/apcu.ini
#phpenmod xmldiff mcrypt apcu

#8. install java 8
apt-get install python-software-properties debconf-utils
#echo debconf shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
#apt-get install -y oracle-java8-installer oracle-java8-set-default

#9. install aws cli
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

#10. /tmp and /var/log/ cleanup crons
echo '0 2 * * * root find /var/log/apache2/ -type f -mtime +1 -delete' >> /etc/cron.d/cleanup
echo '0 2 * * * root find /var/log/app/ -type f -mtime +1 -delete' >> /etc/cron.d/cleanup
echo '0 2 * * * root find /tmp -maxdepth 1 -mtime +0 -type f -delete' >> /etc/cron.d/cleanup

#11. Prod certs

#12. configure php

#13. Add users
usermod -aG admin mbrister

#14. install CD agent
wget https://aws-codedeploy-us-west-2.s3.amazonaws.com/latest/install
chmod +x ./install
./install auto

#15. postfix install and config
debconf-set-selections <<< "postfix postfix/mailname string your.hostname.com"
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'No configuration'"
apt-get install -y postfix bsd-mailx

#16. apache configs
#16a. copy
#16b. Enable
mkdir /usr/local/html
mkdir /var/log/app
mkdir /var/log/apache2
chown www-data:www-data /usr/local/html
chown www-data:www-data /var/log/app
chown www-data:www-data /var/log/apache2

#19. Open firewall for ssl
ufw allow 443/tcp

#20. Reboot!
shutdown -r now
