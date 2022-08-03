#!/bin/bash
 sudo systemctl stop suid
 rm -rf $HOME/suidb $HOME/genesis.blob
 wget  -qO- $(wget -qO-  https://api.github.com/repos/kir3d/Sui_binary/releases/latest | grep browser_download_url | awk '{print $2}' | sed 's/"//g')| tar -C /usr/bin/ -xzf -
 wget -qO $HOME/.sui/genesis.blob https://github.com/MystenLabs/sui-genesis/raw/main/devnet/genesis.blob
 sudo systemctl start suid
