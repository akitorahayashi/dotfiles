#!/bin/bash

start_time=$(date +%s)
echo "Macをセットアップ中..."

command_exists() {
    command -v "$1" >/dev/null 2>&1
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
    echo "シェル設定の適用完了 ✅"
}

# SSH キーの設定（汎用化）
setup_ssh() {
    echo "SSH キーの設定を開始します..."

    # 既存の SSH キーがあるか確認
    if [[ -f "$HOME/.ssh/id_ed25519" ]]; then
        echo "SSH キーは既に存在します ✅"
    else
        # Git の設定からメールアドレスを取得
        GIT_EMAIL=$(git config --global user.email)
        
        # メールアドレスが設定されていない場合、ユーザーに入力を求める
        if [[ -z "$GIT_EMAIL" ]]; then
            read -p "Git のメールアドレスを入力してください: " GIT_EMAIL
            git config --global user.email "$GIT_EMAIL"
        fi

        echo "SSH キーを作成中（メール: $GIT_EMAIL）..."
        ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$HOME/.ssh/id_ed25519" -N ""

        echo "SSH キーの作成が完了しました ✅"
    fi

    # SSH エージェントを起動し、鍵を追加
    eval "$(ssh-agent -s)"
    ssh-add "$HOME/.ssh/id_ed25519"

    # SSH 公開鍵を表示して GitHub に手動登録するよう促す
    echo "⬇⬇⬇ GitHub にこの公開鍵を追加してください ⬇⬇⬇"
    cat "$HOME/.ssh/id_ed25519.pub"
    echo "⬆⬆⬆ GitHub SSH 設定ページ: https://github.com/settings/keys ⬆⬆⬆"

    echo "SSH 設定完了 ✅"
}

# GitHub のリモート URL を SSH に変更（汎用化）
setup_git_ssh() {
    echo "Git のリモート URL をチェック中..."
    GIT_REMOTE=$(git remote get-url origin 2>/dev/null)

    if [[ -z "$GIT_REMOTE" ]]; then
        echo "Git リモートが設定されていません。スキップします。"
        return
    fi

    if [[ $GIT_REMOTE == https://github.com/* ]]; then
        SSH_REMOTE=$(echo "$GIT_REMOTE" | sed -E 's|https://github.com/|git@github.com:|')
        git remote set-url origin "$SSH_REMOTE"
        echo "リモート URL を SSH に変更しました: $SSH_REMOTE ✅"
    else
        echo "Git のリモート URL はすでに SSH になっています ✅"
    fi
}

# SSH エージェントを自動起動するように設定
setup_ssh_agent() {
    if ! grep -q "ssh-agent -s" "$HOME/.zshrc"; then
        echo "SSH エージェントの自動起動設定を追加中..."
        echo 'eval "$(ssh-agent -s)"' >> "$HOME/.zshrc"
        echo 'ssh-add ~/.ssh/id_ed25519' >> "$HOME/.zshrc"
        echo "SSH エージェントの設定を `.zshrc` に追加しました ✅"
    else
        echo "SSH エージェントの設定はすでに `.zshrc` にあります ✅"
    fi
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

# Flutter のセットアップ
setup_flutter() {
    if ! command_exists flutter; then
        echo "Flutter がインストールされていません。セットアップをスキップします。"
        return
    fi

    echo "Flutter 環境をセットアップ中..."
    
    flutter doctor --android-licenses
    flutter doctor

    echo "Flutter 環境のセットアップ完了 ✅"
}

# 実行順序
install_xcode_cli
install_rosetta
install_homebrew
setup_zprofile
setup_git_config
setup_shell_config
setup_ssh
setup_git_ssh
setup_ssh_agent
install_brewfile
setup_flutter

exec $SHELL -l
end_time=$(date +%s)
elapsed_time=$((end_time - start_time))
echo "セットアップ完了 🎉（所要時間: ${elapsed_time}秒）"
