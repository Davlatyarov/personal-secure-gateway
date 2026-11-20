#!/usr/bin/env bash
# ==============================================================================
# Project: Personal Secure Gateway & VPN (AdGuard Home + WireGuard / wg-easy)
# Author: Muhammadqodir Davlatyorov
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
echo -e "${GREEN}   Personal Secure Gateway + WireGuard Deployment    ${NC}"
echo -e "${BLUE}======================================================${NC}"

# Check Docker & Compose
command -v docker >/dev/null || { echo -e "${RED}[ERROR] docker is not installed${NC}"; exit 1; }
docker compose version >/dev/null 2>&1 || { echo -e "${RED}[ERROR] docker compose v2 plugin missing${NC}"; exit 1; }

# Prepare .env if missing
if [ ! -f .env ]; then
  if [ -f .env.example ]; then
    echo -e "${YELLOW}[*] Creating .env from .env.example...${NC}"
    cp .env.example .env
    RANDOM_PASS=$(tr -dc A-Za-z0-9_!@#$% 2>/dev/null < /dev/urandom | head -c 24 || echo "SecurePass$(date +%s)")
    sed -i "s/INIT_PASSWORD=/INIT_PASSWORD=${RANDOM_PASS}/" .env
    echo -e "${GREEN}[+] Generated initial wg-easy password: ${YELLOW}${RANDOM_PASS}${NC}"
  else
    echo -e "${RED}[ERROR] .env and .env.example missing!${NC}"
    exit 1
  fi
fi

# Load variables
set -a; . ./.env; set +a
WG_PORT="${WG_PORT:-51820}"
WG_UI_PORT="${WG_UI_PORT:-51821}"

# Ensure directories exist with restricted permissions
mkdir -p work conf wg
chmod 755 work conf
chmod 700 wg

# Enable IP forwarding if not already set
if [ "$(cat /proc/sys/net/ipv4/ip_forward 2>/dev/null || echo 0)" != "1" ]; then
  echo -e "${BLUE}[*] Enabling net.ipv4.ip_forward in kernel...${NC}"
  sysctl -w net.ipv4.ip_forward=1 >/dev/null 2>&1 || true
fi

echo -e "${BLUE}[*] Pulling and launching containers...${NC}"
docker compose pull
docker compose up -d

SERVER_IP=$(curl -s -4 https://ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}')

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN} [SUCCESS] Gateway & WireGuard stack is running!     ${NC}"
echo -e "${GREEN}======================================================${NC}"
echo -e "AdGuard Web UI : ${BLUE}http://${SERVER_IP}:3080${NC} (login: Str4nge)"
echo -e "WireGuard Port : ${GREEN}${WG_PORT}/UDP${NC} (reachable from internet)"
echo -e "WireGuard UI   : ${YELLOW}Loopback (127.0.0.1:${WG_UI_PORT})${NC}"
echo -e ""
echo -e "To access WireGuard UI and scan QR codes from your laptop:"
echo -e "  1. Run SSH Tunnel: ${BLUE}ssh -L ${WG_UI_PORT}:127.0.0.1:${WG_UI_PORT} root@${SERVER_IP}${NC}"
echo -e "  2. Open browser  : ${GREEN}http://127.0.0.1:${WG_UI_PORT}${NC}"
echo -e "  3. Log in with   : ${YELLOW}admin${NC} / password from .env"
echo -e "${GREEN}======================================================${NC}"
