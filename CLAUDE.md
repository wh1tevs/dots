# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal dotfiles managed via GNU Stow. Configuration is organized into layered packages that are symlinked into `$HOME`.

## Applying dotfiles

```bash
make deps          # install system dependencies (reads packages file, uses dnf)
make common        # symlink pkgs/common/ → $HOME
make tmux-plugins  # bootstrap tmux plugin manager
```

Stow flags used: `--no-folding --dotfiles --target=$HOME`. The `--dotfiles` flag means files/dirs named `dot-*` are symlinked as `.* ` (e.g. `dot-config` → `.config`).

## Structure

```
pkgs/
  common/      shell (zsh, profile, tmux, gnupg, oh-my-posh)
```

## Shell config

`.zshrc` and `.profile` in `pkgs/common/` are the actual config files (no dispatcher indirection). Both source `~/.{zshrc,profile}.local` at the end for untracked local additions.

