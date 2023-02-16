## OTUS Administrator Linux. Professional ДЗ №9: Bash

**Задание**

Написать скрипт для CRON, который раз в час будет формировать письмо и отправлять на заданную почту.
Необходимая информация в письме:

1. Список IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;
2. Список запрашиваемых URL (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;
3. Ошибки веб-сервера/приложения c момента последнего запуска;
4. Список всех кодов HTTP ответа с указанием их кол-ва с момента последнего запуска скрипта.

_Функциональные требования:_

1. Скрипт должен предотвращать одновременный запуск нескольких копий, до его завершения.
2. В письме должен быть прописан обрабатываемый временной диапазон.