-- SELECT reset_all_epcis_counters();

CREATE OR REPLACE FUNCTION reset_all_epcis_counters()
RETURNS integer
AS $function$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "epcis"
    SET    "communes_count"       = count_communes_in_epcis("epcis".*),
           "collectivities_count" = count_collectivities_in_epcis("epcis".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$function$ LANGUAGE plpgsql;
