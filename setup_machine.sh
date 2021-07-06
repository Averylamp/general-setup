#!/bin/bash

echo Makes common directories
mkdir -p ~/Downloads ~/Developer/installs

echo Installing general apt packages
sudo apt-get update
sudo apt-get -y install landscape-common figlet fonts-powerline apt-transport-https \
	build-essential ca-certificates curl gnupg-agent software-properties-common fonts-font-awesome


echo Installing app packages
sudo apt-get -y install parallel vim git gnupg2 tmux openssh-server


echo Install i3
sudo apt-get -y install rofi i3 autojump
echo Install kitty
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
sudo ln -s $HOME/.local/kitty.app/bin/kitty /usr/bin/kitty
sudo cp $HOME/.local/kitty.app/share/applications/kitty.dekstop /usr/share/applications


echo Installing tools
sudo apt-get -y install htop nload iperf vnstat lm-sensors hddtemp gnome-tweaks silversearcher-ag ripgrep

echo Installs subl
sudo wget -O /usr/local/bin/subl https://raw.githubusercontent.com/aurora/rmate/master/rmate
sudo chmod a+x /usr/local/bin/subl

echo Setup Zsh
sudo apt-get -y install zsh curl wget

echo install zinit
mkdir $HOME/.zinit
git clone https://github.com/zdharma/zinit.git ~/.zinit/bin

echo install oh my zsh
yes | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

echo installs oh my tmux

git clone https://github.com/gpakosz/.tmux.git ~/.tmux
ln -s -f ~/.tmux/.tmux.conf ~/.tmux.conf
cp ~/.tmux/.tmux.conf.local ~

echo installs vscode
wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
sudo add-apt-repository -r "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
sudo apt-get install code

echo Install spacemacs
sudo apt-get -y install emacs
git clone -b develop https://github.com/syl20bnr/spacemacs ~/.emacs.d

echo Install Docker
sudo apt-get remove docker docker-engine docker.io containerd runc
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository -r \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker $USER

echo Copies .configs over to configs
rsync -rv --progress .config $HOME/.config

echo Installs some fonts
mkdir -p ~/.fonts/adobe-fonts/source-code-pro
git clone https://github.com/adobe-fonts/source-code-pro.git ~/.fonts/adobe-fonts/source-code-pro
find ~/.fonts/ -iname '*.ttf' -exec echo \{\} \;
fc-cache -f -v ~/.fonts/adobe-fonts/source-code-pro
echo "finished installing"

echo Install Rust
echo Installing Rust Dependencies
sudo apt-get update
sudo apt-get -y install libdbus-1-dev pkg-config libssl-dev
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
echo Install i3-status-rust
cargo install --git https://github.com/greshake/i3status-rust i3status-rs

echo Updates motd
line=$(hostname)
sudo grep -qxF "figlet $line" /etc/update-motd.d/00-header || echo "figlet $line" | sudo tee -a /etc/update-motd.d/00-header



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

echo copying dotfiles
cp dotfiles/.[^.]*  $HOME
