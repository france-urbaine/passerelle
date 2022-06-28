-- SELECT reset_all_communes_counters();

CREATE OR REPLACE FUNCTION reset_all_communes_counters()
RETURNS integer
AS $function$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "communes"
    SET    "collectivities_count" = count_collectivities_in_communes("communes".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$function$ LANGUAGE plpgsql;
