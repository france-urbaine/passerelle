CREATE OR REPLACE FUNCTION get_communes_count_in_regions(regions regions)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "communes"
      INNER JOIN "departements" ON "departements"."code_departement" = "communes"."code_departement"
      WHERE      "departements"."code_region" = regions."code_region"
    );
  END;
$function$ LANGUAGE plpgsql;
