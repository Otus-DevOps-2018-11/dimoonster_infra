#!/bin/bash

sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list << EOF
deb http://repo.mongodb.org/apt/debian stretch/mongodb-org/4.0 main
EOF

sudo tee /etc/apt/sources.list.d/pritunl.list << EOF
deb http://repo.pritunl.com/stable/apt stretch main
EOF

sudo apt-get install dirmngr
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7568D9BB55FF9E5287D586017AE645C0CF8E292A
sudo apt-get update
sudo apt-get --assume-yes install pritunl mongodb-server
sudo systemctl start mongodb pritunl
sudo systemctl enable mongodb pritunl
