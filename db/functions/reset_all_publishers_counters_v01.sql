-- SELECT reset_all_publishers_counters();

CREATE OR REPLACE FUNCTION reset_all_publishers_counters()
RETURNS integer
AS $function$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "publishers"
    SET "users_count" = (
          SELECT COUNT(*)
          FROM   "users"
          WHERE  "users"."organization_type" = 'Publisher'
            AND  "users"."organization_id"   = "publishers"."id"
        ),
        "collectivities_count" = (
          SELECT COUNT(*)
          FROM   "collectivities"
          WHERE  "collectivities"."publisher_id" = "publishers"."id"
            AND  "collectivities"."discarded_at" IS NULL
        );

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$function$ LANGUAGE plpgsql;
