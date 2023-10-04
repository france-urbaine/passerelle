CREATE OR REPLACE FUNCTION get_publishers_collectivities_count(publishers publishers)
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
