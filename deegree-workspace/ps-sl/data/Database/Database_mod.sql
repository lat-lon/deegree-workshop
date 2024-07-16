CREATE DATABASE "inspire"
    WITH 
    ENCODING = 'UTF8'
    CONNECTION LIMIT = -1;
\c inspire

CREATE SCHEMA IF NOT EXISTS "schutzgeb";

CREATE EXTENSION postgis
    SCHEMA public;
