CREATE OR REPLACE FUNCTION get_departements_communes_count(departements departements)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "communes"
      WHERE  "communes"."code_departement" = departements."code_departement"
    );
  END;
$function$ LANGUAGE plpgsql;
