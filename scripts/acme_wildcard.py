#!/usr/bin/env python3
"""
Automated Let's Encrypt Wildcard ACME v2 DNS-01 Verification & Installer
Author: Muhammadqodir Davlatyorov
Purpose: Automates DNS-01 challenge creation, certificate retrieval, and installation into AdGuard Home API.
"""

import os
import sys
import time
import base64
import hashlib
import json
import requests
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives import hashes, serialization
from cryptography import x509
from cryptography.x509.oid import NameOID
import acme.client
import acme.messages
import acme.errors
import acme.challenges
import josepy as jose

DIRECTORY_URL = "https://acme-v02.api.letsencrypt.org/directory"
EMAIL = "davlatyarov@gmail.com"
DOMAINS = ["dns.davlatyarov.uz", "*.dns.davlatyarov.uz"]
ADGUARD_API = "http://79.132.143.211:3080/control/tls/configure"
ADGUARD_AUTH = ("Str4nge", "Salom1505!")

WORKDIR = os.path.dirname(os.path.abspath(__file__))
KEY_FILE = os.path.join(WORKDIR, "account.key")
DOMAIN_KEY_FILE = os.path.join(WORKDIR, "domain.key")

def get_or_create_key(path):
    if os.path.exists(path):
        with open(path, "rb") as f:
            return serialization.load_pem_private_key(f.read(), password=None)
    key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
    with open(path, "wb") as f:
        f.write(key.private_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PrivateFormat.PKCS8,
            encryption_algorithm=serialization.NoEncryption()
        ))
    return key

def main():
    print("[*] Initializing ACME client...")
    acc_key_crypto = get_or_create_key(KEY_FILE)
    acc_key = jose.JWKRSA(key=acc_key_crypto)

    domain_key = get_or_create_key(DOMAIN_KEY_FILE)
    csr = x509.CertificateSigningRequestBuilder().subject_name(
        x509.Name([x509.NameAttribute(NameOID.COMMON_NAME, DOMAINS[0])])
    ).add_extension(
        x509.SubjectAlternativeName([x509.DNSName(d) for d in DOMAINS]),
        critical=False,
    ).sign(domain_key, hashes.SHA256())
    csr_pem = csr.public_bytes(serialization.Encoding.PEM)

    net = acme.client.ClientNetwork(acc_key, user_agent="PersonalSecureGateway/2.0")
    directory = acme.messages.Directory.from_json(net.get(DIRECTORY_URL).json())
    client = acme.client.ClientV2(directory, net)

    try:
        regr = client.new_account(acme.messages.NewRegistration.from_data(email=EMAIL, terms_of_service_agreed=True))
    except acme.errors.ConflictError as e:
        regr = acme.messages.RegistrationResource(body=acme.messages.Registration(), uri=e.location)
        net.account = regr
        print(f"[+] Reusing existing ACME Account: {e.location}")

    print("[*] Creating order for domains:", DOMAINS)
    order = client.new_order(csr_pem)
    print(f"[+] Order created: {order.uri}")

    print("\n[!] Please ensure the following TXT challenge records are published in your DNS provider:")
    for authz in order.authorizations:
        domain = authz.body.identifier.value
        for ch in authz.body.challenges:
            if isinstance(ch.chall, acme.challenges.DNS01):
                key_auth = ch.chall.key_authorization(acc_key)
                digest = hashlib.sha256(key_auth.encode("utf-8")).digest()
                txt_val = base64.urlsafe_b64encode(digest).decode("utf-8").rstrip("=")
                print(f"    Host: _acme-challenge.{domain.replace('*.', '')}. | Type: TXT | Value: {txt_val}")

if __name__ == "__main__":
    main()
