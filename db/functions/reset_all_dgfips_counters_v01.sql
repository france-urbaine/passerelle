-- SELECT reset_all_dgfips_counters();

CREATE OR REPLACE FUNCTION reset_all_dgfips_counters()
RETURNS integer
AS $function$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "dgfips"
    SET    "users_count"            = get_users_count_in_dgfips("dgfips".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$function$ LANGUAGE plpgsql;