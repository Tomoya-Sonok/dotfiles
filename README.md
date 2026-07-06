# dotfiles

macOS (Apple Silicon) 用の個人設定ファイル。新しいマシンの環境構築をできるだけ少ない手数で再現するためのリポジトリ。

## 収録ツール

| ツール | 設定ファイル |
|---|---|
| zsh (oh-my-zsh + Powerlevel10k) | `.zshrc` / `.zprofile` / `.p10k.zsh` |
| WezTerm | `.config/wezterm/` |
| Neovim (LazyVim) | `.config/nvim/` |
| Vim | `.vimrc` |
| Git | `.gitconfig` / `.config/git/ignore` |
| Karabiner-Elements | `.config/karabiner/` |
| Zed | `.config/zed/settings.json` / `keymap.json` |
| mise (node / pnpm) | `.config/mise/config.toml` |
| Claude Code | `.claude/settings.json` / `.claude/plugins/blocklist.json` / `.agents/skills/` |
| Homebrew アプリ一式 | `Brewfile` |

## セットアップ(新環境)

```sh
git clone https://github.com/Tomoya-Sonok/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
exec zsh
```

> [!NOTE]
> `.gitconfig` は `url.pushInsteadOf` により **push だけ** ssh に書き換える設定。clone / fetch は https のまま匿名で動くので、SSH 鍵を設定する前でも上記の https clone・プラグイン類の自動ダウンロードはすべてそのまま成功する。

`install.sh` は何度実行しても安全(冪等)。既存の設定ファイルは `~/.dotfiles_backup/<タイムスタンプ>/` に退避してから symlink に置き換える。`DRY_RUN=1 ./install.sh` で、何が行われるかのプレビューだけ確認できる。

### install.sh がやること

1. Homebrew のインストール(未導入時)+ `brew bundle` で CLI・アプリ・フォントを一括導入
2. oh-my-zsh と plugins(zsh-autosuggestions / zsh-syntax-highlighting)、Powerlevel10k テーマのインストール
3. mise のインストール(`~/.local/bin/mise`)
4. 各設定ファイルの symlink 作成(`~` → このリポジトリ)
5. mise で node / pnpm を導入
6. Neovim プラグインを `lazy-lock.json` のコミット固定で headless 一括インストール
7. `~/.zshrc.local`(マシン固有の秘密情報置き場)の雛形生成

## 手動ステップ(install.sh 後)

1. **SSH 鍵 / GitHub**
   ```sh
   ssh-keygen -t ed25519 -C "your-email"
   gh auth login
   gh ssh-key add ~/.ssh/id_ed25519.pub
   ```
   private リポジトリを https URL で clone/fetch したい場合は `gh auth setup-git` も実行(push は pushInsteadOf で常に ssh)
2. **Neovim 初回起動**: プラグイン本体は install.sh が導入済み。初回の対話起動時に Mason が LSP サーバー類をダウンロードし、treesitter がパーサーをコンパイルする(1〜2分)。Copilot を使うなら `:Copilot auth` を一度実行
3. **Karabiner-Elements**: 初回起動して「入力監視」の権限を許可 → Complex Modifications でルールを有効化
   - Caps Lock → Ctrl / 左右 ⌘ 空打ちで英数・かな切替 / Ctrl 2度押しで WezTerm トグル
4. **Raycast**: 起動してホットキーを設定(Raycast の設定本体はこのリポジトリ対象外)
5. App Store 系アプリや Xcode などはこのリポジトリ対象外

## トラブルシューティング

### nvim が `module 'lazy' not found` で起動しない

プラグインの初回 clone に失敗した状態(ネットワーク断など)。以下で復旧できる:

```sh
cd ~/dotfiles && git pull
rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
./install.sh
```

`~/.local/share/nvim` の削除で Mason 導入済みの LSP なども消えるが、次回起動時に自動で再ダウンロードされる。

## 秘密情報の扱い

API キーなどのマシン固有の秘密は **`~/.zshrc.local`** に書く(`.zshrc` の最後で source される)。このファイルは git 管理外で、リポジトリには雛形の `.zshrc.local.example` のみ収録している。

## 更新方法

設定ファイルはすべて symlink なので、普段どおり設定を編集すればそのままこのリポジトリの diff になる。

```sh
cd ~/dotfiles
git add -p && git commit && git push
```
