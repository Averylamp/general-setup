#!/bin/bash

echo Makes common directories
mkdir -p ~/Downloads ~/Developer/installs

echo Installing apt packages
sudo apt-get update
sudo apt-get -y install parallel vim git gnupg2 tmux landscape-common figlet fonts-powerline openssh-server emacs

echo Installs subl
sudo wget -O /usr/local/bin/subl https://raw.githubusercontent.com/aurora/rmate/master/rmate
sudo chmod a+x /usr/local/bin/subl

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

echo installs spacemacs
git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d

echo Updates motd
line=$(hostname)
sudo grep -qxF "figlet $line" /etc/update-motd.d/00-header || echo "figlet $line" | sudo tee -a /etc/update-motd.d/00-header


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

    echo -e "Printing gpg pubkey\n\n"
    gpg --armor --export "Avery Lamp"
    echo -e "\n"

fi

GPG_KEY_ID=$(gpg --list-secret-keys --keyid-format LONG "Avery Lamp" | grep sec | awk '{ print $2 }' | awk '{split($0, a, "/"); print a[2]}')
git config --global user.signingkey $GPG_KEY_ID
git config --global commit.gpgsign true

