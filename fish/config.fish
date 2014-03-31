# Path to your oh-my-fish.
set fish_path $HOME/.oh-my-fish

for config_file in $HOME/.config/fish/load
  . $config_file
end

set PATH /usr/local/bin $PATH
set PATH /usr/local/sbin $PATH
set PATH $HOME/.bin $PATH


# RBenv
set PATH $HOME/.rbenv/bin $PATH
set PATH $HOME/.rbenv/shims $PATH
rbenv rehash >/dev/null ^&1

# Node
set PATH /usr/local/share/npm/bin $PATH

# Golang

set -xg GOROOT /usr/local/go/
set -xg GOPATH $HOME/Documents/mygo 
set -xg PATH $GOPATH $PATH
set -xg PATH /usr/local/go/bin $PATH
set -xg PATH $HOME/Documents/mygo/bin $PATH
set -xg DOCKER_HOST tcp://172.16.42.43:4243

set fish_git_dirty_color red

. $fish_path/oh-my-fish.fish
