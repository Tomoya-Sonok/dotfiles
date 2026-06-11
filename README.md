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
> 初回の clone は必ず **https** で行うこと。`.gitconfig` が https→ssh の書き換え設定 (`url.insteadOf`) を持つため、SSH 鍵を設定する前に ssh で clone しようとすると失敗する(`install.sh` 内部の clone は対策済み)。

`install.sh` は何度実行しても安全(冪等)。既存の設定ファイルは `~/.dotfiles_backup/<タイムスタンプ>/` に退避してから symlink に置き換える。`DRY_RUN=1 ./install.sh` で、何が行われるかのプレビューだけ確認できる。

### install.sh がやること

1. Homebrew のインストール(未導入時)+ `brew bundle` で CLI・アプリ・フォントを一括導入
2. oh-my-zsh と plugins(zsh-autosuggestions / zsh-syntax-highlighting)、Powerlevel10k テーマのインストール
3. mise のインストール(`~/.local/bin/mise`)
4. 各設定ファイルの symlink 作成(`~` → このリポジトリ)
5. mise で node / pnpm を導入
6. `~/.zshrc.local`(マシン固有の秘密情報置き場)の雛形生成

## 手動ステップ(install.sh 後)

1. **SSH 鍵 / GitHub**
   ```sh
   ssh-keygen -t ed25519 -C "your-email"
   gh auth login
   gh ssh-key add ~/.ssh/id_ed25519.pub
   ```
2. **Karabiner-Elements**: 初回起動して「入力監視」の権限を許可 → Complex Modifications でルールを有効化
   - Caps Lock → Ctrl / 左右 ⌘ 空打ちで英数・かな切替 / Ctrl 2度押しで WezTerm トグル
3. **Raycast**: 起動してホットキーを設定(Raycast の設定本体はこのリポジトリ対象外)
4. App Store 系アプリや Xcode などはこのリポジトリ対象外

## 秘密情報の扱い

API キーなどのマシン固有の秘密は **`~/.zshrc.local`** に書く(`.zshrc` の最後で source される)。このファイルは git 管理外で、リポジトリには雛形の `.zshrc.local.example` のみ収録している。

## 更新方法

設定ファイルはすべて symlink なので、普段どおり設定を編集すればそのままこのリポジトリの diff になる。

```sh
cd ~/dotfiles
git add -p && git commit && git push
```
