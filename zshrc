zstyle ":completion:*:commands" rehash 1

# path
typeset -U path PATH
path=(
  /opt/homebrew/bin(N-/)
  /opt/homebrew/sbin(N-/)
  /usr/bin
  /usr/sbin
  /bin
  /sbin
  /usr/local/bin(N-/)
  /usr/local/sbin(N-/)
  /Library/Apple/usr/bin
  ~/node_modules/.bin
)


# alias
alias python="python3"
# -F でファイル種別の表示
# -G で色を付ける (GNU/Linux での "--color=auto" と等価)
alias ls="ls -FG"
alias la="ls -a"
alias ll="ls -l"
alias lla="ls -la"


# prompt
autoload -Uz colors && colors
source $(brew --prefix)/opt/zsh-git-prompt/zshrc.sh

PROMPT='%F{034}%n%f %F{036}($(arch))%f:%F{075}%~%f $(git_super_status)'
PROMPT+=""$'\n'"%# "

add_newline() {
  if [[ -z $PS1_NEWLINE_LOGIN ]]; then
    PS1_NEWLINE_LOGIN=true
  else
    printf '\n'
  fi
}

git_prompt() {
  if [ "$(git rev-parse --is-inside-work-tree 2> /dev/null)" = true ]; then
    PROMPT='%F{034}%n%f %F{036}($(arch))%f:%F{020}%~%f $(git_super_status)'
    PROMPT+=""$'\n'"%# "
  else
    PROMPT="%F{034}%n%f %F{036}($(arch))%f:%F{020}%~%f "$'\n'"%# "
  fi
}

precmd() {
#  git_prompt
  add_newline
}


# zsh-complietions, zsh-autosuggestions
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  autoload -Uz compinit
  compinit
fi

# Customize to your needs...
export GOPATH=$HOME/go
export GOROOT="$(brew --prefix golang)/libexec"
export PATH=$PATH:$HOME/go/bin
alias rmdd='rm -rf ~/Library/Developer/Xcode/DerivedData/*'

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/satorun/miniforge3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/satorun/miniforge3/etc/profile.d/conda.sh" ]; then
        . "/Users/satorun/miniforge3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/satorun/miniforge3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


export PATH="$PATH:/Users/satorun/development/flutter/bin"
eval "$(rbenv init - zsh)"
