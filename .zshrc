# Homebrew のパスを設定 (Apple Silicon)
if [[ -x "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Android SDK の環境変数
export ANDROID_HOME="$HOME/Library/Android/sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"

for dir in "$ANDROID_HOME/cmdline-tools/latest/bin" "$ANDROID_HOME/tools/bin" "$ANDROID_HOME/platform-tools"; do
    if [[ ":$PATH:" != *":$dir:"* ]]; then
        export PATH="$dir:$PATH"
    fi
done

# Homebrew でインストールされた Flutter のパスを設定
if [[ -x "/opt/homebrew/bin/flutter" ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
fi
