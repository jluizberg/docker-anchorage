#!/bin/bash
set -e

if [ -f /ssl/fullchain.pem ] && [ -f /ssl/privkey.pem ]; then
    echo "Enabling PostgreSQL SSL..."
    mkdir -p "$PGDATA/ssl"
    cp /ssl/fullchain.pem "$PGDATA/ssl/server.crt"
    cp /ssl/privkey.pem "$PGDATA/ssl/server.key"
    chmod 600 "$PGDATA/ssl/server.key"
    chown -R postgres:postgres "$PGDATA/ssl"

    echo "" >> "$PGDATA/postgresql.conf"
    echo "# SSL Configuration" >> "$PGDATA/postgresql.conf"
    echo "ssl = on" >> "$PGDATA/postgresql.conf"
    echo "ssl_cert_file = '$PGDATA/ssl/server.crt'" >> "$PGDATA/postgresql.conf"
    echo "ssl_key_file = '$PGDATA/ssl/server.key'" >> "$PGDATA/postgresql.conf"
else
    echo "WARNING: SSL certificates not found. PostgreSQL will run without SSL."
fi
