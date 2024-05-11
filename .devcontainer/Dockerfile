FROM rust:bullseye

ENV onescript_ver=1.9.0

RUN apt update && DEBIAN_FRONTEND=noninteractive \
    apt install -y --no-install-recommends gcc-mingw-w64 zip

RUN rustup target add x86_64-pc-windows-gnu
RUN rustup toolchain install stable-x86_64-pc-windows-gnu

RUN rustup target add i686-pc-windows-gnu
RUN rustup toolchain install stable-i686-pc-windows-gnu

RUN rustup target add i686-unknown-linux-gnu
RUN rustup toolchain install stable-i686-unknown-linux-gnu

# Install OneScript
ADD https://github.com/EvilBeaver/OneScript/releases/download/v${onescript_ver}/onescript-engine_${onescript_ver}_all.deb ./onescript-engine.deb
RUN DEBIAN_FRONTEND=noninteractive \
    apt install -y --no-install-recommends ./onescript-engine.deb
RUN rm onescript-engine.deb
RUN rm -rf /var/lib/apt/lists/*

# Install gsync
RUN opm install gitsync

# Set ssh key for github authentication
# RUN git config --global url.ssh://git@github.com/.insteadOf https://github.com/