-- SELECT reset_all_services_counters();

CREATE OR REPLACE FUNCTION reset_all_services_counters()
RETURNS integer
AS $function$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "services"
    SET    "users_count"    = get_services_users_count("services".*),
           "communes_count" = get_services_communes_count("services".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$function$ LANGUAGE plpgsql;
