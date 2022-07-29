echo Install JQ
apt update
apt install jq -y

echo Stop service
sudo systemctl stop suid

echo Create .sui and download binary
mkdir $HOME/.sui
cd $HOME/.sui

version=`wget -qO- https://api.github.com/repos/SecorD0/Sui/releases/latest | jq -r ".tag_name"`; \
wget -qO- "https://github.com/SecorD0/Sui/releases/download/${version}/sui-linux-amd64-${version}.tar.gz" | tar -C /usr/bin/ -xzf -

wget -qO $HOME/.sui/genesis.blob https://github.com/MystenLabs/sui-genesis/raw/main/devnet/genesis.blob

printf "# Update this value to the location you want Sui to store its database
db-path: \"/root/.sui/db\"

network-address: \"/dns/localhost/tcp/8080/http\"
metrics-address: \"0.0.0.0:9184\"
json-rpc-address: \"0.0.0.0:9000\"

genesis:
  # Update this to the location of where the genesis file is stored
  genesis-file-location: \"/root/.sui/genesis.blob\"" > $HOME/.sui/fullnode.yaml


echo Firewall
ufw allow 8080
ufw allow 9000
ufw allow 9184
echo y | ufw enable

#Service
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
sudo journalctl --vacuum-size=1G

echo Checking node
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n sui_log -v "sudo journalctl -fn 100 -u suid" -a
wget -qO-  -t 1 -T 5 --header 'Content-Type: application/json' --post-data '{ "jsonrpc":"2.0", "id":1, "method":"sui_getRecentTransactions", "params":[5] }' "http://127.0.0.1:9000/" | jq

echo Address and keys
echo "http://`wget -qO- eth0.me`:9000/" > $HOME/.sui/address.txt
echo y | sui client
sui keytool list > $HOME/.sui/keys.txt
cat ~/.sui/keys.txt
