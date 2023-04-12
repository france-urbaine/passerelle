CREATE OR REPLACE FUNCTION get_epcis_count_in_departements(departements departements)
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
