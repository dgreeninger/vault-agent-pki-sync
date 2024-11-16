pid_file        = "/tmp/pidfile"
#exit_after_auth = true

vault {
  address = "https://127.0.0.1:8200"
  tls_skip_verify = true
}

auto_auth {

  method {
    type = "approle"
    config = {
      role_id_file_path                   = "/tmp/role-id"
      secret_id_file_path                 = "/tmp/secret-id"
      remove_secret_id_file_after_reading = false
    }
  }

  sink {
    type = "file"
    config = {
      path = "/tmp/vault_agent_token"
    }
  }

}

template {
    destination = "vault-agent.key"
    contents = <<EOF
{{- with file "vault-agent.csr" -}}
  {{- with pkiCert "pki/sign/example-dot-com" (print "csr=" .) "ttl=1m" -}}
    {{- .Cert -}}
  {{- end -}}
{{- end -}}
EOF
    exec {
      command = "openssl req -new -newkey rsa:2048 -noenc -keyout private-key-\"$(date +%H:%M:%S)\".pem -subj '/CN=vaultagent.example.com' -out vault-agent-\"$(date +%H:%M:%S)\".csr && cp private-key-\"$(date +%H:%M:%S)\".pem private-key.pem && cp vault-agent-\"$(date +%H:%M:%S)\".csr vault-agent.csr && echo \"primary $(date +%H:%M:%S)\" >> run.log && vault agent -config=vault-agent-secondary.hcl"
    }
}

template {
    destination = "vault-agent.crt"
    contents = <<EOF
{{- with file "vault-agent.csr" -}}
  {{- with pkiCert "pki/sign/example-dot-com" (print "csr=" .) "ttl=1m" -}}
    {{- .Cert -}}
  {{- end -}}
{{- end -}}
EOF
}