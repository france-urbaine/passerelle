CREATE OR REPLACE FUNCTION get_ddfips_users_count(ddfips ddfips)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "users"
      WHERE  "users"."organization_type" = 'DDFIP'
        AND  "users"."organization_id"   = ddfips."id"
    );
  END;
$function$ LANGUAGE plpgsql;
