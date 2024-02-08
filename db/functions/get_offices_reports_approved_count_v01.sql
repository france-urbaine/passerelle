CREATE OR REPLACE FUNCTION get_offices_reports_approved_count(offices offices)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "reports"
      WHERE  "reports"."office_id" = offices."id"
        AND  "reports"."discarded_at" IS NULL
        AND  "reports"."sandbox" = FALSE
        AND  "reports"."state" = 'approved'
    );
  END;
$function$ LANGUAGE plpgsql;
