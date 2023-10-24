# IP адреса:
bastion_IP = 158.160.118.67
someinternalhost_IP = 10.128.0.24

# Подключение к бастионному хосту:
ssh -i ~/.ssh/<приватный_ключ> bastion@<публичный_адрес_IPv4>

# Подключение к внутреннему хосту через бастион (ProxyJump):
ssh -i ~/.ssh/<приватный_ключ> -J bastion@<публичный_IP_адрес_бастионного_хоста> test@<приватный_IP_адрес>

# Подключение к vpn:
sudo openvpn <конфигурационный_файл.ovpn>

# Подключение к внутреннему хосту при включенном vpn:
ssh -i ~/.ssh/<приватный_ключ> appuser@<внутренний_IP_someinternalhost>

#############################################################################################################

# Установка vpn pritunl (инструкция с официального сайта):
sudo tee /etc/apt/sources.list.d/pritunl.list << EOF
deb http://repo.pritunl.com/stable/apt jammy main
EOF

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7568D9BB55FF9E5287D586017AE645C0CF8E292A

sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list << EOF
deb https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse
EOF

wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -

sudo apt update
sudo apt --assume-yes upgrade

sudo apt -y install wireguard wireguard-tools

sudo ufw disable

sudo apt -y install pritunl mongodb-org
sudo systemctl enable mongod pritunl
sudo systemctl start mongod pritunl
