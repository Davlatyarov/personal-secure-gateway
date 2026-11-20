# Personal Secure Gateway & DNS Firewall

[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![AdGuard Home](https://img.shields.io/badge/AdGuard%20Home-v0.107+-68BC71?logo=adguard&logoColor=white)](https://adguard.com/)
[![Security](https://img.shields.io/badge/Security-Threat%20Intelligence%20%7C%20DoT-red)](https://github.com/Davlatyarov/personal-secure-gateway)
[![SSL](https://img.shields.io/badge/SSL-Let's%20Encrypt%20Wildcard-003A70?logo=letsencrypt&logoColor=white)](https://letsencrypt.org/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

An enterprise-grade, containerized **Personal Secure DNS Gateway & Threat Intelligence Firewall** designed for seamless, multi-device mobile and desktop protection. Built on top of **AdGuard Home**, **Docker**, and **DNS-over-TLS (DoT)** with automated zero-trust sinkholing for online gambling/betting platforms, DGA mirrors, content delivery backends (CDNs), tracking telemetries, and evasion countermeasures.

Developed by **Muhammadqodir Davlatyorov** (BSc Cybersecurity Student at International Digital University / University of Wolverhampton programme).

---

## Architecture Overview

```
                      +-------------------------------------------------------------+
                      |                 Client Devices Everywhere                   |
                      |  - Android (Private DNS / DoT: safe.dns.davlatyarov.uz)      |
                      |  - Windows 11 / iOS (Direct DNS / DoT: dns.davlatyarov.uz)  |
                      +-------------------------------------------------------------+
                                                     |
                                                     | [Encrypted DNS-over-TLS / Port 853]
                                                     v
+----------------------------------------------------------------------------------------------------+
| Linux VPS Host (<SERVER_IP>)                                                                    |
|                                                                                                    |
|   +--------------------------------------------------------------------------------------------+   |
|   | AdGuard Home Docker Engine (Hard resource caps: 512MB RAM / 1.0 vCPU)                      |   |
|   |                                                                                            |   |
|   |  [Inbound: Port 853 DoT/TLS | Port 3080 Web UI]                                            |   |
|   |         |                                                                                  |   |
|   |         v                                                                                  |   |
|   |  +--------------------------------------------------------------------------------------+  |   |
|   |  | Cryptographic Identity & SNI Router                                                 |  |   |
|   |  |  - Let's Encrypt Wildcard SSL (*.dns.davlatyarov.uz + dns.davlatyarov.uz)            |  |   |
|   |  |  - Per-Device Client Profiling via TLS SNI (e.g. 'safe', 's21', 'brother')           |  |   |
|   |  +--------------------------------------------------------------------------------------+  |   |
|   |         |                                                                                  |   |
|   |         v                                                                                  |   |
|   |  +--------------------------------------------------------------------------------------+  |   |
|   |  | Threat Intelligence & Sinkhole Engine (1,100,000+ Active Rules)                      |  |   |
|   |  |  - HaGeZi Multi PRO (Privacy, Security & Threat Intelligence)                        |  |   |
|   |  |  - URLhaus by abuse.ch (Active Malware C2 Infrastructure)                            |  |   |
|   |  |  - Anti-Gambling Master List (675,000+ domains with daily automated updates)         |  |   |
|   |  |  - Dynamic Wildcards (*1xbet*, *1xlite*, *mostbet*, *traincdn*, *cdn-global-mb*)      |  |   |
|   |  |  - Anti-Bypass Enforcer (Canary drops for Apple PR, Mozilla, and Public DoH)        |  |   |
|   |  +--------------------------------------------------------------------------------------+  |   |
|   |         |                                                  |                               |   |
|   |         | (Threat Sinkholed -> 0.0.0.0)                    | (Legitimate Queries)          |   |
|   |         v                                                  v                               |   |
|   |  +----------------------+             +-------------------------------------------------+  |   |
|   |  | Null Route (0.0.0.0) |             | Parallel Encrypted Upstreams (Quad9 / Cloudfl.) |  |   |
|   |  +----------------------+             +-------------------------------------------------+  |   |
|   +--------------------------------------------------------------------------------------------+   |
+----------------------------------------------------------------------------------------------------+
```

---

## Key Features

1. **Zero-Trust Gambling & Threat Sinkholing:**
   * Comprehensive blocking covering major bookmakers (`1xbet`, `mostbet`, `melbet`, `1win`, `linebet`, `pin-up`, `fonbet`, `parimatch`, `bet365`, `leon`).
   * Blocks betting content delivery networks (`traincdn.com`, `cdn-global-mb.com`, `playstarthere.com`).
   * Dynamic wildcard regex matching preventing domain hopping/mirror evasion.

2. **DNS-over-TLS (DoT) with Wildcard SSL:**
   * Automated Let's Encrypt ACME v2 DNS-01 verification via Eskiz.uz API.
   * Wildcard certificate for `*.dns.davlatyarov.uz` and `dns.davlatyarov.uz`.
   * Secure, tamper-proof DNS queries encrypted against ISP inspection.

3. **Per-Device SNI Client Profiling:**
   * Custom policies routed by TLS SNI hostname (`safe.dns.davlatyarov.uz`, `s21.dns.davlatyarov.uz`, `brother.dns.davlatyarov.uz`).
   * Zero client software required on Android (native Private DNS support).

4. **Resource Hardening & Shared Host Safety:**
   * Container CPU cap (`1.0 vCPU`) and memory cap (`512MB RAM`).
   * Non-invasive port design: port 53 is unmapped on the host to eliminate external DNS Amplification DDoS vectors and preserve compatibility with shared VPS panels (HestiaCP, cPanel).

---

## Client Setup Instructions

### 1. Android (Samsung Galaxy, Google Pixel, Xiaomi, etc.)
* Open **Settings** ➔ **Connections** ➔ **More connection settings** ➔ **Private DNS**.
* Select **Private DNS provider hostname**.
* Enter your assigned secure DoT endpoint:
  ```text
  s21.dns.davlatyarov.uz
  ```
  *(or `safe.dns.davlatyarov.uz`)*
* Save. All device traffic is instantly protected.

### 2. Windows 11 / 10
* Open **Settings** ➔ **Network & internet** ➔ **Wi-Fi** (or **Ethernet**).
* Set DNS to your secure DoT / DNS gateway.

---

## Verification & Testing

Verify that the gateway actively sinkholes threats:

```powershell
python scripts/verify_gateway.py
```

---

## Project Structure

```
personal-secure-gateway/
├── docker-compose.yml     # Hardened AdGuard Home container deployment
├── deploy.sh              # Automated deployment script for Linux VPS
├── conf/
│   └── AdGuardHome.yaml   # Hardened configuration with preloaded security rules
├── scripts/
│   ├── verify_gateway.py  # 6-point verification suite (TLS + Sinkhole tests)
│   └── acme_wildcard.py   # ACME DNS-01 Let's Encrypt automation
├── work/                  # Runtime database directory
└── README.md              # Engineering documentation
```

---

## Author
* **Muhammadqodir Davlatyorov** — Cybersecurity Researcher & Network Security Enthusiast.
* GitHub: [@Davlatyarov](https://github.com/Davlatyarov)
