-- SELECT reset_all_epcis_counters();

CREATE OR REPLACE FUNCTION reset_all_epcis_counters()
RETURNS integer
AS $function$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "epcis"
    SET    "communes_count"       = get_epcis_communes_count("epcis".*),
           "collectivities_count" = get_epcis_collectivities_count("epcis".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$function$ LANGUAGE plpgsql;
