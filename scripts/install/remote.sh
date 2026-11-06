#!/bin/sh
# 远程安装 chezmoi 单文件二进制, 并直接 init + apply dotfiles
#   本地下载 -> 校验 -> 解压 -> ssh 流式上传 -> chezmoi init --apply
#
# 用法: ./remote.sh [--no-apply] <host|user@host> [user] [version]
#
# 1. SSH config 别名（端口/密钥/Jump 全自动）
#    ./remote.sh myserver
# 2. 指定用户 + 指定版本
#    ./remote.sh myserver deploy 2.74.0
# 3. user@host / 裸 IP
#    ./remote.sh root@192.168.1.10
#    ./remote.sh 192.168.1.10 root
# 4. 只装二进制, 不 init/apply
#    ./remote.sh --no-apply myserver
# 5. 验证
#    ssh myserver '~/.local/bin/chezmoi --version'
#
# 环境变量:
#   REMOTE_BIN_DIR  安装目录（相对远端 $HOME，默认 .local/bin）
#   CHEZMOI_REPO    初始化仓库（默认 https://github.com/horserr/dotfiles）
#   CHEZMOI_ARGS    追加给 init/apply 的参数（如 --dry-run）
#   SSH_OPTS        额外 ssh 参数；本机 ssh 支持连接复用时可用:
#                   SSH_OPTS="-o ControlMaster=auto -o ControlPath=/tmp/cm-%C -o ControlPersist=60"
#
# 密码提示: 全程只建 3 条连接（探测 / 上传 / init+apply），默认交互式 apply。
# 想彻底免密码: ssh-copy-id <host>。
#
# 注意: Windows 上若提示 Permission denied，用 `bash scripts/install/remote.sh ...` 或先 `chmod +x`。

set -eu

REMOTE_BIN_DIR="${REMOTE_BIN_DIR:-.local/bin}" # 相对远程 $HOME
CHEZMOI_REPO="${CHEZMOI_REPO:-https://github.com/horserr/dotfiles}"
CHEZMOI_ARGS="${CHEZMOI_ARGS:-}"
SSH_OPTS="${SSH_OPTS:-}"

TMP="$(mktemp -d)"
trap 'rm -rf -- "$TMP"' EXIT
trap 'exit 1' INT TERM

log() { printf '%s\n' "$*" >&2; }
die() {
	log "错误: $*"
	exit 1
}

# 所有 ssh 调用统一入口，方便复用连接（SSH_OPTS）
# shellcheck disable=SC2086 # SSH_OPTS 需按空格拆分
ssh_run() { ssh $SSH_OPTS "$@"; }

# 可选 flag
APPLY=1
while [ "$#" -gt 0 ]; do
	case "$1" in
	--no-apply | --install-only) APPLY=0 ;;
	--apply) APPLY=1 ;;
	--) shift && break ;;
	-*) die "未知选项: $1（可用: --no-apply）" ;;
	*) break ;;
	esac
	shift
done

HOST="${1:?用法: $0 [--no-apply] <host|user@host> [user] [version]}"
USER_ARG="${2:-}"
VERSION="${3:-latest}"

# 目标: host / user@host / host + 显式 user
case "$HOST" in
*@*) REMOTE="$HOST" ;;
*)
	if [ -n "$USER_ARG" ]; then
		REMOTE="${USER_ARG}@${HOST}"
	else
		REMOTE="$HOST" # 完全依赖 ~/.ssh/config
	fi
	;;
esac

# 本地下载: fetch <url> <dest>，dest 为 - 时输出到 stdout
fetch() {
	if command -v curl >/dev/null 2>&1; then
		curl -fsSL --retry 2 --retry-delay 1 -o "$2" "$1"
	elif command -v wget >/dev/null 2>&1; then
		wget -q -O "$2" "$1"
	else
		die "本地需要 curl 或 wget"
	fi
}

sha256_of() {
	if command -v sha256sum >/dev/null 2>&1; then
		sha256sum "$1" | cut -d' ' -f1
	elif command -v shasum >/dev/null 2>&1; then
		shasum -a 256 "$1" | cut -d' ' -f1
	elif command -v openssl >/dev/null 2>&1; then
		openssl dgst -sha256 "$1" | awk '{ print $NF }'
	else
		die "本地需要 sha256sum / shasum / openssl"
	fi
}

# ---------- 0. 确定版本 ----------
if [ "$VERSION" = latest ]; then
	log ">>> 查询最新版本"
	VERSION="$(fetch https://api.github.com/repos/twpayne/chezmoi/releases/latest - |
		sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"v\{0,1\}\([^"]*\)".*/\1/p' | head -n 1)"
fi
VERSION="${VERSION#v}"
case "$VERSION" in
'' | *[!0-9.]*) die "无法确定版本号（得到 '$VERSION'），请显式指定" ;;
esac
log "    版本=$VERSION"

# ---------- 1. 一次性探测远程环境（脚本走 stdin，避免本地/远端引号地狱） ----------
log ">>> 探测远程环境: $REMOTE"
# 远程输出: <uname-m> <glibc|musl> <glibc-version>
REMOTE_INFO="$(
	ssh_run "$REMOTE" sh -s <<'REMOTE_PROBE_EOF'
set -u
arch=$(uname -m | tr '[:upper:]' '[:lower:]')
libc=''
glibc_version=''
if command -v ldd >/dev/null 2>&1; then
	ldd_out=$(ldd --version 2>&1 | tr '[:upper:]' '[:lower:]')
	case "$ldd_out" in
	*musl*) libc=musl ;;
	*glibc* | *'gnu libc'*)
		libc=glibc
		glibc_version=$(printf '%s\n' "$ldd_out" | awk '$1 == "ldd" { print $NF; exit }')
		;;
	esac
fi
if [ -z "$libc" ] && command -v getconf >/dev/null 2>&1; then
	case "$(getconf GNU_LIBC_VERSION 2>&1 | tr '[:upper:]' '[:lower:]')" in
	*glibc*)
		libc=glibc
		glibc_version=$(getconf GNU_LIBC_VERSION 2>/dev/null | awk '{ print $NF; exit }')
		;;
	esac
fi
if [ -z "$libc" ] && grep -qi '^ID=alpine' /etc/os-release 2>/dev/null; then
	libc=musl
fi
if [ -z "$libc" ]; then
	if ls /lib/ld-musl-*.so.1 >/dev/null 2>&1; then libc=musl; else libc=glibc; fi
fi
printf '%s %s %s\n' "$arch" "$libc" "${glibc_version:-}"
REMOTE_PROBE_EOF
)"

# 只取形如 "<arch> <libc> ..." 的行，容忍远端 banner/motd 干扰
probe_field() {
	printf '%s\n' "$REMOTE_INFO" | awk -v n="$1" '$2 ~ /^(glibc|musl)$/ { print $n; exit }'
}
REMOTE_ARCH="$(probe_field 1)"
REMOTE_LIBC="$(probe_field 2)"
REMOTE_GLIBC="$(probe_field 3)"
[ -n "$REMOTE_ARCH" ] || die "无法解析远程信息: $REMOTE_INFO"
[ -n "$REMOTE_LIBC" ] || die "无法识别远程 libc: $REMOTE_INFO"

# 官方二进制基于 glibc 2.35 构建；更旧的 glibc 回退静态链接的 musl 版
if [ "$REMOTE_LIBC" = glibc ] && [ -n "$REMOTE_GLIBC" ]; then
	case "$REMOTE_GLIBC" in
	[0-9]*.[0-9]*)
		ver="$(printf '%s' "$REMOTE_GLIBC" | sed 's/[^0-9.].*//; s/\.*$//')"
		if awk -v a="$ver" -v b='2.35' 'BEGIN { split(a, x, "."); split(b, y, "."); exit !((x[1] + 0) < (y[1] + 0) || ((x[1] + 0) == (y[1] + 0) && (x[2] + 0) < (y[2] + 0))) }'; then
			log "    提示: glibc $ver < 2.35，改用 musl 静态版"
			REMOTE_LIBC=musl
		fi
		;;
	esac
fi
log "    架构=$REMOTE_ARCH  libc=$REMOTE_LIBC${REMOTE_GLIBC:+  (glibc $REMOTE_GLIBC)}"

# ---------- 2. 映射到 chezmoi 发布包名 ----------
# 资产名形如 chezmoi_<ver>_linux[-glibc|-musl]_<arch>.tar.gz
case "$REMOTE_ARCH" in
x86_64 | amd64) ARCH=amd64 ;;
aarch64 | arm64) ARCH=arm64 ;;
armv5*) ARCH=armv5 ;;
armv6* | armv7* | arm*) ARCH=armv6 ;; # 官方没有 armv7 构建，用 armv6
mips64le*) ARCH=mips64le_hardfloat ;;
mips64*) ARCH=mips64_hardfloat ;;
i386 | i486 | i586 | i686 | x86) ARCH=i386 ;; # 注意资产是 i386，不是 386
loongarch64 | loong64) ARCH=loong64 ;;
ppc64le) ARCH=ppc64le ;;
ppc64) ARCH=ppc64 ;;
riscv64) ARCH=riscv64 ;;
s390x) ARCH=s390x ;;
*) die "不支持的架构: $REMOTE_ARCH" ;;
esac

BASE="https://github.com/twpayne/chezmoi/releases/download/v${VERSION}"
SUMS="chezmoi_${VERSION}_checksums.txt"

# amd64 区分 glibc/musl；旧版本可能只有不带后缀的 linux_amd64
if [ "$ARCH" = amd64 ]; then
	CANDIDATES="chezmoi_${VERSION}_linux-${REMOTE_LIBC}_amd64.tar.gz chezmoi_${VERSION}_linux_amd64.tar.gz"
else
	CANDIDATES="chezmoi_${VERSION}_linux_${ARCH}.tar.gz"
fi

# ---------- 3. 下载 + 校验 + 解压 ----------
TAR=''
for cand in $CANDIDATES; do
	log ">>> 下载 $cand"
	if fetch "$BASE/$cand" "$TMP/$cand" 2>/dev/null; then
		TAR="$cand"
		break
	fi
	log "    跳过（不存在）: $cand"
done
[ -n "$TAR" ] || die "没有找到适配 $REMOTE_ARCH/$REMOTE_LIBC 的发布包"

log ">>> 校验 $SUMS"
fetch "$BASE/$SUMS" "$TMP/$SUMS"

want="$(awk -v f="$TAR" '$NF == f { print $1; exit }' "$TMP/$SUMS")"
got="$(sha256_of "$TMP/$TAR")"
[ -n "$want" ] || die "$SUMS 中没有 $TAR 的校验值"
[ "$want" = "$got" ] || die "$TAR 校验失败 (want=$want got=$got)"
log "    校验通过"

tar -xzf "$TMP/$TAR" -C "$TMP" chezmoi
[ -f "$TMP/chezmoi" ] || die "发布包中没有 chezmoi 二进制"
chmod +x "$TMP/chezmoi"

# ---------- 4. 上传 + 赋权 + 版本校验（一次连接，二进制走 ssh stdin） ----------
R_FILE="$REMOTE_BIN_DIR/chezmoi"
log ">>> 上传到 $REMOTE:~/$R_FILE"
# 用 `ssh 'cat > file'` 流式上传: 比 scp/rsync 少一次认证，也不依赖本地 scp/rsync
ssh_run "$REMOTE" "
set -e
mkdir -p \"\$HOME/$REMOTE_BIN_DIR\"
f=\"\$HOME/$R_FILE\"
cat > \"\$f\"
chmod 755 \"\$f\"
\"\$f\" --version
case \":\$PATH:\" in
*\":\$HOME/$REMOTE_BIN_DIR:\"*) ;;
*) echo \"提示: ~/$REMOTE_BIN_DIR 不在 PATH，建议加到 shell 配置\" ;;
esac
" <"$TMP/chezmoi" || die "上传/校验失败，请检查 ~/$R_FILE"

# ---------- 5. init + apply ----------
if [ "$APPLY" -eq 1 ]; then
	if [ -t 0 ] && [ -t 1 ]; then
		APPLY_TTY='-t' # 交互式: 让 .chezmoi.toml.tmpl 的 prompt* 生效
	else
		APPLY_TTY='' # 非交互: 使用模板默认值
	fi
	log ">>> 在远程执行 chezmoi init --apply（$CHEZMOI_REPO）"
	# shellcheck disable=SC2086 # APPLY_TTY 需要按空格展开
	ssh_run $APPLY_TTY "$REMOTE" "
set -e
export PATH=\"\$HOME/$REMOTE_BIN_DIR:\$PATH\"
src=\$(chezmoi source-path)
if [ -n \"\$src\" ] && [ -d \"\$src\" ] && [ -n \"\$(ls -A \"\$src\" 2>/dev/null)\" ]; then
	echo '>>> 已初始化，执行 chezmoi apply'
	chezmoi apply $CHEZMOI_ARGS
else
	chezmoi init --apply $CHEZMOI_REPO $CHEZMOI_ARGS
fi
" || die "chezmoi init/apply 失败"
else
	log ">>> 已跳过 init/apply（--no-apply）"
fi

log ">>> 完成。验证: ssh $REMOTE '~/$R_FILE --version'"
