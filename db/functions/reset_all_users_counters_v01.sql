-- SELECT reset_all_users_counters();

CREATE OR REPLACE FUNCTION reset_all_users_counters()
RETURNS integer
AS $function$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "users"
    SET    "services_count" = get_users_services_count("users".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$function$ LANGUAGE plpgsql;
