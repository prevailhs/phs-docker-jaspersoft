# Docker repository for JasperReports Server

This provides a docker image for running
[JasperReports Server](http://community.jaspersoft.com/project/jasperreports-server).
This particular image is a litle unique in that in a couple ways:

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
* `DB_USERNAME` - the username to connect to the database.
* `DB_PASSWORD` - the password to connect to the database.


## Running locally

You can run this locally by staring up a database container and then
linking into this image:

```
# Run once to start db server
docker run --name postgres1 -e POSTGRES_PASSWORD=mysecretpassword -d postgres

# Run once to prepare the db with required JasperReports Server data
docker run --rm --link postgres1:postgres -e DB_USERNAME=postgres -e DB_PASSWORD=mysecretpassword jaspersoft db-initialize.sh

# Run to start the server on 8080
docker run -d -p 8080:8080 --link postgres1:postgres -e DB_USERNAME=postgres -e DB_PASSWORD=mysecretpassword jaspersoft
```

You should then be able to access (after a brief startup time) the
webserver at: `http://localhost:8080/jasperserver`. See the
[JasperReports Server](http://community.jaspersoft.com/project/jasperreports-server)
for the default admin username and password. **NOTE: if you are using
boot2docker replace `localhost` with the IP provided by `boot2docker
ip`.**

## Running in production

To run in production you should setup a database in whatever methods you prefer, then use the `db-initialize.sh` script to prepare that database and then run the server, providing the database host and port explicitly:

```
docker run --rm -e DB_HOST=1.2.3.4 -e DB_PORT=5432 -e DB_USERNAME=postgres -e DB_PASSWORD=mysecretpassword jaspersoft db-initialize.sh
docker run -d -P -e DB_HOST=1.2.3.4 -e DB_PORT=5432 -e DB_USERNAME=postgres -e DB_PASSWORD=mysecretpassword jaspersoft
```

You should then be able to access (after a brief startup time) the
webserver via whatever routing layer you're using.


# Contributing

Fork this repo and make PRs as normal. Feel free to knock off anything
on the TODO list.

## TODO

* Add support for other DBs to be swapped in; probably leave PostgreSQL
  as the default but comment where people would alter after forking.
* Overwrite Tomcat default configuration so that the only thing
  available is JasperReports Server and its at the root path.
