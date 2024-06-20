#!/bin/sh

openssl rand -writerand ~/.rnd
mkdir ca certs csv csr asterisk

openssl genrsa -out ./ca/asterisk-CA.key 4096

# Certificado para 100 anos
openssl req -x509 -new -nodes -key ./ca/asterisk-CA.key -sha256 -days 36500 -out ./ca/asterisk-CA.crt -subj "/C=/ST=/L=/O=/OU=/CN=asterisk.local/emailAddress="

openssl req -new -sha256 -nodes -out ./csr/asterisk.csr -newkey rsa:2048 -keyout ./certs/asterisk.key -subj "/C=/ST=/L=/O=/OU=/CN=asterisk.local/emailAddress="

cat > ./csr/openssl-v3.cnf <<EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = asterisk.local
EOF

openssl x509 -req -in ./csr/asterisk.csr -CA ./ca/asterisk-CA.crt -CAkey ./ca/asterisk-CA.key -CAcreateserial -out ./certs/asterisk.crt -days 36500 -sha256 -extfile ./csr/openssl-v3.cnf

cat ./certs/asterisk.crt ./certs/asterisk.key > ./certs/asterisk.pem

cp ./certs/* ./asterisk
cp ./ca/asterisk-CA.crt ./asterisk
ls  -lah ./asterisk/