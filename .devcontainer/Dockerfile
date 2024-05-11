FROM rust:bullseye

RUN apt update && apt upgrade -y
RUN apt install -y gcc-mingw-w64

RUN rustup target add x86_64-pc-windows-gnu
RUN rustup toolchain install stable-x86_64-pc-windows-gnu

RUN rustup target add i686-pc-windows-gnu
RUN rustup toolchain install stable-i686-pc-windows-gnu

RUN rustup target add i686-unknown-linux-gnu
RUN rustup toolchain install stable-i686-unknown-linux-gnu

#WORKDIR /app

#CMD ["cargo", "build", "--target", "x86_64-pc-windows-gnu"]
