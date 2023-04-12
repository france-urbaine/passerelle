CREATE OR REPLACE FUNCTION get_users_count_in_ddfips(ddfips ddfips)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "users"
      WHERE  "users"."organization_type" = 'DDFIP'
        AND  "users"."organization_id"   = ddfips."id"
        AND  "users"."discarded_at" IS NULL
    );
  END;
$function$ LANGUAGE plpgsql;
