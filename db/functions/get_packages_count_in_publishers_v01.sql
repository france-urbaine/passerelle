CREATE OR REPLACE FUNCTION get_packages_count_in_publishers(publishers publishers)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "packages"
      WHERE  "packages"."publisher_id" = publishers."id"
        AND  "packages"."discarded_at" IS NULL
    );
  END;
$function$ LANGUAGE plpgsql;
