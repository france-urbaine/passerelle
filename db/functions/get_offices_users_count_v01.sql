CREATE OR REPLACE FUNCTION get_offices_users_count(offices offices)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT      COUNT(*)
      FROM        "users"
      INNER JOIN  "office_users" ON "office_users"."user_id" = "users"."id"
      WHERE       "office_users"."office_id" = offices."id"
        AND       "users"."discarded_at" IS NULL
    );
  END;
$function$ LANGUAGE plpgsql;
