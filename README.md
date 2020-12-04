# pi_oven

This repo automates configurations for rapberry pi devices, including provisioning pi os images in headless mode, automatically connecting to wifi and configuring ssh from first boot.

So far:

    * Pi OS image writer
    * Pi wifi proxy
    * K3s Installer

The later due to an issue with a laptop, meaning ethernet connection to RPi is needed, for RPi to then handle wifi.

## Getting Started - Ansible

The following makefile targets require ansible => 2.9.9.
### Image Writer

1. Change role defaults as appropriate, these won't need to be encrypted with vault, unless hosted in git.
    * rpi_pi_password - login for `pi` user, enrcrypted with `openssl passwd -6 mypass`
    * rpi_wifi_ssid - Wifi network name
    * rpi_wifi_pass -  Wifi network password, encrypted with `wpa_passphrase mynetwork mypass`
2. Insert a formatted SD card into your machine.
3. Run `make image`, this may ask for sudo password.

### Wifi Proxy

Assuming the pi is fully provisoned, connected to internet and ssh configured.

1. Change inventory as appropriate, using your pi's IP.
2. Open the Makefile, and change the `PRIVATE_KEY_PATH` variable as appropriate.
3. Run `make wifi`

### K3s

Assuming the pi is fully provisoned, connected to internet and ssh configured.
Also assumed `kubectl` is installed.

1. Change inventory in `k3s-ansible/inventory/sample/hosts.ini` as appropriate, using your pi's IP.
2. Run `make k3s-ansible`
3. Verify success by running `kubectl get pods --all-namespaces` from your local machine.

## Getting Started - Helm

Various makefile targets for deploying tools to the cluster. Requires helm version => 3.4. In the sections below it assumed you have a running cluster, with helm and kubectl installed locally.

### Namespaces

Before running any helm deployments, we need to create namespaces first. In helm v2, helm deployments used to create namespaces if they did not already exist. This is no longer the case in helm v3. So run the following:

    make namespaces

### K8s Dashboard

To help understand the state of the cluster at a glance, you may want to install the kubernetes dashboard.Run:

    make k8s-dashboard

### Pi Hole

#### Prerequisites

First off, we need the admin credentials stored in the cluster. Run the following to create a random admin password:

    make pihole-admin

This will deploy the pihole DNS sinkhole as a helm chart to the current cluster. To deploy this regularly, run:

    make pihole

You can then change your device DNS settings to use the pihole DNS.

In some cases, you will want the pihole to serve as a DNS server to all devices on the network. Normally, you can just add the pihole IP as a DNS server in the router settings. Unfortunately, virgin media don't allow this luxury, and as such pihole has to be deployed on the host network, handling all DHCP to also serve DNS.

To do this, run the following:

    make pihole-dhcp

Then once logged into pihole, alter the settings in the UI to serve DHCP.  Ensure DHCP is disabled in your router settings.

