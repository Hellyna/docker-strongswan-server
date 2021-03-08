# hellyna/strongswan-server

An IKEv2 VPN adapted from [trailofbits/algo](https://github.com/trailofbits/algo)

Since that is licensed until AGPLv3, this project is also licensed under that as well.

Documentation will come in the near future.

# Requirements

Minimum kernel version: 5.8 for ipv6 support.

See this link: https://serverfault.com/questions/1046623/received-netlink-error-invalid-argument-when-trying-to-connect-using-ipv6

# Notes

For macOS/iOS mobileconfig, the LocalIdentifier can only be a plain domain name (ie megan-ipad) and not an email address or anything else. See https://wiki.strongswan.org/projects/strongswan/wiki/AppleIKEv2Profile

Also for macOS/iOS mobileconfig, the server `leftid` must be set to the server's domain name used to generate the `host-cert.pem`.
