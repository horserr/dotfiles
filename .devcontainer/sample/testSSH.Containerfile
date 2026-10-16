# Syntax=docker/dockerfile:1.4
# usage:
#   docker build -t ssh-connection .
#   docker run -d -p 2222:22 --name my-ssh-test ssh-connection
#   ssh root@localhost -p 2222
#   password: 123456

ARG TYPE=base
ARG VERSION=latest
FROM mcr.microsoft.com/devcontainers/${TYPE}:${VERSION}

LABEL version="1.0" \
  description="test ssh connection"

ENV DEBIAN_FRONTEND=noninteractive

# install openssh-server
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked <<EOF
  apt-get update && apt-get install -y --no-install-recommends \
    openssh-server \
    vim \
    iproute2 \
    net-tools
EOF

# configure sshd
RUN <<EOF
  set -e
  # 创建 sshd 运行时所需目录
  mkdir -p /var/run/sshd

  # 设置 root 密码为 123456 (仅用于测试)
  echo 'root:123456' | chpasswd

  # 修改 sshd_config 配置以允许 root 密码登录
  sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
  sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
  sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

  # 生成主机密钥 Host Key
  ssh-keygen -A
EOF

EXPOSE 22

# 启动 sshd 服务 (以非守护进程模式前台运行)
CMD ["/usr/sbin/sshd", "-D"]
