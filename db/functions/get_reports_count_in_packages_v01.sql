CREATE OR REPLACE FUNCTION get_reports_count_in_packages(packages packages)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "reports"
      WHERE  "reports"."package_id" = packages."id"
        AND  "reports"."discarded_at" IS NULL
    );
  END;
$function$ LANGUAGE plpgsql;
