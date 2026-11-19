# Personal Secure Gateway & DNS Firewall

[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![AdGuard Home](https://img.shields.io/badge/AdGuard%20Home-v0.107+-68BC71?logo=adguard&logoColor=white)](https://adguard.com/)
[![Security](https://img.shields.io/badge/Security-Threat%20Intelligence%20%7C%20DoH-red)](https://github.com/Davlatyarov/personal-secure-gateway)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

An enterprise-grade, containerized **Personal Secure DNS Gateway & Threat Neutralization Firewall** designed for daily mobile and desktop protection. Built on top of **AdGuard Home**, **Docker Compose**, and **DNS-over-HTTPS (DoH)** with automated zero-trust sinkholing for gambling/betting backends, malware Command & Control (C2) servers, tracking telemetries, and anti-circumvention enforcement.

Developed by **Muhammadqodir Davlatyorov** (BSc Cybersecurity Student at International Digital University / University of Wolverhampton programme).

---

## Architecture Overview

```
                      +---------------------------------------+
                      |       Client Devices Everywhere       |
                      |  (Android / iOS / Windows / macOS)    |
                      +---------------------------------------+
                                          |
                                          | [Encrypted DNS / WireGuard Tunnel]
                                          v
+-----------------------------------------------------------------------------------+
| Linux VPS Host (Fornex / Hetzner / Cloud Provider)                                |
|                                                                                   |
|   +---------------------------------------------------------------------------+   |
|   | AdGuard Home Docker Engine (Host Network Mode)                            |   |
|   |                                                                           |   |
|   |  [Inbound Port 53 UDP/TCP]                                                |   |
|   |         |                                                                 |   |
|   |         v                                                                 |   |
|   |  +---------------------------------------------------------------------+  |   |
|   |  | Threat Intelligence & Sinkhole Engine                               |  |   |
|   |  |  - HaGeZi Multi PRO (Privacy & Threat Protection)                   |  |   |
|   |  |  - URLhaus by abuse.ch (Active Malware C2 Infrastructure)           |  |   |
|   |  |  - Strict Anti-Gambling Filter (API & Mobile App Sinkhole)          |  |   |
|   |  |  - Anti-Bypass Enforcer (Canary drops for Apple PR, Mozilla, DoH)   |  |   |
|   |  +---------------------------------------------------------------------+  |   |
|   |         |                                         |                       |   |
|   |         | (Malicious / Betting / Trackers)        | (Legitimate Domain)   |   |
|   |         v                                         v                       |   |
|   |    [ 0.0.0.0 / NXDOMAIN ]               [ Parallel DoH Upstreams ]        |   |
|   |    Immediate TCP/UDP drop                         |                       |   |
|   +---------------------------------------------------|-----------------------+   |
+-------------------------------------------------------|---------------------------+
                                                        |
                    +-----------------------------------+-------------------+
                    | (Encrypted TLS over Port 443 - DNS-over-HTTPS)        |
                    v                                                       v
         [ Quad9: 9.9.9.9 / DoH ]                       [ Cloudflare Security: 1.1.1.2 / DoH ]
         (Swiss Privacy & Threat Shield)                 (Malware-Blocking Secure Resolver)
```

---

## Core Security Features

1. **Complete Betting & Gambling App Sinkholing:**
   - Blocks not only web frontends, but all backend APIs utilized by mobile applications (`1xbet`, `mostbet`, `melbet`, `1win`, `linebet`, `parimatch`, etc.).
   - Apps fail immediately upon launch with connection errors, preventing wagering or account access.

2. **Command & Control (C2) & Malvertising Defense:**
   - Synchronized with **URLhaus (abuse.ch)** and **HaGeZi Multi PRO**.
   - Proactively drops outbound botnet beacons, infostealer exfiltration attempts, and rogue malvertising scripts.

3. **Anti-Circumvention (Anti-DoH / Canary Rules):**
   - Blocks Mozilla Canary (`use-application-dns.net`) to force Firefox into system DNS mode.
   - Blocks Apple iCloud Private Relay canary (`mask.icloud.com`) to prevent iOS traffic leaks.
   - Restricts unmanaged public DoH endpoints (`dns.google`, `cloudflare-dns.com`).

4. **Zero-Latency Performance (Parallel Requests & Optimistic Caching):**
   - Queries Cloudflare and Quad9 simultaneously, selecting the fastest millisecond response.
   - Caches repeated lookups in memory, serving recurring queries in 1–2ms.

5. **Full Audit Logging & Compliance:**
   - Retains 90-day forensic query logs detailing timestamps, client IPs, requested domains, and triggering security rules.

---

## Quickstart Deployment (1-Click)

### For your Friend / Server Administrator:

Clone the repository and run the automated deployment script:

```bash
git clone https://github.com/Davlatyarov/personal-secure-gateway.git
cd personal-secure-gateway
chmod +x deploy.sh
./deploy.sh
```

The script will automatically:
- Verify Docker and Docker Compose.
- Free up port 53 from Ubuntu's default `systemd-resolved` stub resolver safely.
- Launch AdGuard Home pre-configured with all security policies.
- Display the Web Dashboard URL (`http://<SERVER_IP>:8080`).

---

## How to Connect Devices

### 1. Android Smartphone
* **Option A (Private DNS - Native):**  
  Go to **Settings** ➔ **Connections** ➔ **More connection settings** ➔ **Private DNS** ➔ set your server's hostname/IP.
* **Option B (Wi-Fi Settings):**  
  In your Wi-Fi network settings, switch IP settings to **Static** and set **DNS 1** to your server's IP address.
* **Lockdown Mode (Strict Protection):**  
  If using WireGuard/Tailscale, enable **Always-on VPN** and **Block connections without VPN** in Android Settings.

### 2. Apple iPhone (iOS)
* Go to **Settings** ➔ **Wi-Fi** ➔ tap your network ➔ **Configure DNS** ➔ select **Manual** ➔ add your server's IP address.

### 3. Windows 11 / 10
* Go to **Settings** ➔ **Network & internet** ➔ **Wi-Fi** (or **Ethernet**) ➔ **DNS server assignment: Edit** ➔ set **Manual (IPv4)** to your server's IP.

---

## Verification & Testing

Verify that the sinkhole is actively intercepting threats:

```bash
# Betting Domain Sinkhole Test (Expected: 0.0.0.0)
nslookup 1xbet.com <SERVER_IP>

# Legitimate Domain Test (Expected: Valid Public IP)
nslookup google.com <SERVER_IP>

# Ad Network Sinkhole Test (Expected: 0.0.0.0)
nslookup adservice.google.com <SERVER_IP>
```

---

## Project Structure

```
personal-secure-gateway/
├── docker-compose.yml     # Containerized deployment manifest
├── deploy.sh              # 1-Click automated deployment script for Linux VPS
├── conf/
│   └── AdGuardHome.yaml   # Hardened configuration with preloaded security rules
├── work/                  # Working data directory (auto-created)
└── README.md              # Engineering documentation
```

---

## Author
* **Muhammadqodir Davlatyorov** — Cybersecurity Researcher & Network Security Enthusiast.
* GitHub: [@Davlatyarov](https://github.com/Davlatyarov)
