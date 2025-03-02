#!/bin/bash

# Define backup directory
VSCODE_BACKUP_DIR="$HOME/dotfiles/vscode"
mkdir -p "$VSCODE_BACKUP_DIR"

echo "🔄 Backing up VS Code settings..."

# Copy settings.json and keybindings.json
cp "$HOME/Library/Application Support/Code/User/settings.json" "$VSCODE_BACKUP_DIR/settings.json"
cp "$HOME/Library/Application Support/Code/User/keybindings.json" "$VSCODE_BACKUP_DIR/keybindings.json"

# Backup installed extensions
code --list-extensions > "$VSCODE_BACKUP_DIR/extensions.txt"

echo "✅ VS Code settings and extensions backed up to $VSCODE_BACKUP_DIR"
