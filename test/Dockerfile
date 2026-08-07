FROM ubuntu:latest

ARG APT_MIRROR=""
ARG TARGET_FILE="/etc/apt/sources.list.d/ubuntu.sources"

ENV DEBIAN_FRONTEND=noninteractive

RUN <<EOF
  set -e
  if [ -n ${APT_MIRROR} ]; then
    # 1. 处理 Ubuntu 24.04+ 的 DEB822 格式 (.sources)
    if [ -f "/etc/apt/sources.list.d/ubuntu.sources" ]; then
      echo "Detected DEB822 format (Ubuntu 24.04+)"
      sed -i "s|URIs: .*|URIs: ${APT_MIRROR}|g" /etc/apt/sources.list.d/ubuntu.sources

    # 2. 处理 Ubuntu 22.04- 的传统格式 (.list)
    elif [ -f "/etc/apt/sources.list" ]; then
      echo "Detected traditional format (Ubuntu 22.04-)"
      # 替换官方默认域名（archive.ubuntu.com 和 security.ubuntu.com）
      sed -i "s|http://archive.ubuntu.com/ubuntu/|${APT_MIRROR}/|g" /etc/apt/sources.list
      sed -i "s|http://security.ubuntu.com/ubuntu/|${APT_MIRROR}/|g" /etc/apt/sources.list
    fi
  fi
EOF

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked <<EOF
  apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    wget \
    curl
EOF
