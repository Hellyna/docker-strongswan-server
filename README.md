# hellyna/strongswan-server 🔐

An IKEv2 VPN adapted from [trailofbits/algo](https://github.com/trailofbits/algo), with complete support for IPv6

## Features ✨

- Complete IPv6 support
- Auto generation of identites.
- Authentication are by certificates only.
- Generate `.mobileconfig` for import in iOS and macOS devices.
- Generate PKCS12 store `.p12` for easy usage in android devices.

# Requirements

- Minimum kernel version: 5.8 for IPv6 support. ([Reference](https://serverfault.com/questions/1046623/received-netlink-error-invalid-argument-when-trying-to-connect-using-ipv6)
- Docker daemon started with [ipv6 support](https://docs.docker.com/config/daemon/ipv6/).
- [robbertkl/ipv6nat](https://github.com/robbertkl/docker-ipv6nat) started and configured.
- Domain name pointed to the server.

# Quickstart (`docker-compose`) 💯

These environment variables are required:
+ `STRONGSWAN_HOST_CN` - The domain name of the server you have pointed in the requirements.
+ `STRONGSWAN_IP_POOL` - IPv4 pool which you wish to allocate to the VPN clients.
+ `STRONGSWAN_IP6_POOL` - IPv6 pool which you wish to allocate to the VPN clients.
+ `STRONGSWAN_CLIENTS` - VPN client identities to generate.
+ `STRONGSWAN_DNS` - DNS server to use for the VPN clients.

```yaml
version: '2.4'
services:
  strongswan-server:
    image: quiexotic/strongswan-server
    restart: unless-stopped
    cap_add:
      - NET_ADMIN
    networks:
      strongswan-server:
    environment:
      STRONGSWAN_CLIENTS: robert-ipad robert-computer alice-thinkpad
      STRONGSWAN_HOST_CN: my.happy.domain.example.com
      STRONGSWAN_IP_POOL: 192.168.14.0/24
      STRONGSWAN_IP6_POOL: fd00:14:1:1::/97
      STRONGSWAN_DNS: 1.1.1.1
    sysctls:
      net.ipv4.ip_forward: 1
      net.ipv4.conf.all.forwarding: 1
      net.ipv6.conf.all.forwarding: 1
      net.ipv4.conf.all.accept_redirects: 0
      net.ipv4.conf.all.send_redirects: 0
      net.ipv4.ip_no_pmtu_disc: 1
    volumes:
      - strongswan-server-conf:/etc/ipsec.d:Z
    ports:
      - 500:500/udp
      - 4500:4500/udp
  ipv6-nat:
    image: robbertkl/ipv6nat
    restart: unless-stopped
    network_mode: host
    depends_on:
      - ipv6-nat-docker-proxy
    cap_drop:
      - ALL
    cap_add:
      - NET_ADMIN
      - NET_RAW
      - SYS_MODULE
    environment:
      DOCKER_HOST: tcp://127.0.14.7:27000
    volumes:
      - /lib/modules:/lib/modules:ro
    command:
      - -cleanup
      - -retry
      - -debug
  ipv6-nat-docker-proxy:
    image: quiexotic/docker-socket-proxy
    restart: unless-stopped
    networks:
      ipv6-nat-docker-proxy:
    environment:
      GET_NETWORKS: 1
      GET_CONTAINERS: 1
    ports:
      - 127.0.14.7:27000:2375/tcp
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro

volumes:
  strongswan-server-conf:

networks:
  strongswan-server:
  ipv6-nat-docker-proxy:
```

All files will be generated in the `/etc/ipsec.d` directory.

With this configuration, 3 identities will be generated under `certs` and `private`. The files generated are:
- `certs/<identity>-cert.pem`
- `private/<identity>-key.pem`
- `private/<identity>.p12` encrypted by `STRONGSWAN_P12_PASSWORD`, default is `123`.
- `private/<identity>.mobileconfig`. This is the mobileconfig profile you can use with your iOS or macOS devices.

Additonally, the CA certificate will be generated in `cacerts/ca-cert.pem`.

Re-generation of any file will occur if they didn't exist.

# Notes

For macOS/iOS mobileconfig, the LocalIdentifier can only be a plain domain name (ie megan-ipad) and not an email address or anything else. See https://wiki.strongswan.org/projects/strongswan/wiki/AppleIKEv2Profile

Also for macOS/iOS mobileconfig, the server `leftid` must be set to the server's domain name used to generate the `host-cert.pem`.

Since that is licensed under AGPLv3, this project is also licensed under that as well.
