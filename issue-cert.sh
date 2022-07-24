#!/bin/bash

echo "[issue-cert] start"

echo "[issue-cert] copy cert to etc folder"
cp /tmp/test1.json etc/cert-issuer/data/unsigned_certificates/

echo "[issue-cert] copy private key"
cp cert-issuer/pk_issuer.txt etc/cert-issuer/

echo "[issue-cert] start cert issuing"

cd cert-issuer && cert-issuer -c conf.ini --verification_method "0xEd76Cba060A1c7210c7e10EbE562b4966B9f45A1" > log.txt

echo "[issue-cert] copy signed cert to cert-issuer"
cp /etc/cert-issuer/data/blockchain_certificates/* cert-issuer/signed

echo "[issue-cert] print log"
cat log.txt