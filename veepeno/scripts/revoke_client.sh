#!/bin/bash

# Check if client name is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <client_name>"
    exit 1
fi

CLIENT_NAME="$1"
EASYRSA_DIR="/easy-rsa"
OPENVPN_DIR="/etc/openvpn"
CLIENT_CONFIG_DIR="${OPENVPN_DIR}/client-configs"

# Check if client exists
if [ ! -f "${OPENVPN_DIR}/pki/issued/${CLIENT_NAME}.crt" ]; then
    echo "Error: Client ${CLIENT_NAME} does not exist"
    exit 1
fi

# Revoke the client certificate
cd "${EASYRSA_DIR}"
./easyrsa revoke "${CLIENT_NAME}"

# Update CRL
./easyrsa gen-crl

# Copy CRL to OpenVPN directory
cp pki/crl.pem "${OPENVPN_DIR}/"

# Remove client configuration
rm -f "${CLIENT_CONFIG_DIR}/${CLIENT_NAME}.ovpn"

# Remove client certificates
rm -f "${OPENVPN_DIR}/pki/issued/${CLIENT_NAME}.crt"
rm -f "${OPENVPN_DIR}/pki/private/${CLIENT_NAME}.key"

# Return success message
echo "{\"message\": \"Client ${CLIENT_NAME} has been revoked successfully\"}" 