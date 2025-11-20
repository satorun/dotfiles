# dotfilesセットアップアシスタント

このコマンドは、dotfilesリポジトリを使用して開発環境を安全にセットアップ・更新します。

## コマンドの目的

1. **安全な初回セットアップ**: 既存の設定を壊さずにdotfilesを適用
2. **インテリジェント更新**: リポジトリの更新を既存環境に安全に反映
3. **双方向同期**: 環境の有用な変更をリポジトリに取り込む（オプション）

## 基本原則

### 1. setup.shを信頼できる情報源とする
- すべての処理フローは`setup.sh`に記載
- このコマンドは`setup.sh`の処理を拡張・改善するもの
- **必ず最初にsetup.shを読み込んで最新の処理内容を確認する**

### 2. 安全第一
- すべての変更前にバックアップを作成
- 破壊的な操作は必ずユーザー確認を取る
- 変更は可逆的であることを保証

### 3. 透明性
- 何をしているかを明確に説明
- 差分を視覚的に表示
- 選択肢と影響を明示

---

## 処理フロー

### Phase 1: 初期確認とバックアップ

#### 1-1. 環境確認
```bash
# OS・アーキテクチャ確認
uname -s  # → Darwin（macOS）を期待
uname -m  # → arm64（Apple Silicon）またはx86_64

# Homebrew確認
which brew
```

**報告例**:
```
✓ OS: macOS (Darwin)
✓ Architecture: Apple Silicon (arm64)
✓ Homebrew: インストール済み (/opt/homebrew/bin/brew)
```

#### 1-2. バックアップ作成
**必須**: 以下のファイルが存在する場合、バックアップを作成

対象ファイル:
- `~/.zshrc`
- `~/.vimrc`
- `~/.gitconfig`
- `~/.gitignore_global`
- `~/.gitconfig-work`
- `~/.gitconfig-other`

実装:
```bash
BACKUP_DIR=".claude/tmp/backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

for file in ~/.zshrc ~/.vimrc ~/.gitconfig ~/.gitignore_global ~/.gitconfig-work ~/.gitconfig-other; do
  if [ -e "$file" ]; then
    cp "$file" "$BACKUP_DIR/$(basename $file)"
    echo "✓ $(basename $file)"
  fi
done
```

**報告**: バックアップ先を明示
```
バックアップを作成しました: .claude/tmp/backup-20251119-151645
以下のファイルをバックアップ:
  ✓ .zshrc
  ✓ .gitconfig
  ...
```

---

### Phase 2: Homebrewとパッケージ

#### 2-1. Homebrewインストール確認
setup.sh:36-56に記載の処理に従う

**既にインストール済み**:
```
✓ Homebrew: 既にインストール済み
```

**未インストール**:
- Xcode Command Line Toolsの確認・インストール
- Homebrewのインストール
- setup.shの処理をそのまま実行

#### 2-2. Brewfileパッケージ
setup.sh:61-97に記載の処理を改善

**手順**:
1. Brewfileを読み込み、必要なパッケージリストを取得
2. 現在インストール済みのパッケージを確認
3. 差分を表示

**表示例**:
```
=== Brewfileパッケージ確認 ===

必要なパッケージ: gh, zsh-completions, zsh-git-prompt, zsh-autosuggestions

✓ インストール済み: gh, zsh-completions, zsh-git-prompt, zsh-autosuggestions
✗ 未インストール: なし

→ すべてのパッケージがインストール済みです
```

**未インストールがある場合**:
```
✗ 未インストール: zsh-git-prompt

インストールしますか？
[y] インストールする
[n] スキップ
```

---

### Phase 3: 設定ファイルの統合

このフェーズがこのコマンドの核心機能です。

#### 3-1. 対象ファイルリスト
- `~/.zshrc` ← `zshrc`
- `~/.vimrc` ← `vimrc`
- `~/.gitconfig` ← `gitconfig`
- `~/.gitignore_global` ← `gitignore_global`
- `~/.gitconfig-work` ← `gitconfig-work`（またはテンプレート作成）
- `~/.gitconfig-other` ← `gitconfig-other`（またはテンプレート作成）

#### 3-2. 各ファイルの処理

**ステップ1: 存在確認**
```bash
if [ ! -e ~/.zshrc ]; then
  # 既存ファイルなし → setup.shと同じ処理（単純コピー）
else
  # 既存ファイルあり → 差分分析へ
fi
```

**ステップ2: 差分分析**

完全一致の確認:
```bash
diff -q ~/.zshrc zshrc
```

- **完全一致**:
  ```
  ✓ ~/.zshrc: リポジトリと同一（変更不要）
  ```

- **差分あり**: 詳細分析へ

**ステップ3: 詳細分析と統合プラン**

差分の視覚化:
```bash
diff -u ~/.zshrc zshrc | head -50
```

分析内容を報告:
```
=== ~/.zshrc 差分分析 ===

【既存ファイルの特徴】
- 基本設定: リポジトリと同一
- 追加設定: mise, volta, miniforgeなどの開発ツール設定が有効化されている
- 行数: 198行

【リポジトリファイルの特徴】
- 基本設定のみ
- 開発ツール設定はコメントアウト
- 行数: 198行

【評価】
既存ファイルはリポジトリをベースに、開発ツールを有効化したもの。
既存ファイルの方が実用的な状態です。

【推奨アクション】
A. 既存ファイルを保持（推奨）
   → 現在の設定を維持

B. リポジトリで上書き
   → 開発ツール設定が無効化されるため非推奨

C. 手動マージ
   → 両方の良い部分を統合
```

**ステップ4: ユーザー選択**

AskUserQuestionツールを使用:
```
選択してください:
- A: 既存ファイルを保持（推奨）
- B: リポジトリで上書き
- C: 手動マージ
```

**ステップ5: 実行**

選択に応じて処理:
- **A選択**: 何もしない（既存を保持）
- **B選択**: `cp zshrc ~/.zshrc`
- **C選択**: マージ処理（後述）

#### 3-3. ファイル別の特別処理

**gitconfig**:
- `[user]`セクション: 既存を**絶対に**保持
- `[includeIf]`セクション: 両方の設定をマージ
- その他のセクション: 重複チェック後マージ

実装例:
```
【gitconfig特別処理】

既存の[user]設定を検出:
  name = Satoru Nishimura
  email = satoru.nishimura@genda.jp

既存の[includeIf]設定:
  - gitdir:~/dev.satorun/ → ~/.gitconfig-satorun
  - gitdir:~/project/work/ → ~/.gitconfig-work
  - gitdir:~/project/other/ → ~/.gitconfig-other

リポジトリの[includeIf]設定:
  - gitdir:~/project/work/ → ~/.gitconfig-work
  - gitdir:~/project/other/ → ~/.gitconfig-other

→ 既存ファイルはリポジトリの設定を含み、さらに有用な設定があります

【推奨】既存ファイルを保持
```

**gitconfig-work / gitconfig-other**:
既存ファイルが設定済みの場合、内容を確認:
```bash
cat ~/.gitconfig-work
```

- テンプレート（YOUR_NAMEなど）のまま → リポジトリで更新または手動入力を促す
- 実際の情報が設定済み → 保持

**zshrc**:
- gitwt関数（wtgo, wtback）の存在を確認
- 開発ツール設定の有効化状況を確認

---

### Phase 4: 後処理

setup.shの後処理に従う

#### 4-1. zsh補完の権限修正
setup.sh:112-126に記載

```bash
# 親ディレクトリの権限修正
chmod go-w "$(brew --prefix)/share" 2>/dev/null || true

# zsh関連ディレクトリの権限を再帰的に修正
chmod -R go-w "$(brew --prefix)/share/zsh"* 2>/dev/null || true

# zsh補完キャッシュの削除
rm -f ~/.zcompdump
```

**報告**:
```
✓ zsh補完ディレクトリの権限を修正
✓ 補完キャッシュを削除（次回起動時に再構築）
```

#### 4-2. プロジェクトディレクトリ
setup.sh:167-175に記載

```bash
mkdir -p ~/project/work
mkdir -p ~/project/other
```

**報告**:
```
✓ プロジェクトディレクトリ: 既に存在
```

#### 4-3. gitwtスクリプト
setup.sh:222-272に記載

**重要**: この処理は既存のsetup.mdに抜けていました

手順:
1. `~/.local/lib/gitwt`と`~/.local/bin`を作成
2. 非推奨コマンド削除（gitwt, gitwt-cd, gitwt-back, gitwt-open）
3. lib.shをコピー
4. binスクリプトをシンボリックリンク
5. PATHの確認

**報告例**:
```
=== gitwt セットアップ ===
✓ ディレクトリ作成: ~/.local/lib/gitwt, ~/.local/bin
✓ lib.shをインストール
✓ コマンドをインストール: gitwt-add, gitwt-ls, gitwt-path, gitwt-prune, gitwt-rm, gitwt-root
✓ ~/.local/binはPATHに含まれています
```

---

### Phase 5: 完了報告

setup.shと同様の報告を行う

```
=== セットアップ完了 ===

【変更内容サマリー】
✓ Homebrewパッケージ: すべてインストール済み
✓ ~/.zshrc: 既存ファイルを保持
✓ ~/.vimrc: 既存ファイルを保持（リポジトリと同一）
✓ ~/.gitconfig: 既存ファイルを保持
✓ ~/.gitconfig-work: 既存設定を保持
✓ ~/.gitconfig-other: 既存設定を保持
✓ gitwt: インストール済み
✓ zsh補完: 権限修正完了

【次のステップ】
1. ターミナルを再起動するか、以下を実行:
   source ~/.zshrc

2. 設定の確認:
   - zshプラグイン: ls $(brew --prefix)/share | grep zsh
   - git設定: git config --list
   - gitwt: gitwt-ls（Gitリポジトリ内で実行）

【バックアップ】
問題がある場合は以下から復元できます:
  .claude/tmp/backup-20251119-151645
```

---

## 発展的機能（Phase 6 & 7）

### Phase 6: 環境→リポジトリの取り込み

**実行タイミング**: Phase 5（完了報告）の後、ユーザーに確認してから実行

**目的**: 環境で行った有用な変更をリポジトリに反映し、今後のセットアップを効率化

#### 6-1. 取り込み対象の検出

**検出すべき項目**:

1. **gitconfig-work/other の実際の設定**
   - テンプレート（YOUR_NAME等）ではない実データ
   - リポジトリと異なる内容

2. **gitconfig の追加設定**
   - リポジトリにない[includeIf]エントリ
   - 例: `gitdir:~/dev.satorun/`

3. **その他の有用な差分**
   - 環境にしかない設定で、一般化できるもの

#### 6-2. 検出ロジック

**gitconfig-workの例**:
```bash
# 既存ファイルとリポジトリファイルを比較
diff -q ~/.gitconfig-work gitconfig-work

# 差分がある場合、内容を確認
cat ~/.gitconfig-work | grep -v "YOUR_NAME" | grep -v "YOUR_WORK_EMAIL"
```

判定:
- テンプレート文字列（YOUR_*）が含まれていない
- かつ、リポジトリと内容が異なる
→ **取り込み候補**

#### 6-3. ユーザーへの提案

**表示形式**:
```
=== 環境→リポジトリの取り込み ===

環境に以下の有用な設定があります。リポジトリに反映しますか？

【1. gitconfig-work】
  現在の環境:
    [user]
      name = Satoru Nishimura
      email = satoru.nishimura@genda.jp

  リポジトリ（古い）:
    [user]
      name = satorun
      email = satorun.org@gmail.com

  → リポジトリを更新すると、今後のセットアップ時に正しい情報が自動設定されます

  ⚠️ 注意:
    - メールアドレスがGitリポジトリに記録されます
    - プライベートリポジトリでの使用を推奨
    - パブリックリポジトリの場合は慎重に判断してください

【2. gitconfig の追加設定】
  環境にのみ存在:
    [includeIf "gitdir:~/dev.satorun/"]
      path = ~/.gitconfig-satorun

  → この設定をリポジトリに追加すると、他の環境でも利用できます

  ~/.gitconfig-satorunファイルも追加しますか？
    現在の内容:
      [user]
        name = satorun
        email = satorun.org@gmail.com

---

これらの設定をリポジトリに反映しますか？
```

**AskUserQuestionツールの使用**:
```
質問: 環境の設定をリポジトリに反映しますか？

オプション:
A. すべて反映する
   → 検出された設定をすべてリポジトリに反映（git addまで実行）

B. 個別に選択する
   → 各設定について個別に確認

C. スキップする
   → 今回は反映しない

multiSelect: false
```

#### 6-4. 反映処理

**A選択（すべて反映）の場合**:

1. gitconfig-workの更新:
   ```bash
   cp ~/.gitconfig-work gitconfig-work
   ```

2. gitconfig-otherの更新（同様に差分がある場合）:
   ```bash
   cp ~/.gitconfig-other gitconfig-other
   ```

3. gitconfigの更新（追加設定がある場合）:
   - 既存ファイルから追加の[includeIf]セクションを抽出
   - リポジトリファイルにマージ

   実装例:
   ```bash
   # 環境にしかない[includeIf]を抽出
   grep -A 1 'includeIf "gitdir:~/dev.satorun/"' ~/.gitconfig

   # リポジトリファイルに追加（手動マージが必要）
   ```

4. 新規ファイルの追加（.gitconfig-satorun等）:
   ```bash
   cp ~/.gitconfig-satorun gitconfig-satorun
   ```

5. git addの実行:
   ```bash
   git add gitconfig-work gitconfig-other gitconfig gitconfig-satorun
   ```

**報告**:
```
✓ 以下のファイルをリポジトリに反映しました:
  - gitconfig-work
  - gitconfig-other
  - gitconfig（[includeIf]を追加）
  - gitconfig-satorun（新規追加）

✓ git addまで完了しました

【次のステップ】
以下のコマンドでコミットしてください:
  git diff --cached  # 変更内容を確認
  git commit -m "chore: 環境の設定をdotfilesに反映"
  git push
```

**B選択（個別選択）の場合**:
各項目についてAskUserQuestionで確認しながら処理

**C選択（スキップ）の場合**:
何もしない

#### 6-5. プライバシー警告

**必ず警告すること**:
- メールアドレス、名前などの個人情報が含まれる
- リポジトリがパブリックの場合、これらの情報が公開される
- gitconfig-satorunなど、新規ファイルの内容も確認が必要

**確認方法**:
```bash
# リポジトリの公開状態を確認
git remote -v | grep github.com
gh repo view --json visibility -q .visibility
```

→ "PUBLIC"の場合は特に注意を促す

---

### Phase 7: 重複整理

**実行タイミング**: Phase 6の後、またはユーザーが明示的に要求した場合

**目的**: 同じ機能の重複設定を検出し、統合・削減を提案

#### 7-1. 重複検出の対象

**gitconfig**:
1. 重複した[includeIf]エントリ
   - 同じgitdirパターンが複数ある

2. 重複したエイリアス定義
   - 同じエイリアス名で異なる定義

**zshrc**:
1. 重複したPATH設定
   - 同じディレクトリが複数回PATHに追加される

2. 重複したプラグイン読み込み
   - 同じプラグインが複数箇所で読み込まれる

3. 重複した環境変数設定
   - 同じ変数が複数回exportされる

#### 7-2. 検出ロジック

**gitconfig の重複[includeIf]検出**:
```bash
# [includeIf]エントリを抽出
grep -n 'includeIf' ~/.gitconfig

# 重複をチェック
grep 'includeIf' ~/.gitconfig | sort | uniq -d
```

**zshrc の重複PATH検出**:
```bash
# PATHに追加している行を抽出
grep -n 'export PATH.*:.*PATH' ~/.zshrc
grep -n 'path=(' ~/.zshrc -A 20

# 同じディレクトリが複数回追加されているかチェック
```

実装例:
```
既存ファイルを読み込み、以下をチェック:
1. export PATH="$HOME/.local/bin:$PATH" の重複
2. mise、nvm、voltaなど同一機能ツールの重複有効化
3. precmd_functionsへの重複追加
```

#### 7-3. ユーザーへの提案

**表示例**:
```
=== 重複設定の整理 ===

以下の重複を検出しました:

【1. zshrc: precmd_functionsへの重複追加】
  96行目: precmd_functions=(${precmd_functions:#add_newline})
  97行目: precmd_functions+=(add_newline)

  この2行は重複する可能性があります。

  → 推奨: そのまま保持（意図的な重複除去処理）

【2. zshrc: Node.jsバージョン管理ツールの重複】
  133-138行目: nvm
  140-144行目: volta

  nvmとvoltaは同じ機能（Node.jsバージョン管理）を提供します。
  両方が有効な場合、競合する可能性があります。

  → 推奨: 使用している方のみを有効化

---

重複を整理しますか？
```

**AskUserQuestionツールの使用**:
```
質問: 重複設定をどうしますか？

オプション:
A. 自動整理する
   → 推奨される整理を自動実行

B. 個別に確認する
   → 各重複について個別に判断

C. スキップする
   → 現状を維持

multiSelect: false
```

#### 7-4. 整理処理

**nvmとvoltaの重複解決例**:

1. 現在どちらが使われているか確認:
   ```bash
   which node
   # /Users/xxx/.volta/bin/node → voltaが有効
   # /Users/xxx/.nvm/versions/node/xxx/bin/node → nvmが有効
   ```

2. ユーザーに確認:
   ```
   現在はvoltaが使用されています（which node: ~/.volta/bin/node）

   nvmの設定をコメントアウトしますか？
   [y] nvmをコメントアウト（voltaのみ使用）
   [n] 両方を保持
   ```

3. y選択の場合、nvmセクションをコメントアウト:
   ```bash
   # Edit toolで133-138行目を修正
   # ### nvm (Node.js version manager) ###
   # ↓
   # ### nvm (Node.js version manager) - 無効化（voltaを使用中） ###
   ```

#### 7-5. 整理完了報告

```
=== 重複整理完了 ===

【整理内容】
✓ zshrc: nvmをコメントアウト（voltaのみ使用）
✓ 重複PATH設定: 変更なし（意図的な設定）

【変更ファイル】
- ~/.zshrc

【確認方法】
差分を確認:
  git diff ~/.zshrc

問題があれば、バックアップから復元できます:
  .claude/tmp/backup-20251119-151645/.zshrc

【次のステップ】
設定を反映:
  source ~/.zshrc

Nodeバージョン確認:
  which node
  node --version
```

---

## エラーハンドリング

### 権限エラー
```
エラー: ~/.zshrcへの書き込み権限がありません
→ ファイルの所有者・権限を確認してください
  ls -la ~/.zshrc
```

### Homebrewエラー
setup.shのエラーハンドリングに従う:
- Xcode Command Line Toolsが未インストール → インストール後に再実行
- Homebrewインストール失敗 → エラーメッセージを表示して終了

### 予期しない差分
```
警告: ~/.zshrcに予期しない大きな差分があります
  既存: 500行
  リポジトリ: 198行

→ 慎重に確認することをお勧めします
  差分を表示しますか？ [y/n]
```

---

## 実装時の注意事項

1. **Readツールの活用**: すべてのファイル読み込みはReadツールを使用
2. **Bashツールでの確認**: 差分確認、権限チェックなど
3. **AskUserQuestionツール**: 重要な選択肢の提示
4. **TodoWriteツール**: 処理の進捗管理（Phase 1, 2, 3...）
5. **段階的な報告**: 各ステップの完了後に状況を報告

## コマンド実行の流れ

### 基本フロー（Phase 1-5）

```
1. setup.shを読み込み、最新の処理フローを確認
2. Phase 1: 初期確認とバックアップ
3. Phase 2: Homebrewとパッケージ
4. Phase 3: 設定ファイルの統合（ファイルごとにループ）
5. Phase 4: 後処理（権限修正、gitwt、ディレクトリ）
6. Phase 5: 完了報告
```

### 発展的機能（Phase 6-7）

Phase 5の完了後、以下を提案:

```
=== セットアップ完了 ===

（基本セットアップの報告）

---

【発展的機能】
環境の有用な設定をリポジトリに反映できます。

実行しますか？
[y] Phase 6: 環境→リポジトリの取り込みを実行
[n] スキップ
```

- **y選択**: Phase 6を実行
  - Phase 6完了後、Phase 7（重複整理）を提案
- **n選択**: セットアップ完了

### 実行時の注意事項

1. **各フェーズの完了後、必ずユーザーに状況を報告**
2. **Phase 3では、ファイルごとに差分分析と統合を実施**
3. **Phase 6/7はオプション機能として、ユーザーの選択に基づき実行**
4. **エラー発生時は即座に報告し、バックアップからの復元方法を提示**
