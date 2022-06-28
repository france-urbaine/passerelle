-- SELECT name, count_epcis_in_regions("regions".*) FROM "regions";

CREATE OR REPLACE FUNCTION count_epcis_in_regions(regions)
RETURNS integer
AS $function$
  DECLARE
    total integer DEFAULT 0;
  BEGIN
    SELECT     COUNT(*) INTO TOTAL
    FROM       "epcis"
    INNER JOIN "departements" ON "departements"."code_departement" = "epcis"."code_departement"
    WHERE      "departements"."code_region" = $1."code_region";

    RETURN total;
  END;
$function$ LANGUAGE plpgsql;
