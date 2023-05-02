-- SELECT reset_all_users_counters();

CREATE OR REPLACE FUNCTION reset_all_users_counters()
RETURNS integer
AS $function$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "users"
    SET    "offices_count" = get_offices_count_in_users("users".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$function$ LANGUAGE plpgsql;
