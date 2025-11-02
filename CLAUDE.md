# dotfiles - macOS環境セットアップ

## プロジェクト概要
macOS開発環境の自動セットアップスクリプトと設定ファイル集

## 構成ファイル

### setup.sh
初回セットアップを自動実行するメインスクリプト
- Homebrewインストール(未導入時はXcode Command Line Toolsも自動導入)
- 各種設定ファイルをホームディレクトリに配置(~/.zshrc, ~/.vimrc, ~/.gitconfig等)
- プロジェクトディレクトリ作成(~/project/work, ~/project/other)

### Brewfile
Homebrew管理パッケージ一覧
- **開発ツール**: gh(GitHub CLI), nvm(Node.jsバージョン管理), mysql, direnv
- **zshプラグイン**: zsh-autosuggestions, zsh-completions, zsh-git-prompt
- **GUI**: xcodes(Xcodeバージョン管理)
- **更新方法**: `brew bundle dump --global --force`

### zshrc
zsh設定ファイル
- エイリアス設定(ls, python等)
- カスタムプロンプト(ユーザー名、アーキテクチャ、Gitステータス表示)
- zsh補完機能、自動サジェスト有効化
- nvm、direnv統合

### gitconfig
Git設定(条件付きインクルード)
- Git LFS設定
- ディレクトリ別設定切り替え:
  - `~/project/work/` → `~/.gitconfig-work`
  - `~/project/other/` → `~/.gitconfig-other`

### vimrc
Vim基本設定

## セットアップ手順
```bash
./setup.sh
```

## 環境情報
- **プラットフォーム**: macOS (Apple Silicon想定)
- **Homebrewパス**: /opt/homebrew
- **シェル**: zsh

## 注意事項
- setup.shは各設定ファイルが既に存在する場合はスキップ(上書きしない)
- gitconfig-work、gitconfig-otherはユーザー情報を個別に設定する用途
