#!/bin/bash

CERT_EXPIRATION_DAYS=730
CERT_SUBJECT="/C=pl/ST=pomorskie/L=Gdańsk/O=3mdeb/OU=dasharo-team/CN=BAD_INFLUE"
CA_SUBJECT="/C=pl/ST=pomorskie/L=Gdańsk/O=3mdeb/OU=dasharo-team/CN=BAD_INFLUE Root CA"
INTERMEDIATE_SUBJECT="/C=pl/ST=pomorskie/L=Gdańsk/O=3mdeb/OU=dasharo-team/CN=BAD_INFLUE Intermediate"
LEAF_SUBJECT="/C=pl/ST=pomorskie/L=Gdańsk/O=3mdeb/OU=dasharo-team/CN=BAD_INFLUE Leaf"
EXPIRED_SUBJECT="/C=pl/ST=pomorskie/L=Gdańsk/O=3mdeb/OU=dasharo-team/CN=BAD_INFLUE Expired"

echo "Keys & certificates generation ..."

rm -f *.pem
rm -f *.der
rm -f *.csr
rm -f *.srl

openssl genrsa -out private-key-good.pem 3072
openssl genrsa -out private-key-bad.pem 3072
openssl genrsa -out private-key-expired.pem 3072
openssl genrsa -out private-key-root-ca.pem 3072

openssl rsa -in private-key-good.pem -pubout -out public-key-good.pem
openssl rsa -in private-key-bad.pem -pubout -out public-key-bad.pem

openssl req -new -x509 -key private-key-good.pem -out cert_good.pem \
    -days $CERT_EXPIRATION_DAYS -nodes -subj "$CERT_SUBJECT"
openssl req -new -x509 -key private-key-bad.pem -out cert_bad.pem \
    -days $CERT_EXPIRATION_DAYS -nodes -subj "$CERT_SUBJECT"

openssl x509 -outform der -in cert_good.pem -out cert_good.der

openssl req -new -x509 -key private-key-root-ca.pem -out cert_root_ca.pem \
    -days $CERT_EXPIRATION_DAYS -nodes -subj "$CA_SUBJECT" \
    -addext "basicConstraints=critical,CA:TRUE" \
    -addext "keyUsage=critical,keyCertSign,cRLSign"

openssl x509 -outform der -in cert_root_ca.pem -out cert_root_ca.der

openssl req -new -newkey rsa:3072 -nodes \
    -keyout private-key-intermediate.pem -out req_intermediate.csr \
    -subj "$INTERMEDIATE_SUBJECT"

openssl x509 -req -in req_intermediate.csr \
    -CA cert_root_ca.pem -CAkey private-key-root-ca.pem -CAcreateserial \
    -out cert_intermediate.pem -days $CERT_EXPIRATION_DAYS \
    -extfile <(echo -e "basicConstraints=critical,CA:TRUE\nkeyUsage=critical,digitalSignature,keyCertSign,cRLSign")

openssl x509 -outform der -in cert_intermediate.pem -out cert_intermediate.der

openssl req -new -newkey rsa:3072 -nodes \
    -keyout private-key-leaf.pem -out req_leaf.csr \
    -subj "$LEAF_SUBJECT"

openssl x509 -req -in req_leaf.csr \
    -CA cert_intermediate.pem -CAkey private-key-intermediate.pem -CAcreateserial \
    -out cert_leaf.pem -days $CERT_EXPIRATION_DAYS \
    -extfile <(echo -e "basicConstraints=critical,CA:FALSE\nkeyUsage=digitalSignature\nextendedKeyUsage=codeSigning")

openssl x509 -outform der -in cert_leaf.pem -out cert_leaf.der

faketime '1970-01-01 19:41:00' openssl req -new -x509 -key private-key-expired.pem -out cert_expired.pem \
    -days $CERT_EXPIRATION_DAYS -nodes -subj "$EXPIRED_SUBJECT"
openssl x509 -outform der -in cert_expired.pem -out cert_expired.der

echo "... Done."
