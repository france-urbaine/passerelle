-- SELECT name, count_users_in_publishers("publishers".*) FROM "publishers";

CREATE OR REPLACE FUNCTION count_users_in_publishers(publishers)
RETURNS integer
AS $function$
  DECLARE
    total integer DEFAULT 0;
  BEGIN
    SELECT COUNT(*) INTO total
    FROM   "users"
    WHERE  "users"."organization_type" = 'Publisher'
      AND  "users"."organization_id"   = $1."id";

    RETURN total;
  END;
$function$ LANGUAGE plpgsql;
