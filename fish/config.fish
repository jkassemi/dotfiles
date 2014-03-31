# Path to your oh-my-fish.
set fish_path $HOME/.oh-my-fish

for config_file in $HOME/.config/fish/load
  . $config_file
end

set PATH /usr/local/bin $PATH
set PATH /usr/local/sbin $PATH

set PATH $HOME/.bin $PATH
#
# RBenv
set PATH $HOME/.rbenv/bin $PATH
set PATH $HOME/.rbenv/shims $PATH
rbenv rehash >/dev/null ^&1

set RUBY_HEAP_MIN_SLOTS 800000
set RUBY_HEAP_FREE_MIN 100000
set RUBY_HEAP_SLOTS_INCREMENT 300000
set RUBY_HEAP_SLOTS_GROWTH_FACTOR 1
set RUBY_GC_MALLOC_LIMIT 79000000

# Node
set PATH /usr/local/share/npm/bin $PATH

# Golang

set -xg GOROOT /usr/local/go/
set -xg GOPATH $HOME/Documents/mygo 
set -xg PATH $GOPATH $PATH
set -xg PATH /usr/local/go/bin $PATH
set -xg PATH $HOME/Documents/mygo/bin $PATH
set -xg DOCKER_HOST tcp://172.16.42.43:4243

# Inwater completions
#jset -g fish_complete_path  $fish_complete_path ~/.config/fish/fish-inwater/completions
#set -g fish_function_path  ~/.config/fish/fish-inwater/functions $fish_function_path
#set -gx PATH $PATH  ~/.config/fish/fish-inwater/bin

# this is optional
#     set -g fish_function_path  $fish_function_path ~/.config/fish/fish-inwater/shortcuts

#complete -c rake -a "test:units test:functionals test:integration"

set fish_git_dirty_color red

#function parse_git_dirty 
#   git diff --quiet HEAD ^&-
#   if test $status = 1
#      echo (set_color $fish_git_dirty_color)"Δ"(set_color normal)
#   end
#end

#function parse_git_branch
#   set -l branch (git rev-parse --abbrev-ref HEAD)
#   echo $branch (parse_git_dirty)     
#end

#function fish_prompt
#   if test -z (git branch --quiet 2>| awk '/fatal:/ {print "no git"}')
#    printf '%s@%s %s%s%s (%s) $ ' (whoami) (hostname|cut -d . -f 1) (set_color $fish_color_cwd) (prompt_pwd) (set_color normal) (parse_git_branch)            
#   else
#    printf '%s@%s %s%s%s $ '  (whoami) (hostname|cut -d . -f 1) (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
#   end 
#end

. $fish_path/oh-my-fish.fish
