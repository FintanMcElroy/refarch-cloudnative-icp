#!/bin/bash

MYSQL_ORDERS_DATABASE=$5
MYSQL_ORDERS_USER=$1
MYSQL_ORDERS_PASSWORD=$2
MYSQL_ROOT_PASSWORD=admin123
MYSQL_HOST=$3
MYSQL_PORT=$4

_password_opt="-p${MYSQL_ROOT_PASSWORD}"
if [ -z "${MYSQL_ROOT_PASSWORD}" ]; then
    _password_opt=""
fi

echo "Creating database ${MYSQL_ORDERS_DATABASE} ..."
mysql -h${MYSQL_HOST} -P${MYSQL_PORT} -uroot ${_password_opt} <<EOF
create database if not exists ${MYSQL_ORDERS_DATABASE};
EOF

echo "Creating database user ${MYSQL_ORDERS_USER} ..."
mysql -h${MYSQL_HOST} -P${MYSQL_PORT} -uroot ${_password_opt} <<EOF
create user if not exists '${MYSQL_ORDERS_USER}'@'%' identified by '${MYSQL_ORDERS_PASSWORD}';
grant all on ${MYSQL_ORDERS_DATABASE}.* to '${MYSQL_ORDERS_USER}'@'%';
EOF

echo "Creating orders table ..."

mysql -h${MYSQL_HOST} -P${MYSQL_PORT} -uroot ${_password_opt} <<EOF
use ${MYSQL_ORDERS_DATABASE};
source create_orders_table.sql;
EOF
