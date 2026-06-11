#!/usr/bin/env bash
#
# Bootstrap script for a new macOS machine.
# Idempotent: safe to run multiple times.
#
# Usage:
#   ./install.sh            # full setup
#   DRY_RUN=1 ./install.sh  # print what would happen without changing anything

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d-%H%M%S)"

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mWARN:\033[0m %s\n' "$*"; }

run() {
  if [ "${DRY_RUN:-0}" = "1" ]; then
    echo "[dry-run] $*"
  else
    "$@"
  fi
}

# --- 1. Preconditions --------------------------------------------------------
if [ "$(uname -s)" != "Darwin" ]; then
  echo "This script is for macOS only." >&2
  exit 1
fi

# --- 2. Homebrew ---------------------------------------------------------------
if ! command -v brew >/dev/null 2>&1 && [ ! -x /opt/homebrew/bin/brew ]; then
  info "Installing Homebrew..."
  if [ "${DRY_RUN:-0}" = "1" ]; then
    echo "[dry-run] install Homebrew"
  else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
fi
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# --- 3. Brew packages ----------------------------------------------------------
info "Installing packages from Brewfile..."
if ! run brew bundle --file="$DOTFILES_DIR/Brewfile"; then
  warn "Some brew packages failed (app already installed manually?). Continuing."
fi

# --- 4. oh-my-zsh --------------------------------------------------------------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  info "Installing oh-my-zsh..."
  if [ "${DRY_RUN:-0}" = "1" ]; then
    echo "[dry-run] install oh-my-zsh (unattended)"
  else
    RUNZSH=no KEEP_ZSHRC=yes sh -c \
      "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi
fi

# --- 5. zsh plugins & theme ----------------------------------------------------
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# GIT_CONFIG_GLOBAL=/dev/null keeps these clones on anonymous https even though
# .gitconfig rewrites https://github.com/ to ssh:// (no SSH key needed yet).
clone_if_absent() { # clone_if_absent <https-url> <dest>
  if [ -d "$2" ]; then
    info "already present: $2"
  else
    run env GIT_CONFIG_GLOBAL=/dev/null git clone --depth=1 "$1" "$2"
  fi
}

clone_if_absent https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone_if_absent https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
clone_if_absent https://github.com/romkatv/powerlevel10k "$ZSH_CUSTOM/themes/powerlevel10k"

# --- 6. mise -------------------------------------------------------------------
# Installed via the official installer (not brew) because .zshrc activates it
# from the hardcoded path ~/.local/bin/mise.
if [ ! -x "$HOME/.local/bin/mise" ]; then
  info "Installing mise..."
  if [ "${DRY_RUN:-0}" = "1" ]; then
    echo "[dry-run] curl -fsSL https://mise.run | sh"
  else
    curl -fsSL https://mise.run | sh
  fi
fi

# --- 7. Symlinks ----------------------------------------------------------------
FILES=(
  .zshrc
  .zprofile
  .p10k.zsh
  .vimrc
  .gitconfig
  .config/git/ignore
  .config/mise/config.toml
  .config/wezterm
  .config/nvim
  .config/karabiner
  .config/zed/settings.json
  .config/zed/keymap.json
  .claude/settings.json
  .claude/plugins/blocklist.json
  .agents/skills
)

link() { # link <path-relative-to-home>
  local rel="$1" src dst
  src="$DOTFILES_DIR/$rel"
  dst="$HOME/$rel"

  if [ -L "$dst" ]; then
    [ "$(readlink "$dst")" = "$src" ] && return 0
    run rm "$dst"
  elif [ -e "$dst" ]; then
    run mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
    run mv "$dst" "$BACKUP_DIR/$rel"
    info "backed up: ~/$rel -> $BACKUP_DIR/$rel"
  fi

  run mkdir -p "$(dirname "$dst")"
  run ln -s "$src" "$dst"
  info "linked: ~/$rel"
}

info "Linking dotfiles..."
for f in "${FILES[@]}"; do
  link "$f"
done

# Claude Code skills: ~/.claude/skills/<name> are relative symlinks into
# ~/.agents/skills (itself linked into this repo above), matching the layout
# Claude Code created originally.
CLAUDE_SKILLS=(grill-me grill-with-docs tdd write-a-skill)
run mkdir -p "$HOME/.claude/skills"
for s in "${CLAUDE_SKILLS[@]}"; do
  dst="$HOME/.claude/skills/$s"
  if [ -L "$dst" ]; then
    [ "$(readlink "$dst")" = "../../.agents/skills/$s" ] && continue
    run rm "$dst"
  elif [ -e "$dst" ]; then
    run mkdir -p "$BACKUP_DIR/.claude/skills"
    run mv "$dst" "$BACKUP_DIR/.claude/skills/$s"
  fi
  run ln -s "../../.agents/skills/$s" "$dst"
  info "linked: ~/.claude/skills/$s"
done

# --- 8. Tool versions (node, pnpm) ----------------------------------------------
# Runs after symlinking so mise picks up .config/mise/config.toml.
# The config lives behind a symlink into this repo, so trust its real path first.
if [ -x "$HOME/.local/bin/mise" ]; then
  info "Installing tool versions with mise..."
  run "$HOME/.local/bin/mise" trust "$DOTFILES_DIR/.config/mise/config.toml"
  run "$HOME/.local/bin/mise" install --yes
fi

# --- 9. Machine-local secrets file -----------------------------------------------
if [ ! -f "$HOME/.zshrc.local" ]; then
  run cp "$DOTFILES_DIR/.zshrc.local.example" "$HOME/.zshrc.local"
  run chmod 600 "$HOME/.zshrc.local"
  info "created ~/.zshrc.local — put machine-local secrets (API keys etc.) there"
fi

# --- Done ------------------------------------------------------------------------
cat <<'EOF'

✅ Done! Next steps:

  1. exec zsh                       # reload shell (Powerlevel10k prompt appears)
  2. Set up SSH key for GitHub:
       ssh-keygen -t ed25519 -C "your-email"
       gh auth login                # then: gh ssh-key add ~/.ssh/id_ed25519.pub
     Until then, clone repos via https (this .gitconfig rewrites https -> ssh).
  3. Karabiner-Elements: launch once, grant Input Monitoring permission,
     then enable the rules under Complex Modifications.
  4. Raycast: launch and set the hotkey (its settings are not in this repo).
  5. Put your secrets (OPENAI_API_KEY etc.) into ~/.zshrc.local.

  Anything replaced by a symlink was backed up under ~/.dotfiles_backup/.
EOF
