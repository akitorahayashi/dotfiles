#!/bin/bash

# ================================================
# generate_mac_settings.sh
# 現在の macOS の設定を取得し、自動で setup_mac_settings.sh を生成
# ================================================
#
# 【使い方】
# 1. スクリプトに実行権限を付与
#    chmod +x generate_mac_settings.sh
# 2. スクリプトを実行
#    ./generate_mac_settings.sh
# 3. `setup_mac_settings.sh` が作成される
# 4. `setup_mac_settings.sh` を適用するには:
#    source ~/dotfiles/setup_mac_settings.sh
#
# 【期待される動作】
# - 現在の macOS のシステム設定 (トラックパッド速度, Dock のサイズ, Finder の設定など) を取得
# - 取得した設定を `setup_mac_settings.sh` に書き出す
# - 既存の `setup_mac_settings.sh` がある場合、バックアップ (`setup_mac_settings.bak`) を作成
# - `install.sh` から `setup_mac_settings.sh` を `source` すれば、設定を再適用可能
#
# ================================================

OUTPUT_FILE="$HOME/dotfiles/setup_mac_settings.sh"
BACKUP_FILE="$HOME/dotfiles/setup_mac_settings.bak"

echo "現在の macOS の設定を取得し、$OUTPUT_FILE を生成します..."

# 既存の setup_mac_settings.sh がある場合はバックアップを作成
if [ -f "$OUTPUT_FILE" ]; then
    mv "$OUTPUT_FILE" "$BACKUP_FILE"
    echo "既存の設定ファイルをバックアップしました: $BACKUP_FILE"
fi

# 設定スクリプトのヘッダーを作成
cat <<EOF > "$OUTPUT_FILE"
#!/bin/bash

echo "Mac のシステム設定を適用中..."
EOF

# macOS 設定を取得してファイルに書き込む

# トラックパッドの速度
TRACKPAD_SPEED=$(defaults read -g com.apple.trackpad.scaling)
echo "defaults write -g com.apple.trackpad.scaling -float $TRACKPAD_SPEED" >> "$OUTPUT_FILE"

# マウスの速度
MOUSE_SPEED=$(defaults read -g com.apple.mouse.scaling)
echo "defaults write -g com.apple.mouse.scaling -float $MOUSE_SPEED" >> "$OUTPUT_FILE"

# キーボードのキーリピート速度
INITIAL_KEY_REPEAT=$(defaults read -g InitialKeyRepeat)
KEY_REPEAT=$(defaults read -g KeyRepeat)
echo "defaults write -g InitialKeyRepeat -int $INITIAL_KEY_REPEAT" >> "$OUTPUT_FILE"
echo "defaults write -g KeyRepeat -int $KEY_REPEAT" >> "$OUTPUT_FILE"

# Dock の設定
DOCK_SIZE=$(defaults read com.apple.dock tilesize)
DOCK_AUTOHIDE=$(defaults read com.apple.dock autohide)
DOCK_RECENTS=$(defaults read com.apple.dock show-recents)
echo "defaults write com.apple.dock tilesize -int $DOCK_SIZE" >> "$OUTPUT_FILE"
echo "defaults write com.apple.dock autohide -bool $DOCK_AUTOHIDE" >> "$OUTPUT_FILE"
echo "defaults write com.apple.dock show-recents -bool $DOCK_RECENTS" >> "$OUTPUT_FILE"
echo "killall Dock" >> "$OUTPUT_FILE"

# Finder の設定
FINDER_PATHBAR=$(defaults read com.apple.finder ShowPathbar)
FINDER_STATUSBAR=$(defaults read com.apple.finder ShowStatusBar)
FINDER_SHOW_HIDDEN=$(defaults read com.apple.finder AppleShowAllFiles)
echo "defaults write com.apple.finder ShowPathbar -bool $FINDER_PATHBAR" >> "$OUTPUT_FILE"
echo "defaults write com.apple.finder ShowStatusBar -bool $FINDER_STATUSBAR" >> "$OUTPUT_FILE"
echo "defaults write com.apple.finder AppleShowAllFiles -bool $FINDER_SHOW_HIDDEN" >> "$OUTPUT_FILE"
echo "killall Finder" >> "$OUTPUT_FILE"

# メニューバーの設定
MENU_BAR_HIDDEN=$(defaults read NSGlobalDomain _HIHideMenuBar)
echo "defaults write NSGlobalDomain _HIHideMenuBar -bool $MENU_BAR_HIDDEN" >> "$OUTPUT_FILE"

# スクリーンショットの保存場所
SCREENSHOT_PATH=$(defaults read com.apple.screencapture location)
echo "mkdir -p $SCREENSHOT_PATH" >> "$OUTPUT_FILE"
echo "defaults write com.apple.screencapture location \"$SCREENSHOT_PATH\"" >> "$OUTPUT_FILE"
echo "killall SystemUIServer" >> "$OUTPUT_FILE"

# スクリプトの最後にメッセージを追加
echo 'echo "Mac のシステム設定が適用されました ✅"' >> "$OUTPUT_FILE"

# 実行権限を付与
chmod +x "$OUTPUT_FILE"

echo "設定スクリプトを生成しました: $OUTPUT_FILE"
