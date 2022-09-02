CREATE OR REPLACE FUNCTION get_users_services_count(users users)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT      COUNT(*)
      FROM        "services"
      INNER JOIN  "user_services" ON "user_services"."service_id" = "services"."id"
      WHERE       "user_services"."user_id" = users."id"
    );
  END;
$function$ LANGUAGE plpgsql;
