CREATE OR REPLACE FUNCTION get_users_offices_count(users users)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT      COUNT(*)
      FROM        "offices"
      INNER JOIN  "office_users" ON "office_users"."office_id" = "offices"."id"
      WHERE       "office_users"."user_id" = users."id"
    );
  END;
$function$ LANGUAGE plpgsql;
