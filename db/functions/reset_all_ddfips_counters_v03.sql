-- SELECT reset_all_ddfips_counters();

CREATE OR REPLACE FUNCTION reset_all_ddfips_counters()
RETURNS integer
AS $function$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "ddfips"
    SET    "users_count"          = get_ddfips_users_count("ddfips".*),
           "collectivities_count" = get_ddfips_collectivities_count("ddfips".*),
           "services_count"       = get_ddfips_services_count("ddfips".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$function$ LANGUAGE plpgsql;
