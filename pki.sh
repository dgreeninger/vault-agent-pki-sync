vault secrets enable pki
vault secrets tune -max-lease-ttl=87600h pki
vault write pki/root/generate/internal common_name=myvault.com ttl=87600h
vault write pki/config/urls issuing_certificates="http://127.0.0.1:8200/v1/pki/ca" crl_distribution_points="http://127.0.0.1:8200/v1/pki/crl"
vault write pki/roles/example-dot-com \
  allowed_domains=example.com \
  allow_subdomains=true max_ttl=72h


vault policy write admins admins-policy.hcl
vault auth enable approle
vault write auth/approle/role/chef token_type=service secret_id_ttl=365d token_ttl=20m token_max_ttl=30m token_policies=admins
vault read auth/approle/role/chef/role-id | grep role_id | awk {'print $2'} > /tmp/role-id #copy role-id value to file in /tmp/role-id
vault write -f auth/approle/role/chef/secret-id | grep "secret" | grep -v id_ | awk {'print $2'} > /tmp/secret-id #copy secret-id to file in /tmp/secret-id
