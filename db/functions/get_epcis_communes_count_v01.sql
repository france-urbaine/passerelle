CREATE OR REPLACE FUNCTION get_epcis_communes_count(epcis epcis)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "communes"
      WHERE  "communes"."siren_epci" = epcis."siren"
    );
  END;
$function$ LANGUAGE plpgsql;
