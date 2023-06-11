CREATE OR REPLACE FUNCTION get_packages_rejected_count_in_publishers(publishers publishers)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "packages"
      WHERE  "packages"."publisher_id" = publishers."id"
        AND  "packages"."discarded_at" IS NULL
        AND  "packages"."transmitted_at" IS NOT NULL
        AND  "packages"."rejected_at" IS NOT NULL
    );
  END;
$function$ LANGUAGE plpgsql;
