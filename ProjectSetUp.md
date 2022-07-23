# Set up Ubuntu

1. create an instance in AWS EC2
2. save the .pem file in ~/.ssh
3. modify the permission of the pem file
   `chmod 400 ~./ssh/<yourKeyFile>.pem`
4. go into .ssh
   `cd ~/.ssh`
5. remote to the ec2 instance with command line, instance user is either ubuntu/ec2-user depending on the instance type (ubuntu/amazon linux)
   `ssh -i "hku2022.pem" ubuntu@ec2-3-85-172-202.compute-1.amazonaws.com`
     <!-- joanne-test: ssh -i "hku2022.pem" ubuntu@ec2-52-91-16-213.compute-1.amazonaws.com -->
   [real one1] ssh -i "20220703.pem" ubuntu@ec2-34-230-29-73.compute-1.amazonaws.com
   [real one] ssh -i "20220703.pem" ubuntu@ec2-107-20-26-70.compute-1.amazonaws.com

# Ubuntu

1. fetch the block cert issuer project from git
   `git clone https://github.com/fungjojo/ecert-issuer.git`
   <!-- `git clone https://github.com/blockchain-certificates/cert-issuer.git` -->

2. change directory to the project root
   `cd ecert-issuer`
3. create a new config file for the blockcert and modify the content with vim
   `touch conf.ini`
   `vim conf.ini`

   `issuing_address=0x3c0ba0445c8a3882ac050cc03c45c5ac89f65de9 # matching with the private key above
   chain=ethereum_ropsten # one of ['ethereum_ropsten', 'ethereum_mainnet']

   usb_name=/etc/cert-issuer/
   key_file=pk_issuer.txt

   unsigned_certificates_dir=/etc/cert-issuer/data/unsigned_certificates
   blockchain_certificates_dir=/etc/cert-issuer/data/blockchain_certificates
   work_dir=/etc/cert-issuer/work

   no_safe_mode
   `

4. modify app.py and change bitcoin to ethereum
   `vim app.py`
   `from cert_issuer.blockchain_handlers import ethereum`
   `ethereum.instantiate_blockchain_handlers(config, False)`

5. update apt-get before install
   `sudo apt-get update`
6. install docker
   `sudo apt install docker.io`
7. modify docker permission
   `sudo chmod 666 /var/run/docker.sock`
8. modify dockerfile to remove bitcoin related dependecies (tips: remove line by placing curser to the line and press dd)
   `vim Dockerfile`

   - remove the below 2 lines
     `&& mkdir ~/.bitcoin \`
     `&& echo $'rpcuser=foo\nrpcpassword=bar\nrpcport=8332\nregtest=1\nrelaypriority=0\nrpcallowip=127.0.0.1\nrpcconnect=127.0.0.1\n' > /root/.bitcoin/bitcoin.conf \`
     - modify to
       `COPY conf.ini /etc/cert-issuer/conf.ini`

9. add private key in pk_issuer.txt file
   `touch pk_issuer.txt`
   `vim pk_issuer.txt`
   `0xc4097115e76d1fc722ad6ac1fc88b7b31b7baa54ea0ea0b981741f3d85d02f08`

10. vim setup.py, change name and entrypoint cert-issuer to cert_issuer and all encoding
    `with open(os.path.join(here, ‘README.md’),encoding="utf8") as fp:`

11. copy an example cert to cert input dir
    `cp examples/data-testnet/unsigned_certificates/verifiable-credential.json data/unsigned_certificates/`

12. check docker status before build
    `docker ps -l`
13. build docker image
    <!-- `docker build -t jiyeonf/hku-ecert:joanne-test3 .` -->

    `docker build -t bc/cert-issuer:1.0 .`

14. check built docker image
    `docker image list`

15. update apt-get before install
    `sudo apt-get update`
16. install python-is-python3 so when type python command in terminal, it equals python3
    `sudo apt-get install python-is-python3`
17. install python3-pip so when type pip command in terminal, it equals pip3
    `sudo apt install python3-pip`
18. setup ethereum dependencies for the project
    `python setup.py experimental --blockchain=ethereum`
19. if the above has error, try instal requirments one by one:
    `pip install -r requirements.txt`
    `pip install -r ethereum_requirements.txt`

20. if entercounter this error, run the 3 pip commands

error: legacy-install-failure

× Encountered error while trying to install package.
╰─> coincurve

note: This is an issue with the package mentioned above, not pip.

`pip install --upgrade pip`
`pip install wheel`
`pip install coincurve`

21. run docker when all setup is done
    <!-- `docker run -it jiyeonf/hku-ecert:joanne-test3 bash` -->

        `docker run -it bc/cert-issuer:1.0 bash`

    docker build -t bc/cert-issuer:1.0 .
    docker run --name test1 -d bc/cert-issuer:1.0 bash
    docker logs test1 -f

22. copy the input cert to the container etc folder
    `cp cert-issuer/data/unsigned_certificates/test1.json etc/cert-issuer/data/unsigned_certificates/`
    <!-- `cp cert-issuer/data/unsigned_certificates/verifiable-credential.json etc/cert-issuer/data/unsigned_certificates/` -->

23. copy the pk_issuer.txt to the container etc folder
    `cp cert-issuer/pk_issuer.txt etc/cert-issuer/`

24. check docker status before commit
    `docker ps -l`
25. commit the docker container
    `docker commit <container for your bc/cert-issuer> my_cert_issuer`
26. login docker
    `docker login -u jiyeonf`
27. type in docker password (abcd1234!)
28. tag the docker container to prepare for push
    `docker tag bc/cert-issuer:1.0 jiyeonf/hku-ecert:joanne-test1`
29. push the tagged container to remote
    `docker push jiyeonf/hku-ecert:joanne-test1`
30. issue the cert inside the docker bash, at the root of cert-issuer, use address for verification_method
    `cd cert-issuer && cert-issuer -c conf.ini --verification_method "0xEd76Cba060A1c7210c7e10EbE562b4966B9f45A1"`

python cert-issuer -c cert-issuer/conf.ini

pip install python-bitcoinlib==0.10.1

# Troubleshoot

- ModuleNotFoundError: No module named 'cert_issuer'

  - solution: try restart container / restart whole setup

- handling error "AttributeError: 'CertificateBatchHandler' object has no attribute 'certificates_to_issue'"

  - Priv key of wallet (add to '/etc/cert-issuer/pk_issuer.txt')
    0xdf077511d537910c71ddd553872741d4931c969ddbb0305fc5ff4ae9c3d3cf1b

- Cert Dir
  /etc/cert-issuer/data/unsigned_certificates/verifiable-credential.json

- related problems
  https://community.blockcerts.org/t/problem-with-cert-issuer/165

- /usr/bin/python: can't find '**main**' module in 'cert-issuer'

  - solution: try restart container / restart whole setup

- AttributeError: 'CertificateBatchHandler' object has no attribute 'certificates_to_issue'

  - solution: copy the cert to etc/data/unsigned_certificates
    `cp examples/data-testnet/unsigned_certificates/verifiable-credential.json data/unsigned_certificates/`

# Accounts

(meta)
address: 0xEd76Cba060A1c7210c7e10EbE562b4966B9f45A1
private key: 0xc4097115e76d1fc722ad6ac1fc88b7b31b7baa54ea0ea0b981741f3d85d02f08

# Pull docker images

1.  login docker
    `docker login -u jiyeonf`
2.  type in docker password (abcd1234!)
3.  pull the remote image
    `docker pull jiyeonf/hku-ecert:joanne-test4`

# Set up the server from docker image

1. download docker
   `sudo apt-get update`
   `sudo apt install docker.io`
2. login docker
   `docker login -u jiyeonf`
3. type in docker password (abcd1234!)
4. pull the remote image
   `docker pull jiyeonf/hku-ecert:joanne-test3`
5. `git clone https://github.com/fungjojo/ecert-issuer.git`
6. `cd ecert-issuer`
7. create a new config file for the blockcert and modify the content with vim
   `touch conf.ini`
   `vim conf.ini`

   `issuing_address=0x3c0ba0445c8a3882ac050cc03c45c5ac89f65de9 # matching with the private key above
   chain=ethereum_ropsten # one of ['ethereum_ropsten', 'ethereum_mainnet']

   usb_name=/etc/cert-issuer/
   key_file=pk_issuer.txt

   unsigned_certificates_dir=/etc/cert-issuer/data/unsigned_certificates
   blockchain_certificates_dir=/etc/cert-issuer/data/blockchain_certificates
   work_dir=/etc/cert-issuer/work

   no_safe_mode
   `

8. add private key in pk_issuer.txt file
   `touch pk_issuer.txt`
   `vim pk_issuer.txt`
   `0xc4097115e76d1fc722ad6ac1fc88b7b31b7baa54ea0ea0b981741f3d85d02f08`
9. `docker build -t jiyeonf/hku-ecert:joanne-test5 .`
10. run docker when all setup is done
    `docker run -it jiyeonf/hku-ecert:joanne-test5 bash`
11. copy the input cert to the container etc folder
    `cp cert-issuer/data/unsigned_certificates/test1.json etc/cert-issuer/data/unsigned_certificates/`

12. copy the pk_issuer.txt to the container etc folder
    `cp cert-issuer/pk_issuer.txt etc/cert-issuer/`

13. issue the cert inside the docker bash, at the root of cert-issuer, use address for verification_method
    `cd cert-issuer && cert-issuer -c conf.ini --verification_method "0xEd76Cba060A1c7210c7e10EbE562b4966B9f45A1"`

# Success log

## 1st attempt

bash-5.0# cd cert-issuer && cert-issuer -c conf.ini --verification_method "0xEd76Cba060A1c7210c7e10EbE562b4966B9f45A1"
WARNING - Your app is configured to skip the wifi check when the USB is plugged in. Read the documentation to ensure this is what you want, since this is less secure
INFO - This run will try to issue on the ethereum_ropsten chain
INFO - Set cost constants to recommended_gas_price=20000000000.000000, recommended_gas_limit=25000.000000
INFO - Processing 1 certificates
INFO - Processing 1 certificates under work path=/etc/cert-issuer/work
WARNING - ('Web3.py only accepts checksum addresses. The software that gave you this non-checksum address should be considered unsafe, please file it as a bug on their platform. Try using an ENS name instead. Or, if you must accept lower safety, use Web3.toChecksumAddress(lower_case_address).', '0x3c0ba0445c8a3882ac050cc03c45c5ac89f65de9')
INFO - Balance check succeeded: {'status': '1', 'message': 'OK-Missing/Invalid API Key, rate limit of 1/5sec applied', 'result': '9973749999853000'}
INFO - Total cost will be 500000000000000 wei
INFO - Starting finalizable signer
WARNING - app is configured to skip the wifi check when the USB is plugged in. Read the documentation to ensure this is what you want, since this is less secure
INFO - Stopping finalizable signer
WARNING - app is configured to skip the wifi check when the USB is plugged in. Read the documentation to ensure this is what you want, since this is less secure
INFO - here is the op_return_code data: f4906de7db4f9a826b5998472f51eaac762d429b29b6c2496f38870a477929d9
INFO - Fetching nonce with EthereumRPCProvider
WARNING - ('Web3.py only accepts checksum addresses. The software that gave you this non-checksum address should be considered unsafe, please file it as a bug on their platform. Try using an ENS name instead. Or, if you must accept lower safety, use Web3.toChecksumAddress(lower_case_address).', '0x3c0ba0445c8a3882ac050cc03c45c5ac89f65de9')
WARNING - Max rate limit reached, please use API Key for higher rate limit
INFO - Starting finalizable signer
WARNING - app is configured to skip the wifi check when the USB is plugged in. Read the documentation to ensure this is what you want, since this is less secure
INFO - Stopping finalizable signer
WARNING - app is configured to skip the wifi check when the USB is plugged in. Read the documentation to ensure this is what you want, since this is less secure
INFO - signed Ethereum trx = f884808504a817c8008261a894deaddeaddeaddeaddeaddeaddeaddeaddeaddead80a0f4906de7db4f9a826b5998472f51eaac762d429b29b6c2496f38870a477929d929a08e39f10a0ea6bcad79ca7b3a356571b2d1aeb107992d5057d583bb48e94f7d06a06c8cb9dcc51d4435877af6750898ca39fd14393862185bdf0ff7cf1c4fbdf03b
INFO - verifying ethDataField value for transaction
INFO - verified ethDataField
INFO - Broadcasting transaction with EthereumRPCProvider
WARNING - Caught exception trying provider <cert_issuer.blockchain_handlers.ethereum.connectors.EthereumRPCProvider object at 0x7ff178ca42e0>. Trying another. Exception=HTTPConnectionPool(host='localhost', port=8545): Max retries exceeded with url: / (Caused by NewConnectionError('<urllib3.connection.HTTPConnection object at 0x7ff178bae040>: Failed to establish a new connection: [Errno 111] Connection refused'))
WARNING - Caught exception trying provider <cert_issuer.blockchain_handlers.ethereum.connectors.EtherscanBroadcaster object at 0x7ff178ca48b0>. Trying another. Exception=Max rate limit reached, please use API Key for higher rate limit
WARNING - Broadcasting failed. Waiting before retrying. This is attempt number 0
INFO - Broadcasting transaction with EthereumRPCProvider
WARNING - Caught exception trying provider <cert_issuer.blockchain_handlers.ethereum.connectors.EthereumRPCProvider object at 0x7ff178ca42e0>. Trying another. Exception=HTTPConnectionPool(host='localhost', port=8545): Max retries exceeded with url: / (Caused by NewConnectionError('<urllib3.connection.HTTPConnection object at 0x7ff178bbf8e0>: Failed to establish a new connection: [Errno 111] Connection refused'))
INFO - Transaction ID obtained from broadcast through Etherscan: 0x226dc327b12eeb0966b3ad2fc4d4d176403bb50b9c7f1d31f352d52e05e0aadb
INFO - Broadcasting succeeded with method_provider=<cert_issuer.blockchain_handlers.ethereum.connectors.EtherscanBroadcaster object at 0x7ff178ca48b0>, txid=0x226dc327b12eeb0966b3ad2fc4d4d176403bb50b9c7f1d31f352d52e05e0aadb
INFO - merkle_json: {'path': [], 'merkleRoot': 'f4906de7db4f9a826b5998472f51eaac762d429b29b6c2496f38870a477929d9', 'targetHash': 'f4906de7db4f9a826b5998472f51eaac762d429b29b6c2496f38870a477929d9', 'anchors': ['blink:eth:ropsten:0x226dc327b12eeb0966b3ad2fc4d4d176403bb50b9c7f1d31f352d52e05e0aadb']}
INFO - Broadcast transaction with txid 0x226dc327b12eeb0966b3ad2fc4d4d176403bb50b9c7f1d31f352d52e05e0aadb
INFO - Your Blockchain Certificates are in /etc/cert-issuer/data/blockchain_certificates

## 2nd attempt

bash-5.0# cd cert-issuer && cert-issuer -c conf.ini --verification_method "0xEd76Cba060A1c7210c7e10EbE562b4966B9f45A1"
WARNING - Your app is configured to skip the wifi check when the USB is plugged in. Read the documentation to ensure this is what you want, since this is less secure
INFO - This run will try to issue on the ethereum_ropsten chain
INFO - Set cost constants to recommended_gas_price=20000000000.000000, recommended_gas_limit=25000.000000
INFO - Processing 1 certificates
INFO - Processing 1 certificates under work path=/etc/cert-issuer/work
WARNING - ('Web3.py only accepts checksum addresses. The software that gave you this non-checksum address should be considered unsafe, please file it as a bug on their platform. Try using an ENS name instead. Or, if you must accept lower safety, use Web3.toChecksumAddress(lower_case_address).', '0x3c0ba0445c8a3882ac050cc03c45c5ac89f65de9')
INFO - Balance check succeeded: {'status': '1', 'message': 'OK-Missing/Invalid API Key, rate limit of 1/5sec applied', 'result': '9973749999853000'}
INFO - Total cost will be 500000000000000 wei
INFO - Starting finalizable signer
WARNING - app is configured to skip the wifi check when the USB is plugged in. Read the documentation to ensure this is what you want, since this is less secure
INFO - Stopping finalizable signer
WARNING - app is configured to skip the wifi check when the USB is plugged in. Read the documentation to ensure this is what you want, since this is less secure
INFO - here is the op_return_code data: f4906de7db4f9a826b5998472f51eaac762d429b29b6c2496f38870a477929d9
INFO - Fetching nonce with EthereumRPCProvider
WARNING - ('Web3.py only accepts checksum addresses. The software that gave you this non-checksum address should be considered unsafe, please file it as a bug on their platform. Try using an ENS name instead. Or, if you must accept lower safety, use Web3.toChecksumAddress(lower_case_address).', '0x3c0ba0445c8a3882ac050cc03c45c5ac89f65de9')
WARNING - Max rate limit reached, please use API Key for higher rate limit
INFO - Starting finalizable signer
WARNING - app is configured to skip the wifi check when the USB is plugged in. Read the documentation to ensure this is what you want, since this is less secure
INFO - Stopping finalizable signer
WARNING - app is configured to skip the wifi check when the USB is plugged in. Read the documentation to ensure this is what you want, since this is less secure
INFO - signed Ethereum trx = f884808504a817c8008261a894deaddeaddeaddeaddeaddeaddeaddeaddeaddead80a0f4906de7db4f9a826b5998472f51eaac762d429b29b6c2496f38870a477929d929a08e39f10a0ea6bcad79ca7b3a356571b2d1aeb107992d5057d583bb48e94f7d06a06c8cb9dcc51d4435877af6750898ca39fd14393862185bdf0ff7cf1c4fbdf03b
INFO - verifying ethDataField value for transaction
INFO - verified ethDataField
INFO - Broadcasting transaction with EthereumRPCProvider
WARNING - Caught exception trying provider <cert_issuer.blockchain_handlers.ethereum.connectors.EthereumRPCProvider object at 0x7f10b07272e0>. Trying another. Exception=HTTPConnectionPool(host='localhost', port=8545): Max retries exceeded with url: / (Caused by NewConnectionError('<urllib3.connection.HTTPConnection object at 0x7f10b0632040>: Failed to establish a new connection: [Errno 111] Connection refused'))
WARNING - Caught exception trying provider <cert_issuer.blockchain_handlers.ethereum.connectors.EtherscanBroadcaster object at 0x7f10b07278b0>. Trying another. Exception=Max rate limit reached, please use API Key for higher rate limit
WARNING - Broadcasting failed. Waiting before retrying. This is attempt number 0
INFO - Broadcasting transaction with EthereumRPCProvider
WARNING - Caught exception trying provider <cert_issuer.blockchain_handlers.ethereum.connectors.EthereumRPCProvider object at 0x7f10b07272e0>. Trying another. Exception=HTTPConnectionPool(host='localhost', port=8545): Max retries exceeded with url: / (Caused by NewConnectionError('<urllib3.connection.HTTPConnection object at 0x7f10b06428e0>: Failed to establish a new connection: [Errno 111] Connection refused'))
ERROR - Etherscan returned an error: {'code': -32000, 'message': 'nonce too low'}
WARNING - Caught exception trying provider <cert_issuer.blockchain_handlers.ethereum.connectors.EtherscanBroadcaster object at 0x7f10b07278b0>. Trying another. Exception={'code': -32000, 'message': 'nonce too low'}
WARNING - Broadcasting failed. Waiting before retrying. This is attempt number 1
INFO - Broadcasting transaction with EthereumRPCProvider
WARNING - Caught exception trying provider <cert_issuer.blockchain_handlers.ethereum.connectors.EthereumRPCProvider object at 0x7f10b07272e0>. Trying another. Exception=HTTPConnectionPool(host='localhost', port=8545): Max retries exceeded with url: / (Caused by NewConnectionError('<urllib3.connection.HTTPConnection object at 0x7f10b0632fd0>: Failed to establish a new connection: [Errno 111] Connection refused'))
ERROR - Etherscan returned an error: {'code': -32000, 'message': 'nonce too low'}
WARNING - Caught exception trying provider <cert_issuer.blockchain_handlers.ethereum.connectors.EtherscanBroadcaster object at 0x7f10b07278b0>. Trying another. Exception={'code': -32000, 'message': 'nonce too low'}
WARNING - Broadcasting failed. Waiting before retrying. This is attempt number 2
ERROR - Failed broadcasting through all providers
ERROR - {'code': -32000, 'message': 'nonce too low'}
NoneType: None
WARNING - Failed broadcast reattempts. Trying to recreate transaction. This is attempt number 0
INFO - Fetching nonce with EthereumRPCProvider
WARNING - ('Web3.py only accepts checksum addresses. The software that gave you this non-checksum address should be considered unsafe, please file it as a bug on their platform. Try using an ENS name instead. Or, if you must accept lower safety, use Web3.toChecksumAddress(lower_case_address).', '0x3c0ba0445c8a3882ac050cc03c45c5ac89f65de9')
INFO - Nonce check went correct: {'jsonrpc': '2.0', 'id': 1, 'result': '0x1'}
INFO - Starting finalizable signer
WARNING - app is configured to skip the wifi check when the USB is plugged in. Read the documentation to ensure this is what you want, since this is less secure
INFO - Stopping finalizable signer
WARNING - app is configured to skip the wifi check when the USB is plugged in. Read the documentation to ensure this is what you want, since this is less secure
INFO - signed Ethereum trx = f884018504a817c8008261a894deaddeaddeaddeaddeaddeaddeaddeaddeaddead80a0f4906de7db4f9a826b5998472f51eaac762d429b29b6c2496f38870a477929d929a0465af951ac9b9c0099a576952c92cbebe4db1d80db36edf89b4a80e74168006ea019a4ac969105403a3dd21efd23e7c2fea3e524d69193c0961bd450cb6c2fa346
INFO - verifying ethDataField value for transaction
INFO - verified ethDataField
INFO - Broadcasting transaction with EthereumRPCProvider
WARNING - Caught exception trying provider <cert_issuer.blockchain_handlers.ethereum.connectors.EthereumRPCProvider object at 0x7f10b07272e0>. Trying another. Exception=HTTPConnectionPool(host='localhost', port=8545): Max retries exceeded with url: / (Caused by NewConnectionError('<urllib3.connection.HTTPConnection object at 0x7f10b0642d00>: Failed to establish a new connection: [Errno 111] Connection refused'))
WARNING - Caught exception trying provider <cert_issuer.blockchain_handlers.ethereum.connectors.EtherscanBroadcaster object at 0x7f10b07278b0>. Trying another. Exception=Max rate limit reached, please use API Key for higher rate limit
WARNING - Broadcasting failed. Waiting before retrying. This is attempt number 0
INFO - Broadcasting transaction with EthereumRPCProvider
WARNING - Caught exception trying provider <cert_issuer.blockchain_handlers.ethereum.connectors.EthereumRPCProvider object at 0x7f10b07272e0>. Trying another. Exception=HTTPConnectionPool(host='localhost', port=8545): Max retries exceeded with url: / (Caused by NewConnectionError('<urllib3.connection.HTTPConnection object at 0x7f10b0632be0>: Failed to establish a new connection: [Errno 111] Connection refused'))
INFO - Transaction ID obtained from broadcast through Etherscan: 0xd7998a00d7916403aeff022d88779aca43a2ec2211be50bcdcc462a89b29b437
INFO - Broadcasting succeeded with method_provider=<cert_issuer.blockchain_handlers.ethereum.connectors.EtherscanBroadcaster object at 0x7f10b07278b0>, txid=0xd7998a00d7916403aeff022d88779aca43a2ec2211be50bcdcc462a89b29b437
INFO - merkle_json: {'path': [], 'merkleRoot': 'f4906de7db4f9a826b5998472f51eaac762d429b29b6c2496f38870a477929d9', 'targetHash': 'f4906de7db4f9a826b5998472f51eaac762d429b29b6c2496f38870a477929d9', 'anchors': ['blink:eth:ropsten:0xd7998a00d7916403aeff022d88779aca43a2ec2211be50bcdcc462a89b29b437']}
INFO - Broadcast transaction with txid 0xd7998a00d7916403aeff022d88779aca43a2ec2211be50bcdcc462a89b29b437
INFO - Your Blockchain Certificates are in /etc/cert-issuer/data/blockchain_certificates
bash-5.0# docker ps -l
bash: docker: command not found
bash-5.0# exit
exit

## 3rd attempt

ubuntu@ip-172-31-21-255:~/ecert-issuer$ cat data/unsigned_certificates/test1.json
{
"@context": [
"https://www.w3.org/2018/credentials/v1",
"https://w3id.org/blockcerts/v3"
],
"id": "urn:uuid:bbba8553-8ec1-445f-82c9-a57251dd731c",
"type": ["VerifiableCredential", "BlockcertsCredential"],
"issuer": "did:example:23adb1f712ebc6f1c276eba4dfa",
"issuanceDate": "2022-01-01T19:33:24Z",
"credentialSubject": {
"id": "did:example:ebfeb1f712ebc6f1c276e12ec21",
"alumniOf": {
"id": "did:example:c276e12ec21ebfeb1f712ebc6f1"
}
}
}
ubuntu@ip-172-31-21-255:~/ecert-issuer$ docker build -t bc/cert-issuer:1.0 .
Sending build context to Docker daemon 2.07MB
Step 1/7 : FROM lncm/bitcoind:v22.0
---> 50992b4790b5
Step 2/7 : MAINTAINER Kim Duffy "kimhd@mit.edu"
---> Using cache
---> a778acc78d2d
Step 3/7 : USER root
---> Using cache
---> 42e98c977aaa
Step 4/7 : COPY . /cert-issuer
---> Using cache
---> 2184691b5c7d
Step 5/7 : COPY conf.ini /etc/cert-issuer/conf.ini
---> Using cache
---> cf1a7711be6e
Step 6/7 : RUN apk add --update bash ca-certificates curl gcc gmp-dev libffi-dev libressl-dev libxml2-dev libxslt-dev linux-headers make musl-dev python2 python3 python3-dev tar && python3 -m ensurepip && pip3 install --upgrade pip setuptools && pip3 install Cython && pip3 install wheel && mkdir -p /etc/cert-issuer/data/unsigned_certificates && mkdir /etc/cert-issuer/data/blockchain_certificates && pip3 install /cert-issuer/. && pip3 install -r /cert-issuer/ethereum_requirements.txt && rm -r /usr/lib/python*/ensurepip && rm -rf /var/cache/apk/* && rm -rf /root/.cache
---> Using cache
---> 416788d160ed
Step 7/7 : ENTRYPOINT bitcoind -daemon && bash
---> Using cache
---> 28dc268078ad
Successfully built 28dc268078ad
Successfully tagged bc/cert-issuer:1.0
ubuntu@ip-172-31-21-255:~/ecert-issuer$ python setup.py experimental --blockchain=ethereum
/home/ubuntu/ecert-issuer/setup.py:2: DeprecationWarning: The distutils package is deprecated and slated for removal in Python 3.12. Use setuptools or check PEP 632 for potential alternatives
from distutils.core import Command
running experimental
Defaulting to user installation because normal site-packages is not writeable
Requirement already satisfied: cert-core>=3.0.0b1 in /home/ubuntu/.local/lib/python3.10/site-packages (3.0.0b1)
Requirement already satisfied: Flask-PyMongo>=0.5.1 in /home/ubuntu/.local/lib/python3.10/site-packages (from cert-core>=3.0.0b1) (2.3.0)
Requirement already satisfied: cert-schema>=3.0.0b1 in /home/ubuntu/.local/lib/python3.10/site-packages (from cert-core>=3.0.0b1) (3.2.1)
Requirement already satisfied: python-dateutil>=2.6.1 in /home/ubuntu/.local/lib/python3.10/site-packages (from cert-core>=3.0.0b1) (2.8.2)
Requirement already satisfied: jsonschema>=2.6.0 in /home/ubuntu/.local/lib/python3.10/site-packages (from cert-core>=3.0.0b1) (2.6.0)
Requirement already satisfied: tox>=3.0.0 in /home/ubuntu/.local/lib/python3.10/site-packages (from cert-core>=3.0.0b1) (3.25.1)
Requirement already satisfied: validators>=0.12.1 in /home/ubuntu/.local/lib/python3.10/site-packages (from cert-core>=3.0.0b1) (0.20.0)
Requirement already satisfied: pytz>=2017.2 in /usr/lib/python3/dist-packages (from cert-core>=3.0.0b1) (2022.1)
Requirement already satisfied: simplekv>=0.10.0 in /home/ubuntu/.local/lib/python3.10/site-packages (from cert-core>=3.0.0b1) (0.14.1)
Requirement already satisfied: connexion>=1.1.14 in /home/ubuntu/.local/lib/python3.10/site-packages (from cert-core>=3.0.0b1) (2.14.0)
Requirement already satisfied: configargparse>=0.12.0 in /home/ubuntu/.local/lib/python3.10/site-packages (from cert-core>=3.0.0b1) (0.12.0)
Requirement already satisfied: requests>=2.18.4 in /usr/lib/python3/dist-packages (from cert-core>=3.0.0b1) (2.25.1)
Requirement already satisfied: pyld>=1.0.3 in /home/ubuntu/.local/lib/python3.10/site-packages (from cert-schema>=3.0.0b1->cert-core>=3.0.0b1) (1.0.5)
Requirement already satisfied: packaging>=20 in /home/ubuntu/.local/lib/python3.10/site-packages (from connexion>=1.1.14->cert-core>=3.0.0b1) (21.3)
Requirement already satisfied: PyYAML<7,>=5.1 in /usr/lib/python3/dist-packages (from connexion>=1.1.14->cert-core>=3.0.0b1) (5.4.1)
Requirement already satisfied: itsdangerous>=0.24 in /home/ubuntu/.local/lib/python3.10/site-packages (from connexion>=1.1.14->cert-core>=3.0.0b1) (2.1.2)
Requirement already satisfied: inflection<0.6,>=0.3.1 in /home/ubuntu/.local/lib/python3.10/site-packages (from connexion>=1.1.14->cert-core>=3.0.0b1) (0.5.1)
Requirement already satisfied: flask<3,>=1.0.4 in /home/ubuntu/.local/lib/python3.10/site-packages (from connexion>=1.1.14->cert-core>=3.0.0b1) (2.1.2)
Requirement already satisfied: werkzeug<3,>=1.0 in /home/ubuntu/.local/lib/python3.10/site-packages (from connexion>=1.1.14->cert-core>=3.0.0b1) (2.1.2)
Requirement already satisfied: clickclick<21,>=1.2 in /home/ubuntu/.local/lib/python3.10/site-packages (from connexion>=1.1.14->cert-core>=3.0.0b1) (20.10.2)
Requirement already satisfied: PyMongo>=3.3 in /home/ubuntu/.local/lib/python3.10/site-packages (from Flask-PyMongo>=0.5.1->cert-core>=3.0.0b1) (4.1.1)
Requirement already satisfied: six>=1.5 in /usr/lib/python3/dist-packages (from python-dateutil>=2.6.1->cert-core>=3.0.0b1) (1.16.0)
Requirement already satisfied: toml>=0.9.4 in /home/ubuntu/.local/lib/python3.10/site-packages (from tox>=3.0.0->cert-core>=3.0.0b1) (0.10.2)
Requirement already satisfied: filelock>=3.0.0 in /home/ubuntu/.local/lib/python3.10/site-packages (from tox>=3.0.0->cert-core>=3.0.0b1) (3.7.1)
Requirement already satisfied: py>=1.4.17 in /home/ubuntu/.local/lib/python3.10/site-packages (from tox>=3.0.0->cert-core>=3.0.0b1) (1.11.0)
Requirement already satisfied: virtualenv!=20.0.0,!=20.0.1,!=20.0.2,!=20.0.3,!=20.0.4,!=20.0.5,!=20.0.6,!=20.0.7,>=16.0.0 in /home/ubuntu/.local/lib/python3.10/site-packages (from tox>=3.0.0->cert-core>=3.0.0b1) (20.15.1)
Requirement already satisfied: pluggy>=0.12.0 in /home/ubuntu/.local/lib/python3.10/site-packages (from tox>=3.0.0->cert-core>=3.0.0b1) (1.0.0)
Requirement already satisfied: decorator>=3.4.0 in /home/ubuntu/.local/lib/python3.10/site-packages (from validators>=0.12.1->cert-core>=3.0.0b1) (5.1.1)
Requirement already satisfied: click>=4.0 in /usr/lib/python3/dist-packages (from clickclick<21,>=1.2->connexion>=1.1.14->cert-core>=3.0.0b1) (8.0.3)
Requirement already satisfied: Jinja2>=3.0 in /usr/lib/python3/dist-packages (from flask<3,>=1.0.4->connexion>=1.1.14->cert-core>=3.0.0b1) (3.0.3)
Requirement already satisfied: pyparsing!=3.0.5,>=2.0.2 in /usr/lib/python3/dist-packages (from packaging>=20->connexion>=1.1.14->cert-core>=3.0.0b1) (2.4.7)
Requirement already satisfied: platformdirs<3,>=2 in /home/ubuntu/.local/lib/python3.10/site-packages (from virtualenv!=20.0.0,!=20.0.1,!=20.0.2,!=20.0.3,!=20.0.4,!=20.0.5,!=20.0.6,!=20.0.7,>=16.0.0->tox>=3.0.0->cert-core>=3.0.0b1) (2.5.2)
Requirement already satisfied: distlib<1,>=0.3.1 in /home/ubuntu/.local/lib/python3.10/site-packages (from virtualenv!=20.0.0,!=20.0.1,!=20.0.2,!=20.0.3,!=20.0.4,!=20.0.5,!=20.0.6,!=20.0.7,>=16.0.0->tox>=3.0.0->cert-core>=3.0.0b1) (0.3.4)
Defaulting to user installation because normal site-packages is not writeable
Requirement already satisfied: cert-schema>=3.2.1 in /home/ubuntu/.local/lib/python3.10/site-packages (3.2.1)
Requirement already satisfied: pyld>=1.0.3 in /home/ubuntu/.local/lib/python3.10/site-packages (from cert-schema>=3.2.1) (1.0.5)
Requirement already satisfied: requests>=2.18.4 in /usr/lib/python3/dist-packages (from cert-schema>=3.2.1) (2.25.1)
Requirement already satisfied: jsonschema>=2.6.0 in /home/ubuntu/.local/lib/python3.10/site-packages (from cert-schema>=3.2.1) (2.6.0)
Requirement already satisfied: validators>=0.12.1 in /home/ubuntu/.local/lib/python3.10/site-packages (from cert-schema>=3.2.1) (0.20.0)
Requirement already satisfied: tox>=3.0.0 in /home/ubuntu/.local/lib/python3.10/site-packages (from cert-schema>=3.2.1) (3.25.1)
Requirement already satisfied: pluggy>=0.12.0 in /home/ubuntu/.local/lib/python3.10/site-packages (from tox>=3.0.0->cert-schema>=3.2.1) (1.0.0)
Requirement already satisfied: virtualenv!=20.0.0,!=20.0.1,!=20.0.2,!=20.0.3,!=20.0.4,!=20.0.5,!=20.0.6,!=20.0.7,>=16.0.0 in /home/ubuntu/.local/lib/python3.10/site-packages (from tox>=3.0.0->cert-schema>=3.2.1) (20.15.1)
Requirement already satisfied: six>=1.14.0 in /usr/lib/python3/dist-packages (from tox>=3.0.0->cert-schema>=3.2.1) (1.16.0)
Requirement already satisfied: toml>=0.9.4 in /home/ubuntu/.local/lib/python3.10/site-packages (from tox>=3.0.0->cert-schema>=3.2.1) (0.10.2)
Requirement already satisfied: py>=1.4.17 in /home/ubuntu/.local/lib/python3.10/site-packages (from tox>=3.0.0->cert-schema>=3.2.1) (1.11.0)
Requirement already satisfied: filelock>=3.0.0 in /home/ubuntu/.local/lib/python3.10/site-packages (from tox>=3.0.0->cert-schema>=3.2.1) (3.7.1)
Requirement already satisfied: packaging>=14 in /home/ubuntu/.local/lib/python3.10/site-packages (from tox>=3.0.0->cert-schema>=3.2.1) (21.3)
Requirement already satisfied: decorator>=3.4.0 in /home/ubuntu/.local/lib/python3.10/site-packages (from validators>=0.12.1->cert-schema>=3.2.1) (5.1.1)
Requirement already satisfied: pyparsing!=3.0.5,>=2.0.2 in /usr/lib/python3/dist-packages (from packaging>=14->tox>=3.0.0->cert-schema>=3.2.1) (2.4.7)
Requirement already satisfied: platformdirs<3,>=2 in /home/ubuntu/.local/lib/python3.10/site-packages (from virtualenv!=20.0.0,!=20.0.1,!=20.0.2,!=20.0.3,!=20.0.4,!=20.0.5,!=20.0.6,!=20.0.7,>=16.0.0->tox>=3.0.0->cert-schema>=3.2.1) (2.5.2)
Requirement already satisfied: distlib<1,>=0.3.1 in /home/ubuntu/.local/lib/python3.10/site-packages (from virtualenv!=20.0.0,!=20.0.1,!=20.0.2,!=20.0.3,!=20.0.4,!=20.0.5,!=20.0.6,!=20.0.7,>=16.0.0->tox>=3.0.0->cert-schema>=3.2.1) (0.3.4)
Defaulting to user installation because normal site-packages is not writeable
Requirement already satisfied: merkletools==1.0.3 in /home/ubuntu/.local/lib/python3.10/site-packages (1.0.3)
Requirement already satisfied: pysha3>=1.0b1 in /home/ubuntu/.local/lib/python3.10/site-packages (from merkletools==1.0.3) (1.0.2)
Defaulting to user installation because normal site-packages is not writeable
Requirement already satisfied: configargparse==0.12.0 in /home/ubuntu/.local/lib/python3.10/site-packages (0.12.0)
Defaulting to user installation because normal site-packages is not writeable
Requirement already satisfied: glob2==0.6 in /home/ubuntu/.local/lib/python3.10/site-packages (0.6)
Defaulting to user installation because normal site-packages is not writeable
Requirement already satisfied: mock==2.0.0 in /home/ubuntu/.local/lib/python3.10/site-packages (2.0.0)
Requirement already satisfied: six>=1.9 in /usr/lib/python3/dist-packages (from mock==2.0.0) (1.16.0)
Requirement already satisfied: pbr>=0.11 in /home/ubuntu/.local/lib/python3.10/site-packages (from mock==2.0.0) (5.9.0)
Defaulting to user installation because normal site-packages is not writeable
Requirement already satisfied: requests[security]>=2.18.4 in /usr/lib/python3/dist-packages (2.25.1)
Requirement already satisfied: cryptography>=1.3.4 in /usr/lib/python3/dist-packages (from requests[security]>=2.18.4) (3.4.8)
Requirement already satisfied: pyOpenSSL>=0.14 in /usr/lib/python3/dist-packages (from requests[security]>=2.18.4) (21.0.0)
Defaulting to user installation because normal site-packages is not writeable
Requirement already satisfied: pycoin==0.80 in /home/ubuntu/.local/lib/python3.10/site-packages (0.80)
Defaulting to user installation because normal site-packages is not writeable
Requirement already satisfied: pyld==1.0.5 in /home/ubuntu/.local/lib/python3.10/site-packages (1.0.5)
Defaulting to user installation because normal site-packages is not writeable
Requirement already satisfied: pysha3>=1.0.2 in /home/ubuntu/.local/lib/python3.10/site-packages (1.0.2)
Defaulting to user installation because normal site-packages is not writeable
Requirement already satisfied: python-bitcoinlib>=0.10.1 in /home/ubuntu/.local/lib/python3.10/site-packages (0.11.0)
Defaulting to user installation because normal site-packages is not writeable
Requirement already satisfied: tox>=3.0.0 in /home/ubuntu/.local/lib/python3.10/site-packages (3.25.1)
Requirement already satisfied: toml>=0.9.4 in /home/ubuntu/.local/lib/python3.10/site-packages (from tox>=3.0.0) (0.10.2)
Requirement already satisfied: pluggy>=0.12.0 in /home/ubuntu/.local/lib/python3.10/site-packages (from tox>=3.0.0) (1.0.0)
Requirement already satisfied: virtualenv!=20.0.0,!=20.0.1,!=20.0.2,!=20.0.3,!=20.0.4,!=20.0.5,!=20.0.6,!=20.0.7,>=16.0.0 in /home/ubuntu/.local/lib/python3.10/site-packages (from tox>=3.0.0) (20.15.1)
Requirement already satisfied: six>=1.14.0 in /usr/lib/python3/dist-packages (from tox>=3.0.0) (1.16.0)
Requirement already satisfied: py>=1.4.17 in /home/ubuntu/.local/lib/python3.10/site-packages (from tox>=3.0.0) (1.11.0)
Requirement already satisfied: filelock>=3.0.0 in /home/ubuntu/.local/lib/python3.10/site-packages (from tox>=3.0.0) (3.7.1)
Requirement already satisfied: packaging>=14 in /home/ubuntu/.local/lib/python3.10/site-packages (from tox>=3.0.0) (21.3)
Requirement already satisfied: pyparsing!=3.0.5,>=2.0.2 in /usr/lib/python3/dist-packages (from packaging>=14->tox>=3.0.0) (2.4.7)
Requirement already satisfied: platformdirs<3,>=2 in /home/ubuntu/.local/lib/python3.10/site-packages (from virtualenv!=20.0.0,!=20.0.1,!=20.0.2,!=20.0.3,!=20.0.4,!=20.0.5,!=20.0.6,!=20.0.7,>=16.0.0->tox>=3.0.0) (2.5.2)
Requirement already satisfied: distlib<1,>=0.3.1 in /home/ubuntu/.local/lib/python3.10/site-packages (from virtualenv!=20.0.0,!=20.0.1,!=20.0.2,!=20.0.3,!=20.0.4,!=20.0.5,!=20.0.6,!=20.0.7,>=16.0.0->tox>=3.0.0) (0.3.4)
Defaulting to user installation because normal site-packages is not writeable
Requirement already satisfied: jsonschema<3.0.0 in /home/ubuntu/.local/lib/python3.10/site-packages (2.6.0)
Defaulting to user installation because normal site-packages is not writeable
Requirement already satisfied: lds-merkle-proof-2019>=0.0.2 in /home/ubuntu/.local/lib/python3.10/site-packages (0.0.2)
Requirement already satisfied: py-multibase>=1.0.1 in /home/ubuntu/.local/lib/python3.10/site-packages (from lds-merkle-proof-2019>=0.0.2) (1.0.3)
Requirement already satisfied: cbor2>=4.1.2 in /home/ubuntu/.local/lib/python3.10/site-packages (from lds-merkle-proof-2019>=0.0.2) (5.4.3)
Requirement already satisfied: morphys<2.0,>=1.0 in /home/ubuntu/.local/lib/python3.10/site-packages (from py-multibase>=1.0.1->lds-merkle-proof-2019>=0.0.2) (1.0)
Requirement already satisfied: six<2.0,>=1.10.0 in /usr/lib/python3/dist-packages (from py-multibase>=1.0.1->lds-merkle-proof-2019>=0.0.2) (1.16.0)
Requirement already satisfied: python-baseconv<2.0,>=1.2.0 in /home/ubuntu/.local/lib/python3.10/site-packages (from py-multibase>=1.0.1->lds-merkle-proof-2019>=0.0.2) (1.2.2)
Defaulting to user installation because normal site-packages is not writeable
Requirement already satisfied: web3<=4.4.1 in /home/ubuntu/.local/lib/python3.10/site-packages (4.4.1)
Requirement already satisfied: requests<3.0.0,>=2.16.0 in /usr/lib/python3/dist-packages (from web3<=4.4.1) (2.25.1)
Requirement already satisfied: eth-utils<2.0.0,>=1.0.1 in /home/ubuntu/.local/lib/python3.10/site-packages (from web3<=4.4.1) (1.10.0)
Requirement already satisfied: cytoolz<1.0.0,>=0.9.0 in /home/ubuntu/.local/lib/python3.10/site-packages (from web3<=4.4.1) (0.11.2)
Requirement already satisfied: lru-dict<2.0.0,>=1.1.6 in /home/ubuntu/.local/lib/python3.10/site-packages (from web3<=4.4.1) (1.1.7)
Requirement already satisfied: eth-abi<2,>=1.1.1 in /home/ubuntu/.local/lib/python3.10/site-packages (from web3<=4.4.1) (1.3.0)
Requirement already satisfied: eth-account<0.3.0,>=0.2.1 in /home/ubuntu/.local/lib/python3.10/site-packages (from web3<=4.4.1) (0.2.3)
Requirement already satisfied: eth-hash[pycryptodome] in /home/ubuntu/.local/lib/python3.10/site-packages (from web3<=4.4.1) (0.3.3)
Requirement already satisfied: websockets<6.0.0,>=5.0.1 in /home/ubuntu/.local/lib/python3.10/site-packages (from web3<=4.4.1) (5.0.1)
Requirement already satisfied: hexbytes<1.0.0,>=0.1.0 in /home/ubuntu/.local/lib/python3.10/site-packages (from web3<=4.4.1) (0.2.2)
Requirement already satisfied: toolz>=0.8.0 in /home/ubuntu/.local/lib/python3.10/site-packages (from cytoolz<1.0.0,>=0.9.0->web3<=4.4.1) (0.11.2)
Requirement already satisfied: parsimonious<0.9.0,>=0.8.0 in /home/ubuntu/.local/lib/python3.10/site-packages (from eth-abi<2,>=1.1.1->web3<=4.4.1) (0.8.1)
Requirement already satisfied: eth-typing<3.0.0,>=2.0.0 in /home/ubuntu/.local/lib/python3.10/site-packages (from eth-abi<2,>=1.1.1->web3<=4.4.1) (2.3.0)
Requirement already satisfied: attrdict<3,>=2.0.0 in /home/ubuntu/.local/lib/python3.10/site-packages (from eth-account<0.3.0,>=0.2.1->web3<=4.4.1) (2.0.1)
Requirement already satisfied: eth-keyfile<0.6.0,>=0.5.0 in /home/ubuntu/.local/lib/python3.10/site-packages (from eth-account<0.3.0,>=0.2.1->web3<=4.4.1) (0.5.1)
Requirement already satisfied: eth-keys<0.3.0,>=0.2.0b3 in /home/ubuntu/.local/lib/python3.10/site-packages (from eth-account<0.3.0,>=0.2.1->web3<=4.4.1) (0.2.4)
Requirement already satisfied: eth-rlp<1,>=0.1.2 in /home/ubuntu/.local/lib/python3.10/site-packages (from eth-account<0.3.0,>=0.2.1->web3<=4.4.1) (0.2.1)
Requirement already satisfied: pycryptodome<4,>=3.6.6 in /home/ubuntu/.local/lib/python3.10/site-packages (from eth-hash[pycryptodome]->web3<=4.4.1) (3.15.0)
Requirement already satisfied: six in /usr/lib/python3/dist-packages (from attrdict<3,>=2.0.0->eth-account<0.3.0,>=0.2.1->web3<=4.4.1) (1.16.0)
Requirement already satisfied: rlp<3,>=0.6.0 in /home/ubuntu/.local/lib/python3.10/site-packages (from eth-rlp<1,>=0.1.2->eth-account<0.3.0,>=0.2.1->web3<=4.4.1) (0.6.0)
Defaulting to user installation because normal site-packages is not writeable
Collecting coincurve==7.1.0
Using cached coincurve-7.1.0.tar.gz (911 kB)
Preparing metadata (setup.py) ... done
Requirement already satisfied: asn1crypto in /home/ubuntu/.local/lib/python3.10/site-packages (from coincurve==7.1.0) (1.5.1)
Requirement already satisfied: cffi>=1.3.0 in /home/ubuntu/.local/lib/python3.10/site-packages (from coincurve==7.1.0) (1.15.1)
Requirement already satisfied: pycparser in /home/ubuntu/.local/lib/python3.10/site-packages (from cffi>=1.3.0->coincurve==7.1.0) (2.21)
Building wheels for collected packages: coincurve
Building wheel for coincurve (setup.py) ... error
error: subprocess-exited-with-error

× python setup.py bdist_wheel did not run successfully.
│ exit code: 1
╰─> [158 lines of output]
/usr/lib/python3/dist-packages/pkg_resources/**init**.py:116: PkgResourcesDeprecationWarning: 1.1build1 is an invalid version and will not be supported in a future release
warnings.warn(
/usr/lib/python3/dist-packages/pkg_resources/**init**.py:116: PkgResourcesDeprecationWarning: 0.1.43ubuntu1 is an invalid version and will not be supported in a future release
warnings.warn(
/usr/lib/python3/dist-packages/setuptools/installer.py:27: SetuptoolsDeprecationWarning: setuptools.installer is deprecated. Requirements should be satisfied by a PEP 517 installer.
warnings.warn(
Warning: 'keywords' should be a list, got type 'tuple'
running bdist_wheel
The [wheel] section is deprecated. Use [bdist_wheel] instead.
running build
running build_py
creating build
creating build/lib.linux-x86_64-3.10
creating build/lib.linux-x86_64-3.10/tests
copying tests/**init**.py -> build/lib.linux-x86_64-3.10/tests
copying tests/samples.py -> build/lib.linux-x86_64-3.10/tests
copying tests/test_ecdsa.py -> build/lib.linux-x86_64-3.10/tests
copying tests/test_keys.py -> build/lib.linux-x86_64-3.10/tests
copying tests/test_utils.py -> build/lib.linux-x86_64-3.10/tests
creating build/lib.linux-x86_64-3.10/coincurve
copying coincurve/**init**.py -> build/lib.linux-x86_64-3.10/coincurve
copying coincurve/flags.py -> build/lib.linux-x86_64-3.10/coincurve
copying coincurve/utils.py -> build/lib.linux-x86_64-3.10/coincurve
copying coincurve/ecdsa.py -> build/lib.linux-x86_64-3.10/coincurve
copying coincurve/keys.py -> build/lib.linux-x86_64-3.10/coincurve
copying coincurve/\_windows_libsecp256k1.py -> build/lib.linux-x86_64-3.10/coincurve
copying coincurve/context.py -> build/lib.linux-x86_64-3.10/coincurve
running build_clib
checking build system type... x86_64-unknown-linux-gnu
checking host system type... x86_64-unknown-linux-gnu
checking for a BSD-compatible install... /usr/bin/install -c
checking whether build environment is sane... yes
checking for a thread-safe mkdir -p... /usr/bin/mkdir -p
checking for gawk... gawk
checking whether make sets $(MAKE)... yes
checking whether make supports nested variables... yes
checking how to print strings... printf
checking for style of include used by make... GNU
checking for gcc... gcc
checking whether the C compiler works... yes
checking for C compiler default output file name... a.out
checking for suffix of executables...
checking whether we are cross compiling... no
checking for suffix of object files... o
checking whether we are using the GNU C compiler... yes
checking whether gcc accepts -g... yes
checking for gcc option to accept ISO C89... none needed
checking whether gcc understands -c and -o together... yes
checking dependency style of gcc... none
checking for a sed that does not truncate output... /usr/bin/sed
checking for grep that handles long lines and -e... /usr/bin/grep
checking for egrep... /usr/bin/grep -E
checking for fgrep... /usr/bin/grep -F
checking for ld used by gcc... /usr/bin/ld
checking if the linker (/usr/bin/ld) is GNU ld... yes
checking for BSD- or MS-compatible name lister (nm)... /usr/bin/nm -B
checking the name lister (/usr/bin/nm -B) interface... BSD nm
checking whether ln -s works... yes
checking the maximum length of command line arguments... 1572864
checking whether the shell understands some XSI constructs... yes
checking whether the shell understands "+="... yes
checking how to convert x86_64-unknown-linux-gnu file names to x86_64-unknown-linux-gnu format... func_convert_file_noop
checking how to convert x86_64-unknown-linux-gnu file names to toolchain format... func_convert_file_noop
checking for /usr/bin/ld option to reload object files... -r
checking for objdump... objdump
checking how to recognize dependent libraries... pass_all
checking for dlltool... no
checking how to associate runtime and link libraries... printf %s\n
checking for ar... ar
checking for archiver @FILE support... @
checking for strip... strip
checking for ranlib... ranlib
checking command to parse /usr/bin/nm -B output from gcc object... ok
checking for sysroot... no
checking for mt... mt
checking if mt is a manifest tool... no
checking how to run the C preprocessor... gcc -E
checking for ANSI C header files... yes
checking for sys/types.h... yes
checking for sys/stat.h... yes
checking for stdlib.h... yes
checking for string.h... yes
checking for memory.h... yes
checking for strings.h... yes
checking for inttypes.h... yes
checking for stdint.h... yes
checking for unistd.h... yes
checking for dlfcn.h... yes
checking for objdir... .libs
checking if gcc supports -fno-rtti -fno-exceptions... no
checking for gcc option to produce PIC... -fPIC -DPIC
checking if gcc PIC flag -fPIC -DPIC works... yes
checking if gcc static flag -static works... yes
checking if gcc supports -c -o file.o... yes
checking if gcc supports -c -o file.o... (cached) yes
checking whether the gcc linker (/usr/bin/ld -m elf_x86_64) supports shared libraries... yes
checking dynamic linker characteristics... GNU/Linux ld.so
checking how to hardcode library paths into programs... immediate
checking whether stripping libraries is possible... yes
checking if libtool supports shared libraries... yes
checking whether to build shared libraries... no
checking whether to build static libraries... yes
checking whether make supports nested variables... (cached) yes
checking for pkg-config... no
checking for ar... /usr/bin/ar
checking for ranlib... /usr/bin/ranlib
checking for strip... /usr/bin/strip
checking for gcc... gcc
checking whether we are using the GNU C compiler... (cached) yes
checking whether gcc accepts -g... yes
checking for gcc option to accept ISO C89... (cached) none needed
checking whether gcc understands -c and -o together... (cached) yes
checking dependency style of gcc... (cached) none
checking how to run the C preprocessor... gcc -E
checking for gcc option to accept ISO C89... (cached) none needed
checking dependency style of gcc... none
checking if gcc supports -std=c89 -pedantic -Wall -Wextra -Wcast-align -Wnested-externs -Wshadow -Wstrict-prototypes -Wno-unused-function -Wno-long-long -Wno-overlength-strings... yes
checking if gcc supports -fvisibility=hidden... yes
checking for **int128... yes
checking for **builtin_expect... yes
checking native compiler: gcc... ok
checking for x86_64 assembly availability... yes
checking gmp.h usability... no
checking gmp.h presence... no
checking for gmp.h... no
configure: error: gmp bignum explicitly requested but libgmp not available
Traceback (most recent call last):
File "<string>", line 2, in <module>
File "<pip-setuptools-caller>", line 34, in <module>
File "/tmp/pip-install-2ymuhxua/coincurve_a27d8f9fbcab4831b56d816200ceff36/setup.py", line 267, in <module>
setup(
File "/usr/lib/python3/dist-packages/setuptools/**init**.py", line 153, in setup
return distutils.core.setup(\*\*attrs)
File "/usr/lib/python3.10/distutils/core.py", line 148, in setup
dist.run_commands()
File "/usr/lib/python3.10/distutils/dist.py", line 966, in run_commands
self.run_command(cmd)
File "/usr/lib/python3.10/distutils/dist.py", line 985, in run_command
cmd_obj.run()
File "/tmp/pip-install-2ymuhxua/coincurve_a27d8f9fbcab4831b56d816200ceff36/setup.py", line 99, in run
\_bdist_wheel.run(self)
File "/usr/lib/python3/dist-packages/wheel/bdist_wheel.py", line 299, in run
self.run_command('build')
File "/usr/lib/python3.10/distutils/cmd.py", line 313, in run_command
self.distribution.run_command(command)
File "/usr/lib/python3.10/distutils/dist.py", line 985, in run_command
cmd_obj.run()
File "/usr/lib/python3.10/distutils/command/build.py", line 135, in run
self.run_command(cmd_name)
File "/usr/lib/python3.10/distutils/cmd.py", line 313, in run_command
self.distribution.run_command(command)
File "/usr/lib/python3.10/distutils/dist.py", line 985, in run_command
cmd_obj.run()
File "/tmp/pip-install-2ymuhxua/coincurve_a27d8f9fbcab4831b56d816200ceff36/setup.py", line 196, in run
subprocess.check_call(
File "/usr/lib/python3.10/subprocess.py", line 369, in check_call
raise CalledProcessError(retcode, cmd)
subprocess.CalledProcessError: Command '['/tmp/pip-install-2ymuhxua/coincurve_a27d8f9fbcab4831b56d816200ceff36/libsecp256k1/configure', '--disable-shared', '--enable-static', '--disable-dependency-tracking', '--with-pic', '--enable-module-recovery', '--disable-jni', '--prefix', '/tmp/pip-install-2ymuhxua/coincurve_a27d8f9fbcab4831b56d816200ceff36/build/temp.linux-x86_64-3.10', '--enable-experimental', '--enable-module-ecdh', '--with-bignum=gmp', '--enable-benchmark=no']' returned non-zero exit status 1.
[end of output]

note: This error originates from a subprocess, and is likely not a problem with pip.
ERROR: Failed building wheel for coincurve
Running setup.py clean for coincurve
Failed to build coincurve
Installing collected packages: coincurve
Attempting uninstall: coincurve
Found existing installation: coincurve 17.0.0
Uninstalling coincurve-17.0.0:
Successfully uninstalled coincurve-17.0.0
Running setup.py install for coincurve ... error
error: subprocess-exited-with-error

× Running setup.py install for coincurve did not run successfully.
│ exit code: 1
╰─> [159 lines of output]
/usr/lib/python3/dist-packages/pkg_resources/**init**.py:116: PkgResourcesDeprecationWarning: 1.1build1 is an invalid version and will not be supported in a future release
warnings.warn(
/usr/lib/python3/dist-packages/pkg_resources/**init**.py:116: PkgResourcesDeprecationWarning: 0.1.43ubuntu1 is an invalid version and will not be supported in a future release
warnings.warn(
/usr/lib/python3/dist-packages/setuptools/installer.py:27: SetuptoolsDeprecationWarning: setuptools.installer is deprecated. Requirements should be satisfied by a PEP 517 installer.
warnings.warn(
Warning: 'keywords' should be a list, got type 'tuple'
running install
/usr/lib/python3/dist-packages/setuptools/command/install.py:34: SetuptoolsDeprecationWarning: setup.py install is deprecated. Use build and pip and other standards-based tools.
warnings.warn(
running build
running build_py
creating build
creating build/lib.linux-x86_64-3.10
creating build/lib.linux-x86_64-3.10/tests
copying tests/**init**.py -> build/lib.linux-x86_64-3.10/tests
copying tests/samples.py -> build/lib.linux-x86_64-3.10/tests
copying tests/test_ecdsa.py -> build/lib.linux-x86_64-3.10/tests
copying tests/test_keys.py -> build/lib.linux-x86_64-3.10/tests
copying tests/test_utils.py -> build/lib.linux-x86_64-3.10/tests
creating build/lib.linux-x86_64-3.10/coincurve
copying coincurve/**init**.py -> build/lib.linux-x86_64-3.10/coincurve
copying coincurve/flags.py -> build/lib.linux-x86_64-3.10/coincurve
copying coincurve/utils.py -> build/lib.linux-x86_64-3.10/coincurve
copying coincurve/ecdsa.py -> build/lib.linux-x86_64-3.10/coincurve
copying coincurve/keys.py -> build/lib.linux-x86_64-3.10/coincurve
copying coincurve/\_windows_libsecp256k1.py -> build/lib.linux-x86_64-3.10/coincurve
copying coincurve/context.py -> build/lib.linux-x86_64-3.10/coincurve
running build_clib
checking build system type... x86_64-unknown-linux-gnu
checking host system type... x86_64-unknown-linux-gnu
checking for a BSD-compatible install... /usr/bin/install -c
checking whether build environment is sane... yes
checking for a thread-safe mkdir -p... /usr/bin/mkdir -p
checking for gawk... gawk
checking whether make sets $(MAKE)... yes
checking whether make supports nested variables... yes
checking how to print strings... printf
checking for style of include used by make... GNU
checking for gcc... gcc
checking whether the C compiler works... yes
checking for C compiler default output file name... a.out
checking for suffix of executables...
checking whether we are cross compiling... no
checking for suffix of object files... o
checking whether we are using the GNU C compiler... yes
checking whether gcc accepts -g... yes
checking for gcc option to accept ISO C89... none needed
checking whether gcc understands -c and -o together... yes
checking dependency style of gcc... none
checking for a sed that does not truncate output... /usr/bin/sed
checking for grep that handles long lines and -e... /usr/bin/grep
checking for egrep... /usr/bin/grep -E
checking for fgrep... /usr/bin/grep -F
checking for ld used by gcc... /usr/bin/ld
checking if the linker (/usr/bin/ld) is GNU ld... yes
checking for BSD- or MS-compatible name lister (nm)... /usr/bin/nm -B
checking the name lister (/usr/bin/nm -B) interface... BSD nm
checking whether ln -s works... yes
checking the maximum length of command line arguments... 1572864
checking whether the shell understands some XSI constructs... yes
checking whether the shell understands "+="... yes
checking how to convert x86_64-unknown-linux-gnu file names to x86_64-unknown-linux-gnu format... func_convert_file_noop
checking how to convert x86_64-unknown-linux-gnu file names to toolchain format... func_convert_file_noop
checking for /usr/bin/ld option to reload object files... -r
checking for objdump... objdump
checking how to recognize dependent libraries... pass_all
checking for dlltool... no
checking how to associate runtime and link libraries... printf %s\n
checking for ar... ar
checking for archiver @FILE support... @
checking for strip... strip
checking for ranlib... ranlib
checking command to parse /usr/bin/nm -B output from gcc object... ok
checking for sysroot... no
checking for mt... mt
checking if mt is a manifest tool... no
checking how to run the C preprocessor... gcc -E
checking for ANSI C header files... yes
checking for sys/types.h... yes
checking for sys/stat.h... yes
checking for stdlib.h... yes
checking for string.h... yes
checking for memory.h... yes
checking for strings.h... yes
checking for inttypes.h... yes
checking for stdint.h... yes
checking for unistd.h... yes
checking for dlfcn.h... yes
checking for objdir... .libs
checking if gcc supports -fno-rtti -fno-exceptions... no
checking for gcc option to produce PIC... -fPIC -DPIC
checking if gcc PIC flag -fPIC -DPIC works... yes
checking if gcc static flag -static works... yes
checking if gcc supports -c -o file.o... yes
checking if gcc supports -c -o file.o... (cached) yes
checking whether the gcc linker (/usr/bin/ld -m elf_x86_64) supports shared libraries... yes
checking dynamic linker characteristics... GNU/Linux ld.so
checking how to hardcode library paths into programs... immediate
checking whether stripping libraries is possible... yes
checking if libtool supports shared libraries... yes
checking whether to build shared libraries... no
checking whether to build static libraries... yes
checking whether make supports nested variables... (cached) yes
checking for pkg-config... no
checking for ar... /usr/bin/ar
checking for ranlib... /usr/bin/ranlib
checking for strip... /usr/bin/strip
checking for gcc... gcc
checking whether we are using the GNU C compiler... (cached) yes
checking whether gcc accepts -g... yes
checking for gcc option to accept ISO C89... (cached) none needed
checking whether gcc understands -c and -o together... (cached) yes
checking dependency style of gcc... (cached) none
checking how to run the C preprocessor... gcc -E
checking for gcc option to accept ISO C89... (cached) none needed
checking dependency style of gcc... none
checking if gcc supports -std=c89 -pedantic -Wall -Wextra -Wcast-align -Wnested-externs -Wshadow -Wstrict-prototypes -Wno-unused-function -Wno-long-long -Wno-overlength-strings... yes
checking if gcc supports -fvisibility=hidden... yes
checking for **int128... yes
checking for **builtin_expect... yes
checking native compiler: gcc... ok
checking for x86_64 assembly availability... yes
checking gmp.h usability... no
checking gmp.h presence... no
checking for gmp.h... no
configure: error: gmp bignum explicitly requested but libgmp not available
Traceback (most recent call last):
File "<string>", line 2, in <module>
File "<pip-setuptools-caller>", line 34, in <module>
File "/tmp/pip-install-2ymuhxua/coincurve_a27d8f9fbcab4831b56d816200ceff36/setup.py", line 267, in <module>
setup(
File "/usr/lib/python3/dist-packages/setuptools/**init**.py", line 153, in setup
return distutils.core.setup(\*\*attrs)
File "/usr/lib/python3.10/distutils/core.py", line 148, in setup
dist.run_commands()
File "/usr/lib/python3.10/distutils/dist.py", line 966, in run_commands
self.run_command(cmd)
File "/usr/lib/python3.10/distutils/dist.py", line 985, in run_command
cmd_obj.run()
File "/usr/lib/python3/dist-packages/setuptools/command/install.py", line 68, in run
return orig.install.run(self)
File "/usr/lib/python3.10/distutils/command/install.py", line 619, in run
self.run_command('build')
File "/usr/lib/python3.10/distutils/cmd.py", line 313, in run_command
self.distribution.run_command(command)
File "/usr/lib/python3.10/distutils/dist.py", line 985, in run_command
cmd_obj.run()
File "/usr/lib/python3.10/distutils/command/build.py", line 135, in run
self.run_command(cmd_name)
File "/usr/lib/python3.10/distutils/cmd.py", line 313, in run_command
self.distribution.run_command(command)
File "/usr/lib/python3.10/distutils/dist.py", line 985, in run_command
cmd_obj.run()
File "/tmp/pip-install-2ymuhxua/coincurve_a27d8f9fbcab4831b56d816200ceff36/setup.py", line 196, in run
subprocess.check_call(
File "/usr/lib/python3.10/subprocess.py", line 369, in check_call
raise CalledProcessError(retcode, cmd)
subprocess.CalledProcessError: Command '['/tmp/pip-install-2ymuhxua/coincurve_a27d8f9fbcab4831b56d816200ceff36/libsecp256k1/configure', '--disable-shared', '--enable-static', '--disable-dependency-tracking', '--with-pic', '--enable-module-recovery', '--disable-jni', '--prefix', '/tmp/pip-install-2ymuhxua/coincurve_a27d8f9fbcab4831b56d816200ceff36/build/temp.linux-x86_64-3.10', '--enable-experimental', '--enable-module-ecdh', '--with-bignum=gmp', '--enable-benchmark=no']' returned non-zero exit status 1.
[end of output]

note: This error originates from a subprocess, and is likely not a problem with pip.
WARNING: No metadata found in /home/ubuntu/.local/lib/python3.10/site-packages
Rolling back uninstall of coincurve
Moving to /home/ubuntu/.local/lib/python3.10/site-packages/coincurve-17.0.0.dist-info/
from /home/ubuntu/.local/lib/python3.10/site-packages/~oincurve-17.0.0.dist-info
Moving to /home/ubuntu/.local/lib/python3.10/site-packages/coincurve/
from /home/ubuntu/.local/lib/python3.10/site-packages/~oincurve
error: legacy-install-failure

× Encountered error while trying to install package.
╰─> coincurve

note: This is an issue with the package mentioned above, not pip.
hint: See above for output from the failure.
Traceback (most recent call last):
File "/home/ubuntu/ecert-issuer/setup.py", line 51, in <module>
setup(
File "/usr/lib/python3/dist-packages/setuptools/**init**.py", line 153, in setup
return distutils.core.setup(\*\*attrs)
File "/usr/lib/python3.10/distutils/core.py", line 148, in setup
dist.run_commands()
File "/usr/lib/python3.10/distutils/dist.py", line 966, in run_commands
self.run_command(cmd)
File "/usr/lib/python3.10/distutils/dist.py", line 985, in run_command
cmd_obj.run()
File "/home/ubuntu/ecert-issuer/setup.py", line 44, in run
install(reqs)
File "/home/ubuntu/ecert-issuer/setup.py", line 48, in install
subprocess.check_call([sys.executable, '-m', 'pip', 'install', package])
File "/usr/lib/python3.10/subprocess.py", line 369, in check_call
raise CalledProcessError(retcode, cmd)
subprocess.CalledProcessError: Command '['/usr/bin/python', '-m', 'pip', 'install', 'coincurve==7.1.0\n']' returned non-zero exit status 1.
ubuntu@ip-172-31-21-255:~/ecert-issuer$ docker run -it bc/cert-issuer:1.0 bash
Bitcoin Core starting
bash-5.0# cp cert-issuer/data/unsigned_certificates/test1.json etc/cert-issuer/data/unsigned_certificates/
bash-5.0# cp cert-issuer/pk_issuer.txt etc/cert-issuer/
bash-5.0# docker ps -l
bash: docker: command not found
bash-5.0# cd cert-issuer && cert-issuer -c conf.ini --verification_method "0xEd76Cba060A1c7210c7e10EbE562b4966B9f45A1"
WARNING - Your app is configured to skip the wifi check when the USB is plugged in. Read the documentation to ensure this is what you want, since this is less secure
INFO - This run will try to issue on the ethereum_ropsten chain
INFO - Set cost constants to recommended_gas_price=20000000000.000000, recommended_gas_limit=25000.000000
INFO - Processing 1 certificates
INFO - Processing 1 certificates under work path=/etc/cert-issuer/work
WARNING - HTTPConnectionPool(host='localhost', port=8545): Max retries exceeded with url: / (Caused by NewConnectionError('<urllib3.connection.HTTPConnection object at 0x7f68c7ad64f0>: Failed to establish a new connection: [Errno 111] Connection refused'))
INFO - Balance check succeeded: {'status': '1', 'message': 'OK-Missing/Invalid API Key, rate limit of 1/5sec applied', 'result': '1989139520000000000'}
INFO - Total cost will be 500000000000000 wei
INFO - Starting finalizable signer
WARNING - app is configured to skip the wifi check when the USB is plugged in. Read the documentation to ensure this is what you want, since this is less secure
INFO - Stopping finalizable signer
WARNING - app is configured to skip the wifi check when the USB is plugged in. Read the documentation to ensure this is what you want, since this is less secure
INFO - here is the op_return_code data: f4906de7db4f9a826b5998472f51eaac762d429b29b6c2496f38870a477929d9
INFO - Fetching nonce with EthereumRPCProvider
WARNING - HTTPConnectionPool(host='localhost', port=8545): Max retries exceeded with url: / (Caused by NewConnectionError('<urllib3.connection.HTTPConnection object at 0x7f68c7a3b1c0>: Failed to establish a new connection: [Errno 111] Connection refused'))
WARNING - Max rate limit reached, please use API Key for higher rate limit
INFO - Starting finalizable signer
WARNING - app is configured to skip the wifi check when the USB is plugged in. Read the documentation to ensure this is what you want, since this is less secure
INFO - Stopping finalizable signer
WARNING - app is configured to skip the wifi check when the USB is plugged in. Read the documentation to ensure this is what you want, since this is less secure
INFO - signed Ethereum trx = f884808504a817c8008261a894deaddeaddeaddeaddeaddeaddeaddeaddeaddead80a0f4906de7db4f9a826b5998472f51eaac762d429b29b6c2496f38870a477929d929a08e39f10a0ea6bcad79ca7b3a356571b2d1aeb107992d5057d583bb48e94f7d06a06c8cb9dcc51d4435877af6750898ca39fd14393862185bdf0ff7cf1c4fbdf03b
INFO - verifying ethDataField value for transaction
INFO - verified ethDataField
INFO - Broadcasting transaction with EthereumRPCProvider
WARNING - Caught exception trying provider <cert_issuer.blockchain_handlers.ethereum.connectors.EthereumRPCProvider object at 0x7f68c7b4a2e0>. Trying another. Exception=HTTPConnectionPool(host='localhost', port=8545): Max retries exceeded with url: / (Caused by NewConnectionError('<urllib3.connection.HTTPConnection object at 0x7f68c7a7a2e0>: Failed to establish a new connection: [Errno 111] Connection refused'))
WARNING - Caught exception trying provider <cert_issuer.blockchain_handlers.ethereum.connectors.EtherscanBroadcaster object at 0x7f68c7b4a8b0>. Trying another. Exception=Max rate limit reached, please use API Key for higher rate limit
WARNING - Broadcasting failed. Waiting before retrying. This is attempt number 0
INFO - Broadcasting transaction with EthereumRPCProvider
WARNING - Caught exception trying provider <cert_issuer.blockchain_handlers.ethereum.connectors.EthereumRPCProvider object at 0x7f68c7b4a2e0>. Trying another. Exception=HTTPConnectionPool(host='localhost', port=8545): Max retries exceeded with url: / (Caused by NewConnectionError('<urllib3.connection.HTTPConnection object at 0x7f68c7a57940>: Failed to establish a new connection: [Errno 111] Connection refused'))
ERROR - Etherscan returned an error: {'code': -32000, 'message': 'nonce too low'}
WARNING - Caught exception trying provider <cert_issuer.blockchain_handlers.ethereum.connectors.EtherscanBroadcaster object at 0x7f68c7b4a8b0>. Trying another. Exception={'code': -32000, 'message': 'nonce too low'}
WARNING - Broadcasting failed. Waiting before retrying. This is attempt number 1
INFO - Broadcasting transaction with EthereumRPCProvider
WARNING - Caught exception trying provider <cert_issuer.blockchain_handlers.ethereum.connectors.EthereumRPCProvider object at 0x7f68c7b4a2e0>. Trying another. Exception=HTTPConnectionPool(host='localhost', port=8545): Max retries exceeded with url: / (Caused by NewConnectionError('<urllib3.connection.HTTPConnection object at 0x7f68c7a3b220>: Failed to establish a new connection: [Errno 111] Connection refused'))
ERROR - Etherscan returned an error: {'code': -32000, 'message': 'nonce too low'}
WARNING - Caught exception trying provider <cert_issuer.blockchain_handlers.ethereum.connectors.EtherscanBroadcaster object at 0x7f68c7b4a8b0>. Trying another. Exception={'code': -32000, 'message': 'nonce too low'}
WARNING - Broadcasting failed. Waiting before retrying. This is attempt number 2
ERROR - Failed broadcasting through all providers
ERROR - {'code': -32000, 'message': 'nonce too low'}
NoneType: None
WARNING - Failed broadcast reattempts. Trying to recreate transaction. This is attempt number 0
INFO - Fetching nonce with EthereumRPCProvider
WARNING - HTTPConnectionPool(host='localhost', port=8545): Max retries exceeded with url: / (Caused by NewConnectionError('<urllib3.connection.HTTPConnection object at 0x7f68c7a57190>: Failed to establish a new connection: [Errno 111] Connection refused'))
INFO - Nonce check went correct: {'jsonrpc': '2.0', 'id': 1, 'result': '0x2'}
INFO - Starting finalizable signer
WARNING - app is configured to skip the wifi check when the USB is plugged in. Read the documentation to ensure this is what you want, since this is less secure
INFO - Stopping finalizable signer
WARNING - app is configured to skip the wifi check when the USB is plugged in. Read the documentation to ensure this is what you want, since this is less secure
INFO - signed Ethereum trx = f884028504a817c8008261a894deaddeaddeaddeaddeaddeaddeaddeaddeaddead80a0f4906de7db4f9a826b5998472f51eaac762d429b29b6c2496f38870a477929d92aa0175533e7d9fa894c1e2f19080f7b4d3310a563f981b719d4f886a11c30ce3a52a026272b56fd32ba2b05ba1aaa08caf6a5f9799ba810fff257dd5b9f22bcfdc6a5
INFO - verifying ethDataField value for transaction
INFO - verified ethDataField
INFO - Broadcasting transaction with EthereumRPCProvider
WARNING - Caught exception trying provider <cert_issuer.blockchain_handlers.ethereum.connectors.EthereumRPCProvider object at 0x7f68c7b4a2e0>. Trying another. Exception=HTTPConnectionPool(host='localhost', port=8545): Max retries exceeded with url: / (Caused by NewConnectionError('<urllib3.connection.HTTPConnection object at 0x7f68c7a3b280>: Failed to establish a new connection: [Errno 111] Connection refused'))
WARNING - Caught exception trying provider <cert_issuer.blockchain_handlers.ethereum.connectors.EtherscanBroadcaster object at 0x7f68c7b4a8b0>. Trying another. Exception=Max rate limit reached, please use API Key for higher rate limit
WARNING - Broadcasting failed. Waiting before retrying. This is attempt number 0
INFO - Broadcasting transaction with EthereumRPCProvider
WARNING - Caught exception trying provider <cert_issuer.blockchain_handlers.ethereum.connectors.EthereumRPCProvider object at 0x7f68c7b4a2e0>. Trying another. Exception=HTTPConnectionPool(host='localhost', port=8545): Max retries exceeded with url: / (Caused by NewConnectionError('<urllib3.connection.HTTPConnection object at 0x7f68c7a6b3a0>: Failed to establish a new connection: [Errno 111] Connection refused'))
INFO - Transaction ID obtained from broadcast through Etherscan: 0x2ea105dab00c4ee7221abdc746ffd963396e620d081b5f83c4ef3bfd916036ad
INFO - Broadcasting succeeded with method_provider=<cert_issuer.blockchain_handlers.ethereum.connectors.EtherscanBroadcaster object at 0x7f68c7b4a8b0>, txid=0x2ea105dab00c4ee7221abdc746ffd963396e620d081b5f83c4ef3bfd916036ad
INFO - merkle_json: {'path': [], 'merkleRoot': 'f4906de7db4f9a826b5998472f51eaac762d429b29b6c2496f38870a477929d9', 'targetHash': 'f4906de7db4f9a826b5998472f51eaac762d429b29b6c2496f38870a477929d9', 'anchors': ['blink:eth:ropsten:0x2ea105dab00c4ee7221abdc746ffd963396e620d081b5f83c4ef3bfd916036ad']}
INFO - Broadcast transaction with txid 0x2ea105dab00c4ee7221abdc746ffd963396e620d081b5f83c4ef3bfd916036ad
INFO - Your Blockchain Certificates are in /etc/cert-issuer/data/blockchain_certificates
bash-5.0# ^C
bash-5.0# ^C
bash-5.0# cd ..
bash-5.0# cat etc/cert-issuer/
cat: read error: Is a directory
bash-5.0# cat etc/cert-issuer/data/blockchain_certificates/test1.json
{"@context": ["https://www.w3.org/2018/credentials/v1", "https://w3id.org/blockcerts/v3"], "id": "urn:uuid:bbba8553-8ec1-445f-82c9-a57251dd731c", "type": ["VerifiableCredential", "BlockcertsCredential"], "issuer": "did:example:23adb1f712ebc6f1c276eba4dfa", "issuanceDate": "2022-01-01T19:33:24Z", "credentialSubject": {"id": "did:example:ebfeb1f712ebc6f1c276e12ec21", "alumniOf": {"id": "did:example:c276e12ec21ebfeb1f712ebc6f1"}}, "proof": {"type": "MerkleProof2019", "created": "2022-07-05T15:31:30.151416", "proofValue": "z7veGu1qoKR3AS5M3xfNxYMVGUCxFzaEQ5NkRWDGTowFPyL2gB7vtCVDfK2e4oETN19HnnqmXL3CS2qpMgnWe2XUHCVN7ufHArBc54QVVk2XouWzakWMU83iHnAsk186DuvJv5vLXN2p9bFXRcwFTfqxkyzDL9E8G8CEZ43X9HnFNz6Yz38U4ypGt6XbmKM7EnLTK5NaKRkHrQehPyRXgsePScMFVLztZ49S2Nku1GWewg7noXfYUGAiKxGpeJrBGGNSmq94isLpoM4Li9WKYtnLTWHFLypaLUht9QqDzA4WJzCs1GUdYf", "proofPurpose": "assertionMethod", "verificationMethod": "0xEd76Cba060A1c7210c7e10EbE562b4966B9f45A1"}}bash-5.0#

## commit docker container after broadcast txn success

(base) joanne@Joannes-MacBook-Pro test % docker ps -l
CONTAINER ID IMAGE COMMAND CREATED STATUS PORTS NAMES
42d1793610e2 bc/cert-issuer:1.0 "/bin/sh -c 'bitcoin…" 18 minutes ago Exited (127) 1 second ago nostalgic_chatterjee
(base) joanne@Joannes-MacBook-Pro test % docker commit 42d1793610e2 joanne-test3
sha256:64a6226a1b63ba23446c4ce414a4b1be3766ca2995a2a7aea33f00a0786741ce
(base) joanne@Joannes-MacBook-Pro test % docker tag bc/cert-issuer:1.0 jiyeonf/hku-ecert:joanne-test3
(base) joanne@Joannes-MacBook-Pro test % docker push jiyeonf/hku-ecert:joanne-test3
The push refers to repository [docker.io/jiyeonf/hku-ecert]
a32d238a849e: Layer already exists
977a8c2623ad: Layer already exists
bdedbe12c28e: Layer already exists
688b3098a132: Layer already exists
2d0796f5999b: Layer already exists
7f6ecd5076c5: Layer already exists
027b2ef9f47d: Layer already exists
ba1dadd0698c: Layer already exists
e6688e911f15: Layer already exists
joanne-test3: digest: sha256:7dafd5011bbaea447974f1f7646a2092db7ab920490af404760c51e478358900 size: 2203
(base) joanne@Joannes-MacBook-Pro test %
