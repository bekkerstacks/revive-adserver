FROM alpine
WORKDIR /var/www/html
RUN apk add --no-cache curl ca-certificates && update-ca-certificates --fresh && apk add --no-cache openssl
RUN apk --no-cache add nginx \
        gzip pcre \
        php7 php7-curl \
        php7-fpm php7-gd \
        php7-mbstring php7-mysqli \
        php7-mysqlnd php7-opcache \
        php7-pdo php7-pdo_mysql \
        php7-xml php7-openssl \
        php7-zlib php7-memcached \
        php7-json php7-zip php7

RUN wget -qO- https://download.revive-adserver.com/revive-adserver-4.2.1.tar.gz | tar xz --strip 1 \
    && chown -R nginx:nginx . \
    && echo -e "#!/bin/sh\ncurl -s -o /dev/null http://127.0.0.1/maintenance.php" > /etc/periodic/daily/maintenance \
    && chmod +x /etc/periodic/daily/maintenance \
    && rm -f /etc/nginx/conf.d/default.conf \
    && mkdir -p /run/nginx

RUN chmod -R a+w /var/www/html/var /var/www/html/plugins /var/www/html/www/admin/plugins /var/www/html/www/images

ADD app.conf /etc/nginx/conf.d/app.conf
CMD crond -l 2 -b && php-fpm7 && nginx -g "daemon off;"
