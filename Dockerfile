ARG ALPINE_VERSION=latest
FROM alpine:${ALPINE_VERSION}

ARG FREP_VERSION=1.3.12
ARG S6_OVERLAY_VERSION=2.2.0.3

RUN wget -qO - https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-amd64.tar.gz | tar -xzf - -C / && \
  wget -q https://github.com/subchen/frep/releases/download/v${FREP_VERSION}/frep-${FREP_VERSION}-linux-amd64 -O /usr/bin/frep && \
  chmod +x /usr/bin/frep

RUN apk update && \
  apk add iptables ip6tables openssl strongswan && \
  rm -rf /var/cache/apk/* && \
  ln -sf /etc/ipsec.d/secrets /etc/ipsec.secrets

EXPOSE 500/udp 4500/udp

COPY rootfs /

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
  S6_SERVICES_GRACETIME=10000 \
  S6_KILL_GRACETIME=6000 \
  STRONGSWAN_CA_O=strongSwan \
  STRONGSWAN_CA_C=US \
  STRONGSWAN_CA_CN='strongSwan Root CA' \
  STRONGSWAN_HOST_CN= \
  STRONGSWAN_CLIENTS= \
  STRONGSWAN_CLIENTS_P12_PASSWORD=123 \
  STRONGSWAN_IKE_CIPHERS=aes256gcm16-prfsha512-ecp384,aes128-sha256-ecp256,aes256-sha384-ecp384,aes128-sha256-modp2048,aes128-sha1-modp2048,aes256-sha384-modp4096,aes256-sha256-modp4096,aes256-sha1-modp4096,aes128-sha256-modp1536,aes128-sha1-modp1536,aes256-sha384-modp2048,aes256-sha256-modp2048,aes256-sha1-modp2048,aes128-sha256-modp1024,aes128-sha1-modp1024,aes256-sha384-modp1536,aes256-sha256-modp1536,aes256-sha1-modp1536,aes256-sha384-modp1024,aes256-sha256-modp1024,aes256-sha1-modp1024! \
  STRONGSWAN_ESP_CIPHERS=aes256gcm16-ecp384,aes128gcm16-ecp256,aes256gcm16-ecp384,aes128-sha256-ecp256,aes256-sha384-ecp384,aes128-sha256-modp2048,aes128-sha1-modp2048,aes256-sha384-modp4096,aes256-sha256-modp4096,aes256-sha1-modp4096,aes128-sha256-modp1536,aes128-sha1-modp1536,aes256-sha384-modp2048,aes256-sha256-modp2048,aes256-sha1-modp2048,aes128-sha256-modp1024,aes128-sha1-modp1024,aes256-sha384-modp1536,aes256-sha256-modp1536,aes256-sha1-modp1536,aes256-sha384-modp1024,aes256-sha256-modp1024,aes256-sha1-modp1024,aes128gcm16,aes256gcm16,aes128-sha256,aes128-sha1,aes256-sha384,aes256-sha256,aes256-sha1! \
  STRONGSWAN_ENABLE_IPV6=1 \
  STRONGSWAN_LOG_LEVEL=2 \
  STRONGSWAN_IP_POOL= \
  STRONGSWAN_IP6_POOL= \
  STRONGSWAN_DNS= \
  STRONGSWAN_DNS6= \
  STRONGSWAN_REDUCE_MTU=0 \
  STRONGSWAN_DROP_BETWEEN_CLIENTS=true \
  STRONGSWAN_BLOCK_SMB=true \
  STRONGSWAN_BLOCK_NETBIOS=true

VOLUME /etc/ipsec.d

ENTRYPOINT ["/init"]
