Dual-stack VyOS Zone based Firewall Generator
=============================================

A ruby script to generate the boilerplate for a dual-stack VyOS zone based firewall.


Zones:

* PRIVATE: contains the LAN and WAN modem admin interface
* PUBLIC: The Internet - contains the PPPoE interface
* DMZ: contain the DMZ interface for servers
* LOCAL: The firewall itself
