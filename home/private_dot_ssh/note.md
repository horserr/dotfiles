# SSH common problems

## [SSH Connection Refused: Causes and Fixes](https://linuxize.com/post/fix-ssh-connection-refused/)

## [SSH Permission Denied (publickey): Causes and Fixes](https://linuxize.com/post/fix-ssh-permission-denied-publickey/)

| Problem                              | Fix                               |
| :----------------------------------- | :-------------------------------- |
| Key not on server                    | ssh-copy-id user@host             |
| Wrong permissions on ~/.ssh          | chmod 700 ~/.ssh                  |
| Wrong permissions on authorized_keys | chmod 600 ~/.ssh/authorized_keys  |
| Wrong permissions on private key     | chmod 600 ~/.ssh/id_ed25519       |
| SSH agent not running                | eval "$(ssh-agent -s)" && ssh-add |
| Wrong key offered                    | ssh -i ~/.ssh/key user@host       |
| SELinux blocking access              | sudo restorecon -R ~/.ssh         |
| Check auth log (Ubuntu)              | sudo tail -f /var/log/auth.log    |
| Debug SSH connection                 | ssh -vvv user@host                |

## [Fix SSH "Host Key Verification Failed" Error](https://linuxize.com/post/fix-ssh-host-key-verification-failed/)

| Task                                  | Command                    |
| :------------------------------------ | :------------------------- | ---------------- |
| Remove a host entry                   | ssh-keygen -R hostname     |
| Remove by IP                          | ssh-keygen -R 192.168.1.10 |
| Show the server’s new key fingerprint | ssh-keyscan host           | ssh-keygen -lf - |
| known_hosts file (user)               | ~/.ssh/known_hosts         |
| known_hosts file (system)             | /etc/ssh/ssh_known_hosts   |
