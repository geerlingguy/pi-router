# Pi Router

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

For the Waveshare board, I made sure USB Ethernet support was added (`kmod-usb-net` and `kmod-usb-net-lan78xx` were selected by default), and then I also selected the `kmod-usb-net-sierrawireless` option under Kernel modules > USB support.

I also selected `Broadcom BCM27xx` for the Target System, and `BCM 2711 Boards (64 bit)` for the Subtarget.

Then, run the `make` command to compile OpenWRT:

```
make -j $(nproc) kernel_menuconfig
```

And finally, build the image:

```
make -j $(nproc) download world
make -j $(nproc)
```

## Flashing the OpenWRT Image

After `make` is finished, you should have a file named `openwrt-bcm27xx-bcm2711-rpi-4-ext4-factory.img.gz` inside `/build/openwrt/bin`.

You will need to flash that image file to the Raspberry Pi to boot OpenWRT.

> There is also a `ext4-sysupgrade` image file; this file can be used to upgrade an already-built OpenWRT system.

TODO.

## Author

Jeff Geerling
