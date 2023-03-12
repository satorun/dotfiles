#!/bin/zsh

# Homebrew
if ! (type brew > /dev/null 2>&1); then
  xcode-select --install
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

cd $(dirname $0)
echo "pwd: $(pwd)"

## How to update .Brewfile:
## brew bundle dump --global --force
if [ ! -e ~/.Brewfile ]; then
  cp Brewfile ~/.Brewfile
  brew bundle
fi

if [ ! -e ~/.zshrc ]; then
  cp zshrc ~/.zshrc

  ## pre cmd
  chmod -R go-w /opt/homebrew/share

  echo "source ~/.zshrc"
  source ~/.zshrc 
  echo "complete!"

  ## post cmd
  rm -f ~/.zcompdump; compinit
fi
