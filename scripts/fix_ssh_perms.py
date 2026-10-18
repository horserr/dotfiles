#!/usr/bin/env python3
import os
import pathlib


def fix_ssh_permissions():
    ssh_dir = pathlib.Path.home() / ".ssh"

    if not ssh_dir.exists() or not ssh_dir.is_dir():
        print(f"Error: folder not found: {ssh_dir}")
        return

    print(f"dir: {ssh_dir}")

    # 1. 设置 .ssh 目录权限为 700 (drwx------)
    os.chmod(ssh_dir, 0o700)

    # 2. 遍历并修复子项
    for path in ssh_dir.rglob("*"):
        if path.is_dir():
            # 子目录设为 700
            os.chmod(path, 0o700)
        elif path.is_file():
            filename = path.name
            # 判断是否为私钥或敏感文件（没有 .pub 后缀的 id_ 开头文件，或者特定敏感文件名）
            is_private_key = (
                filename.startswith("id_") and not filename.endswith(".pub")
            ) or filename in ["authorized_keys", "known_hosts", "config"]

            if is_private_key:
                os.chmod(path, 0o600)  # -rw-------
                print(f"设置私钥/敏感文件 (600): {path.name}")
            else:
                os.chmod(path, 0o644)  # -rw-r--r--
                print(f"设置普通文件 (644): {path.name}")

    print("✅ Finish!")


if __name__ == "__main__":
    fix_ssh_permissions()
