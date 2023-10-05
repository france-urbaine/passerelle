CREATE OR REPLACE FUNCTION get_publishers_users_count(publishers publishers)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "users"
      WHERE  "users"."organization_type" = 'Publisher'
        AND  "users"."organization_id"   = publishers."id"
        AND  "users"."discarded_at" IS NULL
    );
  END;
$function$ LANGUAGE plpgsql;
