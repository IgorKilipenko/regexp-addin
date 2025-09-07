# Multi-stage Dockerfile for RegExp AddIn development
FROM rust:1.89-bullseye AS base

# Environment variables
ENV onescript_ver=1.9.0
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies for cross-compilation
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Build essentials
    build-essential \
    pkg-config \
    libssl-dev \
    # Archive tools
    zip \
    unzip \
    # Git and version control
    git \
    # Development tools
    curl \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install MinGW for Windows cross-compilation
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc-mingw-w64-x86-64 \
    gcc-mingw-w64-i686 \
    && rm -rf /var/lib/apt/lists/*

# Install ARM64 cross-compilation (separate to avoid conflicts)
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc-aarch64-linux-gnu \
    && rm -rf /var/lib/apt/lists/*

# Install 32-bit support (separate to avoid conflicts)
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc-multilib \
    && rm -rf /var/lib/apt/lists/*

# Install Rust targets for all supported platforms
RUN rustup target add \
    # Windows targets
    x86_64-pc-windows-gnu \
    i686-pc-windows-gnu \
    # Linux targets
    x86_64-unknown-linux-gnu \
    i686-unknown-linux-gnu \
    aarch64-unknown-linux-gnu \
    # macOS targets (for future use)
    x86_64-apple-darwin \
    aarch64-apple-darwin

# Note: Cross-compilation toolchains are not needed as we only install targets
# The default toolchain can cross-compile to installed targets

# Install OneScript for 1C development
ADD https://github.com/EvilBeaver/OneScript/releases/download/v${onescript_ver}/onescript-engine_${onescript_ver}_all.deb ./onescript-engine.deb
RUN apt-get update && apt-get install -y --no-install-recommends ./onescript-engine.deb
RUN rm onescript-engine.deb

# Install OneScript packages
RUN opm install gitsync

# Development stage
FROM base AS development

# Install additional development tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Code quality tools
    clang-format \
    # Debugging tools
    gdb \
    # Network tools
    net-tools \
    # Text editors
    vim \
    nano \
    # Process monitoring
    htop \
    # File utilities
    tree \
    jq \
    # Cleanup
    && rm -rf /var/lib/apt/lists/*

# Install Rust development tools
RUN rustup component add \
    rustfmt \
    clippy \
    rust-src

# Install useful cargo extensions
RUN cargo install \
    cargo-audit \
    cargo-outdated \
    cargo-tree \
    cargo-expand

# Set up git configuration
RUN git config --global init.defaultBranch main
RUN git config --global pull.rebase false

# Create workspace directory
WORKDIR /workspace

# Copy project files
COPY . .

# Set up the project
RUN make setup

# Verify installation
RUN make check-deps

# Test build to ensure everything works
RUN make build-linux-arm64

# Default command
CMD ["/bin/bash"]
