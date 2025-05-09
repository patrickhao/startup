#!/bin/bash

HERE="$(pwd)"

cd $HOME

sudo apt update &&
  sudo apt install -y vim curl wget git zsh tmux &&
  sudo apt install -y build-essential python3 fzf ripgrep luarocks

if [ ! -e $HOME/softwares ]; then mkdir $HOME/softwares; fi
SOFTWARES="$HOME/softwares"

# zsh
echo "installing oh-my-zsh"

rm -rf ~/.oh-my-zsh
git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh

cp $HERE/zsh/.zshrc ~/.zshrc

chsh -s $(which zsh)

git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/jeffreytse/zsh-vi-mode $HOME/.oh-my-zsh/custom/plugins/zsh-vi-mode

# tmux
echo "installing tmux"

rm -rf ~/.tmux/plugins/tpm
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

cp $HERE/tmux/.tmux.conf $HOME/

# vim
echo "installing lazyvim"

pushd $SOFTWARES

rm -rf fdfind
curl -LO https://github.com/sharkdp/fd/releases/download/v10.2.0/fd-v10.2.0-x86_64-unknown-linux-gnu.tar.gz
tar -C $SOFTWARES -xzf fd-v10.2.0-x86_64-unknown-linux-gnu.tar.gz
mv fd-v10.2.0-x86_64-unknown-linux-gnu fdfind

echo 'export PATH=$PATH:$HOME/softwares/fdfind' >>~/.zshrc

rm -rf $SOFTWARES/nvim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
tar -C $SOFTWARES -xzf nvim-linux-x86_64.tar.gz
mv nvim-linux-x86_64 nvim

rm -rf $HOME/.config/nvim
git clone https://github.com/LazyVim/starter ~/.config/nvim

cp $HERE/nvim/config/options.lua ~/.config/nvim/lua/config/options.lua

cp $HERE/nvim/plugins/*.lua ~/.config/nvim/lua/plugins/

rm -rf ~/.config/nvim/.git

echo 'export PATH=$PATH:$HOME/softwares/nvim/bin' >>~/.zshrc

# lazygit
curl -LO https://github.com/jesseduffield/lazygit/releases/download/v0.49.0/lazygit_0.49.0_Linux_x86_64.tar.gz

rm -rf $SOFTWARES/lazygit
mkdir $SOFTWARES/lazygit

tar -C $SOFTWARES/lazygit -xzf lazygit_0.49.0_Linux_x86_64.tar.gz

echo 'export PATH=$PATH:$HOME/softwares/lazygit' >>~/.zshrc

# golang
echo "installing golang"
curl -LO https://go.dev/dl/go1.24.2.linux-amd64.tar.gz

rm -rf $SOFTWARES/go
tar -C $SOFTWARES/ -xzf go1.24.2.linux-amd64.tar.gz

echo 'export PATH=$PATH:$HOME/softwares/go/bin' >>~/.zshrc

popd
