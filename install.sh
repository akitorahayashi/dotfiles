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

install_brewfile() {
    local brewfile_path="$HOME/dotfiles/Brewfile"
    if [[ -f "$brewfile_path" ]]; then
        echo "Homebrew パッケージの状態を確認中..."
        if ! brew bundle check --file="$brewfile_path" > /dev/null 2>&1; then
            echo "Homebrew パッケージをインストール中..."
            brew bundle --file="$brewfile_path"
            echo "Homebrew パッケージのインストール完了 ✅"
        else
            echo "すべての Homebrew パッケージはすでにインストールされています ✅"
        fi
    else
        echo "Warning: $brewfile_path が見つかりません。スキップします。"
    fi
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

# 実行順序
install_xcode_tools
install_rosetta
install_homebrew

# Mac のシステム設定を適用
source "$HOME/dotfiles/setup_mac_settings.sh"

setup_zprofile
setup_git_config
setup_shell_config
install_brewfile
setup_flutter

end_time=$(date +%s)
elapsed_time=$((end_time - start_time))
echo "セットアップ完了 🎉（所要時間: ${elapsed_time}秒）"

exec $SHELL -l