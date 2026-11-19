#!/usr/bin/env python3
"""
Personal Secure Gateway - Automated Verification Script
Author: Muhammadqodir Davlatyorov
Purpose: Tests DNS sinkholing, DoT TLS handshake, and Wildcard SSL validity.
"""

import socket
import ssl
import struct
import sys

GATEWAY_IP = "79.132.143.211"
DOT_PORT = 853
TEST_HOSTNAMES = [
    "dns.davlatyarov.uz",
    "safe.dns.davlatyarov.uz",
    "s21.dns.davlatyarov.uz"
]

TEST_QUERIES = [
    ("1x-bet-uz.mobi", True),     # Must be sinkholed (0.0.0.0)
    ("1xlite-52092.pro", True),   # Must be sinkholed (0.0.0.0)
    ("mostbet.com", True),        # Must be sinkholed (0.0.0.0)
    ("v3.traincdn.com", True),    # Must be sinkholed (0.0.0.0)
    ("google.com", False),        # Must NOT be sinkholed (Legitimate)
    ("youtube.com", False),       # Must NOT be sinkholed (Legitimate)
]

def check_tls_handshake(hostname):
    print(f"[*] Testing TLS Handshake with SNI '{hostname}'...")
    try:
        ctx = ssl.create_default_context()
        with socket.create_connection((GATEWAY_IP, DOT_PORT), timeout=5) as sock:
            with ctx.wrap_socket(sock, server_hostname=hostname) as ssock:
                cert = ssock.getpeercert()
                san = [item[1] for item in cert.get("subjectAltName", [])]
                print(f"    [+] TLS Connection Established!")
                print(f"    [+] Subject: {dict(x[0] for x in cert.get('subject', []))}")
                print(f"    [+] SANs: {san}")
                return True
    except Exception as e:
        print(f"    [-] TLS Failed: {e}")
        return False

def query_dot(server_hostname, domain_to_query):
    ctx = ssl.create_default_context()
    with socket.create_connection((GATEWAY_IP, DOT_PORT), timeout=5) as sock:
        with ctx.wrap_socket(sock, server_hostname=server_hostname) as ssock:
            # Build DNS wire query
            header = struct.pack("!HHHHHH", 0x4321, 0x0100, 1, 0, 0, 0)
            qname = b"".join(bytes([len(part)]) + part.encode("ascii") for part in domain_to_query.split(".")) + b"\x00"
            dns_req = header + qname + struct.pack("!HH", 1, 1) # Type A, Class IN
            msg = struct.pack("!H", len(dns_req)) + dns_req
            ssock.sendall(msg)

            resp_len = struct.unpack("!H", ssock.recv(2))[0]
            resp = ssock.recv(resp_len)
            
            # Simple check if answer contains 0.0.0.0 in answer section
            is_sinkholed = (b"\x00\x00\x00\x00" in resp[len(dns_req):])
            return is_sinkholed

def main():
    print("==================================================")
    print("  PERSONAL SECURE GATEWAY VERIFICATION SUITE")
    print("==================================================")
    
    tls_ok = True
    for host in TEST_HOSTNAMES:
        if not check_tls_handshake(host):
            tls_ok = False

    print("\n[*] Testing DNS Filtering Policies over DNS-over-TLS...")
    passed = 0
    for domain, should_block in TEST_QUERIES:
        blocked = query_dot("safe.dns.davlatyarov.uz", domain)
        if should_block and blocked:
            print(f"    [+] SINKHOLED: {domain} -> 0.0.0.0 (PASS)")
            passed += 1
        elif not should_block and not blocked:
            print(f"    [+] ALLOWED:   {domain} -> Public IP (PASS)")
            passed += 1
        else:
            status = "Blocked unexpectedly" if not should_block else "Allowed unexpectedly"
            print(f"    [-] FAILED:    {domain} ({status})")

    print(f"\n[=] Results: {passed}/{len(TEST_QUERIES)} DNS Tests Passed.")
    if tls_ok and passed == len(TEST_QUERIES):
        print("[+] ALL CHECKS PASSED. Gateway is fully operational and secure!")
        sys.exit(0)
    else:
        print("[-] Some checks failed.")
        sys.exit(1)

if __name__ == "__main__":
    main()
