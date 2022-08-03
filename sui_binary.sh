#!/bin/bash
if [ $(dpkg-query -W -f='${Status}' jq 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo Install JQ
  apt update
  apt-get install jq curl -y ;
fi

if test -f "/etc/systemd/system/suid.service"
then
  echo 
else
  echo Stop service
  sudo systemctl stop suid
fi

mkdir -p $HOME/.sui
cd $HOME/.sui

echo Dowloading binary
wget  -qO- $(wget -qO-  https://api.github.com/repos/kir3d/Sui_binary/releases/latest | grep browser_download_url | awk '{print $2}' | sed 's/"//g')| tar -C /usr/bin/ -xzf -
wget -qO $HOME/.sui/genesis.blob https://github.com/MystenLabs/sui-genesis/raw/main/devnet/genesis.blob

printf "# Update this value to the location you want Sui to store its database
db-path: \"/root/.sui/db\"
network-address: \"/dns/localhost/tcp/8080/http\"
metrics-address: \"0.0.0.0:9184\"
json-rpc-address: \"0.0.0.0:9000\"
genesis:
  # Update this to the location of where the genesis file is stored
  genesis-file-location: \"/root/.sui/genesis.blob\"" > $HOME/.sui/fullnode.yaml

echo Firewall open ports: 8080, 9000, 9184
ufw allow ssh > /dev/null 2>&1
ufw allow 8080 > /dev/null 2>&1
ufw allow 9000 > /dev/null 2>&1
ufw allow 9184 > /dev/null 2>&1
echo y | ufw enable > /dev/null 2>&1

echo Creating suid.service
printf "[Unit]
Description=Sui node
After=network-online.target
[Service]
User=$USER
ExecStart=`which sui-node` --config-path $HOME/.sui/fullnode.yaml
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/suid.service

sudo systemctl daemon-reload
sudo systemctl enable suid
sudo systemctl restart suid
sudo journalctl --vacuum-size=1G > /dev/null 2>&1

echo Address and keys
echo "http://$(curl -s ifconfig.me):9000/" > $HOME/.sui/address.txt
echo Copy $(tput setaf 2)$(cat address.txt) $(tput setaf 15)and paste to Discord. 
echo Right click and Open link:$(tput setaf 2) https://discord.com/channels/916379725201563759/986662676073709568 $(tput setaf 15)
echo y | sui client > /dev/null 2>&1
echo Backup this
sui keytool list > $HOME/.sui/keys.txt
cat ~/.sui/keys.txt

echo Checking node
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n sui_log -v "sudo journalctl -fn 100 -u suid" -a
sleep 0.5
wget -qO-  -t 1 -T 5 --header 'Content-Type: application/json' --post-data '{ "jsonrpc":"2.0", "id":1, "method":"sui_getRecentTransactions", "params":[5] }' "http://127.0.0.1:9000/" | jq
cd
echo For check log type $(tput setaf 2)sui_log$(tput setaf 15) 

