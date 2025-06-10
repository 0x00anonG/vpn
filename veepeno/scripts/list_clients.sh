#!/bin/bash

OPENVPN_DIR="/etc/openvpn"
CLIENTS=()

# Get list of client certificates
for cert in "${OPENVPN_DIR}/pki/issued/"*.crt; do
    if [ -f "$cert" ]; then
        client_name=$(basename "$cert" .crt)
        # Skip server certificate
        if [ "$client_name" != "server" ]; then
            # Get certificate creation date
            created_at=$(openssl x509 -in "$cert" -noout -startdate | cut -d= -f2)
            created_at=$(date -d "$created_at" -u +"%Y-%m-%dT%H:%M:%SZ")
            CLIENTS+=("{\"name\": \"$client_name\", \"created_at\": \"$created_at\"}")
        fi
    fi
done

# Output as JSON array
echo "["
if [ ${#CLIENTS[@]} -gt 0 ]; then
    printf '%s\n' "${CLIENTS[@]}" | sed '$!s/$/,/'
fi
echo "]" 