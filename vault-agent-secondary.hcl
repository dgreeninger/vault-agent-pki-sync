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
    contents = <<EOF
{{ $OBJ := plugin "openssl" "req" "-new" "-newkey" "rsa:2048" "-noenc" "-keyout" "private-key.pem" "-subj" "/CN=vaultagent.example.com" "-out" "/dev/stdout"}}
{{- spew_dump $OBJ -}}
{{ with pkiCert "pki/sign/example-dot-com" "ttl=60" "common_name=test.example.com" (print "csr=" $OBJ) }}
  {{- .Cert -}}
{{ end }}
EOF
    destination = "secret-agent.crt"
}
