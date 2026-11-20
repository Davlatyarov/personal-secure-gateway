#!/usr/bin/env bash
# Post-deployment checks. Read-only: changes nothing.
set -uo pipefail
cd "$(dirname "$0")"

pass() { printf '\033[32m  PASS\033[0m  %s\n' "$*"; }
fail() { printf '\033[31m  FAIL\033[0m  %s\n' "$*"; }
warn() { printf '\033[33m  WARN\033[0m  %s\n' "$*"; }

[ -f .env ] && { set -a; . ./.env; set +a; }
WG_PORT="${WG_PORT:-51820}"
WG_UI_PORT="${WG_UI_PORT:-51821}"
ADGUARD_IP="${ADGUARD_IP:-172.28.0.10}"
WG_SUBNET="${WG_SUBNET:-10.8.0.0/24}"

echo "== containers =="
for c in adguardhome wg-easy; do
  if [ "$(docker inspect -f '{{.State.Running}}' "$c" 2>/dev/null)" = "true" ]; then
    pass "$c running"
  else
    fail "$c not running  (docker compose logs $c)"
  fi
done

echo
echo "== ports =="
ss -lun | grep -q ":${WG_PORT} " && pass "${WG_PORT}/udp listening" || fail "${WG_PORT}/udp not listening"
if ss -ltn | grep -q "127.0.0.1:${WG_UI_PORT} "; then
  pass "${WG_UI_PORT}/tcp bound to loopback only"
elif ss -ltn | grep -q ":${WG_UI_PORT} "; then
  fail "${WG_UI_PORT}/tcp is listening on a public address — fix the port mapping"
else
  fail "${WG_UI_PORT}/tcp not listening"
fi

echo
echo "== kernel =="
[ "$(cat /proc/sys/net/ipv4/ip_forward)" = "1" ] \
  && pass "net.ipv4.ip_forward = 1" || fail "ip_forward is 0 — routing will not work"
lsmod | grep -q wireguard && pass "wireguard kernel module loaded" \
  || warn "wireguard module not listed (may be built into the kernel)"

echo
echo "== wireguard interface =="
if docker exec wg-easy wg show 2>/dev/null | head -20; then
  peers=$(docker exec wg-easy wg show 2>/dev/null | grep -c '^peer:')
  pass "interface up, ${peers} peer(s) configured"
else
  warn "no interface yet — finish setup in the web UI first"
fi

echo
echo "== dns from inside the tunnel subnet =="
if docker run --rm --network gateway alpine:3.20 \
     sh -c "apk add --no-cache bind-tools >/dev/null 2>&1 && dig +short +time=3 +tries=1 @${ADGUARD_IP} example.com" \
     2>/dev/null | grep -qE '^[0-9]+\.'; then
  pass "AdGuard answers queries on ${ADGUARD_IP}"
else
  fail "AdGuard did NOT answer on ${ADGUARD_IP}"
  fail "  -> add 172.28.0.0/24 and ${WG_SUBNET} to allowed_clients in conf/AdGuardHome.yaml"
fi

echo
echo "== filtering =="
blocked=$(docker run --rm --network gateway alpine:3.20 \
  sh -c "apk add --no-cache bind-tools >/dev/null 2>&1 && dig +short +time=3 +tries=1 @${ADGUARD_IP} 1xbet.com" 2>/dev/null)
if [ -z "$blocked" ] || echo "$blocked" | grep -qE '^0\.0\.0\.0|^$'; then
  pass "blocklists active (gambling domain filtered)"
else
  warn "1xbet.com resolved to ${blocked} — check filter lists"
fi

echo
echo "== disk =="
df -h / | awk 'NR==2 {print "  root filesystem: " $4 " free (" $5 " used)"}'
docker system df 2>/dev/null | sed 's/^/  /'
