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
Homebrew管理パッケージ一覧（最小構成）
- **開発ツール**: gh(GitHub CLI)
- **zshプラグイン**: zsh-autosuggestions, zsh-completions, zsh-git-prompt

**注意**: 環境依存の開発ツール(nvm, direnv, mysql等)は含まれていません。必要に応じて個別にインストールしてください。zshrcにコメントアウトされた設定例があります。

### zshrc
zsh設定ファイル
- エイリアス設定(ls, python等)
- カスタムプロンプト(ユーザー名、アーキテクチャ、Gitステータス表示)
- zsh補完機能、自動サジェスト有効化
- 開発ツール設定はコメントアウト（nvm, direnv, Go, Ruby, Python, Flutter等）

### gitconfig
Git設定(条件付きインクルード)
- Git LFS設定
- 便利なエイリアス(st, co, br, up, ci)
- エディタ設定(vim)、マージツール(vimdiff)
- ディレクトリ別設定切り替え:
  - `~/project/work/` → `~/.gitconfig-work`
  - `~/project/other/` → `~/.gitconfig-other`

### gitignore_global
グローバルgitignore設定
- macOS固有ファイル(.DS_Store等)
- IDE設定ファイル(.idea, .vscode等)
- 環境変数ファイル(.env等)

### vimrc
Vim基本設定
- UTF-8文字コード設定
- 検索、表示、Tab設定
- macOSクリップボード連携

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
