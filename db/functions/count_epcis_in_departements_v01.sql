-- SELECT name, count_epcis_in_departements("departements".*) FROM "departements";

CREATE OR REPLACE FUNCTION count_epcis_in_departements(departements)
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
