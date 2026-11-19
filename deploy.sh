#!/usr/bin/env bash
# ==============================================================================
# Project: Personal Secure Gateway & DNS Firewall (AdGuard Home + Docker)
# Author: Muhammadqodir Davlatyorov
# Purpose: Non-invasive, resource-constrained container deployment
# Safe for shared VPS environments (HestiaCP / cPanel / Plesk friendly)
# ==============================================================================

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}   Personal Secure Gateway - Safe Docker Deployment   ${NC}"
echo -e "${BLUE}======================================================${NC}"

# Check Docker installation
if ! command -v docker &> /dev/null; then
    echo -e "${RED}[ERROR] Docker is not installed.${NC}"
    echo -e "${YELLOW}Please install Docker: curl -fsSL https://get.docker.com | sh${NC}"
    exit 1
fi

# Ensure directories exist and have proper permissions
mkdir -p ./work ./conf
chmod -R 755 ./conf ./work

echo -e "${BLUE}[*] Pulling and starting isolated container (Max RAM: 256MB)...${NC}"
docker compose pull
docker compose up -d

SERVER_IP=$(curl -s -4 https://ifconfig.me || hostname -I | awk '{print $1}')

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN} [SUCCESS] AdGuard Home container is running safely!  ${NC}"
echo -e "${GREEN}======================================================${NC}"
echo -e "Web Dashboard : ${BLUE}http://${SERVER_IP}:3080${NC}"
echo -e "Login         : ${YELLOW}Str4nge${NC}"
echo -e "Memory Limit  : ${GREEN}256 MB (Hard Cap)${NC}"
echo -e "CPU Limit     : ${GREEN}0.25 vCPU (Hard Cap)${NC}"
echo -e "Web Ports     : ${GREEN}Port 3080 (80, 443 and 8080 are untouched!)${NC}"
echo -e "${GREEN}======================================================${NC}"
echo -e "${YELLOW}[NOTE]:${NC}"
echo -e "DNS answers ONLY allowed clients (none by default). Add your device IPs in the dashboard:"
echo -e "Settings -> DNS settings -> Access settings -> Allowed clients."
echo -e "Docker-published ports bypass the HestiaCP firewall - do NOT open 53 for everyone."
echo -e "${GREEN}======================================================${NC}"
