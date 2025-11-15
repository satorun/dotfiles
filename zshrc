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
# gitwt関数: add/backサブコマンド実行後に自動的にディレクトリに移動
gitwt() {
  if [[ $# -eq 0 ]]; then
    command gitwt
    return $?
  fi

  local subcommand="$1"
  shift
  
  if [[ "$subcommand" == "add" ]]; then
    # gitwt add の場合、実行後にworktreeディレクトリに移動
    # stdoutとstderrを分離して処理
    local stdout_file=$(mktemp)
    local stderr_file=$(mktemp)
    
    # コマンドを実行
    command gitwt add "$@" > "$stdout_file" 2> "$stderr_file"
    local exit_code=$?
    
    # stderrを先に表示（エラーメッセージなど）
    if [[ -s "$stderr_file" ]]; then
      cat "$stderr_file" >&2
    fi
    
    # stdoutを表示
    if [[ -s "$stdout_file" ]]; then
      cat "$stdout_file"
      
      # 成功時、最後の行がworktreeパスか確認
      if [[ $exit_code -eq 0 ]]; then
        local wt_path
        wt_path=$(tail -n 1 "$stdout_file" 2>/dev/null | tr -d '\r\n')
        
        # パスが存在し、ディレクトリで、絶対パスであることを確認
        if [[ -n "$wt_path" ]] && [[ "$wt_path" == /* ]] && [[ -d "$wt_path" ]]; then
          cd "$wt_path"
        fi
      fi
    fi
    
    # 一時ファイルを削除
    rm -f "$stdout_file" "$stderr_file"
    
    return $exit_code
  elif [[ "$subcommand" == "back" ]]; then
    # gitwt back の場合、実行後に元のリポジトリディレクトリに移動
    local output
    output=$(command gitwt back "$@" 2>&1)
    local exit_code=$?
    
    # エラーがある場合は表示して終了
    if [[ $exit_code -ne 0 ]]; then
      echo "$output" >&2
      return $exit_code
    fi
    
    # パスを取得（最後の行、改行を削除）
    local repo_path
    repo_path=$(echo "$output" | tail -n 1 | tr -d '\r\n')
    
    # 出力を表示
    echo "$output"
    
    # パスが存在し、ディレクトリであることを確認して移動
    if [[ -n "$repo_path" ]] && [[ -d "$repo_path" ]]; then
      cd "$repo_path"
    fi
    
    return $exit_code
  else
    # その他のサブコマンドは通常通り実行
    command gitwt "$subcommand" "$@"
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
