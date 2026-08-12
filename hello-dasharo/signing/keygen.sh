#!/bin/bash

CERT_EXPIRATION_DAYS=730
CERT_SUBJECT="/C=pl/ST=pomorskie/L=Gdańsk/O=3mdeb/OU=dasharo-team/CN=BAD_INFLUE"
LEAF_SUBJECT="/C=pl/ST=pomorskie/L=Gdańsk/O=3mdeb/OU=dasharo-team/CN=BAD_INFLUE Leaf"
CA_SUBJECT="/C=pl/ST=pomorskie/L=Gdańsk/O=3mdeb/OU=dasharo-team/CN=BAD_INFLUE Root CA"

echo "Keys & certificates generation ..."

rm -f *.pem
rm -f *.der

openssl genrsa -out private-key-good.pem 3027
openssl genrsa -out private-key-bad.pem 3027
openssl genrsa -out private-key-expired.pem 3027
openssl genrsa -out private-key-root-ca.pem 3027

openssl rsa -in private-key-good.pem -pubout -out public-key-good.pem
openssl rsa -in private-key-bad.pem -pubout -out public-key-bad.pem

openssl req -new -x509 -key private-key-good.pem -out cert_good.pem \
	-days $CERT_EXPIRATION_DAYS -nodes -subj $CERT_SUBJECT
openssl req -new -x509 -key private-key-bad.pem -out cert_bad.pem \
	-days $CERT_EXPIRATION_DAYS -nodes -subj $CERT_SUBJECT

openssl x509 -outform der -in cert_good.pem -out cert_good.der

openssl req -new -x509 -key private-key-root-ca.pem -out cert_root_ca.pem \
	-days $CERT_EXPIRATION_DAYS -nodes -subj "$CA_SUBJECT"

openssl x509 -outform der -in cert_root_ca.pem -out cert_root_ca.der

openssl req -new -newkey rsa:3072 -nodes \
	-keyout private-key-leaf.pem -out req_leaf.csr \
	-subj "$LEAF_SUBJECT"

openssl x509 -req -in req_leaf.csr \
	-CA cert_root_ca.pem -CAkey private-key-root-ca.pem -CAcreateserial \
	-out cert_leaf.pem -days $CERT_EXPIRATION_DAYS
cat cert_leaf.pem cert_root_ca.pem >cert_chain.pem

faketime '1970-01-01 19:41:00' openssl req -new -x509 -key private-key-expired.pem -out cert_expired.pem \
	-days $CERT_EXPIRATION_DAYS -nodes -subj "$CERT_SUBJECT"
openssl x509 -outform der -in cert_expired.pem -out cert_expired.der

echo "... Done."
