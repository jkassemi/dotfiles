export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

plugins=(git docker docker-compose pyenv kubectx kubectl kube-ps1)
source $ZSH/oh-my-zsh.sh

alias k="kubectl"
alias vim="nvim"
alias vimam="nvim \$(git status --porcelain | grep '^\\s*[AM]' | awk '{print \$2}')"

RPS1='k8s:$(kube_ps1) py:$(pyenv_prompt_info)'
bindkey -v
