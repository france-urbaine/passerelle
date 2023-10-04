CREATE OR REPLACE FUNCTION get_regions_epcis_count(regions regions)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "epcis"
      INNER JOIN "departements" ON "departements"."code_departement" = "epcis"."code_departement"
      WHERE      "departements"."code_region" = regions."code_region"
    );
  END;
$function$ LANGUAGE plpgsql;
