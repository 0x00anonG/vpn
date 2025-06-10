#!/bin/bash

OPENVPN_DIR="/etc/openvpn"
STATUS_FILE="/tmp/openvpn-status.log"

# Get server status
if [ -f "$STATUS_FILE" ]; then
    # Parse status file
    CLIENT_LIST=$(awk '/^CLIENT_LIST/,/^ROUTING_TABLE/' "$STATUS_FILE" | grep -v '^CLIENT_LIST\|^ROUTING_TABLE\|^Common\|^$')
    ROUTING_TABLE=$(awk '/^ROUTING_TABLE/,/^GLOBAL_STATS/' "$STATUS_FILE" | grep -v '^ROUTING_TABLE\|^GLOBAL_STATS\|^Common\|^$')
    GLOBAL_STATS=$(awk '/^GLOBAL_STATS/,/^END/' "$STATUS_FILE" | grep -v '^GLOBAL_STATS\|^END\|^Common\|^$')

    # Count connected clients
    CONNECTED_CLIENTS=$(echo "$CLIENT_LIST" | wc -l)

    # Get server uptime
    if [ -f "/proc/uptime" ]; then
        UPTIME=$(awk '{print int($1)}' /proc/uptime)
    else
        UPTIME=0
    fi

    # Output as JSON
    echo "{
        \"connected_clients\": $CONNECTED_CLIENTS,
        \"uptime\": $UPTIME,
        \"clients\": [
            $(echo "$CLIENT_LIST" | while read -r line; do
                if [ ! -z "$line" ]; then
                    echo "$line" | awk '{
                        printf "{\"name\": \"%s\", \"real_address\": \"%s\", \"virtual_address\": \"%s\", \"connected_since\": \"%s\"}",
                        $1, $2, $3, $4
                    }'
                    echo ","
                fi
            done | sed '$ s/,$//')
        ],
        \"routes\": [
            $(echo "$ROUTING_TABLE" | while read -r line; do
                if [ ! -z "$line" ]; then
                    echo "$line" | awk '{
                        printf "{\"virtual_address\": \"%s\", \"real_address\": \"%s\", \"last_ref\": \"%s\"}",
                        $1, $2, $3
                    }'
                    echo ","
                fi
            done | sed '$ s/,$//')
        ]
    }"
else
    # If status file doesn't exist, return basic info
    echo "{
        \"connected_clients\": 0,
        \"uptime\": 0,
        \"clients\": [],
        \"routes\": []
    }"
fi 