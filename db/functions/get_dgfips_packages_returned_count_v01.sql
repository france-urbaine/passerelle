CREATE OR REPLACE FUNCTION get_dgfips_packages_returned_count(dgfips dgfips)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "packages"
      WHERE  "packages"."sandbox" = FALSE
        AND  "packages"."discarded_at" IS NULL
        AND  "packages"."returned_at"  IS NOT NULL
    );
  END;
$function$ LANGUAGE plpgsql;
