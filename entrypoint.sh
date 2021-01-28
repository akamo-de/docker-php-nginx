#!/bin/sh

## configure user/group ID
if [ -n "$USERID" -a -n "$GROUPID" ]
then
  groupmod --non-unique --gid "$GROUPID" web
  usermod --non-unique --shell /bin/sh --uid "$USERID" --gid "$GROUPID" web
  usermod -p '*' web
fi
chown web.web /var/www/html
chown -R web.web /run
chown -R web.web /var/lib/nginx
chown -R web.web /var/log/nginx
chown -R web.web /var/log/php7

if [ -z "$PHP_MAX_POST_SIZE" ]
then
  sed -i "s/post_max_size =.*/post_max_size = 64M/g" /etc/php7/php.ini
  sed -i "s/upload_max_filesize =.*/upload_max_filesize = 64M/g" /etc/php7/php.ini
else
  sed -i "s/post_max_size =.*/post_max_size = $PHP_MAX_POST_SIZE/g" /etc/php7/php.ini
  sed -i "s/upload_max_filesize =.*/upload_max_filesize = $PHP_MAX_POST_SIZE/g" /etc/php7/php.ini
fi
if [ -z "$PHP_MEMORY_LIMIT" ]
then
  sed -i "s/memory_limit =.*/memory_limit = 96M/g" /etc/php7/php.ini
else
  sed -i "s/memory_limit =.*/memory_limit = $PHP_MEMORY_LIMIT/g" /etc/php7/php.ini
fi

# cleanup for safty during runtime
apk del shadow
rm -f /sbin/apk

# start syslog for stdout (required for access control and later syslog server redirection)
syslogd -O /proc/1/fd/1

/usr/bin/supervisord -c /etc/supervisord.conf
