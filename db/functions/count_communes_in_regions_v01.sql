-- SELECT name, count_communes_in_regions("regions".*) FROM "regions";

CREATE OR REPLACE FUNCTION count_communes_in_regions(regions)
RETURNS integer
AS $function$
  DECLARE
    total integer DEFAULT 0;
  BEGIN
    SELECT     COUNT(*) INTO TOTAL
    FROM       "communes"
    INNER JOIN "departements" ON "departements"."code_departement" = "communes"."code_departement"
    WHERE      "departements"."code_region" = $1."code_region";

    RETURN total;
  END;
$function$ LANGUAGE plpgsql;