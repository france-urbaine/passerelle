-- SELECT name, count_users_in_collectivities("collectivities".*) FROM "collectivities";

CREATE OR REPLACE FUNCTION count_users_in_collectivities(collectivities)
RETURNS integer
AS $function$
  DECLARE
    total integer DEFAULT 0;
  BEGIN
    SELECT COUNT(*) INTO total
    FROM   "users"
    WHERE  "users"."organization_type" = 'Collectivity'
      AND  "users"."organization_id"   = $1."id";

    RETURN total;
  END;
$function$ LANGUAGE plpgsql;
