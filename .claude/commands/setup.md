# dotfilesセットアップアシスタント

このdotfilesリポジトリを使用して、macOS環境をインタラクティブにセットアップします。

## あなたの役割
ユーザーの環境を確認しながら、安全にdotfilesをセットアップするサポートを行ってください。

## セットアップフロー

### 1. 環境確認
まず以下を確認してください:
```bash
# OS確認
uname -a

# アーキテクチャ確認
arch

# 既存の設定ファイル確認
ls -la ~ | grep -E '^\.|zshrc|vimrc|gitconfig'

# Homebrew確認
which brew && brew --version
```

### 2. 状況の説明
ユーザーに現在の状況を説明してください:
- 既に存在する設定ファイル
- 上書きされるファイル
- 新規作成されるファイル
- 必要なアクション

### 3. setup.shの実行
ユーザーの了承を得てから実行してください:
```bash
cd /Users/satorun/git/dotfiles
./setup.sh
```

**重要**: setup.shは冪等性を持つため、何度実行しても安全です。

### 4. エラー対応
エラーが発生した場合:
1. エラーメッセージを分析
2. 原因を特定
3. 解決方法を提示
4. 必要に応じて手動で修正

よくあるエラー:
- Xcode Command Line Toolsが未インストール
  - 対応: `xcode-select --install` を実行後、再度setup.shを実行
- Homebrewのインストール失敗
  - 対応: 手動でインストール手順を案内
- パーミッションエラー
  - 対応: sudo権限の確認、ファイルの所有者確認
- zsh補完の警告
  - 対応: `chmod -R go-w $(brew --prefix)/share/zsh*` で修正

### 5. セットアップ後の確認
以下を確認してください:
```bash
# zsh設定の確認
cat ~/.zshrc | head -20

# vim設定の確認
vim --version && cat ~/.vimrc | head -10

# git設定の確認
git config --list

# Brewfileパッケージの確認
brew list
```

### 6. 次のステップの案内
ユーザーに以下を案内してください:
1. ターミナルの再起動または `source ~/.zshrc`
2. gitconfig-work/otherの編集（個人情報の設定）
3. 開発ツールの有効化（必要に応じて）
4. 動作確認

## 注意事項
- 既存の設定ファイルは上書きされません（スキップされます）
- バックアップは自動的には取られないため、重要な設定がある場合は事前にバックアップを推奨
- setup.shは冪等性があり、何度実行しても安全です
- gitconfig-work/otherには個人情報が含まれる可能性があるため、慎重に扱ってください

## トラブルシューティング

### Q: 既存の設定を上書きしたい
A: 以下のコマンドで既存ファイルを削除またはバックアップしてから再実行:
```bash
# バックアップ
mv ~/.zshrc ~/.zshrc.backup
mv ~/.vimrc ~/.vimrc.backup
mv ~/.gitconfig ~/.gitconfig.backup

# 再実行
./setup.sh
```

### Q: 一部のパッケージだけインストールしたい
A: Brewfileを編集してから実行:
```bash
vim Brewfile
./setup.sh
```

### Q: 開発ツール(nvm, direnv等)をセットアップしたい
A: ~/.zshrcの該当セクションのコメントを外す:
```bash
vim ~/.zshrc
# 該当行のコメントアウトを削除
source ~/.zshrc
```

## インタラクティブな対応
- ユーザーの環境に応じて柔軟に対応してください
- 不明な点があれば質問してください
- 必要に応じて追加の設定やカスタマイズを提案してください
- エラーが発生した場合は、原因を分析して解決策を提示してください
