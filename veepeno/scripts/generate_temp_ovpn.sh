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

# Create client certificate
cd "${EASYRSA_DIR}"
./easyrsa build-client-full "${CLIENT_NAME}" nopass

# Create client config directory if it doesn't exist
mkdir -p "${CLIENT_CONFIG_DIR}"

# Generate client configuration
cat > "${CLIENT_CONFIG_DIR}/${CLIENT_NAME}.ovpn" << EOF
client
dev tun
proto ${OVPN_PROTOCOL:-udp}
remote ${OVPN_SERVER_NAME} ${OVPN_PORT:-1194}
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher ${OVPN_CIPHER:-AES-256-GCM}
auth ${OVPN_AUTH:-SHA384}
key-direction 1
verb 3
<ca>
$(cat "${OPENVPN_DIR}/pki/ca.crt")
</ca>
<cert>
$(cat "${OPENVPN_DIR}/pki/issued/${CLIENT_NAME}.crt")
</cert>
<key>
$(cat "${OPENVPN_DIR}/pki/private/${CLIENT_NAME}.key")
</key>
<tls-auth>
$(cat "${OPENVPN_DIR}/pki/ta.key")
</tls-auth>
EOF

# Set proper permissions
chmod 600 "${CLIENT_CONFIG_DIR}/${CLIENT_NAME}.ovpn"

# Return client info as JSON
echo "{\"name\": \"${CLIENT_NAME}\", \"created_at\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"}" 