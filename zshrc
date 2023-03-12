#!/bin/bash

### alias ###
alias ls="ls -FG"
alias la="ls -a"
alias ll='ls -al'

alias python="python3"

### zsh-git-prompt ###
source /opt/homebrew/opt/zsh-git-prompt/zshrc.sh

### PROMPT ###
autoload -Uz colors && colors
git_prompt() {
  if [ "$(git rev-parse --is-inside-work-tree 2> /dev/null)" = true ]; then
    PROMPT="%F{green}%n%f %F{cyan}($(arch))%f:%F{blue}%~%f $(git_super_status)"$'\n'"%# "
  else
    PROMPT="%F{green}%n%f %F{cyan}($(arch))%f:%F{blue}%~%f"$'\n'"%# "
  fi
}

add_newline() {
  if [[ -z $PS1_NEWLINE_LOGIN ]]; then
    PS1_NEWLINE_LOGIN=true
  else
    printf '\n'
  fi
}

precmd() {
  git_prompt
  add_newline
}

### zsh-completions ###
if type brew &>/dev/null; then
  FPATH=/opt/homebrew/share/zsh-completions:$FPATH
  autoload -Uz compinit && compinit
fi

### zsh-autosuggestions ###
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
autoload colors
zstyle ':completion:*' list-colors ''
setopt list_packed

#######
# DEV
######
### nvm ###
export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

### direnv ###
eval "$(direnv hook zsh)"

### Haskell ###
[ -f "/Users/satorun/.ghcup/env" ] && source "/Users/satorun/.ghcup/env" # ghcup-env
