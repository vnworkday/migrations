# VNWorkday - Migrations

This project contains all migration scripts of database schemas. The database schema is managed
by [Flyway](https://flywaydb.org/), a database migration tool that brings structure and confidence to the database
schema.

## Project Structure

The project structure is as follows:

```plaintext
|-- migrations/                                  
|   |-- <dbname>/                               
|   |   |-- sql/                                 # Contains migration scripts for the `<dbname>` database
|   |   |   |-- VyyyyMMddHHmmss__description.sql # Migration script for the `<dbname>` database
|   |   |-- ci/                                  # Contains scripts for CI/CD
|   |   |   |-- setup.sh                         # Script to setup the database for CI/CD
|-- docs/                                        # Contains all documentation related to the database schema
|   |-- <dbname>.md                              # Documentation for the `<dbname>` database schema
|__ ci/
|   |-- start.sh                                 # Script to start the local development environment
|   |-- stop.sh                                  # Script to stop the local development environment
|   |-- setup.sh                                 # Script to setup the database for CI/CD
|   |-- <other scripts>                          # Other scripts for CI/CD
|-- README.md                                    # You should read this file first. It contains all the information you need to get started.
```

## Local Development

1. Create a new Docker network by executing the following command:

   ```shell
   docker network create vnworkday
   ```
2. Run the `ci/start.sh` to prepare your local environment. It typically starts a Flyway container and a PostgreSQL
   Server container.
3. Verify that the PostgreSQL Server & Flyway are running by executing the following command:

   ```shell
   docker ps
   ```

   The output should be similar to the following:

   ```plaintext
   CONTAINER ID   IMAGE                 COMMAND                  CREATED         STATUS                  PORTS                    NAMES
   1b3b4b3b4b3b   postgres:16.3-alpine  postgres -c confi...     2 minutes ago   Up 2 minutes (healthy)  0.0.0.0:5432->5432/tcp   postgres
   2b3b4b3b4b3b   flyway:latest                               2 minutes ago   Up 2 minutes                                     flyway
   ```
4. Make sure you can connect to the PostgreSQL Server by executing the following command:

   ```shell
   psql -U dba -h 0.0.0.0
   ```

   The output should prompt you input as the following:

   ```plaintext
   Password for user postgres:
   ```
5. Make sure you can connect to the Flyway container by executing the following command:

   ```shell
   docker exec flyway flyway version
   ```

   The output should be similar to the following:

   ```plaintext
   Flyway Community Edition 10.14.0 by Redgate
   
   << other output >>
   ```
6. When you are done with your local development, run the `ci/stop.sh` to stop the local environment.
