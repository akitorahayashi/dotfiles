#!/bin/bash

start_time=$(date +%s)
echo "Macをセットアップ中..."

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

install_xcode_cli() { ... }
install_rosetta() { ... }

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

    # Brew shellenv 行がなければ追記
    if ! grep -q '/opt/homebrew/bin/brew shellenv' "$HOME/dotfiles/.zprofile"; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/dotfiles/.zprofile"
    fi

    source "$HOME/.zprofile"
    echo "Homebrew のパス設定が完了 ✅"
}

setup_git_config() { ... }
setup_shell_config() { ... }

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

setup_flutter() { ... }

# 実行順を最適化:
install_xcode_cli
install_rosetta
install_homebrew
setup_zprofile
setup_git_config
setup_shell_config
install_brewfile
setup_flutter

exec $SHELL -l
end_time=$(date +%s)
elapsed_time=$((end_time - start_time))
echo "セットアップ完了 🎉（所要時間: ${elapsed_time}秒）"
