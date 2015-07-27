#!/bin/bash
set -e

# Get the DB_HOST and DB_PORT from docker linking if not set
# TODO: Add support for other DBs
: ${DB_HOST:=${DATABASE_PORT_5432_TCP_ADDR}}
: ${DB_PORT:=${DATABASE_PORT_5432_TCP_PORT}}
: ${DB_NAME:="jasperserver"}

# Make corrections in /usr/local/tomcat/webapps/jasperserver/META-INF/context.xml
sed -i "s/db_host_to_replace/$DB_HOST/g; s/db_port_to_replace/$DB_PORT/g; s/db_name_to_replace/$DB_NAME/g; s/db_username_to_replace/$DB_USERNAME/g; s/db_password_to_replace/$DB_PASSWORD/g" /usr/local/tomcat/webapps/ROOT/META-INF/context.xml

# Also make corrections in /usr/src/jasperreports-server/buildomatic/default_master.properties for tools
sed -i -e "s|^dbHost.*$|dbHost=$DB_HOST|g; s|^dbPort.*$|dbPort=$DB_PORT|g; s|^js\.dbName.*$|js\.dbName=$DB_NAME|g; s|^dbUsername.*$|dbUsername=$DB_USERNAME|g; s|^dbPassword.*$|dbPassword=$DB_PASSWORD|g" /usr/src/jasperreports-server/buildomatic/default_master.properties

# Run the passed in command
exec "$@"
