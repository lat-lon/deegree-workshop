CREATE DATABASE "inspire"
    WITH 
    OWNER = inspire
    ENCODING = 'UTF8'
    CONNECTION LIMIT = -1;
\c inspire

CREATE SCHEMA IF NOT EXISTS "schutzgeb"
    AUTHORIZATION inspire;

GRANT ALL ON SCHEMA "schutzgeb" TO inspire WITH GRANT OPTION;

CREATE EXTENSION postgis
    SCHEMA public;
