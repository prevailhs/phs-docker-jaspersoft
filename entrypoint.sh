#!/bin/bash
set -e

# Get the DATABASE_HOST and DATABASE_PORT from docker linking if not set
# TODO: Add support for other DBs
: ${DATABASE_HOST:=${DATABASE_PORT_5432_TCP_ADDR}}
: ${DATABASE_PORT:=${DATABASE_PORT_5432_TCP_PORT}}

# Make corrections in /usr/local/tomcat/webapps/jasperserver/META-INF/context.xml
sed -i "s/db_host_to_replace/$DATABASE_HOST/g; s/db_port_to_replace/$DATABASE_PORT/g; s/db_username_to_replace/$DATABASE_USERNAME/g; s/db_password_to_replace/$DATABASE_PASSWORD/g" /usr/local/tomcat/webapps/jasperserver/META-INF/context.xml

# Also make corrections in /usr/src/jasperreports-server/buildomatic/default_master.properties for tools
sed -i -e "s|^dbHost.*$|dbHost=$DATABASE_HOST|g; s|^dbPort.*$|dbPort=$DATABASE_PORT|g; s|^dbUsername.*$|dbUsername=$DATABASE_USERNAME|g; s|^dbPassword.*$|dbPassword=$DATABASE_PASSWORD|g" /usr/src/jasperreports-server/buildomatic/default_master.properties

# Run the passed in command
exec "$@"
