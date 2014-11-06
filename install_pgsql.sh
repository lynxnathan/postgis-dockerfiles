#!/bin/bash

LC_ALL=C
DEBIAN_FRONTEND=noninteractive

set -xe
apt-get update -qq
apt-get install -y -q wget

wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" >> /etc/apt/sources.list.d/postgresql.list

echo -e '#!/bin/sh\nexit 101' > /usr/sbin/policy-rc.d
chmod +x /usr/sbin/policy-rc.d

apt-get update -qq
apt-get install -y -q \
    postgresql-$POSTGRESQL_VERSION \
    postgresql-contrib-$POSTGRESQL_VERSION \
    postgis postgresql-$POSTGRESQL_VERSION-postgis-2.1 \
    postgresql-$POSTGRESQL_VERSION-pgextwlist
rm -rf /var/lib/apt/lists/
apt-get clean
rm /usr/sbin/policy-rc.d
