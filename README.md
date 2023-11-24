#############################################################################################################
# HW 3. Cloud Bastion

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

#############################################################################################################
# HW 4. Cloud Testapp

testapp_IP = 158.160.125.108
testapp_port = 9292

Выполнено создание виртуальной машины с помощью yandex cli.

Установлено и запущено тестовое приложение.

Команды по настройке системы и деплоя приложения описаны в виде bash скриптов.


#############################################################################################################
# HW 5. Packer Base

# Установка Packer (нужно включить vpn)

wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install packer


# Создание сервисного аккаунта для Packer в Yandex.Cloud

yc config list
SVC_ACCT=packer-svc
FOLDER_ID=xxxxxxxxxx5hl8r7vt5p
yc iam service-account create --name $SVC_ACCT --folder-id $FOLDER_ID


# Делегирование прав сервисному аккаунту для Packer

ACCT_ID=$(yc iam service-account get packer-svc | grep ^id | awk '{print $2}')
yc resource-manager folder add-access-binding --id $FOLDER_ID --role editor --service-account-id $ACCT_ID


# Создание service account key file

yc iam key create --service-account-id $ACCT_ID --output /home/user/key.json


# Установка плагина Yandex Compute Builder

Создайте файл config.pkr.hcl со следующим содержанием:
packer {
  required_plugins {
    yandex = {
      version = ">= 1.1.2"
      source  = "github.com/hashicorp/yandex"
    }
  }
}

Установите плагин:
packer init <путь_к_файлу_config.pkr.hcl>


# Проверка на ошибки

packer validate ./ubuntu16.json


# Запуск сборки образа

packer build ./ubuntu16.json


# После создания ВМ из нового образа зайти на нее:

ssh -i ~/.ssh/<ssh_key> appuser@<публичный IP машины>


# Сборка образа с переменными, вынесенными в файл variables.json

packer build -var-file=./variables.json ./ubuntu16.json


#############################################################################################################
# HW 6. Terraform-1

# Установка Terraform (нужно включить vpn)

wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Созданы конфигурационные файлы terraform
# Создан файл outputs.tf для определения значения необходимых переменных после работы terraform
# Определены provisioners в main.tf для выполнения команд на удаленной ВМ
# Входные переменные вынесены в отдельный файл


#############################################################################################################
# HW 7. Terraform-2

# Приложение разделено на 2 ВМ
# Описание конфигураций ВМ вынесено в модули
# Создано 2 окружения - stage и prod
# Создан бакет в Yandex Object Storage
# Описание бекенда вынесено в отдельный файл backend.tf
# Настроено сохранение state файла в бакете
