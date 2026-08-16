#!/bin/bash
# Uses the certbot image for creating or renewing the SSL certificate
set -euo pipefail

source ./shared-functions.sh

check_root
load_environment

domains=("${GLOBAL_PUBLIC_DOMAIN}" "*.${GLOBAL_PUBLIC_DOMAIN}" "*.${GLOBAL_INTRA_DOMAIN}")
printf -v dns_parms " -d %s" "${domains[@]}"

echo "Getting the certificate for domains: ${dns_parms}"

# Create the dir for the certificates 
mkdir -p ${LETSENCRYPT_CERTIFICATES_DIR}

# Create group for certificate users
getent group ${GLOBAL_CERTIFICATE_GROUP} >/dev/null || groupadd ${GLOBAL_CERTIFICATE_GROUP}

# Request the certificate
docker run -it --rm \
    -v ${LETSENCRYPT_CERTIFICATES_DIR}:${LETSENCRYPT_CERTIFICATES_DIR} \
    certbot/certbot certonly \
    --manual \
    --key-type rsa \
    --rsa-key-size 2048 \
    --preferred-challenges \
    dns ${dns_parms}

source_certs="${LETSENCRYPT_CERTIFICATES_DIR}"
target_certs="${GLOBAL_SSL_DIR}/letsencrypt"

if [[ -d "${source_certs}/live" ]]; then
    if [[ -d "${target_certs}/live" ]]; then
        rm -rf "${target_certs}/live"
    fi

    mkdir -p "${target_certs}/live"

    echo "Copying certificates..."
    cp -rL "${source_certs}/live" "${target_certs}"

    # Set proper permissions
    chown -R root:${GLOBAL_CERTIFICATE_GROUP} "${target_certs}"
    find ${target_certs} -type d -exec chmod u=rwx,g=rx,o= {} +
    find ${target_certs} -type f -name '*.pem' -exec chmod u=rw,g=r,o=r {} +
    find ${target_certs} -type f -name 'privkey*.pem' -exec chmod u=rw,g=r,o= {} +
fi

echo "========================================="
echo "✅ SSL certificates available"
echo "========================================="


