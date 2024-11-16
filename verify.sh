echo key; openssl rsa -noout -modulus -in private-key.pem | openssl md5
openssl pkey -in private-key.pem -pubout
echo csr; openssl req -noout -modulus -in vault-agent.csr | openssl md5
openssl req -in vault-agent.csr -pubkey -noout
echo cert; openssl x509 -noout -modulus -in vault-agent.crt | openssl md5
openssl x509 -in vault-agent.crt -pubkey -noout

echo Current Date
TZ="UTC" date
echo Expiration date of Certificate
openssl x509 -enddate -noout -in vault-agent.crt
