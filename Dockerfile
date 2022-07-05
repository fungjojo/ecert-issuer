FROM lncm/bitcoind:v22.0
MAINTAINER Kim Duffy "kimhd@mit.edu"

USER root

COPY . /cert-issuer
COPY conf.ini /etc/cert-issuer/conf.ini

RUN apk add --update \
    bash \
    ca-certificates \
    curl \
    gcc \
    gmp-dev \
    libffi-dev \
    libressl-dev \
    libxml2-dev \
    libxslt-dev \
    linux-headers \
    make \
    musl-dev \
    python2 \
    python3 \
    python3-dev \
    tar \
    && python3 -m ensurepip \
    && pip3 install --upgrade pip setuptools \
    && pip3 install Cython \
    && pip3 install wheel \
    && mkdir -p /etc/cert-issuer/data/unsigned_certificates \
    && mkdir /etc/cert-issuer/data/blockchain_certificates \
    && pip3 install /cert-issuer/. \
    && pip3 install -r /cert-issuer/ethereum_requirements.txt \
    && rm -r /usr/lib/python*/ensurepip \
    && rm -rf /var/cache/apk/* \
    && rm -rf /root/.cache


ENTRYPOINT bitcoind -daemon && bash


