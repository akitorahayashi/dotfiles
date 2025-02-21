#!/bin/bash

WATCH_DIR="$HOME/Library/Application Support/Code/User"
DOTFILES_DIR="$HOME/dotfiles/vscode"

echo "VS Code の設定変更を監視しています..."

fswatch -o "$WATCH_DIR/settings.json" "$WATCH_DIR/keybindings.json" | while read; do
    echo "VS Code の設定が変更されました。dotfiles を更新します..."
    cp -r "$WATCH_DIR/settings.json" "$DOTFILES_DIR/"
    cp -r "$WATCH_DIR/keybindings.json" "$DOTFILES_DIR/"
    echo "✅ VS Code の設定が dotfiles に保存されました！"
done
