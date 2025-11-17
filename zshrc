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

# Add ~/.local/bin to PATH if not already present
if [[ -d "$HOME/.local/bin" ]] && [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

#######
# ALIAS
#######
alias python="python3"
alias ls="ls -FG"
alias la="ls -a"
alias ll="ls -l"
alias lla="ls -la"

#######
# gitwt (Git worktree management)
#######
wtgo() { cd "$(gitwt-path "$1")" }
wtback() {
  local repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
  if [[ -z "$repo_root" ]]; then
    echo "Error: Not in a git repository" >&2
    return 1
  fi

  # Check if we're in a worktree by checking if repo_root is under _wt/
  if [[ "$repo_root" == */_wt/* ]]; then
    # We're in a worktree
    # repo_root is like: .../_wt/<repo_name>/<branch>
    # Original repo is at: .../<repo_name>
    local wt_dir=$(dirname "$repo_root")  # .../_wt/<repo_name>
    local wt_base=$(dirname "$wt_dir")    # .../_wt
    local wt_parent=$(dirname "$wt_base") # ... (parent of _wt)
    local repo_name=$(basename "$wt_dir")  # <repo_name>
    local original_repo="$wt_parent/$repo_name"

    if [[ ! -d "$original_repo" ]]; then
      echo "Error: Original repository not found at $original_repo" >&2
      return 1
    fi

    cd "$original_repo"
  else
    # We're already in the original repository
    cd "$repo_root"
  fi
}

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
    PROMPT="%F{034}%n%f %F{036}($(arch))%f:%F{075}%~%f "$'\n'"%# "
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
# DEV TOOLS (環境依存 - インストールされていれば自動的に有効化)
#######

### mise (統合開発ツールバージョンマネージャー) ###
if [ -f "$HOME/.local/bin/mise" ]; then
  eval "$("$HOME/.local/bin/mise" activate zsh)"
  export PATH="$HOME/.local/share/mise/shims:$PATH"
fi

### nvm (Node.js version manager) ###
if [ -s "/opt/homebrew/opt/nvm/nvm.sh" ]; then
  export NVM_DIR="$HOME/.nvm"
  \. "/opt/homebrew/opt/nvm/nvm.sh"
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
fi

### Volta (Node.js version manager - nvmの代替) ###
if [ -d "$HOME/.volta" ]; then
  export VOLTA_HOME="$HOME/.volta"
  export PATH="$VOLTA_HOME/bin:$PATH"
fi

### direnv ###
if type direnv &>/dev/null; then
  eval "$(direnv hook zsh)"
fi

### Go ###
if type go &>/dev/null; then
  export GOPATH=$HOME/go
  if type brew &>/dev/null && [ -d "$(brew --prefix golang)/libexec" ]; then
    export GOROOT="$(brew --prefix golang)/libexec"
  fi
  export PATH=$PATH:$HOME/go/bin
fi

### Haskell ###
[ -f "$HOME/.ghcup/env" ] && source "$HOME/.ghcup/env"

### Ruby (rbenv) ###
if type rbenv &>/dev/null; then
  eval "$(rbenv init - zsh)"
fi

### Python (conda/miniforge) ###
if [ -f "$HOME/miniforge3/bin/conda" ]; then
  __conda_setup="$('$HOME/miniforge3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
  if [ $? -eq 0 ]; then
    eval "$__conda_setup"
  else
    if [ -f "$HOME/miniforge3/etc/profile.d/conda.sh" ]; then
      . "$HOME/miniforge3/etc/profile.d/conda.sh"
    else
      export PATH="$HOME/miniforge3/bin:$PATH"
    fi
  fi
  unset __conda_setup
fi

### Flutter (fvm) ###
if [ -d "$HOME/fvm/default/bin" ]; then
  export PATH="$PATH:$HOME/development/flutter/bin:$HOME/fvm/default/bin"
  alias flutter="fvm flutter"
  alias dart="fvm dart"
fi

### Dart CLI completion ###
[ -f "$HOME/.dart-cli-completion/zsh-config.zsh" ] && . "$HOME/.dart-cli-completion/zsh-config.zsh"

### Custom tools ###
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

### Kiro (Terminal App) ###
[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)" 2>/dev/null
