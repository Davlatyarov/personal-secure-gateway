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
| Linux VPS Host (79.132.143.211)                                                                    |
|                                                                                                    |
|   +--------------------------------------------------------------------------------------------+   |
|   | AdGuard Home Docker Engine (Hard resource caps: 256MB RAM / 0.25 vCPU)                     |   |
|   |                                                                                            |   |
|   |  [Inbound: Port 53 UDP/TCP | Port 853 DoT/TLS | Port 3080 Web UI]                          |   |
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
|   |         | (Betting / Mirrors / C2 / Trackers)              | (Legitimate Queries)          |   |
|   |         v                                                  v                               |   |
|   |    [ 0.0.0.0 Sinkhole ]                          [ Parallel Secure Upstreams ]             |   |
|   |    Instant Drop (0.1ms)                                    |                               |   |
|   +------------------------------------------------------------|-------------------------------+   |
+----------------------------------------------------------------|-----------------------------------+
                                                                 |
                                 +-------------------------------+-------------------------------+
                                 |                                                               |
                                 v                                                               v
                    [ Quad9: 9.9.9.9 / DoH ]                                 [ Cloudflare Security: 1.1.1.2 / DoH ]
                    (Threat Shield & Privacy)                                 (Malware-Blocking Resolver)
```

---

## Core Security Features

1. **Complete Betting & Gambling Ecosystem Neutralization:**
   - Universal substring containment rules (`*1xbet*`, `*1x-bet*`, `*1xlite*`, `*mostbet*`, `*melbet*`, `*1win*`, `*linebet*`, etc.).
   - Neutralizes dynamic mirrors (DGA) by targeting **backbone delivery networks** (`*traincdn*`, `*cdn-global-mb*`, `*x011bt*`). Even newly registered mirror domains fail to load stylesheets, APIs, odds, and balances.
   - Blocks mobile APK telemetry and attribution SDKs (`*appsflyersdk*`).

2. **Wildcard Cryptographic Infrastructure (DNS-over-TLS):**
   - Official **Let's Encrypt Wildcard Certificate** (`*.dns.davlatyarov.uz` + `dns.davlatyarov.uz`) issued via automated ACME v2 DNS-01 verification.
   - Zero-trust encrypted communication over port 853 across all mobile 4G and public Wi-Fi networks.

3. **Per-Device SNI Client Profiling:**
   - Utilizes TLS Server Name Indication (SNI) to identify individual clients independently of changing mobile IP addresses.
   - Individual monitoring and customized access policies for different devices (`safe.dns...`, `s21.dns...`).

4. **Anti-Circumvention & Anti-Evasion Countermeasures:**
   - **Mozilla Firefox Canary:** Blocks `use-application-dns.net` to enforce system DNS.
   - **Apple iCloud Private Relay Canary:** Blocks `mask.icloud.com` to prevent uninspected traffic tunneling.
   - **Public DoH Block:** Blocks `dns.google`, `cloudflare-dns.com` to prevent browser DNS hijacking.
   - **IPv6 Leak Defense:** Hardened against multi-homed local router IPv6 leaks.

5. **Resource-Constrained Production Deployment:**
   - Docker container hard-capped at 256MB RAM and 0.25 vCPU with strict log rotation policies to co-exist alongside existing production web stacks (HestiaCP).
   - In-memory optimistic caching providing average response times under 2ms.

---

## Client Connection Guide

### 1. Android Smartphone (Native OS-wide DoT)
* Go to **Settings** ➔ **Connections** ➔ **More connection settings** ➔ **Private DNS**.
* Select **Private DNS provider hostname** and enter:
  ```text
  safe.dns.davlatyarov.uz
  ```
  *(or `dns.davlatyarov.uz`)*
* Once saved, Android automatically routes all app and browser traffic through the encrypted gateway.

### 2. Windows 11 / 10
* Open **Settings** ➔ **Network & internet** ➔ **Wi-Fi** (or **Ethernet**) ➔ **Hardware properties**.
* Set **DNS server assignment** to **Manual**:
  * **IPv4 Preferred DNS:** `79.132.143.211`
  * **IPv4 Alternate DNS:** `9.9.9.9`
* *(Optional)* If browser Secure DNS is enabled, set Chrome/Edge Secure DNS to *"Use current service provider"*.

---

## Verification & Testing

Verify that the gateway actively sinkholes threats:

```powershell
# Betting Domain Sinkhole Test (Expected: 0.0.0.0)
Resolve-DnsName 1x-bet-uz.mobi -Server 79.132.143.211

# Dynamic Mirror Sinkhole Test (Expected: 0.0.0.0)
Resolve-DnsName 1xlite-52092.pro -Server 79.132.143.211

# Legitimate Domain Test (Expected: Valid Public IP)
Resolve-DnsName google.com -Server 79.132.143.211
```

---

## Project Structure

```
personal-secure-gateway/
├── docker-compose.yml     # Production container manifest with resource limits
├── deploy.sh              # Automated deployment script for Linux VPS
├── conf/
│   └── AdGuardHome.yaml   # Hardened configuration with preloaded security rules
├── work/                  # Working data directory
└── README.md              # Engineering documentation
```

---

## Author
* **Muhammadqodir Davlatyorov** — Cybersecurity Researcher & Network Security Enthusiast.
* GitHub: [@Davlatyarov](https://github.com/Davlatyarov)
