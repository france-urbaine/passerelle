-- SELECT name, count_departements_in_regions("regions".*) FROM "regions";

CREATE OR REPLACE FUNCTION count_departements_in_regions(regions)
RETURNS integer
AS $function$
  DECLARE
    total integer DEFAULT 0;
  BEGIN
    SELECT COUNT(*) INTO TOTAL
    FROM   "departements"
    WHERE  "departements"."code_region" = $1."code_region";

    RETURN total;
  END;
$function$ LANGUAGE plpgsql;
