#! /bin/bash

# Author: Ihor Sokorchuk, ihor.sokorchuk@nure.ua

echo '
========
На базі мінімалістичного Docker образу Alpine створити 
образ для Docker контейнера із Веб сервером Apache2 та 
завантаженою стартовою веб сторінкою на цьому сервері.
Створити із цього образу контейнер, запустити його та 
перевірити роботу веб сервера у контейнері.
========'

work_dir="$HOME/sokorchuk-alpine-apache2"

# Виконувати скрипт покомандно із підсвідкою команд                                                                                                                   
trap 'echo -ne "\033[1;33m$BASH_COMMAND\n# \033[0m";read' DEBUG

# Зупинити усі контейнери. Видалити усі контейнери та образи
function clear_project() {

    # Зупинити усі запущені контейнери
    list="$(docker ps -q)" && [ -n "$list" ] \
    && echo "$list" | xargs docker stop

    # Видалити усі наявні контейнери
    list="$(docker ps -aq)" && [ -n "$list" ] \
    && echo "$list" | xargs docker rm

    # Видалити усі наявні образи
    list="$(docker images -q)" && [ -n "$list" ] \
    && echo "$list" | xargs docker rmi

}

# Видалимо робочу директорію з поперередніх запусків скрипта
rm -Rf "${work_dir}"

# Створимо робочу директорію (якщо її немає) та перейдемо у цю директорію
mkdir -p "${work_dir}" && pushd "${work_dir}" || exit 
pwd

# Зупинимо усі контейнери. Видалимо усі контейнери та образи
clear_project

# Створимо власний файл index.html
cat >index.html <<'INDEX_HTML'
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>My Web Server</title>
    </head>
    <body>
        <h1>Hello World!</h1>
    </body>
</html>
INDEX_HTML

# Переглянемо створений файл index.html
cat ./index.html

# Створимо Dockerfile
cat >Dockerfile <<'DOCKERFILE'
FROM alpine

LABEL maintainer="ihor.sokorhuk@nure.ua"

RUN apk update && apk upgrade && \
    apk add apache2 && \
    rm -rf /var/cache/apk/*

COPY ./index.html /var/www/localhost/htdocs/

CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]

DOCKERFILE

# Переглянемо Dockerfile
cat ./Dockerfile

# Створимо новий образ із іменем sokorchuk/apache
# за описом у ./Dockerfile
docker build -t sokorchuk/apache:1.0 .

# Переглянути створені образи
docker images

# Створимо новий контейнер з іменем sokorchuk_web
# та з перенаправленням TCP порта 80 у контейнері на зовнішній порт 8080
docker create --name sokorchuk_web -p:8080:80 sokorchuk/apache:1.0

# Переглянемо усі контейнери
docker ps -a

# Запустимо образ sokorchuk_web
docker start sokorchuk_web

# Пересвідчимося, що веб сервер у образі працює 
# та доступний ззовні із хост системи
wget http://localhost:8080/ -O -

# Переглянемо IP адреси хост системи 
ip addr | grep 'inet '

# Зупинимо образ sokorchuk_web
docker stop sokorchuk_web

# Пересвідчимося, що веб сервер зупинено
wget http://localhost:8080/ -O -

# Збережемо створений образ у файлі
docker save -o sokorchuk-apache-image.tar sokorchuk/apache:1.0 

# Зупинимо усі контейнери. Видалимо усі контейнери та образи.
clear_project

# Переглянемо наявні образи
docker images

# Завантажимо образ із створеного файла
docker load -i sokorchuk-apache-image.tar

# Переглянемо наявні образи
docker images

# Створимо та запустимо контейнер у термінальному інтерактивному режимі
docker run --name my_container2 -ti sokorchuk/apache:1.0 sh

# Переглянемо усі контейнери
docker ps -a

# Повернутися у попередню директорію
popd || exit

# EOF
