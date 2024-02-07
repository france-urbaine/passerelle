CREATE OR REPLACE FUNCTION get_dgfips_reports_approved_count(dgfips dgfips)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "reports"
      WHERE  "reports"."discarded_at" IS NULL
        AND  "reports"."sandbox" = FALSE
        AND  "reports"."state" = 'approved'
    );
  END;
$function$ LANGUAGE plpgsql;
