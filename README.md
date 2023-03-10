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

**Решение**

Для упрощения дальнейшей доработки под другие лог-файлы, функционал разбит на микро-модули, которые располагаются в каталоге "modules" и подгружаются в основной скрипт командой source.
Такой подход позволяет строить внутри основного скрипта микро-конвейры обработки входных данных, и менять модули без необходимости внесения излишних изменений в остальные части скрипта.

Например:

```
input=$(cat access.log|read_from_line $fromline| \
        read_n_lines $readcnt)
```

Такой конвейр означает:

```
Взять содержимое access.log | \
    прочитать содержимое, начиная со строки $fromline | \
    прочитать $readcnt строк
Полученный результат сохранить в переменной input
```

Для ответа на поставленные задачи требуются следующие конвейры:

1. Список IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;

```
echo "$input"|select_ips| \
    group_count_sort_desc| \
    flip_val_count|top_limit 5
```

2. Список запрашиваемых URL (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;

```
echo "$input"|select_urls| \
    group_count_sort_desc| \
    flip_val_count|top_limit 5
```

3. Ошибки веб-сервера/приложения c момента последнего запуска;

```
echo "$input"|select_any_errors
```

4. Список всех кодов HTTP ответа с указанием их кол-ва с момента последнего запуска скрипта.

```
echo "$input"| \
    get_status_codes| \
    group_count_sort_desc| \
    flip_val_count
```

Запрет на одновременный запуск нескольких копий скрипта реализуется при помощи flock.
При работе скрипт устанавливает блокировку на /var/run/myscript.lock (если такого файла нет - он создаётся).
В случае, если блокировку установить не удаётся - значит это повторный запуск, и работа невозможна.
Проиллюстрировано включением принудительной задержки sleep 60. Можно отправить скрипт в фон, и попытаться запустить вторую копию.

Функционал чтения "с последнего запуска" реализован при помощи сохранения номера прочитанной строки в файле /usr/local/myscript.counter.
Из-за того, что данные в предоставленном файле access.log являются историческими, для имитации активной работы приложения пишущего журнал - введён случайный размер выборки (от 40 до 110 строк за 1 запуск). Данное поведение можно изменить, указав readcnt="all", в этом случае сценарий будет читать весь журнал до конца.

При помощи trap реализовано автоматическое снятие блокировки с lock-файла.

Поскольку в задании не указана необходимость фактической отправки писем - функционал не реализован.
При этом, в прилагаемом Vagrantfile устанавливается пакет mailx, которым можно отправлять письма.
Учитывая, что скрипт выводит результаты в stdout - отправку писем достаточно несложно реализовать. Например, отправим письмо пользователю root (локальному):

```
./script.sh | mail -s "HTTPD activity report" root
```

Для отправки писем на реальные адреса необходимо настроить локальный MTA (postfix?), либо использовать внешний, т.к. mailx позволяет это сделать.

Если в журнале не появилось новых строк с последнего запуска - скрипт завершает работу, счётчик не сдвигается.
