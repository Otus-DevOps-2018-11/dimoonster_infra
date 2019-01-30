#!/bin/sh
set -e

APP_DIR=${1:-$HOME}

git clone -b monolith https://github.com/express42/reddit.git $APP_DIR/reddit
cd $APP_DIR/reddit
bundle install

sudo mv /tmp/reddit.service /etc/systemd/system/reddit.service

# заменим адрес сервера БД на переданное нам значение
sudo sed -i "s/127.0.0.1/${IP}/" /etc/systemd/system/reddit.service

sudo /bin/systemctl daemon-reload
sudo /bin/systemctl start reddit
sudo /bin/systemctl enable reddit
