# VeePeno VPN

A professional, self-hosted VPN solution with a web interface for easy client management. VeePeno provides a secure and private way to access your network remotely using OpenVPN technology.

## Features

- 🔒 Secure OpenVPN server with strong encryption
- 🌐 Web-based management interface
- 📱 Easy client certificate generation and management
- 🔄 Automatic client certificate revocation
- 🐳 Docker-based deployment
- 📊 User-friendly dashboard
- 🔐 Strong security defaults

## Prerequisites

Before you begin, ensure you have:

- Docker and Docker Compose installed
- Linux-based server (Ubuntu 20.04+ recommended)
- Open ports:
  - 1194/UDP (OpenVPN)
  - 8080/TCP (Web interface)
- Domain name or public IP address
- Basic understanding of networking concepts

## Quick Setup Guide

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/veepeno.git
cd veepeno
```

### 2. Configuration
1. Create and edit the `.env` file:
```bash
cp .env.example .env
nano .env  # or use your preferred text editor
```

2. Update the following essential variables in `.env`:
   - `OVPN_SERVER_NAME`: Your server's domain or IP
   - `WEB_ADMIN_USER`: Your admin username
   - `WEB_ADMIN_PASSWORD`: Your secure admin password

### 3. Start the Services
```bash
docker-compose up -d
```

### 4. Access the Web Interface
- Open `http://your-server-ip:8080`
- Log in with your admin credentials
- Change the default password immediately

## Detailed Configuration

### Environment Variables (.env)

#### OpenVPN Configuration
| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| OVPN_SERVER_NAME | Server domain or IP | - | Yes |
| OVPN_PROTOCOL | VPN protocol (udp/tcp) | udp | No |
| OVPN_PORT | VPN server port | 1194 | No |
| OVPN_DNS_SERVERS | DNS servers for clients | 8.8.8.8,8.8.4.4 | No |

#### Web Interface Configuration
| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| WEB_PORT | Web interface port | 8080 | No |
| WEB_ADMIN_USER | Admin username | admin | Yes |
| WEB_ADMIN_PASSWORD | Admin password | - | Yes |

#### Security Settings
| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| OVPN_CIPHER | Encryption cipher | AES-256-GCM | No |
| OVPN_AUTH | Authentication algorithm | SHA384 | No |
| OVPN_TLS_VERSION | TLS version | 1.2 | No |

### Port Configuration

#### Required Ports
- 1194/UDP: OpenVPN server
- 8080/TCP: Web interface

#### Opening Ports (Ubuntu/Debian)
```bash
# OpenVPN port
sudo ufw allow 1194/udp

# Web interface port
sudo ufw allow 8080/tcp

# Enable firewall
sudo ufw enable
```

## Usage Guide

### Managing VPN Clients

#### Creating a New Client
1. Log in to the web interface
2. Click "New Client"
3. Enter client name
4. Download the .ovpn configuration file

#### Client Setup
1. Install OpenVPN client:
   - Windows: OpenVPN GUI
   - macOS: Tunnelblick
   - Linux: `sudo apt install openvpn`
   - Mobile: OpenVPN Connect app

2. Import the .ovpn file
3. Connect to the VPN

#### Revoking Access
1. Find the client in the web interface
2. Click "Revoke"
3. Confirm the action

### Maintenance

#### Updating the System
```bash
# Pull latest images
docker-compose pull

# Restart services
docker-compose up -d
```

#### Backup
```bash
# Backup OpenVPN configuration
tar -czf vpn-backup.tar.gz openvpn/

# Backup environment variables
cp .env vpn-backup.env
```

#### Restore
```bash
# Restore OpenVPN files
tar -xzf vpn-backup.tar.gz

# Restore environment variables
cp vpn-backup.env .env
```

## Security Best Practices

1. **Initial Setup**
   - Change default admin credentials
   - Use strong passwords
   - Configure firewall rules
   - Keep system updated

2. **Regular Maintenance**
   - Monitor logs for suspicious activity
   - Regularly update the system
   - Rotate client certificates
   - Review active connections

3. **Client Management**
   - Revoke unused certificates
   - Use unique client names
   - Secure .ovpn file distribution
   - Monitor client connections

## Troubleshooting

### Common Issues

#### Web Interface
- **Can't access web interface**
  - Check if port 8080 is open
  - Verify Docker containers are running
  - Check firewall settings

#### VPN Connection
- **Connection fails**
  - Verify port 1194/UDP is open
  - Check client configuration
  - Ensure server certificate is valid
  - Check OpenVPN logs:
    ```bash
    docker-compose logs openvpn
    ```

#### Certificate Issues
- **Certificate errors**
  - Verify certificate hasn't been revoked
  - Check certificate expiration
  - Regenerate if needed

### Logs and Debugging
```bash
# View all logs
docker-compose logs

# View OpenVPN logs
docker-compose logs openvpn

# View web interface logs
docker-compose logs web

# Follow logs in real-time
docker-compose logs -f
```

## Support

For support:
1. Check the troubleshooting guide
2. Review the logs
3. Open an issue on GitHub
4. Check OpenVPN documentation

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- OpenVPN project
- Docker community
- Flask framework
