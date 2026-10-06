sshCommand="ssh"
sshAddCommand="ssh-add"
sshKeyGenCommand="ssh-keygen"

if [[ "$OS" == "Windows_NT" ]]; then
# if [[ "$OSTYPE" == "cygwin" ]]; then
    sshCommand="/c/Windows/System32/OpenSSH/ssh.exe"
    sshAddCommand="/c/Windows/System32/OpenSSH/ssh-add.exe"
    sshKeyGenCommand="/c/Windows/System32/OpenSSH/ssh-keygen.exe"

    # 模拟 ssh-copy-id 函数，强制使用 Windows 原生 ssh
    #  ssh-copy-id user@192.168.1.100                           # 使用默认的 id_ed25519.pub
    # ssh-copy-id ~/.ssh/id_rsa.pub user@192.168.1.100         # 指定特定公钥
    ssh-copy-id() {
        local keyfile="${1:-$HOME/.ssh/id_ed25519.pub}"
        local target="$2"

        # 如果只传了一个参数（例如：ssh-copy-id user@ip）
        if [ -z "$target" ]; then
            target="$1"
            keyfile="$HOME/.ssh/id_ed25519.pub"
        fi

        if [ ! -f "$keyfile" ]; then
            echo "Error: cannot find public key $keyfile"
            return 1
        fi

        echo "Uploading $keyfile to $target ..."
        cat "$keyfile" | /c/Windows/System32/OpenSSH/ssh.exe "$target" \
            "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
    }
fi

alias ssh="$sshCommand"
alias ssh-add="$sshAddCommand"
alias ssh-keygen="$sshKeyGenCommand"

alias sshkeyed="$sshKeyGenCommand -t ed25519 -C"

# ssh no command
alias sshn="$sshCommand -N"
# ssh require tty, mainly for running sudo commands and visual program, such as vim, top, tmux
alias ssht="$sshCommand -t"
# ssh no pseudo terminal
alias sshnt="$sshCommand -T"
# ssh background running
alias sshf="$sshCommand -f"
# ssh remove key
alias sshkeyd="$sshKeyGenCommand -R"

# ssh folder state reset
# link: https://linuxize.com/post/ssh-folder-files-and-permissions/#reset-ssh-permissions
ssh-mode-reset() {
    chmod 700 ~/.ssh
    find ~/.ssh -maxdepth 1 -type f -name 'id_*' ! -name '*.pub' -exec chmod 600 {} +
    find ~/.ssh -maxdepth 1 -type f -name '*.pub' -exec chmod 644 {} +
    for file in authorized_keys config; do
        [ -e "$HOME/.ssh/$file" ] && chmod 600 "$HOME/.ssh/$file"
    done
    [ -e ~/.ssh/known_hosts ] && chmod 644 ~/.ssh/known_hosts
}
