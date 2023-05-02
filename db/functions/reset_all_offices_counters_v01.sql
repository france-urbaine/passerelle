-- SELECT reset_all_offices_counters();

CREATE OR REPLACE FUNCTION reset_all_offices_counters()
RETURNS integer
AS $function$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "offices"
    SET    "users_count"    = get_users_count_in_offices("offices".*),
           "communes_count" = get_communes_count_in_offices("offices".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$function$ LANGUAGE plpgsql;
