CREATE OR REPLACE FUNCTION get_regions_departements_count(regions regions)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "departements"
      WHERE  "departements"."code_region" = regions."code_region"
    );
  END;
$function$ LANGUAGE plpgsql;
