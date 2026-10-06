# ubuntu on WSL: https://ubuntu.com/wsl/docs/stable/

# wsl commands https://learn.microsoft.com/en-us/windows/wsl/basic-commands

# wsl network setting
# https://learn.microsoft.com/en-us/windows/wsl/networking#identify-ip-address
#
# Identify IP address
# wsl hostname -I: Returns the IP address of your Linux distribution installed via WSL 2 (the WSL 2 VM address)
# ip route show | grep -i default | awk '{ print $3}': Returns the IP address of the Windows machine as seen from WSL 2 (the WSL 2 VM)
# For a more detailed explanation, see Accessing network applications with WSL: Identify IP Address.

alias wsll="wsl --list --verbose"
alias wsls="wsl --status"
alias wslt="wsl --terminate"
alias wslD="wsl --unregister"
alias wslT="wsl --shutdown"
# function wslif="wsl --install --from-file "

# export
# import
# import inplace

# https://learn.microsoft.com/en-us/windows/wsl/wsl2-mount-disk
# mount
# unmount

# https://learn.microsoft.com/en-us/windows/wsl/build-custom-distro
# https://ubuntu.com/wsl/docs/stable/howto/custom-ubuntu-distro/#howto-custom-distro
# custom build
