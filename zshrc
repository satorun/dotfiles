#!/bin/zsh

# コマンドの補完をキャッシュから再読み込み
zstyle ":completion:*:commands" rehash 1

#######
# PATH
#######
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
  /Library/Apple/usr/bin(N-/)
)

#######
# ALIAS
#######
alias python="python3"
alias ls="ls -FG"
alias la="ls -a"
alias ll="ls -l"
alias lla="ls -la"

#######
# PROMPT
#######
autoload -Uz colors && colors

# zsh-git-prompt
HAS_GIT_PROMPT=false
if type brew &>/dev/null; then
  if [ -f "$(brew --prefix)/opt/zsh-git-prompt/zshrc.sh" ]; then
    source $(brew --prefix)/opt/zsh-git-prompt/zshrc.sh
    HAS_GIT_PROMPT=true
  fi
fi

# プロンプト設定
if [[ $HAS_GIT_PROMPT == true ]]; then
  PROMPT='%F{034}%n%f %F{036}($(arch))%f:%F{075}%~%f $(git_super_status)'
else
  PROMPT='%F{034}%n%f %F{036}($(arch))%f:%F{075}%~%f'
fi
PROMPT+=$'\n'"%# "

# プロンプト前に改行を追加
add_newline() {
  if [[ -z $PS1_NEWLINE_LOGIN ]]; then
    PS1_NEWLINE_LOGIN=true
  else
    printf '\n'
  fi
}

# Gitリポジトリ内でプロンプトの色を変更
git_prompt() {
  if [ "$(git rev-parse --is-inside-work-tree 2> /dev/null)" = true ]; then
    if [[ $HAS_GIT_PROMPT == true ]]; then
      PROMPT='%F{034}%n%f %F{036}($(arch))%f:%F{020}%~%f $(git_super_status)'
    else
      PROMPT='%F{034}%n%f %F{036}($(arch))%f:%F{020}%~%f'
    fi
    PROMPT+=$'\n'"%# "
  else
    PROMPT="%F{034}%n%f %F{036}($(arch))%f:%F{020}%~%f "$'\n'"%# "
  fi
}

# precmd関数を安全に追加(他のプラグインと競合しないように)
precmd_functions+=(add_newline)
# git_prompt を有効化する場合は以下のコメントを解除
# precmd_functions+=(git_prompt)

#######
# COMPLETION
#######
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  autoload -Uz compinit
  compinit
fi

# 補完候補をリスト表示
zstyle ':completion:*' list-colors ''
setopt list_packed

#######
# AUTO-SUGGESTIONS
#######
# zsh-autosuggestions (brew install zsh-autosuggestions が必要)
if [ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

#######
# DEV TOOLS (環境依存 - 必要に応じて有効化)
#######

### nvm (Node.js version manager) ###
# export NVM_DIR="$HOME/.nvm"
# [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
# [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

### Volta (Node.js version manager - nvmの代替) ###
# export VOLTA_HOME="$HOME/.volta"
# export PATH="$VOLTA_HOME/bin:$PATH"

### direnv ###
# eval "$(direnv hook zsh)"

### Go ###
# export GOPATH=$HOME/go
# export GOROOT="$(brew --prefix golang)/libexec"
# export PATH=$PATH:$HOME/go/bin

### Haskell ###
# [ -f "$HOME/.ghcup/env" ] && source "$HOME/.ghcup/env"

### Ruby (rbenv) ###
# eval "$(rbenv init - zsh)"

### Python (conda/miniforge) ###
# __conda_setup="$('$HOME/miniforge3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     if [ -f "$HOME/miniforge3/etc/profile.d/conda.sh" ]; then
#         . "$HOME/miniforge3/etc/profile.d/conda.sh"
#     else
#         export PATH="$HOME/miniforge3/bin:$PATH"
#     fi
# fi
# unset __conda_setup

### Flutter (fvm) ###
# export PATH="$PATH:$HOME/development/flutter/bin:$HOME/fvm/default/bin"
# alias flutter="fvm flutter"
# alias dart="fvm dart"

### Dart CLI completion ###
# [[ -f $HOME/.dart-cli-completion/zsh-config.zsh ]] && . $HOME/.dart-cli-completion/zsh-config.zsh || true

### Custom tools ###
# [ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"
