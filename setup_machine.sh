!#/bin/bash

echo Installing apt packages
sudo apt-get install parallel vim git

echo Setup Zsh
sudo apt-get install zsh curl wget

echo copying dotfiles
cp dotfiles/* ~/

echo install oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

sudo chsh -s $(which zsh)



