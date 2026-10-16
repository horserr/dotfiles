# change apt mirror
ARG APT_MIRROR="http://mirrors.nju.edu.cn/ubuntu/"

RUN <<EOF
  set -e
  if [ -n "${APT_MIRROR}" ]; then
    if [ -f "/etc/apt/sources.list.d/ubuntu.sources" ]; then
      echo "Detected DEB822 format (Ubuntu 24.04+)"
      sed -i "s|URIs: .*|URIs: ${APT_MIRROR}|g" /etc/apt/sources.list.d/ubuntu.sources
    elif [ -f "/etc/apt/sources.list" ]; then
      echo "Detected traditional format (Ubuntu 22.04-)"
      sed -i "s|http://archive.ubuntu.com/ubuntu/|${APT_MIRROR}|g" /etc/apt/sources.list
      sed -i "s|http://security.ubuntu.com/ubuntu/|${APT_MIRROR}|g" /etc/apt/sources.list
    fi
  fi
EOF
