# dev-env CI base image
# Reproduces the SAME runtime versions as runtime/.tool-versions + runtime/global.json + runtime/rust-toolchain.toml.
# Build from the repo root:  docker build -f docker/Dockerfile -t dev-env-ci:latest .
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# ----- base system + CLI tools (mirrors Brewfile / winget set) -----
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl git gnupg dirmngr gpg build-essential \
      zip unzip ripgrep bat fd-find git-delta jq gh eza \
      software-properties-common \
      libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
      wget llvm libncurses5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
      libffi-dev liblzma-dev pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Debian/Ubuntu names the fd binary fdfind; expose it as fd
RUN ln -sf "$(command -v fdfind)" /usr/local/bin/fd || true

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
