#!/bin/bash

start_time=$(date +%s)

echo "Macをセットアップ中..."

# コマンドの存在をチェックする関数
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Homebrew のインストール
install_homebrew() {
    if ! command_exists brew; then
        echo "Homebrew をインストール中..."

        # 公式の `curl` を使ったインストール
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Homebrew のパス設定
        echo '# Set PATH, MANPATH, etc., for Homebrew.' >> ~/.zprofile
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        
        # 即座に設定を反映
        source ~/.zprofile

        echo "Homebrew のインストール完了 ✅"
    else
        echo "Homebrew はすでにインストールされています"
    fi
}

# Brewfile からパッケージを一括インストール
install_brewfile() {
    local brewfile_path="${HOME}/dotfiles/Brewfile"
    if [[ -f "$brewfile_path" ]]; then
        echo "Homebrew パッケージの状態を確認中..."
        if timeout 10 brew bundle check --file="$brewfile_path" > /dev/null 2>&1; then
            echo "すべての Homebrew パッケージはすでにインストールされています ✅"
        else
            echo "Homebrew パッケージをインストール中..."
            brew bundle --file="$brewfile_path"
            echo "Homebrew パッケージのインストール完了 ✅"
        fi
    else
        echo "Warning: $brewfile_path が見つかりません。スキップします。"
    fi
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
    echo "シェル設定を適用中..."
    
    ln -sf "${HOME}/dotfiles/.zshrc" "${HOME}/.zshrc"
    
    # すでに .zshrc に "source ~/.zshrc" があるかチェックし、なければ追加
    if ! grep -q 'source ~/.zshrc' ~/.zshrc; then
        echo 'source ~/.zshrc' >> ~/.zshrc
    fi
    
    echo "シェル設定の適用完了 ✅"
}

# Xcode Command Line Tools のインストール（非対話的）
install_xcode_cli() {
    if ! xcode-select -p &>/dev/null; then
        echo "Xcode Command Line Tools をインストール中..."
        softwareupdate --install -a
        echo "Xcode Command Line Tools のインストール完了 ✅"
    else
        echo "Xcode Command Line Tools はすでにインストールされています"
    fi
}

# Apple シリコン向け Rosetta 2 のインストール
install_rosetta() {
    if [[ "$(uname -m)" == "arm64" ]]; then
        if ! softwareupdate --history | grep -q Rosetta; then
            echo "Rosetta 2 をインストール中..."
            softwareupdate --install-rosetta --agree-to-license
            echo "Rosetta 2 のインストール完了 ✅"
        else
            echo "Rosetta 2 はすでにインストールされています"
        fi
    fi
}

# Flutter のセットアップ
setup_flutter() {
    if ! command_exists flutter; then
        echo "Flutter はインストールされていません。セットアップをスキップします。"
        return
    fi

    echo "Flutter 環境をセットアップ中..."
    
    # Android SDK ライセンスの同意（flutter doctor 実行時に確認）
    flutter doctor --android-licenses

    # Flutter のセットアップ状況を確認
    flutter doctor

    echo "Flutter 環境のセットアップ完了 ✅"
}

# Homebrew 経由でインストールするコマンドの統一処理
install_brew_package() {
    local package="$1"
    if ! command_exists "$package"; then
        echo "$package をインストール中..."
        brew install "$package"
        echo "$package のインストール完了 ✅"
    else
        echo "$package はすでにインストールされています"
    fi
}

# 全体のセットアップを実行
setup_git_config
setup_shell_config
install_xcode_cli
install_homebrew
install_rosetta
install_brewfile
setup_flutter

# シェルの再読み込み、パスの反映
exec $SHELL -l

end_time=$(date +%s)
elapsed_time=$((end_time - start_time))

echo "セットアップ完了 🎉（所要時間: ${elapsed_time}秒）"
