create database :"dbname";
create role :username with password :'password';
alter database :"dbname" owner to :username;
\connect :"dbname";
create schema if not exists :"schema";
alter database :"dbname" set search_path to :"schema";
create extension if not exists pgcrypto with schema :"schema";