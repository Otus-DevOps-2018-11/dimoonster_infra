#!/bin/sh

## Проверим, что скрипт запускаем от имени root
MYID=`id -u`
if test "${MYID}" != '0' ; then
    echo Need root access. 
    echo Run $0 use sudo.
    exit
fi

## Добавим ключ и репозиторий
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'

## Установим mongo-db
apt-get update
apt-get install -y mongodb-org

## Запустим mongo-db
systemctl start mongod

## Настроим автозапуск
systemctl enable mongod
