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

    # Homebrew に記録されているパッケージをクリーンアップ（Brewfile にないものは削除）
    echo "Brewfile に記載されていないパッケージを削除中..."
    brew bundle cleanup --file="$brewfile_path" --force
    echo "不要なパッケージを削除しました ✅"

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

# VSCode のセットアップ
setup_vscode() {
    echo "VS Code のセットアップを開始します..."

    if ! command -v code &>/dev/null; then
        echo "VS Code がインストールされていません。セットアップをスキップします。"
        return
    fi

    mkdir -p "$HOME/Library/Application Support/Code/User"

    ln -sf "$HOME/dotfiles/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
    ln -sf "$HOME/dotfiles/vscode/keybindings.json" "$HOME/Library/Application Support/Code/User/keybindings.json"

    if [[ -f "$HOME/dotfiles/vscode/extensions.txt" ]]; then
        while IFS= read -r extension; do
            code --install-extension "$extension" --force
        done < "$HOME/dotfiles/vscode/extensions.txt"
    fi

    echo "✅ VS Code のセットアップが完了しました！"
}

# VSCode の設定自動同期のセットアップ
start_vscode_sync() {
    echo "VS Code の設定同期を開始します..."

    # スクリプトが実行可能になっているか確認
    chmod +x "$HOME/dotfiles/sync_vscode.sh"

    # 既に実行されている場合はスキップ
    if pgrep -f "fswatch.*settings.json" > /dev/null; then
        echo "VS Code の同期スクリプトは既に実行中です。スキップします。"
    else
        nohup "$HOME/dotfiles/sync_vscode.sh" > /dev/null 2>&1 &
        echo "✅ VS Code の設定同期をバックグラウンドで開始しました！"
    fi
}


# 実行順序
install_xcode_tools
install_rosetta
install_homebrew
setup_zprofile

# Mac のシステム設定を適用
source "$HOME/dotfiles/setup_mac_settings.sh"

setup_git_config
setup_shell_config
install_brewfile
setup_flutter
setup_vscode
start_vscode_sync

end_time=$(date +%s)
elapsed_time=$((end_time - start_time))
echo "セットアップ完了 🎉（所要時間: ${elapsed_time}秒）"

exec $SHELL -l