1. Install project from github
   git clone https://github.com/blockchain-certificates/cert-issuer.git && cd cert-issuer

2. python setup.py experimental --blockchain=ethereum
3. touch conf.ini

```
issuing_address=0x3c0ba0445c8a3882ac050cc03c45c5ac89f65de9 # matching with the private key above
chain=ethereum_ropsten # one of ['ethereum_ropsten', 'ethereum_mainnet']

```

3. docker build -t bc/cert-issuer:1.0 .

-Check status and commit
docker ps -l
docker commit <container for your bc/cert-issuer> my_cert_issuer

-Run docker
systemctl start docker
docker run -it bc/cert-issuer:1.0 bash

-Issue cert
python cert-issuer -c cert-issuer/conf_regtest.ini
cert-issuer -c conf_regtest.ini --verification_method "0x6EA56068B809a35254BC419cB2939A24C468c9F5"

-handling error "AttributeError: 'CertificateBatchHandler' object has no attribute 'certificates_to_issue'"
--Priv key of wallet (add to '/etc/cert-issuer/pk_issuer.txt')
0xdf077511d537910c71ddd553872741d4931c969ddbb0305fc5ff4ae9c3d3cf1b

--Cert Dir
/etc/cert-issuer/data/unsigned_certificates/verifiable-credential.json

--related problems
https://community.blockcerts.org/t/problem-with-cert-issuer/165
