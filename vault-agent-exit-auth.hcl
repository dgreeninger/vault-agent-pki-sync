pid_file        = "/tmp/pidfile"
exit_after_auth = true

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
    destination = "vault-agent.log"
    contents = <<EOF
{{ $OBJ := plugin "openssl" "req" "-new" "-newkey" "rsa:2048" "-noenc" "-keyout" "private-key.pem" "-subj" "/CN=vaultagent.example.com" "-out" "/dev/stdout"}}
{{- spew_dump $OBJ -}}
{{ $CERT := plugin "vault" "write" "-format=json" "pki/sign/example-dot-com" "common_name=test.example.com" "ttl=24h" (print "csr=" $OBJ) | parseJSON }}
{{ $CERT.data.certificate | trimSpace | writeToFile "vault-agent.crt" "" "" "0644" }}
{{ $OBJ | trimSpace | writeToFile "vault-agent.csr" "" "" "0644" }}
EOF
}



