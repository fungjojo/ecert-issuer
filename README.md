[![Build Status](https://travis-ci.org/blockchain-certificates/cert-issuer.svg?branch=master)](https://travis-ci.org/blockchain-certificates/cert-issuer)
[![PyPI version](https://badge.fury.io/py/cert-issuer.svg)](https://badge.fury.io/py/cert-issuer)

# cert-issuer

The cert-issuer project issues blockchain certificates by creating a transaction from the issuing institution to the
recipient on the Bitcoin or Ethereum blockchains. That transaction includes the hash of the certificate itself.

Blockcerts v3 is released. This new version of the standard leverages the [W3C Verifiable Credentials specification](https://www.w3.org/TR/vc-data-model/), and documents are signed with [MerkleProof2019 LD signature](https://w3c-ccg.github.io/lds-merkle-proof-2019/). Use of [DIDs (Decentralized Identifiers)](https://www.w3.org/TR/did-core/) is also possible to provide more cryptographic proof of the ownership of the issuing address. See [section](#working-with-dids) down below

Cert-issuer v3 is _not_ backwards compatible and does not support Blockcerts v2 issuances. If you need to work with v2, you need to install cert-issuer v2 or use the [v2](https://github.com/blockchain-certificates/cert-issuer/tree/v2) branch of this repo.
You may expect little to no maintenance to the v2 code at this point.

## Citation

This repository is referencing [Blockcert cert-isser repository](https://github.com/blockchain-certificates/cert-issuer). Minor modification is done in the respository to adapt ethereum blockchain certification generation.
