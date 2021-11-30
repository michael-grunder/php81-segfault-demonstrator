FROM ubuntu:latest as build1

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Los_Angeles

RUN apt-get -y update && \
    apt-get -y install \
        gcc wget autoconf make pkg-config gdb valgrind zlib1g-dev libonig-dev \
        libcurl4-openssl-dev libxml2-dev libzip-dev curl sqlite3 libsqlite3-dev

FROM build1 as build2

RUN cd /tmp && echo "<?php \$x = 'k1';" > test.php && \
    wget -q "https://www.php.net/distributions/php-8.1.0.tar.gz" && \
    tar -xf "php-8.1.0.tar.gz" && \
    mv php-8.1.0 php-src && \
    cd php-src && \
    ./buildconf --force && ./configure && make -j$(nproc)

CMD ["valgrind", "/tmp/php-src/sapi/cli/php", "/tmp/test.php"]
