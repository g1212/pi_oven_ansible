Role Name
=========

Configure a raspberry pi to use as a network access point through ethernet, with the pi handling wireless connection

Requirements
------------

Any pre-requisites that may not be covered by Ansible itself or the role should be mentioned here. For instance, if the role uses the EC2 module, it may be a good idea to mention in this section that the boto package is required.

Role Variables
--------------

ip_prefix: prefix network address to use for the machine connecting to the pi


Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - role: rpi_proxy
           ip_prefix: 192.168.5

