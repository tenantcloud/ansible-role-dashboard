#!/bin/bash

/usr/local/opt/mysql\@5.7/bin/mysql -uroot <<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS {{ database }};
CREATE USER IF NOT EXISTS 'read'@'%' IDENTIFIED BY 'read';
GRANT SELECT, SHOW VIEW ON *.* TO 'read'@'%';
FLUSH PRIVILEGES;
MYSQL_SCRIPT
