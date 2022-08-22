# Pi Router

[![Build](https://github.com/geerlingguy/pi-router/actions/workflows/ci.yml/badge.svg)](https://github.com/geerlingguy/pi-router/actions/workflows/ci.yml)

A Raspberry Pi router build for the [Waveshare CM4-DUAL-ETH-4G/5G-BOX](https://pipci.jeffgeerling.com/boards_cm/waveshare-dual-gb-ethernet-5g-4g-base-board.html), using the [Sierra Wireless EM7565 4G LTE modem](https://pipci.jeffgeerling.com/cards_network/sierra-wireless-em7565.html).

After borrowing my Dad's [Cradlepoint IBR900](https://cradlepoint.com/products/endpoints/#filter=.use_case_router_firewalls), I decided I wanted to build a similar style portable 4G access point/router/firewall.

I bought a [SixFab SIM](https://sixfab.com/sim/) and built a fast 4G router using Waveshare's dual Ethernet 4G/5G kit along with a Raspberry Pi Compute Module 4.

The build runs OpenWRT, but since it is a custom configuration, you have to manually compile an OpenWRT image to flash to the Pi's microSD card or eMMC storage.

## Bringing up the build environment

  1. Install Docker (and Docker Compose if not using Docker Desktop).
  1. Bring up the cross-compile environment:

     ```
     docker-compose up -d
     ```

  1. Log into the running container:

     ```
     docker attach openwrt-build
     ```

You will be dropped into a shell inside the container's `/build/openwrt` directory. From here you can work on compiling OpenWRT.

> After you `exit` out of that shell, the Docker container will stop, but will not be removed. If you want to jump back into it, you can run `docker start openwrt-build` and `docker attach openwrt-build`.

## Compiling OpenWRT

The container should have OpenWRT's source code checked out inside he `/build/openwrt` directory. If you would like, run `git pull` inside the directory to make sure the latest OpenWRT changes are present.

First, run the following command to open `menuconfig` and select options:

```
make menuconfig
```

Choose the Raspberry Pi BCM 2711 for the CM4 as the target platform:

  1. Target System: `Broadcom BCM27xx`
  2. Subtarget: `BCM 2711 Boards (64 bit)`

Then select additional packages and configuration. for the Waveshare board, I added the following options:

  1. USB Ethernet support for RTL8153: Kernel modules > USB Support > `kmod-usb-net-rtl8152`
  2. 4G LTE support for Sierra Wireless EM7565: Kernel modules > USB Support > `kmod-usb-net-sierrawireless`
  3. USB 2.0 and 3.0 Support: Kernel modules > USB Support > `kmod-usb2` (and `kmod-usb3`)
  4. Enable the LuCI Web UI with https: LuCI > 1. Collections > `luci-ssl`

(Make sure to choose the `[*] built-in` option, not `[M] module` option for each of the above selections.)

> TODO: I currently don't have all the /etc/config/network, /etc/config/dhcp, and /etc/config/wireless files set up in this repo—I should do that so I don't have to sit there configuring the router on first boot.

Then, if you would like to customize Linux kernel options, run the following command (this is often not necessary):

```
make -j $(nproc) kernel_menuconfig
```

And finally, compile OpenWRT and build the image:

```
make -j $(nproc)
```

## Flashing the OpenWRT Image

After `make` is finished, you should have a file named `openwrt-bcm27xx-bcm2711-rpi-4-ext4-factory.img.gz` inside `/build/openwrt/bin`.

You will need to flash that image file to the Raspberry Pi to boot OpenWRT.

> There is also a `ext4-sysupgrade` image file; this file can be used to upgrade an already-built OpenWRT system.

First, inside the Docker container, copy the build files out to the shared `images` folder:

```
cp /build/openwrt/bin/targets/bcm27xx/bcm2711/*.img.gz /images
```

Then, use [Raspberry Pi Imager](https://www.raspberrypi.com/software/), [Etcher](https://www.balena.io/etcher/), or some other image-writing tool to write the uncompressed `.img` file to a microSD card or the Pi's eMMC directly.

## First Boot

Plug in a USB-C power supply, and plug the ETH0 port into your computer (preferred) or network (this can cause issues). The default OpenWRT configuration sets up the router at 192.168.1.1, so visit that URL in the browser: https://192.168.1.1

On the first visit, you'll get an HTTPS certificate warning, which you can ignore. On the login page, use `root` for the username and leave the password field blank.

> You should set a strong password for the root account immediately, to keep your router secure!

TODO.

## Author

Jeff Geerling
