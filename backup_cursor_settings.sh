#!/bin/bash

# Cursorの設定ディレクトリ
CURSOR_CONFIG_DIR="$HOME/Library/Application Support/Cursor/User"
DOTFILES_CURSOR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/cursor"

# バックアップ対象のファイル
FILES_TO_BACKUP=(
    "settings.json"
    "keybindings.json"
    "extensions.json"
)

# 設定ファイルのバックアップ
echo "Backing up Cursor settings..."
for file in "${FILES_TO_BACKUP[@]}"; do
    if [ -f "$CURSOR_CONFIG_DIR/$file" ]; then
        echo "Backing up $file..."
        cp "$CURSOR_CONFIG_DIR/$file" "$DOTFILES_CURSOR_DIR/"
    else
        echo "Warning: $file not found"
    fi
done

echo "Cursor settings backup completed!" 