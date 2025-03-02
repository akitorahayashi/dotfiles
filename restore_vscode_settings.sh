#!/bin/bash

# VS Code 設定のバックアップディレクトリ
VSCODE_BACKUP_DIR="$HOME/dotfiles/vscode"

echo "🔄 VS Code の設定を復元しています..."

# VS Code がインストールされているか確認
if ! command -v code &>/dev/null; then
    echo "❌ VS Code がインストールされていません。先にインストールしてください。"
    exit 1
fi

# 設定ファイルを復元
mkdir -p "$HOME/Library/Application Support/Code/User"
cp "$VSCODE_BACKUP_DIR/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
cp "$VSCODE_BACKUP_DIR/keybindings.json" "$HOME/Library/Application Support/Code/User/keybindings.json"
echo "✅ 設定ファイルを復元しました！"

# 現在インストールされている拡張機能を取得
INSTALLED_EXTENSIONS=$(code --list-extensions)

# 拡張機能を復元（すでにインストール済みのものはスキップ）
if [[ -f "$VSCODE_BACKUP_DIR/extensions.txt" ]]; then
    echo "🔄 VS Code 拡張機能をインストールしています..."
    while IFS= read -r extension; do
        if echo "$INSTALLED_EXTENSIONS" | grep -q "^$extension$"; then
            echo "✅ $extension はすでにインストール済みです。スキップします。"
        else
            echo "➕ $extension をインストール中..."
            code --install-extension "$extension"
        fi
    done < "$VSCODE_BACKUP_DIR/extensions.txt"
    echo "✅ すべての拡張機能の処理が完了しました！"
else
    echo "⚠ 拡張機能のバックアップファイルが見つかりません。"
fi

echo "🎉 VS Code の設定復元が完了しました！"
