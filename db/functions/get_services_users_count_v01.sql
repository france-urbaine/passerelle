CREATE OR REPLACE FUNCTION get_services_users_count(services services)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT      COUNT(*)
      FROM        "users"
      INNER JOIN  "user_services" ON "user_services"."user_id" = "users"."id"
      WHERE       "user_services"."service_id" = services."id"
    );
  END;
$function$ LANGUAGE plpgsql;
