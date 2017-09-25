-- as user postgres
CREATE DATABASE cp_canonical
  WITH OWNER = deegree
       ENCODING = 'UTF8'
       TABLESPACE = pg_default
       CONNECTION LIMIT = -1;

COMMENT ON DATABASE cp_canonical
  IS 'Cadastral parcels - canonical schema';

GRANT CONNECT ON DATABASE cp_canonical TO deegree;