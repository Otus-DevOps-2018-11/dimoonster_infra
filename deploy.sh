#!/bin/sh

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

## Запустим web-сервер с нашим проектом
su -c "puma -d" $USER
