-- as user postgres
CREATE DATABASE ps_canonical
  WITH OWNER = deegree
       ENCODING = 'UTF8'
       TABLESPACE = pg_default
       CONNECTION LIMIT = -1;

COMMENT ON DATABASE ps_canonical
  IS 'Protected Sites - canonical schema';

GRANT CONNECT ON DATABASE ps_canonical TO deegree;