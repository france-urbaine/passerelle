-- SELECT reset_all_publishers_counters();

CREATE OR REPLACE FUNCTION reset_all_publishers_counters()
RETURNS integer
AS $function$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "publishers"
    SET    "users_count"          = count_users_in_publishers("publishers".*),
           "collectivities_count" = count_collectivities_in_publishers("publishers".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$function$ LANGUAGE plpgsql;
