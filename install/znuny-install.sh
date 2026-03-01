#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# Author: Antigravity
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://www.znuny.org/

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y \
  apache2 \
  mariadb-server \
  mariadb-client \
  libapache2-mod-perl2 \
  perl \
  libarchive-zip-perl \
  libauthen-sasl-perl \
  libauthen-ntlm-perl \
  libcgi-pm-perl \
  libcrypt-eksblowfish-perl \
  libcrypt-ssleay-perl \
  libcss-minifier-xs-perl \
  libdatetime-perl \
  libdbd-mysql-perl \
  libdbd-odbc-perl \
  libdbd-pg-perl \
  libdbi-perl \
  libencode-hanextra-perl \
  libexcel-writer-xlsx-perl \
  libio-socket-ssl-perl \
  libjavascript-minifier-xs-perl \
  libjson-xs-perl \
  libmail-imapclient-perl \
  libmoo-perl \
  libnet-dns-perl \
  libnet-ldap-perl \
  libnet-dns-sec-perl \
  libnet-ip-perl \
  libpdf-api2-perl \
  libsoap-lite-perl \
  libsystem-sub-perl \
  libtemplate-perl \
  libtext-csv-xs-perl \
  libv-string-perl \
  libxml-libxml-perl \
  libxml-libxslt-perl \
  libxml-parser-perl \
  libyaml-perl \
  libcrypt-jwt-perl \
  tar \
  bash-completion \
  cron \
  wget \
  curl \
  unzip
msg_ok "Installed Dependencies"

setup_mariadb
MARIADB_DB_NAME="znuny" MARIADB_DB_USER="znuny" setup_mariadb_db

msg_info "Downloading Znuny"
cd /opt
$STD wget https://download.znuny.org/releases/znuny-latest-7.1.tar.gz
$STD tar xfz znuny-latest-7.1.tar.gz
$STD mv znuny-7.1.* znuny
$STD rm znuny-latest-7.1.tar.gz
msg_ok "Downloaded Znuny"

msg_info "Configuring Znuny"
useradd -d /opt/znuny -c 'Znuny user' -g www-data -s /bin/bash znuny
cp /opt/znuny/Kernel/Config.pm.dist /opt/znuny/Kernel/Config.pm

# Inject database credentials
sed -i -e "s|^    \$Self->{Database} = 'otrs';|    \$Self->{Database} = '$MARIADB_DB_NAME';|" \
  -e "s|^    \$Self->{DatabaseUser} = 'otrs';|    \$Self->{DatabaseUser} = '$MARIADB_DB_USER';|" \
  -e "s|^    \$Self->{DatabasePw} = 'some-pass';|    \$Self->{DatabasePw} = '$MARIADB_DB_PASS';|" \
  /opt/znuny/Kernel/Config.pm

# Populate database
mysql -u$MARIADB_DB_USER -p$MARIADB_DB_PASS $MARIADB_DB_NAME < /opt/znuny/scripts/database/znuny-schema.mysql.sql
mysql -u$MARIADB_DB_USER -p$MARIADB_DB_PASS $MARIADB_DB_NAME < /opt/znuny/scripts/database/znuny-initial_insert.mysql.sql
mysql -u$MARIADB_DB_USER -p$MARIADB_DB_PASS $MARIADB_DB_NAME < /opt/znuny/scripts/database/znuny-schema-post.mysql.sql

# Set initial Root password to "root" by modifying the user record
# Typically root password might need to be set via API or CLI script
msg_ok "Configured Znuny"

msg_info "Setting Permissions"
cd /opt/znuny
bin/otrs.SetPermissions.pl --web-group=www-data
msg_ok "Set Permissions"

msg_info "Configuring Apache"
ln -s /opt/znuny/scripts/apache2-httpd.include.conf /etc/apache2/sites-available/znuny.conf
$STD a2ensite znuny
$STD a2enmod perl deflate filter headers
systemctl restart apache2
msg_ok "Configured Apache"

msg_info "Starting Znuny Daemon and Cron"
su - znuny -c "/opt/znuny/bin/Cron.sh start" >/dev/null 2>&1
su - znuny -c "/opt/znuny/bin/znuny.Daemon.pl start" >/dev/null 2>&1
msg_ok "Started Znuny Daemon and Cron"

motd_ssh
customize
cleanup_lxc
