CREATE OR REPLACE FUNCTION get_packages_reports_debated_count(packages packages)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "reports"
      WHERE  "reports"."discarded_at" IS NULL
        AND  "reports"."debated_at"   IS NOT NULL
        AND  "reports"."approved_at"  IS NULL
        AND  "reports"."rejected_at"  IS NULL
        AND  "reports"."package_id" = packages."id"
    );
  END;
$function$ LANGUAGE plpgsql;
