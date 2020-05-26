#!/bin/bash

echo Installing apt packages
sudo apt-get update
sudo apt-get -y install parallel vim git

echo Setup Zsh
sudo apt-get -y install zsh curl wget

echo install oh my zsh
yes | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

echo copying dotfiles
cp dotfiles/.[^.]*  $HOME

sudo chsh -s $(which zsh) $USER


git config --global user.email "averylamp@gmail.com"
git config --global user.name "Avery Lamp"
git config --global core.editor "vim"

