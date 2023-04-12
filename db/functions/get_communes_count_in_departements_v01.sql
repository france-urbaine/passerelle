CREATE OR REPLACE FUNCTION get_communes_count_in_departements(departements departements)
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
