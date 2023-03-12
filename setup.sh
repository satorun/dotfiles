#!/bin/zsh

# Homebrew
if ! (type brew > /dev/null 2>&1); then
  xcode-select --install
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

cd $(dirname $0)
echo "pwd: $(pwd)"

### Brewfile
## How to update .Brewfile:
## brew bundle dump --global --force
if [ ! -e ~/.Brewfile ]; then
  echo "cp .Brewfile"
  cp Brewfile ~/.Brewfile
  brew bundle
fi

### .zshrc
if [ ! -e ~/.zshrc ]; then
  echo "cp .zshrc"
  cp zshrc ~/.zshrc

  ## pre cmd
  chmod -R go-w /opt/homebrew/share

  echo "source ~/.zshrc"
  source ~/.zshrc
  echo "complete!"

  ## post cmd
  rm -f ~/.zcompdump; compinit
fi


### .zshrc
if [ ! -e ~/.vimrc ]; then
  echo "cp .vimrc"
  cp vimrc ~/.vimrc
fi
