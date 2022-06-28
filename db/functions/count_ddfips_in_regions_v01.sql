-- SELECT name, count_ddfips_in_regions("regions".*) FROM "regions";

CREATE OR REPLACE FUNCTION count_ddfips_in_regions(regions)
RETURNS integer
AS $function$
  DECLARE
    total integer DEFAULT 0;
  BEGIN
    SELECT COUNT(*) INTO TOTAL
    FROM   "epcis"
    WHERE  "epcis"."code_departement" = $1."code_departement";

    RETURN total;
  END;
$function$ LANGUAGE plpgsql;
