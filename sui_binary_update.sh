#!/bin/bash
echo -e "\033[0;0mStarting"
echo -e "Stop suid.service"
sudo systemctl stop suid
echo -e "Deleteting Sui DataBase and Genesis"
rm -rf $HOME/suidb $HOME/genesis.blob
echo -e "Downloadding binary"for i in $( wget -qO-  https://api.github.com/repos/MystenLabs/sui/releases/latest | grep browser_download_url | awk '{print $2}' | sed 's/"//g'); do wget $i; done; 
for i in *; do chmod +x $i; mv $i /usr/local/bin//$i; done
echo -e "Downloadding Genesis"
wget -qO $HOME/.sui/genesis.blob https://github.com/MystenLabs/sui-genesis/raw/main/devnet/genesis.blob
echo -e "Start suid.service"
sudo systemctl start suid

echo -e "Checking node"
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n sui_log -v "sudo journalctl -fn 100 -u suid" -a
sleep 1
wget -qO-  -t 1 -T 5 --header 'Content-Type: application/json' --post-data '{ "jsonrpc":"2.0", "id":1, "method":"sui_getRecentTransactions", "params":[5] }' "http://127.0.0.1:9000/" | jq
cd
echo -e "For check log type \033[0;32msui_log"
echo -e "\033[0;0mDone"
