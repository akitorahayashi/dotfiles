# Homebrew のパスを設定
eval "$(/opt/homebrew/bin/brew shellenv)"

# Android SDK の環境変数
export ANDROID_HOME=$HOME/Library/Android/sdk
export ANDROID_SDK_ROOT=$ANDROID_HOME
export PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$PATH

# Flutter のパスを設定
export PATH="$HOME/flutter/bin:$PATH"

# 環境変数を適用
source ~/.zshrc
