# homework_lesson4
Провести настройку аутентификации доступа к yandex cloud-id, введя в консоли: export YC_TOKEN=$(yc iam create-token)

export YC_CLOUD_ID=$(yc config get cloud-id)

export YC_FOLDER_ID=$(yc config get folder-id)

Ввести в консоли команды: Инициализация terraform terraform init Проверка сценария terraform terraform plan

Будут созданы ВМ:

web1 и web2 которые будет выполнять роль балансировщика;
bs1 и bs2 в качестве бекендов, на которых установлены php-fpm и nginx. В качестве приложения установлен wordpress

db на которой развернута БД mysql, а также будет выполнять роль файлового хранилища с дополнительным диском,
который будет по iscsi подключен к ВМ bs1 и bs2. На ВМ bs1 и bs2 будет создана ФС gfs2 для хранения статики.
Отказоустойчивость системы будет реализована с помощью сетевого балансировщика Yandex Network Load Balancer.
Сценарий настройки балансировщика описан в файле alb.tf
Запустить сценарий создания ВМ terraform apply 
В консоле будут выведены внешние ip - external_ip_address_... и внутренние ip - internal_ip_address_vm_...

В файле ya.yaml ввести external_ip_address для ВМ web1, web2, bs1, bs2 и db1 
Проверить доступность ВМ с помощью модуля ping ansible all -m ping
