#!/usr/bin/env bash
# ==============================================================================
# Project: Personal Secure Gateway & DNS Firewall (AdGuard Home + Docker)
# Author: Muhammadqodir Davlatyorov
# Purpose: Automated 1-Click Deployment for Linux VPS (Ubuntu / Debian)
# ==============================================================================

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}   Personal Secure Gateway - Automated Deployment     ${NC}"
echo -e "${BLUE}======================================================${NC}"

# Check Docker installation
if ! command -v docker &> /dev/null; then
    echo -e "${RED}[ERROR] Docker is not installed.${NC}"
    echo -e "${YELLOW}Please install Docker first: curl -fsSL https://get.docker.com | sh${NC}"
    exit 1
fi

# Fix Port 53 conflict on Ubuntu / Debian (systemd-resolved)
if ss -tuln | grep -q ':53 '; then
    echo -e "${YELLOW}[!] Port 53 is currently occupied. Releasing port 53 from systemd-resolved...${NC}"
    sudo mkdir -p /etc/systemd/resolved.conf.d/
    sudo tee /etc/systemd/resolved.conf.d/adguard.conf > /dev/null <<EOF
[Resolve]
DNS=1.1.1.1 9.9.9.9
DNSStubListener=no
EOF
    sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf || true
    sudo systemctl restart systemd-resolved || true
    sleep 2
    echo -e "${GREEN}[OK] Port 53 successfully released!${NC}"
fi

# Ensure directory permissions
mkdir -p ./work ./conf
chmod -R 755 ./conf ./work

echo -e "${BLUE}[*] Starting AdGuard Home container...${NC}"
docker compose pull
docker compose up -d

SERVER_IP=$(curl -s -4 https://ifconfig.me || hostname -I | awk '{print $1}')

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN} [SUCCESS] Secure Gateway is successfully deployed!   ${NC}"
echo -e "${GREEN}======================================================${NC}"
echo -e "Web Dashboard : ${BLUE}http://${SERVER_IP}:8080${NC}"
echo -e "Login         : ${YELLOW}Str4nge${NC}"
echo -e "DNS IP        : ${YELLOW}${SERVER_IP}${NC} (Port 53 TCP/UDP)"
echo -e "Active Blocks : ${GREEN}Anti-Gambling, C2 Malware, DoH Bypass, Telemetry${NC}"
echo -e "${GREEN}======================================================${NC}"
