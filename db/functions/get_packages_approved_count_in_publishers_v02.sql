CREATE OR REPLACE FUNCTION get_packages_approved_count_in_publishers(publishers publishers)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "packages"
      WHERE  "packages"."publisher_id" = publishers."id"
        AND  "packages"."sandbox" = FALSE
        AND  "packages"."transmitted_at" IS NOT NULL
        AND  "packages"."approved_at" IS NOT NULL
        AND  "packages"."rejected_at" IS NULL
        AND  "packages"."discarded_at" IS NULL
    );
  END;
$function$ LANGUAGE plpgsql;
