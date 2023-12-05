CREATE OR REPLACE FUNCTION get_dgfips_reports_processing_count(dgfips dgfips)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      WHERE      "reports"."discarded_at" IS NULL
        AND      "reports"."sandbox" = FALSE
        AND      "reports"."state" = 'processing'
        AND      "reports"."debated_at" IS NULL
    );
  END;
$function$ LANGUAGE plpgsql;
