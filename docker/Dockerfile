# dev-env CI base image
# Reproduces the SAME runtime versions as runtime/.tool-versions + runtime/global.json + runtime/rust-toolchain.toml.
# Build from the repo root:  docker build -f docker/Dockerfile -t dev-env-ci:latest .
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# ----- base system packages -----
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl git gnupg dirmngr gpg build-essential \
      software-properties-common \
      zip unzip jq \
      libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
      wget llvm libncurses5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
      libffi-dev liblzma-dev pkg-config \
    && rm -rf /var/lib/apt/lists/*

# ----- CLI tools that mirror the winget/Brewfile set -----
# ripgrep/bat/fd-find live in universe; bat provides 'batcat', fd-find provides 'fdfind'
RUN add-apt-repository -y universe \
    && apt-get update \
    && apt-get install -y --no-install-recommends ripgrep bat fd-find \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf "$(command -v fdfind)" /usr/local/bin/fd \
    && ln -sf "$(command -v batcat)" /usr/local/bin/bat || true

# GitHub CLI (official apt repository)
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod 644 /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends gh \
    && rm -rf /var/lib/apt/lists/*

# git-delta (GitHub release .deb)
ARG DELTA_VERSION=0.19.2
RUN curl -fsSL "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/git-delta_${DELTA_VERSION}_amd64.deb" -o /tmp/git-delta.deb \
    && dpkg -i /tmp/git-delta.deb || (apt-get update && apt-get install -f -y --no-install-recommends) \
    && rm -f /tmp/git-delta.deb

# eza (GitHub release binary)
ARG EZA_VERSION=0.23.5
RUN curl -fsSL "https://github.com/eza-community/eza/releases/download/v${EZA_VERSION}/eza_x86_64-unknown-linux-gnu.tar.gz" -o /tmp/eza.tar.gz \
    && tar -xzf /tmp/eza.tar.gz -C /usr/local/bin eza \
    && chmod +x /usr/local/bin/eza \
    && rm -f /tmp/eza.tar.gz

# ----- asdf (runtime version manager) -----
ENV ASDF_ROOT=/opt/asdf
ENV PATH=$ASDF_ROOT/shims:$ASDF_ROOT/bin:$PATH
RUN git clone https://github.com/asdf-vm/asdf.git $ASDF_ROOT --branch v0.14.1
RUN asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git \
 && asdf plugin add python https://github.com/danhper/asdf-python.git \
 && asdf plugin add java https://github.com/halcyon/asdf-java.git \
 && asdf plugin add golang https://github.com/asdf-community/asdf-golang.git \
 && asdf plugin add rust https://github.com/asdf-community/asdf-rust.git

# Copy the team's pinned versions and install them (single source of truth)
COPY runtime/.tool-versions /opt/asdf/.tool-versions
WORKDIR /opt/asdf
RUN asdf install
WORKDIR /

# ----- .NET SDK (version pinned in runtime/global.json) -----
COPY runtime/global.json /tmp/global.json
RUN DOTNET_VERSION=$(jq -r '.sdk.version' /tmp/global.json) \
 && curl -fsSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh \
 && chmod +x /tmp/dotnet-install.sh \
 && /tmp/dotnet-install.sh --version "$DOTNET_VERSION" --install-dir /usr/share/dotnet \
 && ln -s /usr/share/dotnet/dotnet /usr/local/bin/dotnet \
 && rm -f /tmp/dotnet-install.sh /tmp/global.json

# ----- non-root user -----
ARG USERNAME=dev
RUN useradd -m -s /bin/bash "$USERNAME" \
 && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/"$USERNAME"
USER $USERNAME
ENV PATH=$ASDF_ROOT/shims:$ASDF_ROOT/bin:$PATH
WORKDIR /workspace

CMD ["/bin/bash"]
