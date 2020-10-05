# pi_oven

This repo automates configurations for rapberry pi devices, including provisioning pi os images in headless mode, automatically connecting to wifi and configuring ssh from first boot.

So far:

    * Pi OS image writer
    * Pi wifi proxy
    * K3s Installer

The later due to an issue with a laptop, meaning ethernet connection to RPi is needed, for RPi to then handle wifi.

## Getting Started

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

1. Change inventory of `pi3_group` as appropriate, using your pi's IP.
2. Run `make k3s`
3. Verify success by running `kubectl get pods --all-namespaces` from your local machine.