Dual-stack VyOS Zone based Firewall Generator
=============================================

A ruby script to generate a dual-stack zone based firewall for [VyOS].

VyOS currently handles IPv4 and IPv6 firewall rules separately (this mirrors the underlying iptables in the Linux kernel). This means that if you want to allow connections to your web server on port 80 on both IPv4 and IPv6, you need to create two rules. This creates a management overhead and risk of inconsistencies between IPv4 and IPv6.


How the script works
--------------------

The dual-stack configuration is abstracted into a JSON configuration file. The script reads in that JSON file and outputs VyOS configuration. Either as a configuration snippet, or as commands to run on the VyOS router.

The `zones` section allows you to define the zones that make up your firewall. There are different names you might give for your zones, but you might have `PRIVATE` (your LAN), `PUBLIC` (the internet), `DMZ` (servers accessible from the internet) and `LOCAL` (the firewall itself). You must allow say which network interfaces belong in which zone.

```
  "zones": {
    "PRIVATE": {
      "description": "The local private LAN",
      "interfaces": ["eth0"]
    },
    "PUBLIC": {
      "description": "The Internet",
      "interfaces": ["eth1"]
    }
  }
```

The `default-actions` section describes the default action to take for packets being transmitted between zones. For example you would probably want to `drop` or `reject` packets from the public Internet to your LAN using `PRIVATE-from-PUBLIC`.

```
  "default-actions": {
    "PRIVATE-from-PUBLIC": "reject",
    "PUBLIC-from-PRIVATE": "accept"
  }
```

The `aliases` section allows you to define the addresses associated with hosts, so that you don't have to keep repeating IP addresses in the rules. You can then use the alias name in place of `source-address` or `destination-address`.

```
  "aliases": {
    "server1": [
      "203.0.113.40",
      "2001:0DB8:DEAD::40"
    ]
  }
```

Finally, the `rules` section allows you to define custom firewall rules for packets being transmitted between zones. For example allowing connections to a server in the DMZ on port 80 and 443 from the Internet.

```
  "rules": {
    "DMZ-from-PUBLIC": [
      {
        "description": "allow HTTP/HTTPS to server1 from the Internet",
        "action": "accept",
        "destination-address": "server1",
        "destination-port": [80, 443]
      }
    ]
  }
```


There is an example JSON file here: [firewall.json](/examples/firewall.json)

And example of the VyOS configuration that it generates here: [firewall-config.txt](/examples/firewall-config.txt)



[VyOS]:  https://www.vyos.net/

