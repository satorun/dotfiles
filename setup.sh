#!/bin/zsh
set -e  # エラー時に即座に終了

# カラー出力用
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo_error() {
  echo "${RED}[ERROR]${NC} $1" >&2
}

echo_success() {
  echo "${GREEN}[SUCCESS]${NC} $1"
}

echo_info() {
  echo "${BLUE}[INFO]${NC} $1"
}

echo_warn() {
  echo "${YELLOW}[WARN]${NC} $1"
}

# スクリプトのディレクトリに移動
cd "$(dirname "$0")"
DOTFILES_DIR=$(pwd)
echo_info "Dotfiles directory: $DOTFILES_DIR"

#######
# Homebrew
#######
echo_info "Checking Homebrew..."
if ! (type brew > /dev/null 2>&1); then
  echo_info "Installing Homebrew..."

  # Xcode Command Line Tools
  if ! xcode-select -p > /dev/null 2>&1; then
    echo_info "Installing Xcode Command Line Tools..."
    xcode-select --install
    echo_warn "Please complete Xcode Command Line Tools installation, then run this script again."
    exit 0
  fi

  # Homebrew本体
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # PATH設定（Apple Silicon）
  eval "$(/opt/homebrew/bin/brew shellenv)"

  echo_success "Homebrew installed"
else
  echo_success "Homebrew already installed"
fi

#######
# Brewfile
#######
echo_info "Checking Brewfile packages..."

# Brewfileから必要なパッケージを抽出
REQUIRED_PACKAGES=$(grep '^brew ' "$DOTFILES_DIR/Brewfile" | awk '{print $2}' | tr -d '"')

# 現在インストール済みのパッケージ
INSTALLED_PACKAGES=$(brew list --formula)

# 差分を確認
MISSING_PACKAGES=()
INSTALLED_FROM_BREWFILE=()

for pkg in $REQUIRED_PACKAGES; do
  if echo "$INSTALLED_PACKAGES" | grep -q "^${pkg}$"; then
    INSTALLED_FROM_BREWFILE+=($pkg)
  else
    MISSING_PACKAGES+=($pkg)
  fi
done

# 結果表示
if [ ${#INSTALLED_FROM_BREWFILE[@]} -gt 0 ]; then
  echo_success "Already installed: ${INSTALLED_FROM_BREWFILE[@]}"
fi

if [ ${#MISSING_PACKAGES[@]} -gt 0 ]; then
  echo_info "Missing packages: ${MISSING_PACKAGES[@]}"
  read "?Install missing packages? (y/N): " answer
  if [[ "$answer" == "y" ]] || [[ "$answer" == "Y" ]]; then
    brew install ${MISSING_PACKAGES[@]}
    echo_success "Packages installed"
  else
    echo_warn "Skipped package installation"
  fi
else
  echo_success "All Brewfile packages are already installed"
fi

#######
# zshrc
#######
echo_info "Setting up zshrc..."
if [ ! -e ~/.zshrc ]; then
  echo_info "Copying zshrc to ~/.zshrc"
  cp "$DOTFILES_DIR/zshrc" ~/.zshrc
  echo_success "zshrc installed"
else
  echo_warn "~/.zshrc already exists (skipped)"
fi

# zsh補完のパーミッション修正（"insecure directories"警告を防ぐ）
echo_info "Fixing zsh completion directory permissions..."
if [ -d "$(brew --prefix)/share" ]; then
  # 親ディレクトリの権限修正
  chmod go-w "$(brew --prefix)/share" 2>/dev/null || true
  # zsh関連ディレクトリの権限を再帰的に修正
  chmod -R go-w "$(brew --prefix)/share/zsh"* 2>/dev/null || true
  echo_success "Directory permissions fixed"
fi

# zsh補完キャッシュの削除（次回起動時に再構築される）
if [ -f ~/.zcompdump ]; then
  echo_info "Removing zsh completion cache..."
  rm -f ~/.zcompdump
  echo_success "Completion cache removed (will be rebuilt on next shell startup)"
fi

#######
# vimrc
#######
echo_info "Setting up vimrc..."
if [ ! -e ~/.vimrc ]; then
  echo_info "Copying vimrc to ~/.vimrc"
  cp "$DOTFILES_DIR/vimrc" ~/.vimrc
  echo_success "vimrc installed"
else
  echo_warn "~/.vimrc already exists (skipped)"
fi

#######
# gitconfig
#######
echo_info "Setting up gitconfig..."
if [ ! -e ~/.gitconfig ]; then
  echo_info "Copying gitconfig to ~/.gitconfig"
  cp "$DOTFILES_DIR/gitconfig" ~/.gitconfig
  echo_success "gitconfig installed"
else
  echo_warn "~/.gitconfig already exists (skipped)"
fi

# gitignore_global
echo_info "Setting up gitignore_global..."
if [ ! -e ~/.gitignore_global ]; then
  if [ -e "$DOTFILES_DIR/gitignore_global" ]; then
    echo_info "Copying gitignore_global to ~/.gitignore_global"
    cp "$DOTFILES_DIR/gitignore_global" ~/.gitignore_global
    echo_success "gitignore_global installed"
  else
    echo_error "gitignore_global not found in $DOTFILES_DIR"
  fi
else
  echo_warn "~/.gitignore_global already exists (skipped)"
fi

# プロジェクトディレクトリ
echo_info "Setting up project directories..."
if [ ! -e ~/project ]; then
  echo_info "Creating ~/project/work and ~/project/other"
  mkdir -p ~/project/work
  mkdir -p ~/project/other
  echo_success "Project directories created"
else
  echo_success "Project directories already exist"
fi

# gitconfig-work
echo_info "Setting up gitconfig-work..."
if [ ! -e ~/.gitconfig-work ]; then
  if [ -e "$DOTFILES_DIR/gitconfig-work" ]; then
    echo_info "Copying gitconfig-work to ~/.gitconfig-work"
    cp "$DOTFILES_DIR/gitconfig-work" ~/.gitconfig-work
    echo_warn "Please update ~/.gitconfig-work with your work credentials"
  else
    echo_info "Creating gitconfig-work template"
    cat > ~/.gitconfig-work <<EOF
[user]
  name = YOUR_NAME
  email = YOUR_WORK_EMAIL
EOF
    echo_warn "Please update ~/.gitconfig-work with your work credentials"
  fi
  echo_success "gitconfig-work created"
else
  echo_success "~/.gitconfig-work already exists"
fi

# gitconfig-other
echo_info "Setting up gitconfig-other..."
if [ ! -e ~/.gitconfig-other ]; then
  if [ -e "$DOTFILES_DIR/gitconfig-other" ]; then
    echo_info "Copying gitconfig-other to ~/.gitconfig-other"
    cp "$DOTFILES_DIR/gitconfig-other" ~/.gitconfig-other
    echo_warn "Please update ~/.gitconfig-other with your personal credentials"
  else
    echo_info "Creating gitconfig-other template"
    cat > ~/.gitconfig-other <<EOF
[user]
  name = YOUR_NAME
  email = YOUR_PERSONAL_EMAIL
EOF
    echo_warn "Please update ~/.gitconfig-other with your personal credentials"
  fi
  echo_success "gitconfig-other created"
else
  echo_success "~/.gitconfig-other already exists"
fi

#######
# 完了
#######
echo ""
echo_success "Setup completed!"
echo ""
echo_info "Next steps:"
echo "  1. Restart your terminal or run: source ~/.zshrc"
echo "  2. Update ~/.gitconfig-work with your work credentials"
echo "  3. Update ~/.gitconfig-other with your personal credentials"
echo "  4. (Optional) Enable development tools in ~/.zshrc by uncommenting them"
echo ""
echo_info "To verify installation:"
echo "  - zsh plugins: ls \$(brew --prefix)/share | grep zsh"
echo "  - git config: git config --list"
echo ""
