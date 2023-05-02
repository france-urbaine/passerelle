CREATE OR REPLACE FUNCTION get_collectivities_count_in_publishers(publishers publishers)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "collectivities"
      WHERE  "collectivities"."discarded_at" IS NULL
        AND  "collectivities"."publisher_id" = publishers."id"
    );
  END;
$function$ LANGUAGE plpgsql;
