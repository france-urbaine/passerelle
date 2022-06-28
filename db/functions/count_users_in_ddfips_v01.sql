-- SELECT name, count_users_in_ddfips("ddfips".*) FROM "ddfips";

CREATE OR REPLACE FUNCTION count_users_in_ddfips(ddfips)
RETURNS integer
AS $function$
  DECLARE
    total integer DEFAULT 0;
  BEGIN
    SELECT COUNT(*) INTO total
    FROM   "users"
    WHERE  "users"."organization_type" = 'DDFIP'
      AND  "users"."organization_id"   = $1."id";

    RETURN total;
  END;
$function$ LANGUAGE plpgsql;
