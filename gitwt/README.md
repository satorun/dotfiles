# gitwt - Git Worktree Management Tool

Git worktreeを直感的に管理するためのコマンドラインツールです。

## 概要

各ブランチに対応したworktreeを `../_wt/<repo名>/` に自動で配置し、短いコマンドで作成・削除・一覧・掃除を行えます。

## インストール

`setup.sh` を実行すると、自動的に以下の場所にインストールされます：

- `~/.local/lib/gitwt/lib.sh` - 共通ライブラリ
- `~/.local/bin/gitwt-*` - 各コマンド
- `~/.zshrc` - wtgo/wtback関数を含む設定ファイル

`~/.local/bin` がPATHに含まれていることを確認してください。

インストール後、zshを再起動するか以下を実行：
```bash
source ~/.zshrc
```

## コマンド一覧

### 基本コマンド

```bash
# ブランチとworktreeを作成
gitwt-add <branch> [base]

# worktreeとブランチを削除
gitwt-rm <branch>

# worktree一覧を表示
gitwt-ls

# 孤児化したworktreeを掃除
gitwt-prune

# worktreeパスを取得（内部用）
gitwt-path <branch>
```

### zshrc関数（ディレクトリ移動）

zshrcで定義された便利な関数：

```bash
# worktreeに移動
wtgo <branch>

# 元のリポジトリに戻る
# worktree内から実行した場合は元のリポジトリへ、
# 元のリポジトリ内ではリポジトリルートへ移動
wtback
```

## 使用例

### 基本的なワークフロー

```bash
# 1. ブランチとworktreeを作成
gitwt-add feature/login-form
# ✓ Worktree created successfully!
#   To navigate: wtgo feature/login-form

# 2. worktreeに移動
wtgo feature/login-form

# 3. 作業を行う
# ... 開発作業 ...

# 4. 元のリポジトリに戻る
wtback

# 5. 作業後に削除
gitwt-rm feature/login-form
```

### 複数のブランチで並行作業

```bash
# 複数のブランチでworktreeを作成
gitwt-add feature/login-form
gitwt-add feature/user-profile
gitwt-add bugfix/crash-fix

# 一覧を確認
gitwt-ls

# 各worktreeで作業
wtgo feature/login-form
# ... 作業 ...

wtgo feature/user-profile
# ... 作業 ...

# 元のリポジトリに戻る
wtback
```

### Verboseモード

デフォルトでは、実行されるgitコマンドが表示されます：

```bash
$ gitwt-add feature/test
Creating branch 'feature/test' from origin/HEAD
> git branch feature/test origin/HEAD
Creating worktree at /path/to/_wt/repo/feature__test
> git worktree add /path/to/_wt/repo/feature__test feature/test

✓ Worktree created successfully!
  To navigate: wtgo feature/test
```

verbose出力を抑制するには `-q` または `--quiet` オプションを使用：

```bash
$ gitwt-add --quiet feature/test
Creating branch 'feature/test' from origin/HEAD
Creating worktree at /path/to/_wt/repo/feature__test

✓ Worktree created successfully!
  To navigate: wtgo feature/test
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

worktreeが存在しない場合は、`gitwt-add` で作成してください。

```bash
gitwt-add <branch-name>
```

### 孤児化したworktree

`gitwt-prune` を実行して、不要なworktreeを削除できます。

```bash
gitwt-prune
```

### wtgo関数が見つからない

zshrcが読み込まれていない可能性があります。以下を実行：

```bash
source ~/.zshrc
```

### パスが通っていない

`~/.local/bin` がPATHに含まれているか確認してください。

```bash
echo $PATH | grep -q "$HOME/.local/bin" || export PATH="$HOME/.local/bin:$PATH"
```

## ライセンス

このプロジェクトは dotfiles リポジトリの一部として公開されています。
