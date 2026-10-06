SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

for f in $SCRIPT_DIR/windows/**/*.sh; do
  # 确保它是一个普通文件（防止匹配到空目录）
  if [ -f "$f" ]; then
    source "$f"
  fi
done
