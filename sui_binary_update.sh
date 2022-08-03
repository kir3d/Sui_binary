#!/bin/bash
echo -e "$(tput setaf 15)Starting"
echo -e "Stop suid.service"
sudo systemctl stop suid
echo -e "Deleteting Sui DataBase and Genesis"
rm -rf $HOME/suidb $HOME/genesis.blob
echo -e "Downloadding binary"
wget  -qO- $(wget -qO-  https://api.github.com/repos/kir3d/Sui_binary/releases/latest | grep browser_download_url | awk '{print $2}' | sed 's/"//g')| tar -C /usr/local/bin/ -xzf -
echo -e "Downloadding Genesis"
wget -qO $HOME/.sui/genesis.blob https://github.com/MystenLabs/sui-genesis/raw/main/devnet/genesis.blob
echo -e "Start suid.service"
sudo systemctl start suid

echo -e "Checking node"
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n sui_log -v "sudo journalctl -fn 100 -u suid" -a
sleep 1
wget -qO-  -t 1 -T 5 --header 'Content-Type: application/json' --post-data '{ "jsonrpc":"2.0", "id":1, "method":"sui_getRecentTransactions", "params":[5] }' "http://127.0.0.1:9000/" | jq
cd
echo -e "For check log type $(tput setaf 2)sui_log"
echo -e "$(tput setaf 15)Done"
