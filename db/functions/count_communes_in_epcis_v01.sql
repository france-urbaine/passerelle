-- SELECT name, count_communes_in_epcis("epcis".*) FROM "epcis";

CREATE OR REPLACE FUNCTION count_communes_in_epcis(epcis)
RETURNS integer
AS $function$
  DECLARE
    total integer DEFAULT 0;
  BEGIN
    SELECT COUNT(*) INTO TOTAL
    FROM   "communes"
    WHERE  "communes"."siren_epci" = $1."siren";

    RETURN total;
  END;
$function$ LANGUAGE plpgsql;
