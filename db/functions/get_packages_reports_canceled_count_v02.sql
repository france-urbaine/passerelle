CREATE OR REPLACE FUNCTION get_packages_reports_canceled_count(packages packages)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "reports"
      WHERE  "reports"."package_id" = packages."id"
        AND  "reports"."discarded_at" IS NULL
        AND  "reports"."state" = 'canceled'
    );
  END;
$function$ LANGUAGE plpgsql;
