-- SELECT name, count_collectivities_in_publishers("publishers".*) FROM "publishers";

CREATE OR REPLACE FUNCTION count_collectivities_in_publishers(publishers)
RETURNS integer
AS $function$
  DECLARE
    total integer DEFAULT 0;
  BEGIN
    SELECT COUNT(*) INTO total
    FROM   "collectivities"
    WHERE  "collectivities"."publisher_id" = $1."id";

    RETURN total;
  END;
$function$ LANGUAGE plpgsql;
