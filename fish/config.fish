# Path to your oh-my-fish.
set fish_path $HOME/.oh-my-fish

for config_file in $HOME/.config/fish/load/*.fish
  source $config_file
end

set PATH /usr/local/bin $PATH
set PATH /usr/local/sbin $PATH
set PATH $HOME/.bin $PATH

# Everything in moderation
set -xg NO_SIMPLECOV true

# Node
set PATH /usr/local/share/npm/bin $PATH

# Docker
set -xg DOCKER_HOST tcp://172.16.42.43:4243
set fish_git_dirty_color red
source $fish_path/oh-my-fish.fish

# Vim
set -xg EDITOR /usr/local/bin/vim

# No phoning home by default
set -xg HOMEBREW_NO_ANALYTICS 1
