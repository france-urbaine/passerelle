-- SELECT reset_all_publishers_counters();

CREATE OR REPLACE FUNCTION reset_all_publishers_counters()
RETURNS integer
AS $function$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "publishers"
    SET    "users_count"          = get_publishers_users_count("publishers".*),
           "collectivities_count" = get_publishers_collectivities_count("publishers".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$function$ LANGUAGE plpgsql;