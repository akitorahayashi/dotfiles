#!/bin/bash

start_time=$(date +%s)
echo "Macをセットアップ中..."

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Xcode Command Line Tools のインストール（非対話的）
install_xcode_tools() {
    if ! xcode-select -p &>/dev/null; then
        echo "Xcode Command Line Tools をインストール中..."
        xcode-select --install
        echo "Xcode Command Line Tools のインストール完了 ✅"
    else
        echo "Xcode Command Line Tools はすでにインストールされています"
    fi
}

# Apple M1, M2 向け Rosetta 2 のインストール
install_rosetta() {
    if [[ "$(uname -m)" == "arm64" ]]; then
        # Mac のチップモデルを取得
        MAC_MODEL=$(sysctl -n machdep.cpu.brand_string)
        echo "Mac Model: $MAC_MODEL"  # デバッグ出力

        # M1 または M2 の場合のみ Rosetta 2 をインストール
        if [[ "$MAC_MODEL" == *"M1"* || "$MAC_MODEL" == *"M2"* ]]; then
            # すでに Rosetta 2 がインストールされているかチェック
            if pgrep oahd >/dev/null 2>&1; then
                echo "Rosetta 2 はすでにインストールされています ✅"
                return
            fi

            # Rosetta 2 をインストール
            echo "Rosetta 2 を $MAC_MODEL 向けにインストール中..."
            softwareupdate --install-rosetta --agree-to-license

            # インストールの成否をチェック
            if pgrep oahd >/dev/null 2>&1; then
                echo "Rosetta 2 のインストールが完了しました ✅"
            else
                echo "Rosetta 2 のインストールに失敗しました ❌"
            fi
        else
            echo "この Mac ($MAC_MODEL) には Rosetta 2 は不要です ✅"
        fi
    else
        echo "この Mac は Apple Silicon ではないため、Rosetta 2 は不要です ✅"
    fi
}


install_homebrew() {
    if ! command_exists brew; then
        echo "Homebrew をインストール中..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        echo "Homebrew のインストール完了 ✅"
    else
        echo "Homebrew はすでにインストールされています"
    fi
}

setup_zprofile() {
    echo "Homebrew のパス設定を更新中..."
    # zprofile シンボリックリンク
    rm -f "$HOME/.zprofile"
    ln -s "$HOME/dotfiles/.zprofile" "$HOME/.zprofile"

    if ! grep -q '/opt/homebrew/bin/brew shellenv' "$HOME/dotfiles/.zprofile"; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/dotfiles/.zprofile"
    fi

    source "$HOME/.zprofile"
    echo "Homebrew のパス設定が完了 ✅"
}

# Git の設定を適用
setup_git_config() {
    ln -sf "${HOME}/dotfiles/.gitconfig" "${HOME}/.gitconfig"
    ln -sf "${HOME}/dotfiles/.gitignore_global" "${HOME}/.gitignore_global"
    git config --global core.excludesfile "${HOME}/.gitignore_global"
    echo "Git 設定を適用しました ✅"
}

# シェルの設定を適用
setup_shell_config() {
    echo "シェルの設定を適用中..."
    ln -sf "${HOME}/dotfiles/.zshrc" "${HOME}/.zshrc"
    echo "シェルの設定の適用完了 ✅"
}

# Brewfile に記載されているパッケージをインストール
install_brewfile() {
    local brewfile_path="$HOME/dotfiles/Brewfile"
    
    if [[ ! -f "$brewfile_path" ]]; then
        echo "Warning: $brewfile_path が見つかりません。スキップします。"
        return
    fi

    echo "Homebrew パッケージの状態を確認中..."

    # Brewfile からインストールすべきパッケージを1行ずつ処理
    while IFS= read -r line; do
        # コメントや空行をスキップ
        [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue

        # "brew" または "cask" で始まる行をパース
        if [[ "$line" =~ ^brew\ \"(.*)\"$ ]]; then
            package_name="${BASH_REMATCH[1]}"
            
            # `brew list` で確認し、未インストールならインストール
            if ! brew list --formula | grep -q "^$package_name\$"; then
                echo "➕ $package_name をインストール中..."
                brew install "$package_name"
            else
                echo "✔ $package_name はすでにインストールされています"
            fi

        elif [[ "$line" =~ ^cask\ \"(.*)\"$ ]]; then
            package_name="${BASH_REMATCH[1]}"
            
            # `brew list --cask` で確認し、未インストールならインストール
            if ! brew list --cask | grep -q "^$package_name\$"; then
                echo "➕ $package_name をインストール中..."
                brew install --cask "$package_name"
            else
                echo "✔ $package_name はすでにインストールされています"
            fi
        fi
    done < "$brewfile_path"

    echo "Homebrew パッケージの適用が完了しました ✅"
}

# Flutter のセットアップ（Android SDK のパスを適切に設定）
setup_flutter() {
    if ! command_exists flutter; then
        echo "Flutter がインストールされていません。セットアップをスキップします。"
        return
    fi

    echo "Flutter 環境をセットアップ中..."
    
    # Android SDK のパスを適切に設定
    export ANDROID_HOME="$HOME/Library/Android/sdk"
    export ANDROID_SDK_ROOT="$ANDROID_HOME"
    export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$PATH"

    flutter doctor --android-licenses
    flutter doctor

    echo "Flutter 環境のセットアップ完了 ✅"
}

# VS Code のセットアップ
setup_vscode() {
    echo "🔄 VS Code のセットアップを開始します..."

    # VS Code がインストールされているか確認
    if ! command -v code &>/dev/null; then
        echo "❌ VS Code がインストールされていません。スキップします。"
        return
    fi

    # 設定の復元スクリプトが存在するか確認し、実行
    if [[ -f "$HOME/dotfiles/restore_vscode_settings.sh" ]]; then
        bash "$HOME/dotfiles/restore_vscode_settings.sh"
    else
        echo "⚠ VS Code の復元スクリプトが見つかりません。設定の復元をスキップします。"
    fi

    # Flutter SDK のパスを VS Code に適用
    FLUTTER_VERSION=$(ls /opt/homebrew/Caskroom/flutter | sort -rV | head -n 1)
    FLUTTER_SDK_PATH="/opt/homebrew/Caskroom/flutter/${FLUTTER_VERSION}/flutter"

    if [[ -d "$FLUTTER_SDK_PATH" ]]; then
        VSCODE_SETTINGS="$HOME/dotfiles/vscode/settings.json"
        
        echo "🔧 Flutter SDK のパスを VS Code に適用中..."
        jq --arg path "$FLUTTER_SDK_PATH" '.["dart.flutterSdkPath"] = $path' "$VSCODE_SETTINGS" > "${VSCODE_SETTINGS}.tmp" && mv "${VSCODE_SETTINGS}.tmp" "$VSCODE_SETTINGS"
        echo "✅ Flutter SDK のパスを $FLUTTER_SDK_PATH に設定しました！"
    else
        echo "⚠ Homebrew でインストールされた Flutter SDK が見つかりませんでした。"
    fi

    echo "✅ VS Code のセットアップが完了しました！"
}



# Xcode の設定
setup_xcode() {
    echo "🔄 Xcode の設定中..."

    if [[ -f "$HOME/dotfiles/restore_xcode_settings.sh" ]]; then
        bash "$HOME/dotfiles/restore_xcode_settings.sh"
        echo "✅ Xcode 設定の適用が完了しました！"
    else
        echo "⚠ restore_xcode_settings.sh が見つかりません"
    fi
}

# 実行順序
install_xcode_tools
install_rosetta
install_homebrew
setup_zprofile

# Mac のシステム設定を適用
if [[ -f "$HOME/dotfiles/setup_mac_settings.sh" ]]; then
    source "$HOME/dotfiles/setup_mac_settings.sh"
else
    echo "⚠ setup_mac_settings.sh が見つかりません"
fi

setup_git_config
setup_shell_config
install_brewfile
setup_flutter
setup_vscode
setup_xcode

end_time=$(date +%s)
elapsed_time=$((end_time - start_time))
echo "セットアップ完了 🎉（所要時間: ${elapsed_time}秒）"

exec $SHELL -l