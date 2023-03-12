"---------
" 入力
"---------
" タブをスペースに
set expandtab
" タブ幅を4に
set tabstop=4
" インデントを前の行に合わせる
set autoindent
" ファイルごとの設定を読み込む
filetype plugin indent on

"---------
" 表示
"---------
" 行番号
set number
" 暗い背景にあった色を使おうとする
set background=dark
" シンタックスハイライト
syntax on
" カラースキーム
colorscheme desert
" コメントの色を緑に
hi Comment ctermfg=2
" エラー時の音消去
set noerrorbells
" 対応するカッコなどを表示
set showmatch matchtime=1
" 対応する括弧に一瞬ジャンプする
set showmatch
" ステータス行を常に表示
set laststatus=2
" ノーマルモードのコマンドを表示
set showcmd
" カーソル位置を表示
set ruler
" カーソルがある行を強調する
set cursorline
" 行末を '↲,'、タブを '>...'、末尾のスペースを '_' で表示
set listchars=eol:↲,tab:>.,trail:_
hi NonText    ctermbg=NONE ctermfg=59 guibg=NONE guifg=NONE
hi SpecialKey ctermbg=NONE ctermfg=205 guibg=NONE guifg=NONE
" 制御文字を表示
set list
    
"---------
" 検索
"---------
"先頭に戻る
set wrapscan
"文字毎に検索
set incsearch
"検索テキストをすべてハイライト
set hlsearch
"大文字小文字を区別しない
set ignorecase
"大文字で検索した場合は大文字小文字を区別する
set smartcase

"---------
" ノーマルモード
"---------
" コマンド拡張
set wildmenu
" コマンドラインの履歴を10000件保存する
set history=10000
" ヤンクでクリップボードにコピー
set clipboard=unnamed,autoselect
