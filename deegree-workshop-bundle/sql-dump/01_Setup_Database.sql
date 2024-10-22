CREATE ROLE inspire WITH LOGIN PASSWORD 'inspire';

CREATE DATABASE "inspire"
    WITH 
    OWNER = inspire
    ENCODING = 'UTF8'
    CONNECTION LIMIT = -1;
