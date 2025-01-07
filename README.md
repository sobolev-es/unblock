# Unblock script for Keenetic/Entware

## Prerequisites

### Keenetic system components

- Open Package support
- IPv6 (required fo netfilter modules)
- Kernel modules for Netfilter

### Open packages

- bind-dig
- cron
- dnsmasq-full
- flock
- incron
- ipset
- iptables
- xray
- xray-core

## How it works
- Redirect/tproxy by destination (ipset).
- Dynamically update ipset via dnsmasq

## Setup
- Setup entware
- Install prerequisites
- Copy files on its places
- Execute ndmc -c 'opkg dns-override'
- Reboot Keenetic
- Add addresses to /opt/etc/unblock.txt

## Общая концепция

- Заворачиваем в VPN/прокси только нужные IP адреса. Список адресов инициализируется при старте и динамически обновляется в процессе работы.

## Как это работает

- Основной скрипт /opt/etc/init.d/S60unblock (конфигурация /opt/etc/unblock.conf)
- Cписок адресов в файле /opt/etc/unblock.txt - при изменении файла incrond выполняет /opt/etc/init.d/S60unblock reconfigure
- Адреса могут быть как в виде IP (CIDR), так и в форме доменных имен.
- IP просто добавляются в набор IPSET.
- Доменные имена разрешаются в IP адреса и также добавляются в набор. Кроме того, в конфигурацию dnsmasq добавляется запись, обновляющая набор при разрешении адреса.
- В dnsmasq на запросы для известных серверов DNS-over-HTTPS возвращаем NXDOMAIN. Некоторым клиентам это помогает понять, что надо использовать стандартный DNS.
- Для клиентов, использующих свои методы разрешения DNS, можно на Keenetic дополнительно добавить в cron регулярный вызов /opt/etc/init.d/S60unblock reconfigure
- Настройки XRAY приведены для примера. Переделать на другой VPN несложно - для openvpn/openconnect и т.п. вообще достаточно одного правила с MARK и PBR
- На Keenetic есть особенность - TPROXY для протокола TCP конфликтует с функцией аппаратного ускорения маршрутизации. Поэтому для UDP - TPROXY, для TCP - REDIRECT
- Скрипт /opt/etc/ndm/netfilter.d/0-unblock.sh обновляет правила - иногда Keenetic-овский демон NDM обновляет конфигурацию пакетного фильтра и правила слетают.

## Что происходит при выполнении /opt/etc/init.d/S60unblock start

- Подгружается модуль xt_TPROXY
- Создается набор ipset (имя задается в /opt/etc/unblock.conf)
- Добавляются правила iptables для TPROXY и REDIRECT (состояние VPN при этом скрипт не проверяет)
- Из файла /opt/etc/unblock.txt читаем список адресов. CIDR просто добавляем в набор, имена добавляем в конфигурацию dnsmasq, резольвим и тоже добавляем в набор.
