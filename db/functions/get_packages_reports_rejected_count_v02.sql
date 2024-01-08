CREATE OR REPLACE FUNCTION get_packages_reports_rejected_count(packages packages)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "reports"
      WHERE  "reports"."discarded_at" IS NULL
        AND  "reports"."sandbox" = FALSE
        AND  "reports"."state" = 'rejected'
        AND  "reports"."package_id" = packages."id"
    );
  END;
$function$ LANGUAGE plpgsql;
