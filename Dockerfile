FROM alpine:3.13
LABEL Maintainer="Mario Lombardo <ml@akamo.de>" \
      Description="Lightweight container for php and nginx"

# Configure nginx
RUN apk --no-cache add nginx && \
    rm /etc/nginx/conf.d/default.conf && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log
COPY config/nginx.conf /etc/nginx/nginx.conf


# Configure PHP
RUN apk --no-cache add php7 php7-fpm php7-opcache php7-mysqli php7-json php7-openssl php7-curl \
    php7-zlib php7-xml php7-phar php7-intl php7-dom php7-xmlreader php7-ctype php7-session \
    php7-mbstring php7-gd
RUN sed -i 's/;sendmail_path =.*/sendmail_path = "\/usr\/sbin\/sendmail -t -i"/g' /etc/php7/php.ini && \
    sed -i 's/default_charset =.*/default_charset = "utf-8"/g' /etc/php7/php.ini && \
    sed -i 's/expose_php =.*/expose_php = Off/g' /etc/php7/php.ini && \
    sed -i 's/;daemonize =.*/daemonize = no/g' /etc/php7/php-fpm.conf && \
    sed -i 's/;error_log =.*/error_log = syslog/g' /etc/php7/php-fpm.conf && \
    sed -i 's/user =.*/user = web/g' /etc/php7/php-fpm.d/www.conf && \
    sed -i 's/group =.*/group = web/g' /etc/php7/php-fpm.d/www.conf && \
    sed -i 's/;listen\.owner =.*/listen\.owner = web/g' /etc/php7/php-fpm.d/www.conf && \
    sed -i 's/;listen\.group =.*/listen\.group = web/g' /etc/php7/php-fpm.d/www.conf && \
    sed -i 's/listen =.*/listen = \/tmp\/php\.sock/g' /etc/php7/php-fpm.d/www.conf && \
    sed -i 's/;ping\.path =.*/ping\.path = \/fpm-ping/g' /etc/php7/php-fpm.d/www.conf

# Configure supervisor
RUN apk --no-cache add supervisor
COPY config/supervisord.conf /etc/supervisord.conf

# Configure other tools
RUN apk --no-cache add curl ssmtp shadow && \
  addgroup -g 5000 -S web && \
  adduser -S -D -H -u 5000 -h /var/www/html -s /sbin/nologin -G web -g web web
  
COPY entrypoint.sh /entrypoint.sh

# Setup document root
RUN mkdir -p /var/www/html

# Make sure files/folders needed by the processes are accessable when they run under the web user
RUN chown -R web.web /var/www/html && \
  chown -R web.web /run && \
  chown -R web.web /var/lib/nginx && \
  chown -R web.web /var/log/nginx

# Expose the port nginx is reachable on
EXPOSE 8080

CMD ["/entrypoint.sh"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping
