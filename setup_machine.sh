#!/bin/bash

echo Makes common directories
mkdir -p ~/Downloads ~/Developer/installs

echo Installing general apt packages
sudo apt-get update
sudo apt-get -y install landscape-common figlet fonts-powerline apt-transport-https \
	   build-essential ca-certificates curl gnupg-agent software-properties-common fonts-font-awesome \
     cmake libfontconfig libfontconfig1-dev libxkbcommon-dev libsdl-pango-dev playerctl xclip xscreensaver mplayer scrot

#echo Install xscreensaver
#wget https://raw.githubusercontent.com/graysky2/xscreensaver-aerial/master/atv4-4k.sh


echo Installing app packages
sudo apt-get -y install parallel vim git gnupg2 tmux openssh-server libxcb-xfixes0-dev

echo Install Python
sudo apt-get install python3.8-venv python3.8
wget https://bootstrap.pypa.io/get-pip.py
sudo python3.8 get-pip.py
rm get-pip.py
pip install yapf importmagic isort epc toml

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

echo Install Emacs
sudo apt-get install -y imagemagick libjansson4 libjansson-dev
wget -qO- http://ftp.gnu.org/gnu/emacs/emacs-28.1.tar.xz | tar -xJ
sudo apt-get install -y gnutls-bin libc6-dev pkg-config libgnutls28-dev libncurses5-dev libpng-dev libtiff5-dev libgif-dev xaw3dg-dev zlib1g-dev libice-dev libsm-dev libx11-dev libxext-dev libxi-dev libxmu-dev libxmuu-dev libxpm-dev libxrandr-dev libxt-dev  libxtst-dev libxv-dev elpa-yasnippet-snippets
cd emacs-28.1
./configure --wtih-json
make -j
sudo make install
cd ../
rm -rf emacs-28.1


echo Install spacemacs
git clone -b develop https://github.com/syl20bnr/spacemacs ~/.emacs.d
rsync -av dotfiles/.  $HOME
emacs -nw -batch -u "${UNAME}" -q -kill
echo fs.inotify.max_user_watches=524289 | sudo tee -a /etc/sysctl.conf

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

echo Install Docker Composer
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose


echo Installs Kubectl
sudo apt-get update && sudo apt-get install -y apt-transport-https gnupg2
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl

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
sudo apt-get -y install libdbus-1-dev pkg-config libssl-dev libsensors-dev
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
echo Install i3-status-rust
cargo install --git https://github.com/greshake/i3status-rust i3status-rs

echo Install Alacritty
sudo apt-get install cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev
cargo install alacritty

echo Updates motd
line=$(hostname)
sudo grep -qxF "figlet $line" /etc/update-motd.d/00-header || echo "figlet $line" | sudo tee -a /etc/update-motd.d/00-header

echo Install Node
curl -fsSL https://deb.nodesource.com/setup_16.x |  sudo bash
sudo apt-get -y update && sudo apt-get -y install nodejs
sudo npm install -g npm
sudo npm install -g pyright vscode-json-languageserver yaml-language-server bash-language-server

echo Install Spotify
curl -sS https://download.spotify.com/debian/pubkey_5E3C45D7B312C643.gpg | sudo apt-key add -
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
sudo apt-get -y update && sudo apt-get -y install spotify-client

echo Install Slack
wget https://downloads.slack-edge.com/releases/linux/4.17.0/prod/x64/slack-desktop-4.17.0-amd64.deb -O slack.deb
sudo dpkg -i slack.deb
sudo apt-get update && sudo apt-get install slack-desktop
rm slack.deb

echo Install Zoom
wget https://zoom.us/client/latest/zoom_amd64.deb -O zoom.deb
sudo apt-get install -y libgl1-mesa-glx libegl1-mesa libxcb-xtest0
sudo dpkg -i zoom.deb
rm zoom.deb

echo Install Postman
wget https://dl.pstmn.io/download/latest/linux64 -O postman.tar.gz
tar xvf postman.tar.gz
sudo mv Postman /usr/local/lib/
sudo rm -rf Postman
sudo rm postman.tar.gz
sudo cat > /usr/local/share/applications/postman.desktop <<EOL
[Desktop Entry]
Name=Postman
GenericName=Web Requests
Comment=Send Web Requests
MimeType=text/english;text/plain;text/x-makefile;text/x-c++hdr;text/x-c++src;text/x-chdr;text/x-csrc;text/x-java;text/x-moc;text/x-pascal;text/x-tcl;text/x-tex;application/x-shellscript;text/x-c;text/x-c++;
Exec=Postman
Icon=Postman
Type=Application
Terminal=false
Categories=Development;
Keywords=Text;Editor;Web
EOL

echo Install MongoDB Compass
wget https://downloads.mongodb.com/compass/mongodb-compass_1.29.6_amd64.deb -O mongodb_compass.deb
sudo dpkg -i mongodb_compass.deb
rm mongodb_compass.deb

echo Add Github to ssh config
touch ~/.ssh/config
grep -Fxq "Host github.com" ~/.ssh/config ||  {
cat >> /home/avery/.ssh/config <<EOL
Host github.com
    User git
    Hostname github.com
    PreferredAuthentications publickey
    IdentityFile /home/avery/.ssh/github
EOL
}

sudo chsh -s $(which zsh) $USER


echo Configuring Git
git config --global user.email "averylamp@gmail.com"
git config --global user.name "Avery Lamp"
git config --global core.editor "vim"

yes "" | ssh-keygen -t rsa -b 4096 -N ""
echo -e "SSH pubkey for id_rsa\n\n"
cat ~/.ssh/id_rsa.pub
echo -e "\n"

yes "" | ssh-keygen -t rsa -b 4096 -f /home/avery/.ssh/github -N  ""
echo -e "SSH pubkey for github\n\n"
cat ~/.ssh/github.pub
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

echo Copying dotfiles
rsync -av dotfiles/.  $HOME
rsync -av .config/ $HOME/.config/
