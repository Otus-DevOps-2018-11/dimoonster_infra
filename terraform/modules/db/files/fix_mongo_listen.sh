#!/bin/sh

# replace localhost listen to any
sudo sed -i "s/bindIp: 127.0.0.1/bindIp: 0.0.0.0/" /etc/mongod.conf

#restart mongod service
sudo systemctl restart mongod.service
