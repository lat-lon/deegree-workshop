-- as user postgres
CREATE DATABASE ps_blob
  WITH OWNER = deegree
       ENCODING = 'UTF8'
       TABLESPACE = pg_default
       CONNECTION LIMIT = -1;

COMMENT ON DATABASE ps_blob
  IS 'Protected Sites - blob schema';

GRANT CONNECT ON DATABASE ps_blob TO deegree;