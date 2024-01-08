CREATE OR REPLACE FUNCTION get_offices_reports_processing_count(offices offices)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "reports"
      WHERE  "reports"."office_id" = offices."id"
        AND  "reports"."discarded_at" IS NULL
        AND  "reports"."sandbox" = FALSE
        AND  "reports"."state" = 'processing'
    );
  END;
$function$ LANGUAGE plpgsql;
