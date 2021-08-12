# Обновление ядра в базовой системе и сборка бокса

## Сборка ядра

Для ДЗ выбрал вариант `*` - сборка ядра из исходников.

Пришлось пофиксить конфиг сборщика, поскольку он отказывался его принимать
```
packer fix centos.json
``` 
Внутри centos.json: для сборки увеличил размер диска ВМ, поменял скрипты в секции `provisioners.override.scripts`
Более подробно шаги сборки описаны в комментариях внутри скриптов. 

Основная проблема состояла в неподходящей версии `gcc-4.8.5` базовой системы для сборки стабильного свежего ядра 
(на момент сборки `5.13.9`). Для решения использовал готовую сборку `gcc` из `devtoolset-10`.
Собрал полный вариант: kernel, kernel-headers, kernel-devel - для возможности впоследствии собирать модули для ядра,
в частности это пригодилось для второго задания (`**`)


## Публикация и запуск ВМ

Собранный бокс опубликован [sashis/centos-7-5](https://app.vagrantup.com/sashis/boxes/centos-7-5).

В базовом `Vagrantfile` поменял ссылку на свой бокс, добавил в зависимости плагин `vagrant-vbguest` для двунаправленной
синхронизации папок (в отличии от базового rsync) и настройки для автоматически создаваемой shared-папки.

```
vagrant up
```
При запуске Vagrant просит подтвердить установку плагина, далее при старте ВМ автоматически соберется модуль для поддержки
`VirtualBox Shared Folders`. После запуска можем проверить версию ядра и расшаренную папку
```
vagrant ssh

[vagrant@kernel-update ~]$ uname -r
5.13.9

[vagrant@kernel-update ~]$ mount -lt vboxsf
home_vagrant_synced on /home/vagrant/synced type vboxsf (rw,nodev,relatime,iocharset=utf8,uid=1000,gid=1000)
```

