-- as user postgres
CREATE DATABASE cp_blob
  WITH OWNER = deegree
       ENCODING = 'UTF8'
       TABLESPACE = pg_default
       CONNECTION LIMIT = -1;

COMMENT ON DATABASE cp_blob
  IS 'Cadastral parcels - blob schema';

GRANT CONNECT ON DATABASE cp_blob TO deegree;