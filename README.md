# Docker repository for JasperReports Server

This provides a docker image for running
[JasperReports Server](http://community.jaspersoft.com/project/jasperreports-server).
This particular image is a little unique in a couple of ways:

* It does all the compilation/building during `docker build .`; alot of
  the other repositories out there unzip the source code, but then run
  installation on the first `docker run` (for some reason?).
* It runs by default _only_ the webapp (via Tomcat) and leaves the
  database to run on a different server, which should be more normal in
  a docker-based deploy environment.

### Required Environment Variables

There are a few environment variables that should be set whenever
running this image; by setting them both the webapp configuration and
the src files configuration will be updated correctly for the database:

* `DB_HOST` - the host of the database to connect to; it will
  default to `DATABASE_PORT_5432_TCP_ADDR` if set.
* `DB_PORT` - the port of the database to connect to; it will
  default to `DATABASE_PORT_5432_TCP_PORT` if set.
* `DB_NAME` - the name of the database for holding reports data; it will
  default to `jasperserver` if not set.
* `DB_USERNAME` - the username to connect to the database.
* `DB_PASSWORD` - the password to connect to the database.


## Running locally

You can run this locally by starting up a database container and then
linking into this image; __NOTE: We use the Aptible
[postgresql](https://github.com/aptible/docker-postgresql) image as it
supports SSL which is required in the JasperSoft config now.__

```
# Create a data volume for the data
docker create --name data quay.io/aptible/postgresql

# Initialize the DB's username, password and database
docker run --volumes-from data -e USERNAME=user1 -e PASSPHRASE=password1 -e DATABASE=jasperserver quay.io/aptible/postgresql --initialize

# Run the postgres server (we use the aptible image because it has SSL support)
docker run --name postgres1 --volumes-from data -d quay.io/aptible/postgresql

# Run once to prepare the db with required JasperReports Server data (skip creating the DB since we did that above)
docker run --rm --link postgres1:database -e DB_NAME=jasperserver -e DB_USERNAME=user1 -e DB_PASSWORD=password1 prevailhs/jaspersoft db-initialize.sh --skip-create

# Run to start the server on 8080
docker run -d -p 8080:8080 --link postgres1:database -e DB_NAME=jasperserver -e DB_USERNAME=user1 -e DB_PASSWORD=password1 prevailhs/jaspersoft
```

You should then be able to access (after a brief startup time) the
webserver at: `http://localhost:8080/`. See the
[JasperReports Server](http://community.jaspersoft.com/project/jasperreports-server)
for the default admin username and password. **NOTE: if you are using
boot2docker replace `localhost` with the IP provided by `boot2docker
ip`.**

## Running in production

To run in production you should setup a database server in whatever methods you prefer,
then use the `db-initialize.sh` script to prepare a new database and then run the server, providing the database host and port explicitly:

```
docker run --rm -e DB_HOST=1.2.3.4 -e DB_PORT=5432 -e DB_NAME=jasperserver -e DB_USERNAME=postgres -e DB_PASSWORD=mysecretpassword prevailhs/jaspersoft db-initialize.sh
docker run -d -P -e DB_HOST=1.2.3.4 -e DB_PORT=5432 -e DB_NAME=jasperserver -e DB_USERNAME=postgres -e DB_PASSWORD=mysecretpassword prevailhs/jaspersoft
```

You should then be able to access (after a brief startup time) the
webserver via whatever routing layer you're using.

__NOTE: If the database has already been created for your, you can use
the `--skip-create` flag to only initialize the data in the database.__


# Contributing

Fork this repo and make PRs as normal. Feel free to knock off anything
on the TODO list.

## TODO

* Add a DB_SSL env var (default: true) that controls SSL connection to
  DB or not.
* Use official postgres image but figure out how to turn on SSL support.
* Add support for other DBs to be swapped in; probably leave PostgreSQL
  as the default but comment where people would alter after forking.
