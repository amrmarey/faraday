#!/bin/bash
set -e

CERT_DIR="/etc/nginx/certs"
mkdir -p "${CERT_DIR}"

KEY_FILE="${CERT_DIR}/faraday.key"
CRT_FILE="${CERT_DIR}/faraday.crt"

if [ ! -f "${CRT_FILE}" ] || [ ! -f "${KEY_FILE}" ]; then
  echo "🔐 Generating self-signed certificate..."
  openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout "${KEY_FILE}" \
    -out "${CRT_FILE}" \
    -subj "/C=EG/ST=Alexandria/L=Alexandria/O=Faraday/OU=IT/CN=${DOMAIN_NAME}"
else
  echo "ℹ️ Certificate already exists."
fi

exec nginx -g "daemon off;"
