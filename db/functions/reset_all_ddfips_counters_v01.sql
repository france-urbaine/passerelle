-- SELECT reset_all_ddfips_counters();

CREATE OR REPLACE FUNCTION reset_all_ddfips_counters()
RETURNS integer
AS $function$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "ddfips"
    SET    "users_count"          = count_users_in_ddfips("ddfips".*),
           "collectivities_count" = count_collectivities_in_ddfips("ddfips".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$function$ LANGUAGE plpgsql;
