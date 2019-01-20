#!/bin/sh

## Проверим, что скрипт запускаем от имени root
MYID=`id -u`
if test "${MYID}" != '0' ; then
    echo Need root access. 
    echo Run $0 use sudo.
    exit
fi

## Обновим репозитории и установим ruby, bundler и инструменты для сборки
apt-get update
apt-get install install -y ruby-full ruby-bundler build-essential
