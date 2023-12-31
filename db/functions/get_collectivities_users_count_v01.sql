CREATE OR REPLACE FUNCTION get_collectivities_users_count(collectivities collectivities)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "users"
      WHERE  "users"."organization_type" = 'Collectivity'
        AND  "users"."organization_id"   = collectivities."id"
        AND  "users"."discarded_at" IS NULL
    );
  END;
$function$ LANGUAGE plpgsql;
