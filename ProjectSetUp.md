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
   ssh -i "20220703.pem" ubuntu@ec2-34-230-29-73.compute-1.amazonaws.com

# Ubuntu

1. fetch the block cert issuer project from git
   `git clone https://github.com/blockchain-certificates/cert-issuer.git`
2. change directory to the project root
   `cd cert-issuer`
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
    `docker run -it bc/cert-issuer:1.0 bash`

22. copy the input cert to the container etc folder
    `cp cert-issuer/data/unsigned_certificates/verifiable-credential.json etc/cert-issuer/data/unsigned_certificates/`

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
    `docker pull jiyeonf/hku-ecert:joanne-test3`

# Set up the server from docker image

1. download docker
   `sudo apt-get update`
   `sudo apt install docker.io`
2. login docker
   `docker login -u jiyeonf`
3. type in docker password (abcd1234!)
4. pull the remote image
   `docker pull jiyeonf/hku-ecert:joanne-test3`

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
