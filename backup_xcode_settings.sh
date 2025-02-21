#!/bin/bash

# ==========================
# Xcode 設定のバックアップ方法
# ==========================
# 1. このスクリプトを実行すると、Xcode の設定が `dotfiles/.xcode/` に保存されます。
# 2. バックアップした設定は GitHub に保存できます。
#
# 実行方法:
# $ bash backup_xcode_settings.sh
#
# ==========================

DOTFILES_XCODE_DIR="$HOME/dotfiles/.xcode"
XCODE_USERDATA_DIR="$HOME/Library/Developer/Xcode/UserData"
XCODE_PREFS_FILE="$HOME/Library/Preferences/com.apple.dt.Xcode.plist"

mkdir -p "$DOTFILES_XCODE_DIR"

echo "🔄 Xcode 設定を dotfiles にバックアップ中..."

# コードスニペット
rsync -av --delete "$XCODE_USERDATA_DIR/CodeSnippets/" "$DOTFILES_XCODE_DIR/CodeSnippets/"

# カラースキーム
rsync -av --delete "$XCODE_USERDATA_DIR/FontAndColorThemes/" "$DOTFILES_XCODE_DIR/FontAndColorThemes/"

# テンプレートマクロ
if [[ -f "$XCODE_USERDATA_DIR/IDETemplateMacros.plist" ]]; then
    cp "$XCODE_USERDATA_DIR/IDETemplateMacros.plist" "$DOTFILES_XCODE_DIR/IDETemplateMacros.plist"
    echo "✅ IDETemplateMacros.plist をバックアップしました"
else
    echo "⚠ IDETemplateMacros.plist が見つかりません"
fi

# キーバインド
rsync -av --delete "$XCODE_USERDATA_DIR/KeyBindings/" "$DOTFILES_XCODE_DIR/KeyBindings/"

echo "🎉 Xcode 設定のバックアップ完了！"
