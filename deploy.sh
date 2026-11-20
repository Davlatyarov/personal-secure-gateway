#!/usr/bin/env bash
# ==============================================================================
# Project: Personal Secure Gateway & DNS Firewall (AdGuard Home + Docker)
# Author: Muhammadqodir Davlatyorov
# Purpose: Non-invasive, hardened container deployment
# Safe for shared VPS environments (HestiaCP / cPanel friendly)
# ==============================================================================
set -euo pipefail
cd "$(dirname "$0")"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}   Personal Secure Gateway - Safe Docker Deployment   ${NC}"
echo -e "${BLUE}======================================================${NC}"

# Check Docker installation
command -v docker >/dev/null || { echo -e "${RED}[ERROR] Docker is not installed.${NC}"; exit 1; }
docker compose version >/dev/null 2>&1 || { echo -e "${RED}[ERROR] docker compose v2 plugin is missing.${NC}"; exit 1; }

# Ensure directories exist and have proper permissions
mkdir -p ./work ./conf
chmod -R 755 ./conf ./work

echo -e "${BLUE}[*] Pulling and starting isolated container (Max RAM: 512MB, 1.0 CPU)...${NC}"
docker compose pull
docker compose up -d

SERVER_IP=$(curl -s -4 https://ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}')

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN} [SUCCESS] AdGuard Home container is running safely!  ${NC}"
echo -e "${GREEN}======================================================${NC}"
echo -e "Web Dashboard : ${BLUE}http://${SERVER_IP}:3080${NC}"
echo -e "Login         : ${YELLOW}Str4nge${NC}"
echo -e "DoT Hostname  : ${GREEN}s21.dns.davlatyarov.uz / safe.dns.davlatyarov.uz${NC}"
echo -e "Memory Limit  : ${GREEN}512 MB (Hard Cap)${NC}"
echo -e "CPU Limit     : ${GREEN}1.0 vCPU (Burst Cap)${NC}"
echo -e "Web Ports     : ${GREEN}Port 3080 (80, 443, 8083, and 53 are untouched!)${NC}"
echo -e "${GREEN}======================================================${NC}"
