#!/bin/bash

# Dotfiles initialization script for Ubuntu
# Sets up zsh, tmux, starship, fzf and related tools
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/samm393/dotfiles/main/init.sh | bash

set -e  # Exit on error

# Configuration
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/samm393/dotfiles.git}"
DOTFILES_DIR="$HOME/.dotfiles"

echo "🚀 Starting dotfiles initialization for Ubuntu..."

# Clone dotfiles repo if it doesn't exist
if [[ ! -d "$DOTFILES_DIR" ]]; then
    echo "📦 Cloning dotfiles repository..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR" 2>/dev/null || {
        # If git clone fails, we might not have git yet
        echo "📦 Installing git first..."
        sudo apt-get update
        sudo apt-get install -y git
        git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
    }
else
    echo "✅ Dotfiles directory already exists at $DOTFILES_DIR"
    echo "🔄 Pulling latest changes..."
    cd "$DOTFILES_DIR" && git pull
fi

echo "📁 Dotfiles directory: $DOTFILES_DIR"

# Update package list
echo "🔄 Updating package list..."
sudo apt-get update

# Install base packages
echo "📦 Installing base packages..."
sudo apt-get install -y zsh tmux git curl

# Install fzf from git (Ubuntu apt version is too old)
if [[ ! -d "$HOME/.fzf" ]]; then
    echo "📦 Installing fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    "$HOME/.fzf/install" --all --no-bash --no-fish
else
    echo "✅ fzf already installed"
fi

# Install starship prompt
if ! command -v starship &> /dev/null; then
    echo "📦 Installing starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
else
    echo "✅ starship already installed"
fi

# Install zsh-autosuggestions
AUTOSUGGESTIONS_DIR="$HOME/.zsh/zsh-autosuggestions"
if [[ ! -d "$AUTOSUGGESTIONS_DIR" ]]; then
    echo "📦 Installing zsh-autosuggestions..."
    mkdir -p "$HOME/.zsh"
    git clone https://github.com/zsh-users/zsh-autosuggestions "$AUTOSUGGESTIONS_DIR"
else
    echo "✅ zsh-autosuggestions already installed"
fi

# Install zsh-syntax-highlighting
SYNTAX_HIGHLIGHTING_DIR="$HOME/.zsh/zsh-syntax-highlighting"
if [[ ! -d "$SYNTAX_HIGHLIGHTING_DIR" ]]; then
    echo "📦 Installing zsh-syntax-highlighting..."
    mkdir -p "$HOME/.zsh"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$SYNTAX_HIGHLIGHTING_DIR"
else
    echo "✅ zsh-syntax-highlighting already installed"
fi

# Backup existing configs
echo "💾 Backing up existing configs..."
for file in .zshrc .tmux.conf; do
    if [[ -f "$HOME/$file" ]] && [[ ! -L "$HOME/$file" ]]; then
        backup="$HOME/${file}.backup.$(date +%Y%m%d_%H%M%S)"
        echo "   Backing up $HOME/$file to $backup"
        mv "$HOME/$file" "$backup"
    fi
done

# Create .zshrc adapted for Linux
echo "🔗 Creating .zshrc..."
cat > "$HOME/.zshrc" << 'EOF'
# Starship prompt
eval "$(starship init zsh)"

# zsh-autosuggestions
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# zsh-syntax-highlighting
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ls with colors
alias ls='ls --color=auto'

# fzf
if [ -f ~/.fzf.zsh ]; then
    source ~/.fzf.zsh
    export FZF_CTRL_R_OPTS="--tmux"
fi

# Conda (if installed)
if [ -f "$HOME/miniconda3/bin/conda" ] || [ -f "$HOME/anaconda3/bin/conda" ]; then
    eval "$(conda "shell.$(basename "${SHELL}")" hook)"
fi

# Local bin environment (if exists)
if [ -f "$HOME/.local/bin/env" ]; then
    . "$HOME/.local/bin/env"
fi
EOF

echo "✅ Created .zshrc"

# Symlink tmux.conf
if [[ -f "$DOTFILES_DIR/.tmux.conf" ]]; then
    ln -sf "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"
    echo "✅ Linked .tmux.conf"
else
    echo "⚠️  .tmux.conf not found in $DOTFILES_DIR"
fi

# Change default shell to zsh
if [[ "$SHELL" != */zsh ]]; then
    echo "🐚 Setting zsh as default shell..."
    chsh -s $(which zsh)
    echo "⚠️  You'll need to log out and back in for the shell change to take effect"
else
    echo "✅ zsh is already the default shell"
fi

echo ""
echo "✨ Setup complete!"
echo "🔄 Run 'zsh' to start using zsh, then 'source ~/.zshrc' to apply changes"
