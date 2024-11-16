# Demo using plugin to get a certificate file templated

Unfortunately, using `plugin` does not give Vault Agent the awareness of the certificate's TTL, so you need to run `vault agent` every time to create a new key/csr and get it signed by vault.

# Run Vault
`vault server -dev -dev-root-token-id root`

# Set up PKI
`sh pki.sh`

# Execute Agent
`vault agent -config=vault-agent-exit-auth.hcl`

# Verify Certs
sh verify.sh
