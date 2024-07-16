\c inspire
CREATE OR REPLACE VIEW schutzgeb.v_ps_protectedsites_default AS
 SELECT classification.attr_gml_id,
    classification.ps_geometry_value,
    schutzgeb.ps_protectedsite_ps_sitedesignation.ps_designationtype_ps_designationscheme_href AS ps_designationscheme,
    schutzgeb.ps_protectedsite_ps_sitedesignation.ps_designationtype_ps_designation_href AS ps_designation,
    classification.ps_siteprotectionclassification,
    st_geometrytype(classification.ps_geometry_value) AS geom_type
 FROM (SELECT schutzgeb.ps_protectedsite.attr_gml_id,
         schutzgeb.ps_protectedsite.ps_geometry_value,
         schutzgeb.ps_protectedsite_ps_siteprotectionclassification.value AS ps_siteprotectionclassification
       FROM schutzgeb.ps_protectedsite LEFT JOIN schutzgeb.ps_protectedsite_ps_siteprotectionclassification 
       ON schutzgeb.ps_protectedsite.attr_gml_id = schutzgeb.ps_protectedsite_ps_siteprotectionclassification.parentfk
      ) AS classification LEFT JOIN schutzgeb.ps_protectedsite_ps_sitedesignation 
 ON classification.attr_gml_id = schutzgeb.ps_protectedsite_ps_sitedesignation.parentfk;

ALTER TABLE schutzgeb.v_ps_protectedsites_default
    OWNER TO inspire;
