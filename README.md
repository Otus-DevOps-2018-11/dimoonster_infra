# dimoonster_infra
dimoonster Infra repository

# ДЗ 7 (terraform 2)
Из замеченных приколов: 
 * не удалось создать образы, при выполненом terraform destroy, т.к. правило разрешающее ssh было им прибито

созданы образы
  reddit-app - образ с руби
  reddit-db  - образ с mongo

storage-buckets:
```sh
$ gsutil ls
gs://storage-bucket-rain/
gs://storage-bucket-winter/
```

# ДЗ 6 (terraform 1)

Сильная нуедобность, нельзя в dafult значении переменной использовать значение другой переменной, даже если у той есть своё значение по умолчанию:
```sh
variable "vm_zone" {
  description = "Zone to start vm"
  default = "${var.region}-1"
}
```
выдаёт ошибку:
```sh
Error: variable "vm_zone": default may not contain interpolations
```

Идея была такая - если зона не указана, то создавать её будем автоматически, основываясь на название региона. Реализовать идею помогла документация https://www.terraform.io/docs/configuration/locals.html 

Если есть ключи в проекте, то при выполнении получаю ошибку:
```sh
* google_compute_project_metadata.ssh_keys: 1 error(s) occurred:

* google_compute_project_metadata.ssh_keys: Error, key 'ssh-keys' already exists in project
```
А также словил ошибку, что тераформ не зафиксировал у себя, что он создал VM и при попытке запустить apply выдал
```sh
1 error(s) occurred:

* google_compute_instance.app[1]: 1 error(s) occurred:

* google_compute_instance.app.1: Error creating instance: googleapi: Error 409: The resource 'projects/clean-algebra-226316/zones/europe-west3-a/instances/reddit-tf-app-var' already exists, alreadyExists

Terraform does not automatically rollback in the face of errors.
Instead, your Terraform state file has been partially updated with
any resources that successfully completed. Please address the error
above and apply again to incrementally change your infrastructure.
```

При введении параметра count изменились переменные





# ДЗ из Лекции 4

Базовая интеграция с TravisCI и проверка работспособности, а также получение результат работы в slack

# Домашнее задание 4 (Основные сервисы Google Cloud Platform (GCP).) 

Параметры для прохождения тестов

```sh
testapp_IP = 35.246.128.233
testapp_port = 9292
```

## Дополнительное задание 2:

При создании VM присвоил tag ul-srv1

```sh
$ gcloud compute firewall-rules create reddit-app --allow=tcp:9292 --direction=INGRESS --target-tags=ul-srv1
Creating firewall...⠏Created [https://www.googleapis.com/compute/v1/projects/clean-algebra-226316/global/firewalls/reddit-app].                                                               
Creating firewall...done.                                                                                                                                                                     
NAME        NETWORK  DIRECTION  PRIORITY  ALLOW     DENY  DISABLED
reddit-app  default  INGRESS    1000      tcp:9292        False
```


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

```sh
bastion_IP = 35.207.87.178
someinternalhost_IP = 10.156.0.3
```
