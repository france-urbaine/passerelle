-- SELECT reset_all_collectivities_counters();

CREATE OR REPLACE FUNCTION reset_all_collectivities_counters()
RETURNS integer
AS $function$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "collectivities"
    SET    "users_count" = get_collectivities_users_count("collectivities".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$function$ LANGUAGE plpgsql;
