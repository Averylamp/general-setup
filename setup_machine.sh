#!/bin/bash

echo Installing apt packages
sudo apt-get update
sudo apt-get -y install parallel vim git gnupg2 tmux

echo Setup Zsh
sudo apt-get -y install zsh curl wget

echo install oh my zsh
yes | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

echo installs oh my tmux

git clone https://github.com/gpakosz/.tmux.git ~/.tmux
ln -s -f ~/.tmux/.tmux.conf ~/.tmux.conf
cp ~/.tmux/.tmux.conf.local ~


echo copying dotfiles
cp dotfiles/.[^.]*  $HOME

sudo chsh -s $(which zsh) $USER


git config --global user.email "averylamp@gmail.com"
git config --global user.name "Avery Lamp"
git config --global core.editor "vim"

yes "" | ssh-keygen -t rsa -b 4096 -N ""
echo -e "SSH pubkey for github\n\n"
cat ~/.ssh/id_rsa.pub
echo -e "\n"

echo -e "GPG key generation\n"

if ! gpg --list-keys "Avery Lamp" ; then
    echo -e "Creating gpg key\n"

    gpg --batch --gen-key gen-key-script
    gpg --armor --export "Avery Lamp"

fi
