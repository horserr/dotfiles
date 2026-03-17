set -gx EDITOR nvim
set -gx VISUAL nvim

set -gx HOMEBREW_API_DOMAIN https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api
set -gx HOMEBREW_BREW_GIT_REMOTE https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git
set -gx HOMEBREW_BOTTLE_DOMAIN https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles
set -gx HOMEBREW_CORE_GIT_REMOTE https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git

set -gx RUSTUP_DIST_SERVER https://rsproxy.cn
set -gx RUSTUP_UPDATE_ROOT https://rsproxy.cn/rustup

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv fish)"