CREATE OR REPLACE FUNCTION get_departements_epcis_count(departements departements)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "epcis"
      WHERE  "epcis"."code_departement" = departements."code_departement"
    );
  END;
$function$ LANGUAGE plpgsql;
