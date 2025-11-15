# gitwt - Git Worktree Management Tool

Git worktreeを直感的に管理するためのコマンドラインツールです。

## 概要

各ブランチに対応したworktreeを `../_wt/<repo名>/` に自動で配置し、短いコマンドで作成・移動・削除・一覧・掃除を行えます。

## インストール

`setup.sh` を実行すると、自動的に以下の場所にインストールされます：

- `~/.local/lib/gitwt/lib.sh` - 共通ライブラリ
- `~/.local/bin/gitwt-*` - 各コマンド

`~/.local/bin` がPATHに含まれていることを確認してください。

## コマンド一覧

### gitwt (メインコマンド)

すべての機能は `gitwt` コマンドからアクセスできます。デフォルトでは実行されるgitコマンドが表示されます（verboseモード）。

```bash
# ブランチとworktreeを作成（デフォルトのstartpointから）
gitwt add feature/login-form

# 特定のブランチから作成
gitwt add feature/new-feature develop

# verbose出力を抑制
gitwt --quiet add feature/login-form

# worktreeパスを取得
cd "$(gitwt path feature/login-form)"

# worktreeディレクトリに移動（pathのエイリアス）
cd "$(gitwt cd feature/login-form)"

# worktreeを削除
gitwt rm feature/login-form

# worktree一覧を表示
gitwt ls

# 元のリポジトリディレクトリに戻る（worktreeから実行時）
cd "$(gitwt back)"

# 孤児化したworktreeエントリと空ディレクトリを削除
gitwt prune

# worktreeでsubshellを開く
gitwt open feature/login-form
```

### 個別コマンド（後方互換性）

`gitwt-add`, `gitwt-ls`, `gitwt-rm` などの個別コマンドも使用可能です。これらは `gitwt` コマンドのラッパーとして機能します。

```bash
# 個別コマンドの例
gitwt-add feature/login-form
gitwt-path feature/login-form
gitwt-rm feature/login-form
gitwt-ls
gitwt-prune
gitwt-open feature/login-form
gitwt-back
gitwt-cd feature/login-form
```

## 使用例

### 基本的なワークフロー

```bash
# 1. ブランチとworktreeを作成
gitwt add feature/login-form

# 2. worktreeディレクトリに移動
cd "$(gitwt cd feature/login-form)"

# 3. 作業を行う
# ... 開発作業 ...

# 4. 元のリポジトリに戻る
cd "$(gitwt back)"

# 5. 作業後に削除
gitwt rm feature/login-form
```

### 複数のブランチで並行作業

```bash
# 複数のブランチでworktreeを作成
gitwt add feature/login-form
gitwt add feature/user-profile
gitwt add bugfix/crash-fix

# 一覧を確認
gitwt ls

# 各worktreeで作業
cd "$(gitwt cd feature/login-form)"
# ... 作業 ...

cd "$(gitwt cd feature/user-profile)"
# ... 作業 ...

# 元のリポジトリに戻る
cd "$(gitwt back)"
```

### Verboseモード

デフォルトでは、実行されるgitコマンドが表示されます：

```bash
$ gitwt add feature/test
Creating branch 'feature/test' from origin/HEAD
> git branch feature/test origin/HEAD
> git worktree add /path/to/_wt/repo/feature__test feature/test
```

verbose出力を抑制するには `--quiet` オプションを使用：

```bash
$ gitwt --quiet add feature/test
Creating branch 'feature/test' from origin/HEAD
```

## ディレクトリ構造

worktreeは以下の場所に配置されます：

```
<repo_root>/
  ... (メインリポジトリ)
../_wt/<repo_name>/
  feature__login-form/    # feature/login-form ブランチのworktree
  feature__user-profile/  # feature/user-profile ブランチのworktree
  bugfix__crash-fix/      # bugfix/crash-fix ブランチのworktree
```

ブランチ名の `/` は `__` に置き換えられます。

## 動作環境

- bash 4.0+
- zsh 5.0+
- Linux
- macOS
- Git 2.5+ (worktree機能が必要)

## トラブルシューティング

### worktreeが見つからない

worktreeが存在しない場合は、`gitwt add` で作成してください。

```bash
gitwt add <branch-name>
```

### 孤児化したworktree

`gitwt-prune` を実行して、不要なworktreeを削除できます。

```bash
gitwt-prune
```

### パスが通っていない

`~/.local/bin` がPATHに含まれているか確認してください。

```bash
echo $PATH | grep -q "$HOME/.local/bin" || export PATH="$HOME/.local/bin:$PATH"
```

## ライセンス

このプロジェクトは dotfiles リポジトリの一部として公開されています。
