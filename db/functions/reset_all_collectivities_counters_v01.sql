-- SELECT reset_all_collectivities_counters();

CREATE OR REPLACE FUNCTION reset_all_collectivities_counters()
RETURNS integer
AS $function$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "collectivities"
    SET
      "users_count" = (
        SELECT COUNT(*)
        FROM   "users"
        WHERE  "users"."organization_type" = 'Collectivity'
          AND  "users"."organization_id"   = "collectivities"."id"
      );

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$function$ LANGUAGE plpgsql;
