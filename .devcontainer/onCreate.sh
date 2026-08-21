#!/bin/bash
set -e

# 初始化变量
APT_MIRROR=""
SOURCES_FILE=""

# 解析命令行参数
while getopts "m:f:h" opt; do
  case $opt in
    m)
      APT_MIRROR="$OPTARG"
      ;;
    f)
      SOURCES_FILE="$OPTARG"
      ;;
    h)
      echo "Usage: $0 [-m <mirror_url>] [-f <sources_file>]"
      echo "  -m: Mirror URL (optional, if not set, script will skip mirror replacement)"
      echo "  -f: Specific sources file path (optional)"
      echo "  -h: Show this help"
      exit 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      echo "Use -h for help" >&2
      exit 1
      ;;
  esac
done

# 如果 APT_MIRROR 为空，直接退出
if [ -z "${APT_MIRROR}" ]; then
  echo "No mirror specified, skipping mirror replacement"
  exit 0
fi

# 如果指定了文件，直接使用该文件
if [ -n "${SOURCES_FILE}" ] && [ -f "${SOURCES_FILE}" ]; then
  echo "Using specified sources file: ${SOURCES_FILE}"
  # 检测文件格式并相应处理
  if [[ "${SOURCES_FILE}" == *.sources ]]; then
    # DEB822 格式
    sudo sed -i "s|URIs: .*|URIs: ${APT_MIRROR}|g" "${SOURCES_FILE}"
  else
    # 传统格式
    sudo sed -i "s|http://archive.ubuntu.com/ubuntu/|${APT_MIRROR}/|g" "${SOURCES_FILE}"
    sudo sed -i "s|http://security.ubuntu.com/ubuntu/|${APT_MIRROR}/|g" "${SOURCES_FILE}"
  fi

# 1. 处理 Ubuntu 24.04+ 的 DEB822 格式 (.sources)
elif [ -f "/etc/apt/sources.list.d/ubuntu.sources" ]; then
  echo "Detected DEB822 format (Ubuntu 24.04+)"
  sudo sed -i "s|URIs: .*|URIs: ${APT_MIRROR}|g" /etc/apt/sources.list.d/ubuntu.sources

# 2. 处理 Ubuntu 22.04- 的传统格式 (.list)
elif [ -f "/etc/apt/sources.list" ]; then
  echo "Detected traditional format (Ubuntu 22.04-)"
  sudo sed -i "s|http://archive.ubuntu.com/ubuntu/|${APT_MIRROR}/|g" /etc/apt/sources.list
  sudo sed -i "s|http://security.ubuntu.com/ubuntu/|${APT_MIRROR}/|g" /etc/apt/sources.list
else
  echo "Warning: No sources file found" >&2
  exit 1
fi

echo "Mirror replacement completed successfully"

sudo apt update && sudo apt upgrade -y
