# WSL SSH Agent Bridge (Windows -> WSL)
if status is-interactive
    set -gx SSH_AUTH_SOCK "$HOME/.ssh/agent.sock"

    # 检查 Socket 是否已经存在且有效
    if not ss -lnx | grep -q "$SSH_AUTH_SOCK"
        # 自动清理过时的无效 Socket 文件
        rm -f "$SSH_AUTH_SOCK"

        # 动态查找 Windows PATH 中的 npiperelay.exe
        set -l npiperelay_path (command -v npiperelay.exe)

        if test -n "$npiperelay_path"
            # 使用 nohup 和 setsid 让进程在后台静默运行
            # 这里的 2>/dev/null 是为了防止 socat 的启动输出干扰终端
            nohup socat UNIX-LISTEN:"$SSH_AUTH_SOCK",fork \
                EXEC:"$npiperelay_path -ei -s //./pipe/openssh-ssh-agent",nofork >/dev/null 2>&1 &

            # 记得脱离任务控制，防止关闭 shell 时杀死进程
            disown
        else
            echo "Warning: npiperelay.exe not found in Windows PATH."
        end
    end
end
