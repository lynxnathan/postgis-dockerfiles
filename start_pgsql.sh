#!/bin/bash

set -e

if [[ -z "$POSTGRESQL_VERSION" ]]; then
    echo "No postgresql version defined"
    exit 1
fi

PGPATH="/usr/lib/postgresql/$POSTGRESQL_VERSION/bin"
PGDATA="/opt/postgresql/$POSTGRESQL_VERSION/main"

INITIALIZED_FILE="/opt/postgresql/$POSTGRESQL_VERSION/initialized"

# read admin password
if [[ -z "$DB_PASSWORD" ]]; then
    if [[ ! -f /opt/postgresql_password ]]; then
        echo "No postgresql password defined"
        exit 1
    else
        DB_PASSWORD="$(cat "/opt/postgresql_password")"
    fi
fi

# upgrade initialized flag
if [[ -f /opt/postgresql/initialized ]]; then
    touch "$INITIALIZED_FILE"
    rm -f /opt/postgresql/initialized
fi

# initialize database
if [[ ! -f "$INITIALIZED_FILE" ]]; then
    mkdir -p "/opt/postgresql/$POSTGRESQL_VERSION/main"
    chown -R postgres:postgres "/opt/postgresql/$POSTGRESQL_VERSION/main"
    su postgres -c "$PGPATH/initdb -D $PGDATA"
    su postgres -c "$PGPATH/postgres --single -D $PGDATA" <<EOF
CREATE USER root WITH SUPERUSER PASSWORD '$DB_PASSWORD';
CREATE DATABASE root OWNER root;
EOF
    echo 'host all all 0.0.0.0/0 md5' >> /opt/postgresql/9.3/main/pg_hba.conf
    touch "$INITIALIZED_FILE"
fi

# symlink initialized flag
ln -sf "$POSTGRESQL_VERSION/initialized" /opt/postgresql/initialized

# run postgresql database
exec su postgres -c "$PGPATH/postgres -D $PGDATA -c 'listen_addresses=*'"
