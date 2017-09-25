-- as user deegree
CREATE TABLE FEATURE_TYPES (id smallint PRIMARY KEY, qname text NOT NULL);
COMMENT ON TABLE FEATURE_TYPES IS 'Ids and bboxes of concrete feature types';
SELECT ADDGEOMETRYCOLUMN('public', 'feature_types','bbox','0','GEOMETRY',2);
INSERT INTO FEATURE_TYPES  (id,qname) VALUES (0,'{http://inspire.ec.europa.eu/schemas/au/4.0}AdministrativeBoundary');
INSERT INTO FEATURE_TYPES  (id,qname) VALUES (1,'{http://inspire.ec.europa.eu/schemas/au/4.0}AdministrativeUnit');
INSERT INTO FEATURE_TYPES  (id,qname) VALUES (2,'{http://inspire.ec.europa.eu/schemas/au/4.0}Condominium');
INSERT INTO FEATURE_TYPES  (id,qname) VALUES (3,'{http://inspire.ec.europa.eu/schemas/cp/4.0}BasicPropertyUnit');
INSERT INTO FEATURE_TYPES  (id,qname) VALUES (4,'{http://inspire.ec.europa.eu/schemas/cp/4.0}CadastralBoundary');
INSERT INTO FEATURE_TYPES  (id,qname) VALUES (5,'{http://inspire.ec.europa.eu/schemas/cp/4.0}CadastralParcel');
INSERT INTO FEATURE_TYPES  (id,qname) VALUES (6,'{http://inspire.ec.europa.eu/schemas/cp/4.0}CadastralZoning');
INSERT INTO FEATURE_TYPES  (id,qname) VALUES (7,'{http://inspire.ec.europa.eu/schemas/gn/4.0}NamedPlace');
CREATE TABLE GML_OBJECTS (id serial PRIMARY KEY, gml_id text UNIQUE NOT NULL, ft_type smallint REFERENCES FEATURE_TYPES , binary_object bytea);
COMMENT ON TABLE GML_OBJECTS IS 'All objects (features and geometries)';
SELECT ADDGEOMETRYCOLUMN('public', 'gml_objects','gml_bounded_by','0','GEOMETRY',2);
ALTER TABLE GML_OBJECTS ADD CONSTRAINT gml_objects_geochk CHECK (ST_IsValid(gml_bounded_by));
CREATE INDEX gml_objects_sidx ON GML_OBJECTS  USING GIST (gml_bounded_by);