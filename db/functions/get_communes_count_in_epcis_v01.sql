CREATE OR REPLACE FUNCTION get_communes_count_in_epcis(epcis epcis)
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
