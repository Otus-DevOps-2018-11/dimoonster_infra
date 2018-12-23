# dimoonster_infra
dimoonster Infra repository


# Поднятые тестовые машины в GCP
| Hostname | Назначение | IP int (ext) |
| -------- | ---------- | ------------ |
| bastion--europe-w3-b | bastion-host | 10.156.0.2 (35.207.87.178) |
| eu-w3-a-node01 | test node 01 | 10.156.0.3 |
В файле *~/.ssh/gcp_infra* хранится ключь для текущего пользователя

# Подключение по ssh

## Используя bastion как proxy одной строкой

### вариант 1. С выполнениемм команды при подключении
```sh
$ ssh -i ~/.ssh/gcp_infra -A -t 35.207.87.178 ssh eu-w3-a-node01
```
### варинт 2. С использованием встроенного функционала клиента ssh (опция -J)
 ```sh
 $ ssh -i ~/.ssh/gcp_infra -A -J 35.207.87.178 eu-w3-a-node01
 ```

### вариант 3. С созданием консольного пользователя.  

Идея такая, что мы получаем доступ к внетреннему серверу, используя специально созданного пользователя.
Логин такого пользователя состоит из нашего логина и имени сервера. 
Пример, для пользователя moon и внутреннего сервера eu-w3-a-node01 мы будем получать доступ 
подключаясь по ssh:  moon--u-w3-a-node01@<bastion-ip>.

На bastion создадим структуру каталогов:
/opt/ssh-proxy-shell        - основной каталог
/opt/ssh-proxy-shell/keys   - тут будут лежать наши публичные ключи ssh
/opt/ssh-proxy-shell/shells - тут будут хранится login-shells

концепт срипта по созданию пользователей приложен в рерпозитории: /lesson05/console/create.sh

в каталог keys копируем ключи из наших /home/<username>/.ssh/authorized_keys в kyes/<username>

добавление пользователя:
```sh
$ sudo ./create.sh eu-w3-a-node01 moon
```
после этого с рабочей машины можно подключаться:
```sh
moon@leniva:~$ ssh -i ~/.ssh/gcp_infra -A eu-w3-a-node01@35.207.87.178
Linux bastion--europe-w3-b 4.9.0-8-amd64 #1 SMP Debian 4.9.130-2 (2018-10-27) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
The authenticity of host '10.156.0.3 (10.156.0.3)' can't be established.
ECDSA key fingerprint is SHA256:MjIhGzdQFa3SD0KwRIycptyVEq8L4XNHRlHWDWJhwSQ.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '10.156.0.3' (ECDSA) to the list of known hosts.
Linux eu-w3-a-node01 4.9.0-8-amd64 #1 SMP Debian 4.9.130-2 (2018-10-27) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Sat Dec 22 19:14:14 2018 from 10.156.0.2
moon@eu-w3-a-node01:~$ 
```

Если развивать концепт дальше, то можно продумать скрипты по удалению пользователей (для лишения доступа), изменению ключей, полного удаления и т.д.

## Используя alias 

В файле ~/.ssh/config создаём соответсвующие alias для подключения 
пример такого файла лежит в репозитории /lesson05/alias/config

результат выполнения
```sh
moon@leniva:~$ ssh eu-w3-a-node01
Linux eu-w3-a-node01 4.9.0-8-amd64 #1 SMP Debian 4.9.130-2 (2018-10-27) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Sat Dec 22 20:48:30 2018 from 10.156.0.2
moon@eu-w3-a-node01:~$ 

```

# Подключение через OpenVPN

На bastion поднят надстройка над openvpn - pritunl
сеть для соединений клиентов - 192.168.219.0/24
клиентам анонсирует только маршрут к внутренней сети - 10.156.0.0/20

bastion_IP = 35.207.87.178
someinternalhost_IP = 10.156.0.3
