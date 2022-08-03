#!/bin/bash
echo Stop suid.service
sudo systemctl stop suid
echo Deleteting DB and Genesis
rm -rf $HOME/suidb $HOME/genesis.blob
echo Downloadding binary
wget  -qO- $(wget -qO-  https://api.github.com/repos/kir3d/Sui_binary/releases/latest | grep browser_download_url | awk '{print $2}' | sed 's/"//g')| tar -C /usr/bin/ -xzf -
echo Downloadding Genesis
wget -qO $HOME/.sui/genesis.blob https://github.com/MystenLabs/sui-genesis/raw/main/devnet/genesis.blob
echo Start suid.service
sudo systemctl start suid
