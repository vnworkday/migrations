# Getting Started

This project contains all migration scripts of database schemas. The database schema is managed
by [Flyway](https://flywaydb.org/), a database migration tool that brings structure and confidence to the database
schema.

## Project Structure

The project structure is as follows:

```plaintext
|-- migrations/          # Contains all migration scripts
|   |-- account/         # Contains migration scripts for the `account` database
|   |   |-- VyyyyMMddHHmmss__description.sql # Migration script, where `yyyyMMddHHmmss` is the timestamp and `description` is the brief summary of the migration
|-- docs/                # Contains all documentation related to the database schema
|   |-- account.md       # Documentation for the `account` database schema
|-- db/
|   |-- V1__create_database_$service.sql # Initializing script to create database for $service
|-- configs/             # Contains all configurations for Flyway
|   |-- flyway.toml      # Flyway configuration file
```

