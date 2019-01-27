#!/bin/sh

## Проверим, что скрипт запускаем от имени root
MYID=`id -u`
if test "${MYID}" != '0' ; then
    echo Need root access. 
    echo Run $0 use sudo.
    exit
fi

USER=appuser

## Создадим пользователя
useradd -m -s /bin/bash $USER

## Перейдём в каталог 
cd /home/$USER

## Склонируем проект
git clone -b monolith https://github.com/express42/reddit.git

## Перейдём в каталог проекта и установим необходимые gem'ы
cd reddit && bundle install
chown -R $USER /home/$USER
