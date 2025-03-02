#!/bin/bash

# ==========================
# Xcode 設定の復元方法
# ==========================
# 1. このスクリプトを実行すると、`dotfiles/.xcode/` のバックアップデータが Xcode に復元されます。
# 2. `install.sh` で自動実行する場合は、以下のように記述:
#
# install.sh:
# ----------------------
# #!/bin/bash
# echo "🔄 Xcode 設定を復元中..."
# bash ~/dotfiles/restore_xcode_settings.sh
# echo "✅ Xcode 設定の適用が完了しました！"
# ----------------------
#
# 実行方法:
# $ bash restore_xcode_settings.sh
#
# ==========================

DOTFILES_XCODE_DIR="$HOME/dotfiles/.xcode"
XCODE_USERDATA_DIR="$HOME/Library/Developer/Xcode/UserData"
XCODE_PREFS_FILE="$HOME/Library/Preferences/com.apple.dt.Xcode.plist"

echo "🔄 Xcode 設定を復元中..."

# 設定フォルダを作成
mkdir -p "$XCODE_USERDATA_DIR/CodeSnippets"
mkdir -p "$XCODE_USERDATA_DIR/FontAndColorThemes"
mkdir -p "$XCODE_USERDATA_DIR/KeyBindings"

# コードスニペット
rsync -av --delete "$DOTFILES_XCODE_DIR/CodeSnippets/" "$XCODE_USERDATA_DIR/CodeSnippets/"

# カラーテーマ
rsync -av --delete "$DOTFILES_XCODE_DIR/FontAndColorThemes/" "$XCODE_USERDATA_DIR/FontAndColorThemes/"

# テンプレートマクロ
if [[ -f "$DOTFILES_XCODE_DIR/IDETemplateMacros.plist" ]]; then
    cp "$DOTFILES_XCODE_DIR/IDETemplateMacros.plist" "$XCODE_USERDATA_DIR/IDETemplateMacros.plist"
    echo "✅ IDETemplateMacros.plist を復元しました"
else
    echo "⚠ IDETemplateMacros.plist が見つかりません"
fi

# キーバインド
rsync -av --delete "$DOTFILES_XCODE_DIR/KeyBindings/" "$XCODE_USERDATA_DIR/KeyBindings/"

echo "🎉 Xcode 設定の復元が完了しました！"
