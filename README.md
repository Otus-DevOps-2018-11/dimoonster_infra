# dimoonster_infra
dimoonster Infra repository

# ДЗ 10

- созданы роли для серверов app и db
- заметка: при запуске не забывать обновлять ip inventory
- разделение на окружения. каталоги prod/stage в enviroments
- приведён в порядок каталог ansible
- добавлена роль nginx-proxy для app




# ДЗ 9

packer создал образа:
```sh
--> googlecompute: A disk image was created: reddit-app-1549575034
--> googlecompute: A disk image was created: reddit-db-1549575485
```

Произведён запуск с этими образами:
в terraform.tfvars добавлено:
```
app_disk_image = "reddit-app-1549575034"
db_disk_image = "reddit-db-1549575485"
```

Результат сборки:
```
Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

Outputs:

app_external_ip = [
    35.246.128.233
]
db_external_ip = [
    35.234.98.24
]
db_internal_ip = [
    10.156.0.54
]
```
Результат развёртывания:
```
app.host                   : ok=9    changed=7    unreachable=0    failed=0
mongodb.host               : ok=3    changed=2    unreachable=0    failed=0
```

# ДЗ 8

Написал небольшой скриптик на perl, который возвращает динамически сгенерённый json для ansible

скрипт переходит в каталог с инициализированным terraform, получает оттуда текущие ip адреса запущенных хостов app и db, на основании этих данных и создаёт json

пример работы:

ansible.cfg:
```sh
[defaults]
inventory = ./appexp.pl
remote_user = appuser
private_key_file = ~/.ssh/id_rsa
host_key_checking = False
retry_files_enabled = False
```
вывод
```sh
$ ansible all -m ping
app.host | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
mongodb.host | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

пример сгенерённого json - файл ansible/inventory.json

т.к. тест с perl скриптом не проходит (https://travis-ci.com/Otus-DevOps-2018-11/dimoonster_infra/builds/99676750) то в закомиченном конфиге указан ini

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

### Задание *

в backend.tf описываем, что хранить состояние мы будем в gcs

при запуске terraform init в чистом состоянии файл terraform.tfstate не создаётся, при запуске в работающей среде появляется предложение о переносе файла terraform.tfstate в gcs

при одновременном запуске из другого католога получем ошибку о блокировке
```sh
$ terraform plan
Acquiring state lock. This may take a few moments...

Error: Error locking state: Error acquiring the state lock: writing "gs://storage-bucket-rain/prod/default.tflock" failed: googleapi: Error 412: Precondition Failed, conditionNotMet
Lock Info:
  ID:        1548880641499146
  Path:      gs://storage-bucket-rain/prod/default.tflock
  Operation: OperationTypeApply
  Who:       moon@leniva
  Version:   0.11.11
  Created:   2019-01-30 20:37:21.198605855 +0000 UTC
  Info:      


Terraform acquires a state lock to protect the state from being written
by multiple users at the same time. Please resolve the issue above and try
again. For most commands, you can disable locking with the "-lock=false"
flag, but this is not recommended.

```

### Задание 2*
- Скрипты и необходимые файлы скопированы в каталоги соответсвующих модулей
- в модуль app добавлена переменная *db_ip_addr* в которую небходимо передавать ip адрес сервера БД
- в модуль db добавлен shell скрипт, который меняет значение ip адреса на котором должен работать mongodb
- выходной параметр модуля db internal_ip передаётся в качестве параметра db_ip_addr в модуль app
- в скрипт deploy.sh модуля app db_ip_addr передаётся как переменная окружения. скрипт меняет значение enviroment DATABASE_URL для сервиса reddit.service на переданное значение


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
