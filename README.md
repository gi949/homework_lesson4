Провести настройку аутентификации доступа к yandex cloud-id, введя в консоли:

export YC_TOKEN=$(yc iam create-token)

export YC_CLOUD_ID=$(yc config get cloud-id)

export YC_FOLDER_ID=$(yc config get folder-id)

Ввести в консоли команды: 
Инициализация terraform terraform init 
Проверка сценария terraform terraform plan

Будут созданы ВМ:

web1 и web2 которые будет выполнять роль балансировщика;

bs1 и bs2 в качестве бекендов, на которых установлены php-fpm и nginx. В качестве приложения установлен wordpress

db на которой развернута БД mysql, а также будет выполнять роль файлового хранилища с дополнительным диском, 
который будет по iscsi подключен к ВМ bs1 и bs2. На ВМ bs1 и bs2 будет создана ФС gfs2 для хранения статики.

Отказоустойчивость системы будет реализована с помощью сетевого балансировщика Yandex Network Load Balancer. 
Сценарий настройки балансировщика описан в файле alb.tf

Запустить сценарий создания ВМ 
terraform apply

В консоле будут выведены внешние ip - external_ip_address_... и внутренние ip - internal_ip_address_vm_...

В файле ya.yaml ввести external_ip_address для ВМ web1, web2, bs1, bs2 и db 

Проверить доступность ВМ с помощью модуля 
ping ansible all -m ping 

В файле all групповых переменных в group_vars/ ввести internal_ip_address_vm_... для ВМ bs1, bs2 и db1, 
а также название базы, пользователя и пароль, а также домен для настройки wordpress.

Также ввести external_ip_address и internal_ip_address для ВМ db, bs1 и bs2, а также iqn портала iscsi и пароль кластера psc.

В файлах lb1 и lb2 в папке host_vars/ ввести внутренние ip - internal_ip_address_vm_... bs1 и bs2 для настройки балансировки.

Проверить корректность синтаксиса плэйбука main.yaml 
ansible-playbook --syntax-check main.yaml

Роль pcs_start выполняет установку ПО на bs1 и bs2, создание и настройку pacemaker кластера,

а также настройку iqn на bs1 и bs2

Роль target_start выполняет настройку портала iscsi на ВМ db

Роль gfs2_start выполняет настройку ФС gfs2 на bs1 и bs2

Роль db_ins выполняет установку и рзвертывание mysql

Роль bs_ins выполняет установку и рзвертывание php-fpm, nginx и wordpress

Роль web_ins выполняет настройку балансировщика с nginx

Проверить корректность синтаксиса плэйбука main.yaml

ansible-playbook --syntax-check main.yaml

Запускаем playbook на выполнение

ansible-playbook main.yaml

Для проверки в /etc/hosts своей ВМ прописываем: 
external_ip_address Yandex Network Load Balancer www.example.com

В браузере проверяем доступность wordpress введя www.example.com

Для проверки отключаем nginx или php-fpm на ВМ.

Проверяем доступность сайта по адресу www.example.com

