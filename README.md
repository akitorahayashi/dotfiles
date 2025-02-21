# Mac Environment Setup Script

This repository provides `install.sh`, a script to automate macOS environment setup.  
By running this script, you can apply Git configurations, install Homebrew, set up Xcode Command Line Tools, install various development tools, and configure SSH keys for GitHub.

# Setup Instructions

## 1. Clone the Repository

```sh
git clone git@github.com:akitorahayashi/dotfiles.git ~/dotfiles
cd ~/dotfiles
```
## 2. Grant Execution Permission
```sh
chmod +x install.sh
```
## 3. Run the Setup Script
```sh
./install.sh
```
This will automatically start the environment setup process:
- Installs Homebrew if it is not already installed.
- Installs Rosetta 2 if running on Apple Silicon (M1/M2).
- Installs Xcode Command Line Tools if they are missing.
- Installs apps and CLI tools specified in the `Brewfile`.
## 4. Create and Register an SSH Key for GitHub
If no SSH key exists, the script will generate one.
You need to add the public key to GitHub manually.
```sh
cat ~/.ssh/id_ed25519.pub
```
Copy the output and add it to your GitHub SSH Key Settings.
Then, verify the SSH connection:
```sh
ssh -T git@github.com
```
If you see the following message, SSH authentication was successful:
```sh
Hi akitorahayashi! You've successfully authenticated, but GitHub does not provide shell access.
```
## 5. Reload the Shell
After setup is complete, reload the shell to apply the changes.
```sh
exec $SHELL -l
```
# Features
## 1. Git Configuration
`dotfiles/.gitconfig` and `dotfiles/.gitignore_global` are symlinked to the home directory.

## 2. Homebrew Installation
Installs Homebrew if it is not already installed.
Uses `/opt/homebrew` for Apple Silicon (ARM) devices.

## 3. Install Packages from Brewfile
Installs packages listed in `Brewfile` using `brew bundle`.
Main packages included:
- **CLI Tools**: `git`, `gh`, `cocoapods`, `zsh`, `fdupes`
- **Development Tools**: `visual-studio-code`, `android-studio`, `flutter`
- **Other Apps**: `google-chrome`, `slack`, `spotify`, `zoom`, `notion`, `figma`, `cleanmymac`

> **Note**: Xcode is **not installed via Homebrew**.  
> Please install Xcode manually from the Mac App Store.

## 4. Xcode Command Line Tools Installation
Installs Xcode Command Line Tools if missing.

## 5. Rosetta 2 Installation for Apple Silicon
Installs Rosetta 2 **only on Apple M1/M2 Macs**.  
Newer Apple Silicon chips (M3 and later) do **not** require Rosetta 2.

## 6. Flutter Setup
If Flutter is installed via Homebrew, it will execute
`flutter doctor --android-licenses` to ensure a proper setup.

## 7. SSH Key Generation and Configuration
Generates a new SSH key (`id_ed25519`) if none exists.
Adding the public key to GitHub allows passwordless `git push` operations.