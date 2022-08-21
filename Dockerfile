FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get clean && apt-get update && \
    apt-get install -y \
    build-essential gawk luajit flex git gettext \
    python3-distutils rsync unzip wget file \
    libncurses5-dev libssl-dev zlib1g-dev

RUN mkdir -p /root/.ssh
RUN chmod 644 /root/.ssh

# Add build user.
RUN useradd -ms /bin/bash build

# Create build directory.
RUN mkdir /build && chown build:build /build
WORKDIR /build

# Clone OpenWRT.
USER build
RUN git clone https://git.openwrt.org/openwrt/openwrt.git
WORKDIR /build/openwrt

# Update the feeds.
RUN ./scripts/feeds update -a
RUN ./scripts/feeds install -a

CMD ["bash"]
