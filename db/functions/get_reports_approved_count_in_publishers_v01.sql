CREATE OR REPLACE FUNCTION get_reports_approved_count_in_publishers(publishers publishers)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "reports"
      WHERE  "reports"."publisher_id" = publishers."id"
        AND  "reports"."discarded_at" IS NULL
        AND  "reports"."approved_at" IS NOT NULL
    );
  END;
$function$ LANGUAGE plpgsql;
