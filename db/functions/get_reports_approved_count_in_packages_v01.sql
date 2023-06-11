CREATE OR REPLACE FUNCTION get_reports_approved_count_in_packages(packages packages)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "reports"
      WHERE  "reports"."package_id" = packages."id"
        AND  "reports"."approved_at" IS NOT NULL
    );
  END;
$function$ LANGUAGE plpgsql;
