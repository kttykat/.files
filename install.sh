#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

distro=$(uname -n)

if [ "$distro" != "pop-os" ]; then
  echo "This script can only run on Pop!_OS"
  exit 1
else
    echo "Pop!_OS detected, proceeding with the script..."
  # Add the commands that you want to run only on Pop!_OS


    echo "Cloning the repo into ~/.config/dotfiles"
    git clone https://github.com/kttykat/.files ~/.config/dotfiles

    # Installing stuff

    echo "Installing ~all required pkgs"
    sudo apt-get install curl cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3 libxext-dev libxcb1-dev libxcb-damage0-dev libxcb-dpms0-dev libxcb-xfixes0-dev libxcb-shape0-dev libxcb-render-util0-dev libxcb-render0-dev libxcb-randr0-dev libxcb-composite0-dev libxcb-image0-dev libxcb-present-dev libxcb-glx0-dev libpixman-1-dev libdbus-1-dev libconfig-dev libgl-dev libegl-dev libpcre2-dev libevdev-dev uthash-dev libev-dev libx11-xcb-dev meson -y
    sudo apt-get git -y

    # Required stuff

    echo "\n\nStarship: "

    curl -sS https://starship.rs/install.sh | sh

    echo "\n\nZSH: "

    sudo apt-get install zsh -y

    echo "\n\nOh My ZSH: "

    SHELL=$(ps -p $$ | awk '{print $4}' | tail -n1)

    if [ "$SHELL" != "/bin/zsh" ]; then
    env zsh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    exec zsh
    else
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi


    echo "\n\nI3: "

    /usr/lib/apt/apt-helper download-file https://debian.sur5r.net/i3/pool/main/s/sur5r-keyring/sur5r-keyring_2022.02.17_all.deb keyring.deb SHA256:52053550c4ecb4e97c48900c61b2df4ec50728249d054190e8a0925addb12fc6
    sudo apt install ./keyring.deb
    echo "deb http://debian.sur5r.net/i3/ $(grep '^DISTRIB_CODENAME=' /etc/lsb-release | cut -f2 -d=) universe" | sudo tee /etc/apt/sources.list.d/sur5r-i3.list
    sudo apt update
    sudo apt install i3 -y
    rm -r ./keyring.deb

    echo "\n\nPolybar: "
    sudo apt install polybar

    echo "\n\nNitrogen: "
    sudo apt-get -y install nitrogen

    echo "\n\nPICom: "
    cd ~/
    mkdir tmp
    cd tmp
    git clone https://github.com/yshui/picom
    cd picom
    git submodule update --init --recursive
    meson setup --buildtype=release . build
    ninja -C build
    ninja -C build install
    cd ../

    echo "\n\nRustup: "

    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

    echo "\n\nAlacritty: "
    git clone https://github.com/alacritty/alacritty/
    cd alacritty
    cargo build --release
    sudo cp target/release/alacritty /usr/local/bin
    sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
    sudo desktop-file-install extra/linux/Alacritty.desktop
    sudo update-desktop-database
    cd ../

    echo "\n\nRofi: "
    sudo apt install rofi -y

    echo "\n\nNeofetch: "
    sudo apt-get install neofetch -y

    echo "\n\nTerminal font (fira mono NF): "

    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/FiraMono.zip
    mkdir ~/.fonts
    cp FiraMono.zip ~/.fonts && cd ~/.fonts
    unzip FiraMono.zip
    fc-cache -fv

    echo "\n\nClearning tmp folder: "
    cd ~/
    sudo rm -r tmp

    echo "\n\nCopying Folders over and editing configs"

    whoami=$(whoami)

    sed -i "s/saige/$username/g" nitrogen/nitrogen.cfg

    resolution=xdpyinfo | grep dimensions | sed -r 's/^[^0-9]*([0-9]+x[0-9]+).*$/\1/'
    sed -i "s/1920x1080/$resolution/g" i3/config

    sed -i "s/saige/${username}/g" nitrogen/bg-saved.cfg
    
    cd ~/.config/dotfiles
    cp -r alacritty ~/.config/
    cp -r i3 ~/.config
    cp -r local/bin ~/.local/bin
    cp -r neofetch ~/.config
    cp -r nitrogen ~/.config
    cp -r nvim ~/.config
    cp -r polybar ~/.config
    cp -r rofi ~/.config
    cp -r wallpaper ~/Pictures/
    cp zsh/.zshrc ~/
    cp starship.toml ~/.config
    cp picom.conf ~/.config/picom

    echo "\n\nIt should be fished!! 🤞"

fi
