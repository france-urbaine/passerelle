CREATE OR REPLACE FUNCTION get_publishers_reports_approved_count(publishers publishers)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "reports"
      WHERE  "reports"."publisher_id" = publishers."id"
        AND  "reports"."discarded_at" IS NULL
        AND  "reports"."sandbox" = FALSE
        AND  "reports"."state" = 'approved'
    );
  END;
$function$ LANGUAGE plpgsql;
