provider "vault" {
  address = "http://127.0.0.1:8200" # Adjust this to your Vault address
  token   = "root"
}

# 1. Enable the PKI Secrets Engine
resource "vault_mount" "pki" {
  path = "pki"
  type = "pki"
  description = "PKI Secrets Engine for issuing certificates"
}

# 2. Configure the PKI Secrets Engine with a maximum TTL for certificates
resource "vault_pki_secret_backend_config_urls" "pki_urls" {
  backend = vault_mount.pki.path
  issuing_certificates = ["http://127.0.0.1:8200/v1/pki/ca"]
  crl_distribution_points = ["http://127.0.0.1:8200/v1/pki/crl"]
}

# 3. Generate a Root Certificate with the PKI Backend
resource "vault_pki_secret_backend_root_cert" "pki_root_cert" {
  backend     = vault_mount.pki.path
  type        = "internal"         # Specifies that Vault generates and manages the root certificate internally
  common_name = "example.com"      # Replace with your root domain name
  ttl         = "87600h"           # Set desired TTL for the root CA certificate
}

# 4. Configure a role for issuing certificates from the PKI engine
resource "vault_pki_secret_backend_role" "example_role" {
  backend         = vault_mount.pki.path
  name            = "example-dot-com"
  allowed_domains = ["example.com"]
  allow_subdomains = true
  max_ttl          = "72h"
}

# 5. Generate Key and CSR Locally
provider "tls" {}

resource "tls_private_key" "example_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_cert_request" "example_csr" {
  private_key_pem = tls_private_key.example_key.private_key_pem
  subject {
    common_name  = "example.example.com"
    organization = "Example Corp"  # Corrected to a single string
  }
}
