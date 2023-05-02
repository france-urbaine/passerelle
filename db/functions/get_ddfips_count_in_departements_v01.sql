CREATE OR REPLACE FUNCTION get_ddfips_count_in_departements(departements departements)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "ddfips"
      WHERE  "ddfips"."code_departement" = departements."code_departement"
    );
  END;
$function$ LANGUAGE plpgsql;
