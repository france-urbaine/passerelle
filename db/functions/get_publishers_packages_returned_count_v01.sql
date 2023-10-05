CREATE OR REPLACE FUNCTION get_publishers_packages_returned_count(publishers publishers)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "packages"
      WHERE  "packages"."sandbox" = FALSE
        AND  "packages"."discarded_at" IS NULL
        AND  "packages"."returned_at"  IS NOT NULL
        AND  "packages"."publisher_id" = publishers."id"
    );
  END;
$function$ LANGUAGE plpgsql;
