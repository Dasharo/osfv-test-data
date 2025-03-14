#!/bin/bash

CERT_EXPIRATION_DAYS=730
CERT_SUBJECT="/C=pl/ST=pomorskie/L=Gdańsk/O=3mdeb/OU=dasharo-team/CN=BAD_INFLUE"

echo "Keys & certificates generation ..."

rm -f *.pem
rm -f *.der

openssl genrsa -out private-key-good.pem 3027
openssl genrsa -out private-key-bad.pem 3027

openssl rsa -in private-key-good.pem -pubout -out public-key-good.pem
openssl rsa -in private-key-bad.pem -pubout -out public-key-bad.pem

openssl req -new -x509 -key private-key-good.pem -out cert_good.pem \
	-days $CERT_EXPIRATION_DAYS -nodes -subj $CERT_SUBJECT
openssl req -new -x509 -key private-key-bad.pem -out cert_bad.pem \
	-days $CERT_EXPIRATION_DAYS -nodes -subj $CERT_SUBJECT

openssl x509 -outform der -in cert_good.pem -out cert_good.der

echo "... Done."

