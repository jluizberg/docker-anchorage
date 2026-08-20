#!/bin/bash
set -euo pipefail

source ./shared-functions.sh

check_root
load_environment

echo "Installing configuration files..."

# Remove existing nginx configuration if it exists
if [ -d "${NGINX_DATA_DIR}" ]; then
    # Remove old configuration
    rm -rf ${NGINX_DATA_DIR}
fi

mkdir -p ${NGINX_DATA_DIR}/conf.d
mkdir -p ${NGINX_DATA_DIR}/logs
# mkdir -p ${RANCHER_DATA_DIR}
mkdir -p ${PROGET_DATA_DIR}/packages
mkdir -p ${PROGET_DATA_DIR}/database
mkdir -p ${PROGET_DATA_DIR}/backups
mkdir -p ${POSTGRES_DATA_DIR}
mkdir -p ${KEYCLOAK_DATA_DIR}
mkdir -p ${QDRANT_DATA_DIR}
# mkdir -p ${WEBSEARCH_DATA_DIR}
mkdir -p ${TRANSLATOR_DATA_DIR}

chown -R 1000:1000 ${KEYCLOAK_DATA_DIR}
chmod 755 ${KEYCLOAK_DATA_DIR}

# Converts the .env variables script into a list of variables to be replaced by "envsubst" function
VARS=$(grep -v '^#' .env | cut -d= -f1 | sed 's/^/${/;s/$/}/' | tr '\n' ' ')

# Substitute the variables in WEBSEARCH config.json and copy it to the WEBSEARCH_DATA_DIR
# envsubst "$VARS" < "./web-search/config.json" > "${WEBSEARCH_DATA_DIR}/config.json"

# Check if nginx config files exist in current directory
if [ ! -d "./nginx" ]; then
    echo "ERROR: ./nginx directory not found!" >&2
    exit 1
fi

echo "Copying nginx configuration files..."
mkdir -p ${NGINX_DATA_DIR}/conf.d

for file in "./nginx/conf.d"/*; do
    [ -f "$file" ] || continue

    filename="$(basename "$file")"
    output_file="${NGINX_DATA_DIR}/conf.d/$filename"

    envsubst "$VARS" < "$file" > "$output_file"
done

cp ./nginx/*.conf ${NGINX_DATA_DIR}/

# Validate nginx configuration before proceeding
if command_exists docker && docker compose ps 2>/dev/null | grep -q "nginx"; then
    echo "Validating nginx configuration..."
    if ! docker exec nginx nginx -t 2>/dev/null; then
        echo "WARNING: nginx configuration validation failed when applied."
        echo "The configuration files were copied but may contain errors."
        echo "Check the logs with: docker logs nginx"
    else
        echo "nginx configuration is valid."
    fi
fi

echo "Installing images..."

envsubst < ./docker-compose.yaml > /tmp/docker-compose.yaml

# Start containers
echo "Starting containers..."
docker compose -f /tmp/docker-compose.yaml up -d

# Wait for services to be healthy
echo "Waiting for services to start..."
sleep 5

echo "Setup complete!"
echo ""

