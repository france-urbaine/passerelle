CREATE OR REPLACE FUNCTION get_dgfips_users_count(dgfips dgfips)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "users"
      WHERE  "users"."organization_type" = 'DGFIP'
        AND  "users"."organization_id"   = dgfips."id"
        AND  "users"."discarded_at" IS NULL
    );
  END;
$function$ LANGUAGE plpgsql;
